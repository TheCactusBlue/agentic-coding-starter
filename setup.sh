#!/usr/bin/env bash
set -euo pipefail

# ── Agentic Evolution — Setup Script ──
# Clones the starter repo, copies .claude/ configs into the target project,
# merges settings.json intelligently, then cleans up after itself.
# Supports both fresh installs and updates with content-aware diffing.

REPO_URL="https://github.com/TheCactusBlue/agentic-evolution.git"

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
Usage: $(basename "$0") [--target <path>] [--domains <list>] [--dry-run] [--force]

Install or update .claude/ configs (skills, agents, settings) in a project.
Clones the starter repo automatically — no manual clone needed.

Options:
  --target <path>    Project directory to install into (default: current directory)
  --domains <list>   Comma-separated languages to install domain skills for
                     (e.g. typescript,python). Omit to skip all domain skills.
  --dry-run          Show what would be done without making changes
  --force            Force update even if already up to date
  --help             Show this help message

Examples:
  $(basename "$0") --target ~/Projects/my-app --domains typescript,python
  $(basename "$0") --domains rust
  $(basename "$0") --target . --dry-run
  $(basename "$0") --target . --force
EOF
}

# ── Parse args ──
TARGET=""
DOMAINS=""
DRY_RUN=false
FORCE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --target)  TARGET="$2"; shift 2 ;;
        --domains) DOMAINS="$2"; shift 2 ;;
        --dry-run) DRY_RUN=true; shift ;;
        --force)   FORCE=true; shift ;;
        --help)    usage; exit 0 ;;
        *)         error "Unknown option: $1"; usage; exit 1 ;;
    esac
done

# Build an associative array of requested domains for fast lookup
declare -A DOMAIN_SET
if [[ -n "$DOMAINS" ]]; then
    IFS=',' read -ra _domains <<< "$DOMAINS"
    for d in "${_domains[@]}"; do
        DOMAIN_SET["$d"]=1
    done
fi

if [[ -z "$TARGET" ]]; then
    TARGET="$(pwd)"
fi

TARGET="$(cd "$TARGET" 2>/dev/null && pwd)" || {
    error "Target directory does not exist: $TARGET"
    exit 1
}

# ── Check dependencies ──
if ! command -v git &>/dev/null; then
    error "git is required. Please install git first."
    exit 1
fi

if ! command -v jq &>/dev/null; then
    error "jq is required for settings.json merging. Install it:"
    echo "  macOS:  brew install jq"
    echo "  Ubuntu: sudo apt install jq"
    echo "  Arch:   sudo pacman -S jq"
    exit 1
fi

# ── Clone starter repo into a temp directory ──
TMPDIR="$(mktemp -d)"
cleanup() { rm -rf "$TMPDIR"; }
trap cleanup EXIT

info "Cloning agentic-evolution..."
git clone --depth 1 --quiet "$REPO_URL" "$TMPDIR/starter"

SOURCE_CLAUDE="$TMPDIR/starter/.claude"
TARGET_CLAUDE="$TARGET/.claude"
VERSION_FILE="$TARGET_CLAUDE/.starter-version"
HEAD_SHA="$(git -C "$TMPDIR/starter" rev-parse HEAD)"

# ── Detect install vs update mode ──
UPDATE_MODE=false
if [[ -f "$VERSION_FILE" ]]; then
    UPDATE_MODE=true
    STORED_SHA="$(cat "$VERSION_FILE")"
fi

# ── Up-to-date check ──
if $UPDATE_MODE && ! $FORCE && ! $DRY_RUN; then
    if [[ "$STORED_SHA" == "$HEAD_SHA" ]]; then
        echo ""
        echo -e "${GREEN}Already up to date.${NC} (${HEAD_SHA:0:8})"
        echo "Run with --force to re-apply anyway."
        exit 0
    fi
fi

echo ""
if $UPDATE_MODE; then
    echo -e "${BOLD}Agentic Evolution — Update${NC}"
    echo -e "Target: ${TARGET}"
    echo -e "Version: ${STORED_SHA:0:8} → ${HEAD_SHA:0:8}"
else
    echo -e "${BOLD}Agentic Evolution — Setup${NC}"
    echo -e "Target: ${TARGET}"
