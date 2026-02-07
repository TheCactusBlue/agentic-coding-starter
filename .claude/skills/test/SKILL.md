---
name: test
description: "Test workflow for running, analyzing, and generating tests. Use this to run tests for changed files, diagnose failures, or scaffold new tests."
---

# Test Workflow

## Overview

Standardized test discovery, execution, and generation. Automatically detects the test framework, runs tests targeted to changed files, and offers to generate missing tests using existing tests as a style reference.

## The Process

**Detect the test framework:**

- Look for configuration files to identify the runner:
  - `jest.config.*`, `vitest.config.*`, `playwright.config.*` — JS/TS
  - `pytest.ini`, `pyproject.toml` (with `[tool.pytest]`), `setup.cfg` — Python
  - `Cargo.toml` — Rust
  - `go.mod` — Go
  - `*.test.*`, `*_test.*`, `*_spec.*` patterns in the tree
- If multiple frameworks exist, ask the user which to use
- If none detected, ask the user how tests are run

**Identify changed files and their tests:**

- Run `git diff --name-only` (including staged) to find changed files
- For each changed file, locate corresponding test files using common conventions:
  - `src/foo.ts` -> `src/foo.test.ts`, `tests/foo.test.ts`, `src/__tests__/foo.ts`
  - `src/foo.py` -> `tests/test_foo.py`, `src/foo_test.py`
  - `src/foo.rs` -> inline `#[cfg(test)]` module or `tests/foo.rs`
- If the user specifies a file or pattern, use that instead of auto-detection

**Run targeted tests:**

- Run only the tests relevant to changed files, not the full suite
- Use framework-specific targeting (e.g., `pytest tests/test_foo.py`, `npx vitest run src/foo.test.ts`)
- Capture both stdout and exit code

**Handle results:**

- **All pass** - Report a brief summary: number of tests, time taken
- **Failures** - For each failing test:
  - Show the test name and assertion that failed
  - Analyze the failure — is it a test bug or a code bug?
  - Suggest a specific fix
- **No tests found** - Offer to generate tests (see below)

**Generate missing tests:**

- Find 2-3 existing test files in the project as style references
- Match the conventions: imports, describe/it structure, assertion style, setup/teardown patterns
- Generate tests covering: happy path, edge cases, error conditions
- Write the test file and run it to verify it passes

## Key Principles

- **Targeted by default** - Run only what's relevant to the changes, not the whole suite
- **Framework-agnostic** - Auto-detect, don't assume
- **Style-consistent** - Generated tests match the project's existing test conventions
- **Diagnose, don't just report** - Analyze failures and suggest fixes
- **Fast feedback** - Minimize test scope for quick iteration cycles
