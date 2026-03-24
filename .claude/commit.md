---
description: Validate changes, review diff with user, and create a conventional commit
allowed-tools: Read, Glob, Grep, Bash
---

# Safe Commit Workflow

## Step 1 — Pre-commit Checks

Run all checks. ALL must pass before committing:

```bash
dart format lib/ test/
flutter analyze
flutter test
```

If any check fails, STOP and report the issues. Do NOT commit.

## Step 2 — Review Changes with User

Show the user what will be committed:

```bash
git status
git diff --stat
git diff
```

Present a summary:
- **New files**: list each with a one-line description
- **Modified files**: list each with what changed
- **Deleted files**: list each with why

If there are unexpected or unrelated changes, flag them to the user.

## Step 3 — Stage Specific Files

Stage files explicitly — do NOT use `git add -A` or `git add .` to avoid accidentally committing secrets or unintended files:

```bash
git add lib/features/<scope>/ test/features/<scope>/ [other specific paths]
```

Verify the staging area matches expectations:

```bash
git diff --cached --stat
```

NEVER stage:
- `.env`, `.env.*`, or `config/supabase.env`
- `*.keystore`, `*.jks`
- `GoogleService-Info.plist`, `google-services.json`
- Any file containing secrets or credentials

## Step 4 — Commit

Generate a commit message following conventional commits:
- `feat(scope): description` — new feature
- `fix(scope): description` — bug fix
- `refactor(scope): description` — code change that neither fixes nor adds
- `test(scope): description` — adding or fixing tests
- `docs(scope): description` — documentation only
- `chore(scope): description` — build, tooling, dependencies
- `style(scope): description` — formatting, no logic change

Scope = the feature module or area (e.g., auth, tours, map, contacts, core).

Present the proposed commit message to the user before committing. Then:

```bash
git commit -m "<type>(<scope>): <description>"
```

If $ARGUMENTS is provided and is a valid conventional commit message, use it directly.

## Step 5 — Confirm

```bash
git log --oneline -3
```

Report the commit hash, message, and number of files changed.
Do NOT push unless the user explicitly asks.