fi
echo ""

# ── Helper: compare a source file to a destination file ──
# Returns: "new", "updated", or "unchanged"
file_status() {
    local src="$1" dest="$2"
    if [[ ! -e "$dest" ]]; then
        echo "new"
    elif diff -q "$src" "$dest" &>/dev/null; then
        echo "unchanged"
    else
        echo "updated"
    fi
}

# ── Helper: compare a source directory to a destination directory ──
# Returns: "new", "updated", or "unchanged"
dir_status() {
    local src="${1%/}" dest="$2"
    if [[ ! -d "$dest" ]]; then
        echo "new"
        return
    fi
    # Compare all files in source against dest
    local has_diff=false
    while IFS= read -r -d '' src_file; do
        local rel="${src_file#"$src"/}"
        local dest_file="$dest/$rel"
        if [[ ! -f "$dest_file" ]] || ! diff -q "$src_file" "$dest_file" &>/dev/null; then
            has_diff=true
            break
        fi
    done < <(find "$src" -type f -print0)
    if $has_diff; then
        echo "updated"
    else
        echo "unchanged"
    fi
}

# ── 1. Copy skills ──
info "Installing skills..."
new_skills=0
updated_skills=0
unchanged_skills=0
skipped_domains=0

# Build a set of upstream skill names for stale detection
declare -A UPSTREAM_SKILLS
for skill_dir in "$SOURCE_CLAUDE"/skills/*/; do
    UPSTREAM_SKILLS["$(basename "$skill_dir")"]=1
done

for skill_dir in "$SOURCE_CLAUDE"/skills/*/; do
    skill_name="$(basename "$skill_dir")"

    # Filter domain skills: only install if explicitly requested via --domains
    if [[ "$skill_name" == domain:* ]]; then
        lang="${skill_name#domain:}"
        if [[ -z "${DOMAIN_SET[$lang]+x}" ]]; then
            skipped_domains=$((skipped_domains + 1))
            continue
        fi
    fi

    dest="$TARGET_CLAUDE/skills/$skill_name"
    status="$(dir_status "$skill_dir" "$dest")"

    case "$status" in
        new)       label="new"; new_skills=$((new_skills + 1)) ;;
        updated)   label="updated"; updated_skills=$((updated_skills + 1)) ;;
        unchanged) label="unchanged"; unchanged_skills=$((unchanged_skills + 1)) ;;
    esac

    if $DRY_RUN; then
        echo -e "  ${YELLOW}(dry-run)${NC} ${label}  skills/${skill_name}/"
    elif [[ "$status" != "unchanged" ]]; then
        mkdir -p "$dest"
        cp -r "$skill_dir"* "$dest/"
    fi
done

[[ $new_skills -gt 0 ]] && info "  Added $new_skills new skill(s)" || true
[[ $updated_skills -gt 0 ]] && info "  Updated $updated_skills skill(s)" || true
[[ $unchanged_skills -gt 0 ]] && info "  Unchanged $unchanged_skills skill(s)" || true
[[ $skipped_domains -gt 0 ]] && warn "  Skipped $skipped_domains domain skill(s) (not in --domains list)" || true

# ── 2. Copy agents ──
info "Installing agents..."
new_agents=0
updated_agents=0
unchanged_agents=0

