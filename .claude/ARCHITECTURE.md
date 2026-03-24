# Architecture Overview

## Layered Architecture

This project follows **Clean Architecture** adapted for Flutter with Riverpod 3.

```
┌─────────────────────────────────────────────┐
│              Presentation Layer              │
│   Screens, Widgets, @riverpod Notifiers     │
├─────────────────────────────────────────────┤
│                Domain Layer                  │
│   Entities, Repository Interfaces            │
├─────────────────────────────────────────────┤
│                 Data Layer                   │
│   Repository Impls, Freezed DTOs, Sources   │
├─────────────────────────────────────────────┤
│              External Services               │
│   Supabase, Drift (SQLite), MapLibre        │
└─────────────────────────────────────────────┘
```

## Dependency Rule

Dependencies point inward. The domain layer has ZERO dependencies on Flutter, data, or presentation layers. The data layer depends on domain interfaces. The presentation layer depends on domain entities via Riverpod providers.

## Feature Module Pattern

Each feature is self-contained:

```
features/
  <feature_name>/
    data/
      datasources/        # Supabase calls, Drift DAOs
      models/             # Freezed DTOs with @JsonSerializable
      repositories/       # Repository interface implementations
    domain/
      entities/           # Pure Dart business objects (no framework deps)
      repositories/       # Abstract repository interfaces
    presentation/
      providers/          # @riverpod annotated AsyncNotifiers
      screens/            # Full-page widgets
      widgets/            # Feature-specific UI components
```

## State Management

- **Riverpod 3** with code generation is the sole state management solution
- `@riverpod AsyncNotifier` for stateful logic with loading/error states
- `@riverpod` functions for simple computed/derived values
- `FutureProvider` for one-shot async data
- `StreamProvider` for real-time data (e.g., Supabase realtime subscriptions)
- Use `ref.watch` in widgets, `ref.read` for one-off actions, `ref.listen` for side effects

## Navigation

- **GoRouter** with typed routes (via `go_router_builder`)
- Routes defined in `lib/app/router/`
- Auth redirect via GoRouter's `redirect` callback, reactive to Riverpod auth state
- `ShellRoute` / `StatefulShellRoute` for persistent navigation shells
- Modal sheets and dialogs presented imperatively, not as routes

## Data Flow

```
UI (Widget)
  → ref.watch(provider)
    → @riverpod AsyncNotifier
      → Repository (abstract interface from domain/)
        → DataSource (Supabase client / Drift DAO)
          → Supabase (remote) or SQLite (local cache via Drift)
```

- Repositories are the single source of truth — providers never call Supabase directly
- DTOs (freezed models in `data/models/`) map between API JSON and domain entities
- Domain entities (in `domain/entities/`) are pure Dart, no framework dependencies

## Error Handling

- Providers expose errors via Riverpod's `AsyncValue` (loading / data / error states)
- Widgets handle all three states using `asyncValue.when(data:, loading:, error:)`
- Custom exceptions in `core/exceptions/` for domain-specific error types
- Presentation layer maps exceptions to user-facing messages
- No exceptions cross layer boundaries unhandled — catch in repositories, surface via AsyncValue

## Map Architecture

- **MapLibre GL** (`maplibre_gl`) renders Swisstopo vector tiles (WMTS)
- Swisstopo provides free tiles without API key
- Map styles loaded from assets (`assets/swisstopo_wmts_style.json`) and remote URLs
- Map state (camera, selection, picking mode) managed via dedicated Riverpod provider
- Tour markers rendered as MapLibre circle layers with metadata for tap handling
- Platform-specific camera handling: web uses latitude offset, iOS uses content insets

## Platform Considerations

- Web: no `dart:io`, use `kIsWeb` checks, responsive layouts with `LayoutBuilder` / `MediaQuery`
- iOS: Cupertino-style navigation, `.adaptive()` constructors, safe area handling, haptic feedback
- Android: Full Material 3, dynamic color support, standard back button handling
- Shared: abstract platform differences behind interfaces in `core/`

## Styling

- Material 3 with `ColorScheme.fromSeed()` (orange seed color)
- `.adaptive()` constructors for automatic Cupertino rendering on iOS
- `cupertinoOverrideTheme` set so Cupertino widgets inherit app colors
- Design tokens as theme extensions: `SpacingTokens`, `RadiusTokens`
- Typography via custom `TextTheme` — access via `Theme.of(context).textTheme`

## Testing Strategy

| Layer        | Test Type     | Tools                                    |
|-------------|---------------|------------------------------------------|
| Domain      | Unit          | flutter_test, mocktail                    |
| Data        | Unit          | flutter_test, mocktail                    |
| Presentation| Widget        | flutter_test, mocktail, ProviderScope     |
| Providers   | Unit          | ProviderContainer.test()                  |
| Full flow   | Integration   | integration_test                          |

## Key Decisions

| Decision | Rationale |
|----------|-----------|
| Riverpod 3 over Provider/Bloc | Code generation, compile-time safety, native async support, less boilerplate |
| GoRouter over manual Navigator | Official Flutter recommendation, typed routes, deep linking, auth redirects |
| Supabase directly (no Dio) | supabase_flutter handles auth tokens, retries, and realtime — wrapping adds complexity |
| Freezed for models | Immutable, generated equality/copyWith/serialization, eliminates manual boilerplate |
| Drift for local storage | SQLite-backed, compile-time SQL validation, works on all platforms including web |
| MapLibre GL for maps | Native vector tile rendering, free Swisstopo WMTS support, best performance |
| very_good_analysis | Strictest community lint set, catches real bugs, enforces consistency |
| mocktail over mockito | Null-safety first, no codegen required, simpler syntax |
