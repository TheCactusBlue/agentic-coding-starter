---
name: handoff
description: "Session capture. Run this at the end of a session to record what you did, decisions made, and what's left. Writes a handoff file for /start to pick up later."
---

# Session Capture

## Overview

Capture the current session state so a future `/start` can pick up where you left off. Summarizes accomplishments, records decisions, notes blockers, and writes everything to a timestamped handoff file.

Pairs with `/start` — that skill reads the files this skill writes.

## The Process

**1. Summarize accomplishments**

- Review git log for commits made during this session (since the last handoff file's timestamp, or the session's first commit if no prior handoff)
- Group related commits into logical chunks of work
- Write a brief narrative of what was done and why

**2. Capture current state**

- Current branch name
- Staged but uncommitted changes (summarize what and why)
- Unstaged modifications or untracked files
- Any running processes or servers the next session should know about

**3. Record decisions made**

- Pull key decisions from the conversation context
- Include the reasoning, not just the conclusion
- Note any alternatives that were considered and rejected

**4. List blockers and open questions**

- Anything that's blocking progress
- Questions that need answers before continuing
- External dependencies (PRs awaiting review, upstream issues, etc.)

**5. Suggest next steps**

- What should the next session tackle first?
- Any setup needed before continuing (e.g., "rebase on main", "run migrations")

**6. Write the handoff file**

- Create `.claude/handoff/YYYYMMDD-HHMMSS.md` using the current timestamp
- Use the format below
- Commit the handoff file with message: `chore: session handoff`

## Handoff File Format

```markdown
# Session Handoff — YYYY-MM-DD HH:MM

## Accomplished
- [Narrative of what was done]

## Current State
- **Branch:** branch-name
- **Uncommitted work:** [description or "none"]
- **Notes:** [anything relevant about the working state]

## Decisions
- [Decision]: [reasoning]

## Blockers / Open Questions
- [blocker or question]

## Next Steps
1. [most important next action]
2. [second priority]
3. [third priority]
```

## Key Principles

- **Lightweight** — Should take under a minute; don't over-document
- **Accumulate, don't overwrite** — Each handoff is a new timestamped file, preserving history
- **Future-you is the audience** — Write for someone with no context about this session
- **Always commit** — The handoff file should be committed so it survives branch switches
