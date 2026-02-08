# Setup

Install the skills, agents, and settings from this starter repo into your own project.

## Quick Start (Script)

```bash
# Download and run — no clone needed
curl -fsSL https://raw.githubusercontent.com/TheCactusBlue/agentic-coding-starter/main/setup.sh -o setup.sh
chmod +x setup.sh

# Install into your project, specifying which language domain skills to include
./setup.sh --target ~/Projects/my-app --domains typescript,python

# Only install domain skills for languages in your codebase
./setup.sh --domains rust

# Omit --domains to skip all domain skills
./setup.sh --target ~/Projects/my-app

# Preview changes first
./setup.sh --target ~/Projects/my-app --domains typescript --dry-run
```

The script clones the repo into a temp directory, copies the configs, and cleans up automatically.

Requires [`git`](https://git-scm.com/) and [`jq`](https://jqlang.github.io/jq/download/).

## Claude-Assisted Setup

Paste this prompt into a Claude Code session running in your **target project**:

> Install agentic-coding-starter into this project. Download setup.sh from
> https://raw.githubusercontent.com/TheCactusBlue/agentic-coding-starter/main/setup.sh
> and run it with --target set to the current directory.

## What Gets Installed

| Component | Count | Description |
|-----------|-------|-------------|
| Skills | 13 | `/brainstorm`, `/commit`, `/create-pr`, `/review`, `/test`, `/refactor`, `/learn`, `/start`, `/handoff`, plus `domain:typescript`, `domain:python`, `domain:rust` |
| Agents | 2 | `researcher` (read-only codebase/web research), `test-runner` (test execution) |
| Settings | 1 | Sandbox config, pre-approved permissions, agent teams flag |

## How Merging Works

- **Skills & agents**: Copied into `.claude/skills/` and `.claude/agents/`. Existing starter skills get updated; your custom skills are left untouched.
- **`settings.json`**: Permission arrays are combined and deduplicated. `env` and `sandbox` objects are merged with your existing values taking precedence.
- **`.gitignore`**: `.brainstorm/` is appended if not already present.

Running the script again is safe — it's idempotent.

## After Setup

1. Review `.claude/settings.json` and adjust permissions for your project
2. Write a `CLAUDE.md` describing your project's architecture and conventions
3. Try `/brainstorm`, `/commit`, `/review`, `/test` in Claude Code
