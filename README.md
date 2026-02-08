# Agentic Evolution

Just some opinionated sets of skills and subagents that I personally find useful for using Claude Code.

## Key Principles

1. The user acts as a project manager. The user must be kept in loop, capable of defining how the workflow works, and must not be doing things without actual understanding of the goal.
2. Embrace agentic evolution. Let agents modify their own configurations and knowledge to match the project workflow.
3. Workflows are built in a structured way. If something is used repeatedly, it should be extracted.
4. Move fast by securing things. Use things like sandbox and automated permission checking as much as possible, to remove the human in the loop as much as possible.

## Setup

```bash
curl -fsSL https://raw.githubusercontent.com/TheCactusBlue/agentic-evolution/main/setup.sh -o setup.sh
chmod +x setup.sh
./setup.sh --target ~/Projects/my-app
```

The script clones the repo, copies `.claude/` configs (skills, agents, settings) into your project, and cleans up automatically. Defaults to the current directory if `--target` is omitted. Use `--dry-run` to preview changes.

Requires `git` and [`jq`](https://jqlang.github.io/jq/download/). See [SETUP.md](SETUP.md) for more details.
