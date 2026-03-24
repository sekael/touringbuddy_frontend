---
description: Run tests, analyze failures, and fix them
allowed-tools: Read, Write, Edit, MultiEdit, Glob, Grep, Bash
---

# Test Workflow

## Step 1 — Run Tests

```bash
flutter test $ARGUMENTS
```

If no arguments provided, run the full suite: `flutter test`

## Step 2 — Analyze Results

If all tests pass: report the count and exit.

If tests fail:
1. Read each failing test file
2. Read the corresponding source file
3. Determine if the issue is in the test or the source
4. Categorize: logic bug, missing mock, stale assertion, or test setup issue?

Present findings to the user:
- Which tests failed and why (file path + line number)
- Whether the fix belongs in the source or the test
- Proposed fix for each failure

## Step 3 — Fix (with user awareness)

- If the SOURCE code is wrong: fix the source, show the diff to the user, then re-run the test
- If the TEST is wrong (stale assertion, missing mock setup): fix the test, show the diff
- NEVER delete or skip a test to make the suite pass
- NEVER weaken assertions to make tests pass
- When mocking, use `mocktail` and mock abstract repository interfaces, never concrete classes
- For Riverpod providers, use `ProviderContainer.test()` for unit tests and `ProviderScope.overrides` for widget tests

## Step 4 — Verify

```bash
flutter test
flutter analyze
```

Both must pass with zero issues. Report:
- Total tests passing
- What was fixed and why
- Any follow-up actions needed
