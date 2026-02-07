---
name: refactor
description: "Guided refactoring with safety guarantees. Use this to restructure existing code — rename, extract, simplify, or reorganize — with tests verifying each step."
---

# Guided Refactoring

## Overview

Transform existing code through incremental, test-gated steps. Analyze the target code, propose refactoring strategies with trade-offs, then execute the chosen approach in small steps — running tests after each one to verify behavior is preserved.

## The Process

**Understand the target:**

- User identifies what to refactor: a file, function, module, class, or pattern
- Read the target code and its surrounding context
- Analyze: dependencies, callers/call sites, test coverage, complexity
- Summarize what you found — confirm understanding before proposing changes

**Propose refactoring strategies:**

- Propose 2-3 approaches with clear trade-offs
- For each approach, describe:
  - What changes and what stays the same
  - Number of files/functions affected
  - Risk level (how likely to break things)
  - What improves (readability, performance, testability, etc.)
- Lead with your recommended approach and explain why
- Let the user choose before proceeding

**Establish a test baseline:**

- Run existing tests that cover the target code
- If tests fail before refactoring, stop and inform the user — refactoring on a broken baseline is risky
- If no tests exist, flag this and offer to generate them first using the test skill's workflow
- Record the passing test count as the baseline

**Execute incrementally:**

- Break the refactoring into small, reviewable steps
- Each step should be a single logical change (e.g., extract a function, rename a variable, move a block)
- After each step:
  - Run the relevant tests
  - If tests pass, continue to the next step
  - If tests fail, revert the step and propose an alternative approach
- Summarize what changed at each step so the user can follow along

**Wrap up:**

- Run the full relevant test suite one final time
- Summarize all changes made: files modified, functions changed, lines added/removed
- Highlight any follow-up work the user might want to do

## Key Principles

- **Test-gated** - Never proceed past a step with failing tests
- **Incremental** - Small steps, not big-bang rewrites
- **Reversible** - Each step can be reverted independently
- **User-directed** - Propose options, let the user choose
- **Baseline-first** - Establish passing tests before touching code
- **Transparent** - Summarize each step so changes are reviewable
