---
name: rebase
description: "Rebase the current branch onto its upstream branch with guided conflict resolution."
---

# Rebase

Rebase the current branch onto its upstream (target) branch. Handle conflicts interactively.

Use the AskUserQuestion tool whenever you need user input during conflict resolution.

## Steps

### 1. Pre-flight checks

- Run `git status` to check for uncommitted changes.
- If the working tree is dirty, ask the user whether to **stash changes** (`git stash`) or **abort**.
- Run `git fetch` to get the latest upstream refs.

### 2. Detect the target branch

Try these in order and use the first that succeeds:

1. Open PR base branch: `gh pr view --json baseRefName -q .baseRefName`
2. Tracking branch: `git rev-parse --abbrev-ref @{upstream}` (strip the remote prefix)
3. Fall back to `dev` if it exists (`git rev-parse --verify dev`)
4. Fall back to `main` if it exists (`git rev-parse --verify main`)

If none are found, ask the user which branch to rebase onto.

Before rebasing, show the user which target branch was detected and how many commits will be replayed, and confirm they want to proceed.

### 3. Execute the rebase

Run `git rebase <target>`.

**If no conflicts:** Report success — how many commits were replayed, new HEAD.

**If conflicts occur**, handle each one:

1. Run `git diff --name-only --diff-filter=U` to list conflicted files.
2. For each conflicted file, read the file and examine the conflict markers.
3. Attempt trivial resolution: if one side is clearly a superset (the other side made no changes in that region), resolve automatically.
4. For genuine conflicts, show the user both sides with surrounding context using AskUserQuestion. Offer:
   - **Keep ours** — accept the current branch's version
   - **Keep theirs** — accept the upstream version
   - **Abort rebase** — run `git rebase --abort` and stop
5. After resolving all files in the current step: `git add <files>` and `git rebase --continue`.
6. Repeat until the rebase completes or the user aborts.

### 4. Report result

On success: show the final `git log --oneline` of replayed commits and confirm the branch is up to date.

On abort: confirm the branch is back to its pre-rebase state.
