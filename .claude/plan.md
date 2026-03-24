---
description: Create a detailed implementation plan for a feature WITHOUT writing any code
allowed-tools: Read, Glob, Grep, Bash, Agent, WebSearch, WebFetch
---

# Planning Mode — No Code Allowed

You are in PLANNING MODE. You MUST NOT write, edit, or create any source code files.
You may ONLY read existing files and create a plan document.

## Step 1 — Understand the Request

Analyze: $ARGUMENTS

Ask clarifying questions if the request is ambiguous. Focus on:
- What exactly should the feature do?
- Who is the user and what is their workflow?
- Are there constraints (platform-specific, performance, accessibility)?
- What existing patterns in the codebase should be followed?

## Step 2 — Research the Codebase

1. Read `CLAUDE.md` for project conventions (Riverpod 3, GoRouter, freezed, Drift, etc.)
2. Read `.claude/ARCHITECTURE.md` for layered architecture rules
3. Use Glob and Grep to find related code
4. Identify existing Riverpod providers, freezed models, and GoRouter routes as structural references
5. Check existing tests to understand testing patterns
6. If researching a new library or API, use WebSearch/WebFetch to verify current best practices

## Step 3 — Produce the Plan

Create `docs/plans/<feature-name>.md` with:

```markdown
# Plan: [Feature Name]

## Goal
One sentence.

## User Story
As a [user], I want [action] so that [benefit].

## Technical Approach
Describe the approach in 3-5 sentences. Reference existing patterns from the codebase.

## TODO — Files to Create
- [ ] `lib/features/.../entities/entity.dart` — domain entity
- [ ] `lib/features/.../models/dto.dart` — freezed DTO with JSON serialization
- [ ] `lib/features/.../datasources/remote_datasource.dart` — Supabase calls
- [ ] `lib/features/.../repositories/repository_impl.dart` — repository implementation
- [ ] `lib/features/.../providers/feature_provider.dart` — @riverpod AsyncNotifier
- [ ] `lib/features/.../screens/feature_screen.dart` — UI screen
- [ ] `test/features/.../file_test.dart` — what it tests

## TODO — Files to Modify
- [ ] `lib/app/router/router.dart` — add typed route
- [ ] ...

## Data Flow
```
UI (Widget)
  → ref.watch(featureProvider)
    → @riverpod AsyncNotifier
      → Repository (abstract interface)
        → DataSource (Supabase / Drift)
```

## State Management
Which @riverpod providers and AsyncNotifiers are needed. How they connect.

## Edge Cases
1. ...
2. ...
3. ...

## Test Strategy
- Unit tests: domain logic, repository implementations (with mocktail mocks)
- Widget tests: screens and widgets (with ProviderScope.overrides)
- Integration tests: [if applicable]

## Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2
- [ ] All tests pass (`flutter test`)
- [ ] Zero analysis issues (`flutter analyze`)
- [ ] Code formatted (`dart format .`)
- [ ] Doc comments (`///`) on all public APIs
- [ ] Generated files committed (`*.g.dart`, `*.freezed.dart`)
```

## Step 4 — Present and Discuss

Present the full plan to the user including:
- The TODO checklist of files to create/modify
- Any open questions or trade-offs you identified
- A recommendation on implementation order

Iterate until the user explicitly approves. Do NOT proceed to implementation — that is a separate step.
