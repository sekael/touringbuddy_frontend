---
description: Implement a new feature or fix using the full planning-first workflow
allowed-tools: Read, Write, Edit, MultiEdit, Glob, Grep, Bash, Agent
---

# Feature Implementation Workflow

You MUST follow every step below in order. Do NOT skip steps.
Keep the user informed at each phase transition with a brief status update.

## Phase 1 — Branch Setup

1. Check current git status: `git status`
2. If there are uncommitted changes, STOP and ask the user what to do
3. Fetch latest and create a feature branch:
   ```
   git fetch origin
   git checkout main
   git pull origin main
   git checkout -b feat/<issue-number>-<short-description>
   ```
4. Report to user: "Branch `feat/...` created from latest `main`."

## Phase 2 — Planning (MANDATORY)

1. Gather context:
   - Read `CLAUDE.md` for project conventions
   - Read `.claude/ARCHITECTURE.md` for layered architecture rules
   - Identify all files that will be affected
   - Read existing related code to understand patterns
   - Check for existing tests in the area
2. Create a plan document at `docs/plans/<feature-name>.md` containing:
   - **Goal**: One-sentence summary
   - **User story**: As a [user], I want [action] so that [benefit]
   - **TODO — Files to create**: Checklist with paths and purpose
   - **TODO — Files to modify**: Checklist with paths and what changes
   - **Data flow**: How data moves through the layers (UI → Provider → Repository → DataSource)
   - **Edge cases**: At least 3 edge cases to handle
   - **Test strategy**: Unit tests (domain/data), widget tests (UI), integration tests
   - **Acceptance criteria**: Checkboxes for when this feature is done
3. Present the plan to the user and WAIT for explicit approval before proceeding
4. Do NOT write any source code until the user approves the plan

## Phase 3 — Implementation (layer by layer, inside-out)

After each layer, report progress to the user with a brief summary of what was done.

### Step 1 — Code Generation Setup (if new models needed)
1. Create freezed models (`data/models/`) with `@freezed` and `@JsonSerializable`
2. Create domain entities (`domain/entities/`) as pure Dart classes
3. Run code generation: `dart run build_runner build --delete-conflicting-outputs`
4. Report: "Models created. Generated files: [list]. Moving to domain layer."

### Step 2 — Domain Layer
1. Write unit tests FIRST for domain logic (entities, repository interfaces)
2. Implement domain layer (entities, abstract repository interfaces)
3. Run tests: `flutter test test/features/<name>/domain/`
4. Report: "Domain layer done. [N] tests passing."

### Step 3 — Data Layer
1. Write unit tests FIRST for repository implementations
2. Implement data layer (datasources with Supabase calls, Drift DAOs, repository implementations)
3. Mock abstract repository interfaces with `mocktail` — never mock concrete classes
4. Run tests: `flutter test test/features/<name>/data/`
5. Report: "Data layer done. [N] tests passing."

### Step 4 — Presentation Layer
1. Write widget tests FIRST for screens/widgets
2. Implement Riverpod providers (`@riverpod` annotated AsyncNotifiers)
3. Implement screens and widgets
4. Use `ProviderScope.overrides` in widget tests for dependency injection
5. Run code generation if new providers were added: `dart run build_runner build --delete-conflicting-outputs`
6. Run tests: `flutter test test/features/<name>/presentation/`
7. Report: "Presentation layer done. [N] tests passing."

### Step 5 — Routing Integration
1. Add typed route in `lib/app/router/`
2. Wire up auth guards if needed via GoRouter `redirect`

## Phase 4 — Validation

Run all checks and present results to the user:

```bash
# 1. Code generation (ensure all generated files are up to date)
dart run build_runner build --delete-conflicting-outputs

# 2. Format
dart format lib/ test/

# 3. Analyze (zero issues required)
flutter analyze

# 4. Full test suite
flutter test
```

If any check fails, fix the issue and re-run. Report each check result:
- "Format: PASS"
- "Analyze: PASS (0 issues)"
- "Tests: PASS ([N] tests)"

## Phase 5 — Review & Commit

1. Show the user what changed:
   ```bash
   git diff --stat
   ```
2. Show a summary diff of key changes for the user to review
3. Add doc comments (`///`) on all new public APIs
4. Stage files explicitly — list the files being staged (do NOT blindly `git add -A`):
   ```bash
   git add lib/features/<name>/ test/features/<name>/ [other specific files]
   ```
5. Verify nothing unexpected is staged: `git diff --cached --stat`
6. Present the proposed commit message to the user for approval
7. Commit with conventional format:
   ```bash
   git commit -m "feat(<scope>): <description>"
   ```
8. Final report to user:
   - Files changed (created/modified/deleted)
   - Tests added and total count
   - What to do next (push, open PR, continue with next task)
