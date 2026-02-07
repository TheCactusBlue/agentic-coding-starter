---
name: start
description: "Session bootstrap. Run this at the beginning of a session to pick up where you left off. Reads handoff notes, reviews recent work, and suggests what to do next. Pairs with /handoff."
---

# Session Bootstrap

## Overview

Pick up where you left off. Reads the most recent handoff file, reviews recent git activity, and presents a concise summary of project state with suggestions for what to work on next.

Pairs with `/handoff` — that skill writes the state this skill reads.

## The Process

**1. Read the last handoff**

- Look in `.claude/handoff/` for the most recent file (sorted by timestamp filename)
- If a handoff file exists, summarize: what was accomplished, decisions made, blockers, and open questions
- If no handoff files exist, note this and proceed with the remaining steps

**2. Review recent git history**

- Show the last 5-10 commits on the current branch
- Note the current branch name and whether there are uncommitted changes
- Highlight any work-in-progress (staged but uncommitted, or untracked files)

**3. Check open branches**

- List local branches with their last commit date
- Flag branches that look active (recent commits) or stale

**4. Scan for unfinished plans**

- Check `.brainstorm/plans/` for design documents
- Cross-reference with recent commits to identify plans not yet implemented
- Briefly list any unstarted or partially completed plans

**5. Find TODOs in recent work**

- Search for `TODO`, `FIXME`, and `HACK` comments in files changed in the last 10 commits
- List them grouped by file

**6. Present the summary**

- Keep it concise — a few short sections, not a wall of text
- Structure: "Last session", "Current state", "Outstanding work"
- End with 2-3 concrete suggestions for what to work on next, prioritized by urgency

## Key Principles

- **Fast** — This should take under a minute to run
- **Concise** — Summarize, don't dump raw output
- **Actionable** — Always end with concrete next-step suggestions
- **Graceful** — Work fine even with no handoff files or empty history
