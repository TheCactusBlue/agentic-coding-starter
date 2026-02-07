# New Skills & Agents for Agentic Coding Starter

**Date:** 2026-02-07
**Status:** Approved

## Overview

Add 5 skills, 3 agents, and 4 language convention skills to the starter kit. These address four workflow pain points: repetitive ceremonies, multi-step coordination, session handoff, and parallel workstreams.

## New Skills

### `/review` — Pre-Commit Self-Review

**File:** `.claude/skills/review/SKILL.md`

Catches issues before they're committed.

**Workflow:**
1. Run `git diff --staged` (or `git diff` if nothing staged) to get changeset
2. Analyze changes for: bugs/logic errors, leftover debug code, security issues, missing error handling, style inconsistencies
3. If `CLAUDE.md` exists, check against project-specific conventions
4. Present findings grouped by severity (blocking / warning / nitpick)
5. For blocking issues, suggest specific fixes
6. If clean, confirm with brief summary

**Design decisions:**
- Does NOT auto-fix — presents findings for user to decide
- Reads `CLAUDE.md` for project conventions
- Focuses on the diff only, not entire files

---

### `/test` — Test Workflow

**File:** `.claude/skills/test/SKILL.md`

Standardizes test discovery, execution, and generation.

**Workflow:**
1. Auto-detect test framework/runner from config files
2. Identify changed files via `git diff --name-only` and find corresponding test files
3. Run relevant tests for changed files only (not full suite)
4. If tests pass: report summary
5. If tests fail: show failures with analysis and suggest fixes
6. If no tests exist for changed files: offer to generate them using existing tests as style reference

**Design decisions:**
- Targeted runs by default (changed files only) for fast feedback
- Uses existing tests as style guide when generating new ones
- Framework auto-detection works across project types without config

---

### `/start` — Session Bootstrap

**File:** `.claude/skills/start/SKILL.md`

Picks up where you left off. Pairs with `/handoff`.

**Workflow:**
1. Check for handoff files in `.claude/handoff/` — summarize last session's state
2. Show recent git history (last 5-10 commits on current branch)
3. Check for open branches and their status
4. Scan for `.brainstorm/plans/` docs not yet implemented
5. Look for `TODO`/`FIXME`/`HACK` in recently changed files
6. Present concise "here's where things stand" summary
7. Suggest what to work on next

---

### `/handoff` — Session Capture

**File:** `.claude/skills/handoff/SKILL.md`

Captures session state for future `/start` pickup.

**Workflow:**
1. Summarize what was accomplished (from git log since session start or last handoff)
2. Capture current state: branch, staged changes, uncommitted work
3. Record decisions made (from conversation context)
4. List known blockers or open questions
5. Write to `.claude/handoff/YYYYMMDD-HHMMSS.md`
6. Commit the handoff file

**Design decisions:**
- Timestamped files accumulated (not overwritten) — gives history
- `/start` reads most recent handoff; full history available
- Lightweight — minutes to run

---

### `/refactor` — Guided Refactoring

**File:** `.claude/skills/refactor/SKILL.md`

Guided refactoring with safety guarantees.

**Workflow:**
1. User identifies target code (file, function, module, or pattern)
2. Analyze target: dependencies, callers, test coverage, complexity
3. Propose 2-3 refactoring strategies with trade-offs
4. After user selects approach, run existing tests to establish baseline
5. Execute refactoring incrementally — small, reviewable steps
6. Run tests after each step to verify behavior preservation
7. If tests break, revert the step and propose alternative

**Design decisions:**
- Test-gated execution: won't proceed past a failing step
- Incremental steps rather than big-bang changes
- Reuses brainstorm's "propose approaches" pattern
- Distinct from brainstorm: transforms existing code, doesn't design new features

---

## New Agents

### `researcher` — Background Investigation

**File:** `.claude/agents/researcher.md`
**Tools:** Read-only (Glob, Grep, Read, WebFetch, WebSearch) — cannot edit files

Investigates codebase questions or external topics in the background while the user keeps working. Returns written summaries.

**Examples:** "How does auth work in this project?", "What are the best libraries for X?", "Find all places where we handle errors."

---

### `test-runner` — Background Test Execution

**File:** `.claude/agents/test-runner.md`
**Tools:** Read + Bash (needs to execute test commands) — no file editing

Runs test suites in background, analyzes failures, reports results. Spawned after making changes so the user doesn't wait.

**Output:** Pass/fail summary with failure analysis.

---

### `implementer` — Autonomous Plan Executor

**File:** `.claude/agents/implementer.md`
**Tools:** Full access (Read, Write, Edit, Bash, Glob, Grep)

Given a plan file path, works through implementation steps autonomously. Best used with git worktrees.

**Constraints:**
- Must create a branch before making changes
- Must commit after each logical step
- Runs tests after each step (if tests exist)
- Stops and reports if tests fail rather than pushing forward

---

## Language Convention Skills

**Pattern:** `.claude/skills/lang:<language>/SKILL.md`

Each language skill covers:
- **Idioms:** Preferred patterns for the language
- **Project structure:** Expected directory layout and naming
- **Testing:** Preferred framework, assertion style, organization
- **Error handling:** Language-specific patterns
- **Dependencies:** Preferred libraries for common tasks
- **Anti-patterns:** Things to avoid

**Initial set:** `lang:rust`, `lang:typescript`, `lang:python`, `lang:go`

**Design decisions:**
- Passive — loaded as context, not invoked as commands
- Opinionated but minimal — designed as living documents
- Continuously refined by agents via `/learn`
- Ship with reasonable starting opinions that users and agents evolve over time

---

## Design Principles

- **YAGNI** — each addition solves a specific workflow pain point
- **Composable** — skills and agents reference each other (`/review` before `/commit`, `/start` reads `/handoff`)
- **Living documents** — especially lang:* skills, meant to evolve with the project
- **Human-in-the-loop** — skills present options and findings; agents report back rather than silently proceeding
