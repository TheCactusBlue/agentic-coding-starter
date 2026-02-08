#!/usr/bin/env bash
set -euo pipefail

# ── Agentic Coding Starter — Setup Script ──
# Copies .claude/ configs (skills, agents, settings) into a target project.
# Merges settings.json intelligently instead of overwriting.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_CLAUDE="$SCRIPT_DIR/.claude"

# ── Colors ──
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BOLD='\033[1m'
NC='\033[0m'

info()  { echo -e "${GREEN}[+]${NC} $1"; }
warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[x]${NC} $1" >&2; }

usage() {
    cat <<EOF
Usage: $(basename "$0") --target <path>

Install .claude/ configs (skills, agents, settings) into a project.

Options:
  --target <path>   Project directory to install into (required)
  --dry-run         Show what would be done without making changes
  --help            Show this help message

Examples:
  $(basename "$0") --target ~/Projects/my-app
  $(basename "$0") --target . --dry-run
EOF
}

# ── Parse args ──
TARGET=""
DRY_RUN=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --target)  TARGET="$2"; shift 2 ;;
        --dry-run) DRY_RUN=true; shift ;;
        --help)    usage; exit 0 ;;
        *)         error "Unknown option: $1"; usage; exit 1 ;;
    esac
done

if [[ -z "$TARGET" ]]; then
    error "Missing required --target argument"
    usage
    exit 1
fi

TARGET="$(cd "$TARGET" 2>/dev/null && pwd)" || {
    error "Target directory does not exist: $TARGET"
    exit 1
}

if [[ "$TARGET" == "$SCRIPT_DIR" ]]; then
    error "Target cannot be the starter repo itself"
    exit 1
fi

# ── Check dependencies ──
if ! command -v jq &>/dev/null; then
    error "jq is required for settings.json merging. Install it:"
    echo "  macOS:  brew install jq"
    echo "  Ubuntu: sudo apt install jq"
    echo "  Arch:   sudo pacman -S jq"
    exit 1
fi

TARGET_CLAUDE="$TARGET/.claude"

echo ""
echo -e "${BOLD}Agentic Coding Starter — Setup${NC}"
echo -e "Source: ${SCRIPT_DIR}"
echo -e "Target: ${TARGET}"
echo ""

# ── 1. Copy skills ──
info "Installing skills..."
added_skills=0
updated_skills=0

for skill_dir in "$SOURCE_CLAUDE"/skills/*/; do
    skill_name="$(basename "$skill_dir")"
    dest="$TARGET_CLAUDE/skills/$skill_name"

    if [[ -d "$dest" ]]; then
        label="update"
        updated_skills=$((updated_skills + 1))
    else
        label="add"
        added_skills=$((added_skills + 1))
    fi

    if $DRY_RUN; then
        echo -e "  ${YELLOW}(dry-run)${NC} ${label}  skills/${skill_name}/"
    else
        mkdir -p "$dest"
        cp -r "$skill_dir"* "$dest/"
    fi
done

[[ $added_skills -gt 0 ]] && info "  Added $added_skills new skill(s)" || true
[[ $updated_skills -gt 0 ]] && info "  Updated $updated_skills existing skill(s)" || true

# ── 2. Copy agents ──
info "Installing agents..."
added_agents=0
updated_agents=0

for agent_file in "$SOURCE_CLAUDE"/agents/*; do
    agent_name="$(basename "$agent_file")"
    dest="$TARGET_CLAUDE/agents/$agent_name"

    if [[ -f "$dest" ]]; then
        label="update"
        updated_agents=$((updated_agents + 1))
    else
        label="add"
        added_agents=$((added_agents + 1))
    fi

    if $DRY_RUN; then
        echo -e "  ${YELLOW}(dry-run)${NC} ${label}  agents/${agent_name}"
    else
        mkdir -p "$TARGET_CLAUDE/agents"
        cp "$agent_file" "$dest"
    fi
done

[[ $added_agents -gt 0 ]] && info "  Added $added_agents new agent(s)" || true
[[ $updated_agents -gt 0 ]] && info "  Updated $updated_agents existing agent(s)" || true

# ── 3. Merge settings.json ──
SOURCE_SETTINGS="$SOURCE_CLAUDE/settings.json"
TARGET_SETTINGS="$TARGET_CLAUDE/settings.json"

info "Merging settings.json..."

if [[ ! -f "$TARGET_SETTINGS" ]]; then
    if $DRY_RUN; then
        echo -e "  ${YELLOW}(dry-run)${NC} add  settings.json (new)"
    else
        mkdir -p "$TARGET_CLAUDE"
        cp "$SOURCE_SETTINGS" "$TARGET_SETTINGS"
    fi
    info "  Created new settings.json"
else
    if $DRY_RUN; then
        echo -e "  ${YELLOW}(dry-run)${NC} merge  settings.json"
    else
        # Merge using jq:
        # - Union permissions.allow arrays (deduplicated)
        # - Merge env objects (target values take precedence)
        # - Merge sandbox objects (target values take precedence)
        # - Preserve $schema from source
        tmp_merged="$(mktemp)"
        jq -s '
            .[0] as $source | .[1] as $target |
            {
                "$schema": ($target["$schema"] // $source["$schema"]),
                "env": (($source.env // {}) * ($target.env // {})),
                "permissions": {
                    "allow": (
                        (($source.permissions.allow // []) + ($target.permissions.allow // []))
                        | unique
                    )
                },
                "sandbox": (($source.sandbox // {}) * ($target.sandbox // {}))
            }
            | with_entries(select(.value != null and .value != {} and .value != []))
        ' "$SOURCE_SETTINGS" "$TARGET_SETTINGS" > "$tmp_merged"
        mv "$tmp_merged" "$TARGET_SETTINGS"
    fi
    info "  Merged permissions and settings (your overrides preserved)"
fi

# ── 4. Update .gitignore ──
TARGET_GITIGNORE="$TARGET/.gitignore"

if [[ -f "$TARGET_GITIGNORE" ]]; then
    if ! grep -qF '.brainstorm/' "$TARGET_GITIGNORE"; then
        info "Adding .brainstorm/ to .gitignore..."
        if ! $DRY_RUN; then
            printf '\n# Brainstorm plans (agentic-coding-starter)\n.brainstorm/\n' >> "$TARGET_GITIGNORE"
        fi
    fi
else
    info "Creating .gitignore with .brainstorm/ entry..."
    if ! $DRY_RUN; then
        printf '# Brainstorm plans (agentic-coding-starter)\n.brainstorm/\n' > "$TARGET_GITIGNORE"
    fi
fi

# ── Done ──
echo ""
if $DRY_RUN; then
    echo -e "${YELLOW}Dry run complete. No changes were made.${NC}"
else
    echo -e "${GREEN}${BOLD}Setup complete!${NC}"
    echo ""
    echo "Installed into: $TARGET_CLAUDE/"
    echo ""
    echo "Next steps:"
    echo "  1. Review .claude/settings.json and adjust permissions for your project"
    echo "  2. Write a CLAUDE.md describing your project's architecture and conventions"
    echo "  3. Try /brainstorm, /commit, /review, /test in Claude Code"
fi
