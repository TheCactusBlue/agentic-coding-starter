# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

An opinionated collection of Claude Code skills, agents, and language conventions. There is no application code — the repository contains only `.claude/` configuration files and documentation.

## Key Principles

1. **User as project manager** — Always keep the user in the loop. Don't act without understanding the goal.
2. **Agentic evolution** — Agents can modify their own configurations and knowledge to match the project workflow.
3. **Extract repeated workflows** — If something is used repeatedly, it should become a skill.
4. **Move fast via sandboxing** — Use sandbox mode and auto-permissions to reduce friction.

## Architecture

```
.claude/
├── agents/           # Subagent definitions (read-only background workers)
│   ├── researcher.md   # Codebase/web research — read-only, returns summaries
│   └── test-runner.md  # Runs tests and reports results — read-only, no edits
├── skills/           # Slash-command skills (invoked via /skill-name)
│   ├── brainstorm/     # /brainstorm — MUST run before any creative/feature work
│   ├── review/         # /review — pre-commit diff review
│   ├── test/           # /test — targeted test discovery, execution, generation
│   ├── refactor/       # /refactor — incremental, test-gated refactoring
│   ├── commit/         # /commit — conventional commit, auto-push, no attribution footer
│   ├── create-pr/      # /create-pr — PR via gh CLI, base branch is `dev` not `main`
│   ├── learn/          # /learn — capture knowledge into new/existing skills
│   ├── domain-builder/ # /domain-builder — generate domain skills from codebase + research
│   ├── start/          # /start — session bootstrap from handoff notes
│   ├── handoff/        # /handoff — session capture for /start to read later
│   ├── domain:typescript/
│   ├── domain:python/
│   └── domain:rust/
└── settings.json     # Sandbox enabled, auto-allow bash when sandboxed, agent teams experimental flag
```

## Important Workflow Details

- **Always /brainstorm before building** — The brainstorm skill is mandatory before any creative work (features, components, behavior changes). Designs are saved to `.brainstorm/plans/`.
- **Commit style** — Conventional commits, one-line messages describing *why*, no attribution footer. The /commit skill stages all, commits, and pushes.
- **PR base branch is `dev`** — The /create-pr skill targets `dev`, not `main`.
- **Session continuity** — Use `/handoff` at end of session, `/start` at beginning. Handoff files accumulate in `.claude/handoff/` as timestamped markdown.
- **Refactoring is test-gated** — The /refactor skill requires a passing test baseline before making changes, and runs tests after each incremental step.

## Settings

Sandbox is enabled with `autoAllowBashIfSandboxed: true`. The experimental agent teams feature is turned on via `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`. Pre-approved permissions include common git, gh, and read-only bash commands plus WebFetch for docs.rs, github.com, and anthropic.com domains.
