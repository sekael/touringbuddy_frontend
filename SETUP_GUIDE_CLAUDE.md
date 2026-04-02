# Claude Code Setup Guide — Flutter Hybrid Project

## What's Included

This setup provides a complete Claude Code infrastructure optimized for building a clean, safe, well-tested Flutter application targeting iOS, Android, and Web.

### Files Overview

```
your-project/
├── CLAUDE.md                          # Main project memory file
├── .claude/
│   ├── settings.json                  # Permissions, hooks, environment
│   └── commands/
│       ├── implement.md               # /implement — full feature workflow
│       ├── plan.md                     # /plan — planning-only mode
│       ├── review.md                   # /review — code review checklist
│       ├── test.md                     # /test — run and fix tests
│       └── commit.md                   # /commit — safe conventional commits
├── docs/
│   ├── ARCHITECTURE.md                # Living architecture reference
│   └── plans/                         # Feature plans live here
│       └── .gitkeep
└── ... (your Flutter project files)
```

---

## Installation Steps

### 1. Copy files into your Flutter project root

Place all the provided files into your existing (or new) Flutter project. The structure above shows where each file goes.

### 2. Initialize your Flutter project (if new)

```bash
flutter create --org com.yourcompany your_app
cd your_app
```

### 3. Create the plans directory

```bash
mkdir -p docs/plans
touch docs/plans/.gitkeep
```

### 4. Commit the infrastructure

```bash
git add CLAUDE.md .claude/ docs/
git commit -m "chore: add Claude Code infrastructure"
```

### 5. Start Claude Code

```bash
claude
```

Claude will automatically read `CLAUDE.md` and load your commands and settings.

---

## How the Workflow Operates

### Starting a New Feature

The recommended workflow uses two phases — plan first, then implement:

**Option A: Two-step (recommended for complex features)**
```
> /plan auth-login
```
Claude researches your codebase, creates a detailed plan in `docs/plans/auth-login.md`, and presents it for your review. No code is written. Once you approve:
```
> /implement auth-login
```
Claude creates a branch, writes tests first, implements the feature, validates everything, and commits.

**Option B: One-step (for simpler features)**
```
> /implement user-avatar
```
This runs the full workflow including planning, but in a single session.

### The Implementation Pipeline

Every `/implement` execution follows this exact sequence:

1. **Branch** — Creates `feature/<name>` from latest `main`
2. **Plan** — Writes a plan doc, waits for your approval
3. **Test-first** — Writes failing tests before source code
4. **Implement** — Builds domain → data → presentation layers
5. **Validate** — Runs `flutter analyze`, `dart format`, `flutter test`
6. **Document** — Adds doc comments, updates feature README
7. **Commit** — Stages and commits with conventional message

### Reviewing Changes

```
> /review
```

Performs a read-only review of all uncommitted changes against your project standards. Reports pass/fail with specific file and line references.

### Running Tests

```
> /test
> /test test/features/auth/
```

Runs tests, analyzes failures, fixes issues (in source or test as appropriate), and re-validates.

### Committing Safely

```
> /commit feat(auth): add login screen with email validation
```

Runs all checks before committing. Blocks if analyze or tests fail.

---

## Safety Guardrails

### What the hooks enforce automatically

| Hook | When | What it does |
|------|------|-------------|
| Auto-format | After every Dart file edit | Runs `dart format` on changed files |
| Block force push | Before any Bash command | Prevents `git push --force` and `git push -f` |
| Block push to main | Before any Bash command | Prevents direct pushes to `main` or `master` |

### What the permissions control

- **Allowed**: Reading/writing project files, running Flutter/Dart/Git commands
- **Blocked**: Reading `.env` files, keystores, Firebase config files; `rm -rf`; `flutter clean` (destructive)

---

## Customizing for Your Project

### Adjusting CLAUDE.md

The file is intentionally concise (~60 effective instructions). If you find Claude repeatedly making a specific mistake, add a targeted instruction. If Claude starts ignoring instructions, the file is too long — prune it.

Rules of thumb:
- Every line should prevent a specific mistake Claude would otherwise make
- Reference files by path rather than embedding their content
- Update it when you add new packages or change conventions

### Adding more commands

Create a new `.md` file in `.claude/commands/`. Use the frontmatter to control which tools the command can access:

```markdown
---
description: What this command does (shown in /help)
allowed-tools: Read, Glob, Grep
---

Your prompt instructions here. Use $ARGUMENTS for user input.
```

### Adding more hooks

Edit `.claude/settings.json`. Common additions:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit|MultiEdit",
        "hooks": [
          {
            "type": "command",
            "command": "your-lint-or-format-command"
          }
        ]
      }
    ]
  }
}
```

Hook types: `PreToolUse` (can block with exit 2), `PostToolUse` (runs after), `Stop` (when Claude finishes), `SessionStart` (on startup).

### Switching models

The settings default to Sonnet for cost efficiency. For complex architectural planning, switch to Opus in-session:

```
> /model claude-opus-4-6
```

Or change the default in `.claude/settings.json` under `env.ANTHROPIC_MODEL`.

---

## Tips for Best Results

1. **Keep context lean.** Use `/clear` between unrelated tasks. Manually `/compact` when you notice quality dropping (usually around 40-50% context usage).

2. **Use subagents for research.** Say "use subagents to investigate how our auth system works" — this keeps your main conversation clean.

3. **Iterate on CLAUDE.md.** Treat it like code. When Claude makes a mistake, add a rule. When it stops following rules, prune the file.

4. **One feature per session.** Start fresh for each feature to avoid context contamination.

5. **Review plans carefully.** The biggest time savings come from catching wrong approaches in the plan phase, before any code is written.

6. **Let hooks handle formatting.** Don't waste CLAUDE.md instructions on formatting rules — the PostToolUse hook enforces `dart format` automatically.

---

## Quick Reference Card

| Action | Command |
|--------|---------|
| Plan a feature | `/plan <feature-name>` |
| Implement a feature | `/implement <feature-name>` |
| Review changes | `/review` |
| Run/fix tests | `/test` or `/test <path>` |
| Safe commit | `/commit <message>` |
| Check context usage | `/status` |
| Compact context | `/compact` |
| Clear context | `/clear` |
| Switch model | `/model <model-name>` |
| Simplify recent code | `/simplify` |