# Build a set of upstream agent names for stale detection
declare -A UPSTREAM_AGENTS
for agent_file in "$SOURCE_CLAUDE"/agents/*; do
    UPSTREAM_AGENTS["$(basename "$agent_file")"]=1
done

for agent_file in "$SOURCE_CLAUDE"/agents/*; do
    agent_name="$(basename "$agent_file")"
    dest="$TARGET_CLAUDE/agents/$agent_name"
    status="$(file_status "$agent_file" "$dest")"

    case "$status" in
        new)       label="new"; new_agents=$((new_agents + 1)) ;;
        updated)   label="updated"; updated_agents=$((updated_agents + 1)) ;;
        unchanged) label="unchanged"; unchanged_agents=$((unchanged_agents + 1)) ;;
    esac

    if $DRY_RUN; then
        echo -e "  ${YELLOW}(dry-run)${NC} ${label}  agents/${agent_name}"
    elif [[ "$status" != "unchanged" ]]; then
        mkdir -p "$TARGET_CLAUDE/agents"
        cp "$agent_file" "$dest"
    fi
done

[[ $new_agents -gt 0 ]] && info "  Added $new_agents new agent(s)" || true
[[ $updated_agents -gt 0 ]] && info "  Updated $updated_agents agent(s)" || true
[[ $unchanged_agents -gt 0 ]] && info "  Unchanged $unchanged_agents agent(s)" || true

# ── 3. Detect stale (removed upstream) skills and agents ──
stale_count=0

if [[ -d "$TARGET_CLAUDE/skills" ]]; then
    for local_skill in "$TARGET_CLAUDE"/skills/*/; do
        [[ -d "$local_skill" ]] || continue
        local_name="$(basename "$local_skill")"
        # Only flag skills that match upstream naming — skip user-created ones
        if [[ -n "${UPSTREAM_SKILLS[$local_name]+x}" ]]; then
            continue
        fi
        # Check if it looks like a starter skill (has domain: prefix or matches a known pattern)
        # For domain skills that were installed but are no longer upstream
        if [[ "$local_name" == domain:* ]]; then
            warn "  Stale skill: skills/$local_name/ (no longer in upstream)"
            stale_count=$((stale_count + 1))
        fi
    done
fi

if [[ -d "$TARGET_CLAUDE/agents" ]]; then
    for local_agent in "$TARGET_CLAUDE"/agents/*; do
        [[ -f "$local_agent" ]] || continue
        local_name="$(basename "$local_agent")"
        if [[ -z "${UPSTREAM_AGENTS[$local_name]+x}" ]]; then
            # Only warn about .md files (agent definitions), not random files
            if [[ "$local_name" == *.md ]]; then
                warn "  Stale agent: agents/$local_name (no longer in upstream)"
                stale_count=$((stale_count + 1))
            fi
        fi
    done
fi

if [[ $stale_count -gt 0 ]]; then
    warn "  Found $stale_count stale file(s) — review and remove manually if no longer needed"
fi

# ── 4. Merge settings.json ──
SOURCE_SETTINGS="$SOURCE_CLAUDE/settings.json"
TARGET_SETTINGS="$TARGET_CLAUDE/settings.json"

info "Merging settings.json..."

if [[ ! -f "$TARGET_SETTINGS" ]]; then
    if $DRY_RUN; then
        echo -e "  ${YELLOW}(dry-run)${NC} new  settings.json"
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

# ── 5. Update .gitignore ──
TARGET_GITIGNORE="$TARGET/.gitignore"

if [[ -f "$TARGET_GITIGNORE" ]]; then
    if ! grep -qF '.brainstorm/' "$TARGET_GITIGNORE"; then
        info "Adding .brainstorm/ to .gitignore..."
        if ! $DRY_RUN; then
            printf '\n# Brainstorm plans (agentic-evolution)\n.brainstorm/\n' >> "$TARGET_GITIGNORE"
        fi
    fi
else
    info "Creating .gitignore with .brainstorm/ entry..."
    if ! $DRY_RUN; then
        printf '# Brainstorm plans (agentic-evolution)\n.brainstorm/\n' > "$TARGET_GITIGNORE"
    fi
fi

# ── 6. Write version file ──
if ! $DRY_RUN; then
    mkdir -p "$TARGET_CLAUDE"
    echo "$HEAD_SHA" > "$VERSION_FILE"
fi

# ── Done ──
echo ""
if $DRY_RUN; then
    echo -e "${YELLOW}Dry run complete. No changes were made.${NC}"
elif $UPDATE_MODE; then
    echo -e "${GREEN}${BOLD}Update complete!${NC} (${HEAD_SHA:0:8})"
    echo ""
    total_new=$((new_skills + new_agents))
    total_updated=$((updated_skills + updated_agents))
    total_unchanged=$((unchanged_skills + unchanged_agents))
    echo "  New: $total_new  Updated: $total_updated  Unchanged: $total_unchanged  Stale: $stale_count"
    echo ""
    echo "Installed into: $TARGET_CLAUDE/"
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
