---
name: review
description: "Pre-commit self-review. Use this to catch bugs, security issues, debug artifacts, and style problems in your changes before committing."
---

# Pre-Commit Self-Review

## Overview

Review the current changeset for issues before committing. Analyzes the diff for bugs, security problems, leftover debug code, and style inconsistencies. Presents findings for the user to decide on — does not auto-fix.

## The Process

**Gather the changeset:**

- Run `git diff --staged` to get staged changes
- If nothing is staged, fall back to `git diff` for unstaged changes
- If both are empty, inform the user there's nothing to review

**Check project conventions:**

- If `CLAUDE.md` exists at the project root, read it for project-specific rules
- Note any conventions around naming, error handling, imports, or formatting
- Use these as additional review criteria alongside the defaults

**Analyze changes for issues:**

- **Bugs and logic errors** - Off-by-one, null/undefined access, wrong comparisons, missing edge cases, race conditions
- **Leftover debug code** - `console.log`, `debugger`, `print()` statements, `TODO`/`FIXME`/`HACK` comments added in this diff
- **Security issues** - Hardcoded secrets, SQL injection, XSS, unsanitized input, overly permissive permissions
- **Missing error handling** - Unhandled promise rejections, unchecked return values, bare `except`/`catch` blocks
- **Style inconsistencies** - Naming convention mismatches, inconsistent patterns compared to surrounding code

**Present findings:**

- Group issues by severity:
  - **Blocking** - Bugs, security issues, or errors that must be fixed before committing
  - **Warning** - Likely problems worth addressing but not strictly required
  - **Nitpick** - Style or preference issues, take-or-leave
- For blocking issues, suggest a specific fix with code
- For warnings and nitpicks, describe the issue and location
- If the changeset is clean, confirm with a brief summary of what was reviewed

## Key Principles

- **Diff-focused** - Only review what changed, not the entire file
- **Advisory, not automatic** - Present findings for the user to act on
- **Convention-aware** - Respect project-specific rules from `CLAUDE.md`
- **Severity-driven** - Clearly separate must-fix from nice-to-have
- **Concise** - Don't repeat the code back; reference file and line, describe the issue, suggest the fix
