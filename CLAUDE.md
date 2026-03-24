# Project: TouringBuddy Frontend

A Flutter tour-planning app for outdoor enthusiasts. Users pin tour objectives on a Swiss topographic map (Swisstopo), associate contacts as tour partners, and manage their profile. Deployed as a web app at test.tourenbuddy.ch with iOS and Android planned.

## Stack & Architecture

- **Framework:** Flutter (latest stable) with Dart
- **Targets:** Web (primary, Cloudflare Pages), iOS, Android
- **State management:** Riverpod 3 with code generation (`@riverpod`, `AsyncNotifier`, `riverpod_generator`)
- **Routing:** GoRouter with typed routes (`go_router_builder`) and `redirect` for auth guards
- **Backend:** Supabase (PostgreSQL + PostgREST + Auth via email/OTP) — use `supabase_flutter` directly in repositories, do NOT wrap with Dio
- **Map:** MapLibre GL (`maplibre_gl`) with Swisstopo vector tiles (WMTS)
- **Models:** Freezed + json_serializable for immutable models with generated (de)serialization
- **Local storage:** Drift for structured data caching (SQLite-backed, works on all platforms); SharedPreferences for simple key-value settings only
- **DI:** Riverpod providers — no service locator, no manual MultiProvider
- **Logging:** Custom `AppLogger` wrapping the `logger` package — no `print()` in production code
- **Testing:** `flutter_test`, `mocktail` for mocks, Riverpod test utilities (`ProviderContainer.test()`, `ProviderScope.overrides`)
- **Linting:** `very_good_analysis` — strictest recommended lint set
- **Versioning:** Automated via release-please with conventional commits

## Project Structure

```
lib/
  app/                              # App-level config
    router/                         # GoRouter config, route definitions, auth redirect
    theme/                          # Material 3 theme, color scheme, design tokens, typography
  core/                             # Shared across all features
    constants/                      # App-wide constants
    extensions/                     # Dart/Flutter extension methods
    exceptions/                     # Custom exception classes
    logging/                        # AppLogger, LogPrinter
    widgets/                        # Shared reusable widgets (Crosshair, ErrorSnackbar, etc.)
  features/                         # Feature modules — each self-contained
    feature_name/
      data/
        datasources/                # Supabase calls, Drift DAOs, local cache
        models/                     # Freezed DTOs with JSON serialization
        repositories/               # Repository implementations
      domain/
        entities/                   # Business objects
        repositories/               # Abstract repository interfaces
      presentation/
        providers/                  # Riverpod providers (@riverpod annotated)
        screens/                    # Full-page widgets
        widgets/                    # Feature-specific widgets
  l10n/                             # Localization ARB files (when implemented)
test/                               # Unit & widget tests, mirrors lib/ structure
integration_test/                   # E2E integration tests
```

## Key Dependencies

```yaml
dependencies:
  flutter_riverpod: ^3.3.1          # State management
  riverpod_annotation: ^4.0.2       # @riverpod code generation annotations
  go_router: ^17.1.0                # Declarative routing
  supabase_flutter: ^2.12.0         # Backend (PostgreSQL + Auth)
  maplibre_gl: ^0.25.0              # Map rendering with Swisstopo vector tiles
  drift: ^2.32.1                    # Local structured data (SQLite)
  freezed_annotation: ^3.2.5        # Immutable model annotations
  json_annotation: ^4.9.0           # JSON serialization annotations
  logger: ^2.6.2                    # Logging
  uuid: ^4.5.2                      # UUID generation
  flutter_dotenv: ^6.0.0            # Environment variables
  url_launcher: ^6.3.2              # External links
  cupertino_icons: ^1.0.8           # iOS-style icons

dev_dependencies:
  very_good_analysis: ^10.2.0       # Strict lint rules
  build_runner: ^2.4.0              # Code generation runner
  riverpod_generator: ^4.0.3        # Riverpod code generation
  riverpod_lint: ^4.0.0             # Riverpod-specific lint rules
  custom_lint: ^0.7.5               # Required by riverpod_lint
  freezed: ^3.2.5                   # Immutable model code generation
  json_serializable: ^6.9.5         # JSON serialization code generation
  drift_dev: ^2.26.0                # Drift code generation
  mocktail: ^1.0.4                  # Mocking for tests
```

## Key Commands

```bash
# Install dependencies
flutter pub get

# Run on web (primary target)
flutter run -d chrome

# Run on iOS simulator
flutter run -d iphone

# Run all tests
flutter test

# Run a single test file
flutter test test/features/tours/domain/tour_test.dart

# Analyze code (must pass with zero issues — enforced in CI)
flutter analyze

# Format code (enforced in CI)
dart format .

# Generate code (freezed, json_serializable, riverpod_generator, drift)
dart run build_runner build --delete-conflicting-outputs

# Watch mode for code generation during development
dart run build_runner watch --delete-conflicting-outputs

# Build for release
flutter build web --release --base-href "/"
flutter build apk --release
flutter build ios --release
```

## Code Style & Conventions

