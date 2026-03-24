---
description: Review current changes for code quality, test coverage, and adherence to project standards
allowed-tools: Read, Glob, Grep, Bash
---

# Code Review Workflow

Review all current changes against project standards. Do NOT modify any files.

## Step 1 — Identify Changes

```bash
git diff --name-only
git diff --cached --name-only
git diff --stat
```

## Step 2 — Review Checklist

For each changed file, evaluate:

### Code Quality
- Does it follow project conventions from CLAUDE.md?
- Are public APIs documented with `///` doc comments?
- Are widgets under 150 lines? If not, what should be extracted?
- Is `const` used wherever possible?
- Are errors handled properly (no swallowed exceptions)?
- Is there any `print()` that should be an `AppLogger` call?
- Are named parameters used when there are >2 parameters?

### Architecture (per CLAUDE.md and .claude/ARCHITECTURE.md)
- Does it follow the feature module structure (`data/` → `domain/` → `presentation/`)?
- Are dependencies flowing inward (presentation → domain ← data)?
- Are Riverpod providers using `@riverpod` code generation (not manual `Provider()`)?
- Are `AsyncNotifier` used for all async state?
- Are models defined with `freezed` and `@JsonSerializable` (not manual `fromJson`/`toJson`)?
- Are routes defined in `lib/app/router/` using GoRouter typed routes?
- Is Supabase accessed only through repository implementations, never directly from providers?
- Are platform-specific checks handled correctly (`kIsWeb` / `defaultTargetPlatform`)?

### Styling & Theming
- Does the UI use `Theme.of(context).textTheme` and design tokens (`SpacingTokens`, `RadiusTokens`)?
- Are `.adaptive()` constructors used on supported widgets for iOS?
- Are responsive breakpoints handled for web via `LayoutBuilder` / `MediaQuery`?

### Testing
- Does every new public function/class have a corresponding test?
- Are tests descriptive (`'should return user when credentials are valid'`)?
- Are mocks using `mocktail` against abstract interfaces, not concrete implementations?
- Do test files mirror the source structure (`lib/features/x/` → `test/features/x/`)?
- Are Riverpod providers tested with `ProviderContainer.test()` / `ProviderScope.overrides`?

### Safety
- No hardcoded secrets, API keys, or credentials?
- No `print()` statements leaking sensitive data?
- Input validation on user-facing fields?
- No `.env` or credential files staged?

## Step 3 — Run Automated Checks

```bash
dart format --output=none --set-exit-if-changed lib/ test/
flutter analyze
flutter test
```

## Step 4 — Report

Present findings as:
- **Pass**: Things done well
- **Issues**: Things that must be fixed (with file path and line number)
- **Suggestions**: Optional improvements (clearly marked as non-blocking)

Rate the overall change: **Ready to merge** / **Needs fixes** / **Needs rework**
