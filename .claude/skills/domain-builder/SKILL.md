---
name: domain-builder
description: "Generates domain convention skills for any language, framework, or tool stack. Combines codebase analysis with web research and built-in knowledge. Use when setting up a new project or adding a technology to an existing one."
---

# Domain Builder

## Overview

Automatically build `domain:*` convention skills by analyzing the codebase and researching best practices. Produces skills that follow the same structure as existing domain skills (Idioms, Project Structure, Testing, Error Handling, Dependencies, Anti-patterns).

## The Process

### Step 1 — Identify Target Technologies

**If the user provides an argument** (e.g., `/domain-builder go+echo` or `/domain-builder react`):
- Parse the argument as the target stack
- Split on `+` if multiple technologies are specified

**If no argument is provided**, auto-detect by scanning for config files:

| File | Technology |
|------|-----------|
| `package.json` | Node.js (check dependencies for framework: React, Vue, Next.js, Express, etc.) |
| `tsconfig.json` | TypeScript |
| `go.mod` | Go (check imports for framework: echo, gin, fiber, etc.) |
| `Cargo.toml` | Rust |
| `pyproject.toml`, `setup.py` | Python (check dependencies for framework: FastAPI, Django, Flask, etc.) |
| `Gemfile` | Ruby (check for Rails, Sinatra, etc.) |
| `pom.xml`, `build.gradle` | Java/Kotlin (check for Spring, Quarkus, etc.) |
| `mix.exs` | Elixir (check for Phoenix, etc.) |
| `composer.json` | PHP (check for Laravel, Symfony, etc.) |
| `*.csproj`, `*.sln` | C#/.NET |
| `deno.json` | Deno |
| `bun.lockb` | Bun |
| `CMakeLists.txt` | C/C++ |
| `Package.swift` | Swift |
| `pubspec.yaml` | Dart/Flutter |

Present detected technologies and ask the user to confirm or adjust.

### Step 2 — Check for Existing Domain Skills

- List all `domain:*` directories in `.claude/skills/`
- If a skill already covers part of the target stack, ask the user:
  - Update the existing skill with new information?
  - Create a new, separate skill?
  - Skip that technology?

### Step 3 — Analyze Codebase Patterns

Use the Explore agent or direct file reads to discover project-specific conventions:

**Directory structure:**
- How is source code organized? (`src/`, `lib/`, `app/`, `pkg/`, etc.)
- Where do tests live? (colocated, separate `tests/` directory, etc.)
- What's the module/package layout?

**Testing:**
- Which test framework is configured? (look at config files and test file patterns)
- What naming convention do test files follow?
- What assertion style is used?
- Are there shared fixtures or test utilities?

**Error handling:**
- How are errors defined? (custom classes, error types, Result patterns)
- What logging is used?
- How are errors propagated?

**Dependencies:**
- What are the key dependencies and what purposes do they serve?
- Are there clear choices for common needs (HTTP, validation, logging, etc.)?

**Code style:**
- Linter and formatter configuration
- Import organization patterns
- Naming conventions visible in the code

### Step 4 — Research Best Practices

Use WebSearch to look up current best practices for each target technology:

- Search for `"<technology> best practices 2026"`, `"<technology> project structure conventions"`, `"<technology> idiomatic patterns"`
- Focus on official documentation and widely-respected community guides
- Look for recent changes in conventions (e.g., new recommended tools, deprecated patterns)

Combine web research findings with built-in knowledge. Prioritize:
1. Project-specific patterns already in use (from Step 3)
2. Official documentation recommendations
3. Widely-adopted community conventions

When the codebase already follows a convention, keep it. Only suggest changes where the codebase has no established pattern or uses a clearly outdated one.

### Step 5 — Determine Skill Grouping

Decide how to group technologies into skills:

**Combine into one skill** when technologies are always used together:
- Next.js + React (Next.js implies React)
- Rails + Ruby (Rails is the primary context)
- Django + Python (Django is the primary context)
- Flutter + Dart (Flutter implies Dart)

**Keep as separate skills** when technologies are used independently:
- TypeScript used in both frontend (React) and backend (Express) — keep `domain:typescript` separate
- A database (PostgreSQL) used by multiple services
- A testing framework used across different languages

Ask the user to confirm the proposed grouping.

### Step 6 — Generate Skill Content

For each skill to create, generate content following this exact section structure:

```markdown
---
name: "domain:<name>"
description: "Loaded automatically when working with <technology> code. Defines project conventions for <key areas>."
---

# <Technology> Conventions

## Idioms

- 6-8 bullets covering the most important language/framework idioms
- Prioritize patterns found in this codebase
- Include type system usage, preferred constructs, naming conventions

## Project Structure

- 4-6 bullets on directory layout, module organization, config file locations
- Reflect the actual project structure when applicable
- Note any path aliases, build tool conventions

## Testing

- 5-7 bullets on test framework, file naming, assertion style
- Include fixture/helper patterns if the project uses them
- Note any test runner configuration

## Error Handling

- 4-6 bullets on error definition, propagation, logging patterns
- Match patterns already established in the codebase
- Include recommended libraries for error handling

## Dependencies

- 4-6 key dependency recommendations organized by purpose
- Prefer dependencies already in use in the project
- Only recommend alternatives when the project has no established choice

## Anti-patterns

- 5-7 common mistakes to avoid
- Include language-specific pitfalls and framework misuse patterns
- Note any anti-patterns observed in the codebase (tactfully)
```

**Present each section to the user for review.** After each section, ask if it looks right or needs adjustment. Be ready to revise based on feedback.

### Step 7 — Write and Commit

After the user approves all sections:

1. Create the skill directory: `.claude/skills/domain:<name>/`
2. Write the `SKILL.md` file
3. If multiple skills were generated, write them all
4. Commit the new skill(s)

## Key Principles

- **Codebase-first** — Existing project patterns take priority over generic best practices
- **One question at a time** — Don't overwhelm during review
- **Opinionated but adjustable** — Start with strong recommendations, adjust based on user feedback
- **Match existing skill quality** — Generated skills should be indistinguishable from the hand-written domain skills
- **No bloat** — Keep each section concise and actionable. Every bullet should change behavior.
- **Use `/learn` for incremental updates** — Once a domain skill exists, small tweaks (swapping a dependency, adding a convention) should go through `/learn` rather than re-running the full builder.