- ALWAYS run `flutter analyze` after changes — zero warnings allowed (CI blocks PRs)
- ALWAYS run `dart format .` before committing (CI checks with `--set-exit-if-changed`)
- Use `const` constructors wherever possible
- Prefer named parameters for >2 parameters
- Every public API must have a doc comment (`///`)
- File names: `snake_case.dart`. Class names: `PascalCase`
- One widget per file. Keep widgets under 150 lines; extract sub-widgets
- No `print()` in production code — use `AppLogger`
- Use `freezed` for all models and state classes — no manual `fromJson`/`toJson`
- Handle errors with `AsyncValue` in Riverpod providers — never swallow exceptions
- Platform-specific code must use `kIsWeb` / `defaultTargetPlatform` checks
- Generated files (`*.g.dart`, `*.freezed.dart`) must be committed to the repository

## Riverpod Patterns

- Use `@riverpod` annotation for all providers (code generation, not manual)
- Use `AsyncNotifier` for all async state (data fetching, mutations)
- Use `ref.watch` in widgets, `ref.read` for one-off actions (e.g., button callbacks)
- Use `ref.listen` for side effects (navigation, showing snackbars)
- Providers live in `features/<name>/presentation/providers/`
- Override providers in tests using `ProviderScope.overrides`
- Repository providers return abstract interfaces — implementations injected via overrides in tests

## Routing Patterns

- All routes defined in `lib/app/router/`
- Use typed routes via `go_router_builder` for type-safe navigation
- Auth redirect logic in GoRouter's `redirect` callback, reactive to Riverpod auth state
- Use `ShellRoute` / `StatefulShellRoute` for persistent navigation shells
- Modal sheets and dialogs are presented imperatively from within page widgets, not as routes

## Styling & Theming

- **Material 3** as the base design system with `ColorScheme.fromSeed()` (orange seed color)
- Use `.adaptive()` constructors on supported widgets (`Switch.adaptive`, `Slider.adaptive`, etc.) for automatic Cupertino rendering on iOS
- Use `ThemeData.platform` and `defaultTargetPlatform` for platform-specific styling decisions
- Set `cupertinoOverrideTheme` in `ThemeData` so Cupertino widgets inherit the app color scheme
- **Design tokens** as theme extensions: `SpacingTokens` (xxs through xxl), `RadiusTokens` (sm, md, lg)
- Web: Material 3 with responsive breakpoints using `LayoutBuilder` / `MediaQuery`
- iOS: Cupertino-style navigation bars, adaptive widgets, platform-appropriate gestures
- Android: Full Material 3 with dynamic color support where available
- Typography via custom `TextTheme` — use `Theme.of(context).textTheme` consistently

## Data Flow

```
UI (Widget)
  → ref.watch(provider)
    → Riverpod Provider (@riverpod AsyncNotifier)
      → Repository (abstract interface from domain/)
        → DataSource (Supabase client / Drift DAO)
          → Supabase (remote) or SQLite (local cache)
```

- Repositories are the single source of truth — providers never call Supabase directly
- DTOs (freezed models in `data/models/`) map between API JSON and domain entities
- Domain entities (in `domain/entities/`) are pure Dart, no framework dependencies

## Git Workflow

- IMPORTANT: Before starting ANY new feature or task, ALWAYS create a new branch from latest `main`:
  `git fetch origin && git checkout main && git pull && git checkout -b feat/<issue-number>-<short-description>`
- Branch naming: `feat/<issue-number>-<description>` or `fix/<issue-number>-<description>`
- Commit messages follow conventional commits: `type(scope): description`
  - Types: feat, fix, refactor, test, docs, chore, style
- Commits should be atomic — one logical change per commit
- Never commit directly to `main`
- Versioning is automated by release-please — do not manually edit version in pubspec.yaml

## Planning & Thinking

- IMPORTANT: For any new feature or non-trivial change, ALWAYS start in plan mode
- Before writing ANY code, produce a plan covering: goal, affected files, data flow, edge cases, test strategy
- Wait for explicit user approval of the plan before implementing
- If a task seems simple but touches >3 files, still produce a brief plan

## Testing Requirements

- Every new public function or class MUST have corresponding tests
- Minimum test types per feature: unit tests for domain/data logic, widget tests for UI
- Use `mocktail` for dependency mocking — mock abstract repository interfaces, never concrete implementations
- Test Riverpod providers using `ProviderContainer.test()` for unit tests and `ProviderScope.overrides` for widget tests
- Test file location mirrors source: `lib/features/tours/...` → `test/features/tours/...`
- Name tests descriptively: `'should return user when credentials are valid'`
- Run `flutter test` after every implementation — all tests must pass

## CI/CD Pipeline

- **PR checks** (`analyze-and-test.yml`): format check → `flutter analyze` → `flutter test`
- **Release** (`release.yml`): release-please auto-versions on merge to `main`
- **Deploy** (`build-web-and-push.yml`): builds Flutter web, deploys to Cloudflare Pages
- CI creates a dummy `config/supabase.env` — real env file is not committed

## Important Context

- The app uses Supabase free tier — expect higher latency on auth operations
- Swisstopo provides free WMTS vector tiles without API key — MapLibre handles these natively
- Swisstopo full color map has a known issue on web (GitHub issue #24)
- Backlog tracked at: https://github.com/users/sekael/projects/1
- This project values thoughtful, intentional development — understand code before changing it, keep PRs small and reviewable
