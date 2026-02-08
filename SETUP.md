# Setup

Install the skills, agents, and settings from this starter repo into your own project.

## Quick Start (Script)

```bash
# Clone the starter repo (if you haven't)
git clone https://github.com/your-user/agentic-coding-starter.git
cd agentic-coding-starter

# Install into your project
./setup.sh --target ~/Projects/my-app

# Preview changes first
./setup.sh --target ~/Projects/my-app --dry-run
```

Requires [`jq`](https://jqlang.github.io/jq/download/) for merging `settings.json`.

## Claude-Assisted Setup

If you'd rather have Claude handle the setup interactively, paste this prompt into a Claude Code session running in your **target project**:

> I want to install the agentic-coding-starter configs into this project. The starter repo is cloned at `<path-to-starter-repo>`.
>
> Please:
> 1. Read the starter repo's `.claude/` directory (skills, agents, settings.json)
> 2. Check what `.claude/` configs already exist in this project
> 3. Copy all skills and agents into this project's `.claude/`
> 4. Merge `settings.json` — combine the `permissions.allow` arrays (deduplicated) and merge `env`/`sandbox` objects, keeping my existing overrides
> 5. Add `.brainstorm/` to `.gitignore` if it's not already there
> 6. Tell me what was added or changed

Replace `<path-to-starter-repo>` with the actual path where you cloned this repo.

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
