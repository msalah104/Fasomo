# Fasomo — project instructions

Flutter app that tracks recommended (Sunnah) and obligatory fasting days on the Hijri calendar, with reminders, in Arabic and English.

## Conventions

The skills in `.claude/skills/` (from the Flutter Skills pack, MIT — see `.claude/skills/LICENSE-flutter-skills`) are the house rules. Start every task with `flutter-conventions-index`, then the skill it routes to.

### Project override: BLoC + GetIt, not Riverpod

This project deliberately follows the FA app structure. Where any skill says Riverpod, apply this instead:

| Skill says | In Fasomo |
|---|---|
| `Notifier` / `AsyncNotifier` (ViewModel) | `Bloc` with `Equatable` events and an immutable state (`status` enum + `copyWith`, or sealed states). `Cubit` only for trivial screens. |
| Providers as DI, overrides at the composition root | `get_it` in `lib/core/di/injection_container.dart`. Blocs `registerFactory`; use cases, repositories, data sources and services `registerLazySingleton`. |
| `ConsumerWidget` / `ref.watch` | `BlocBuilder` / `BlocSelector` / `BlocListener` / `context.read<XBloc>()`. |
| `ProviderContainer.test()` + `overrideWith` | `bloc_test` + `mocktail` fakes of use cases / repositories. |
| `state-management-riverpod` skill | Not installed. Not applicable. |

Everything else in the skills applies as written: typed `Result`/`Failure` errors, injected `Clock` (no `DateTime.now()` in domain/data code), side effects behind interfaces, ARB-based l10n with RTL-safe geometry, strict lints, small units, tests per layer.

### Layers (clean architecture, per feature)

```
lib/
  core/                  # shared: di, error, theme, l10n, services (clock, notifications), utils
  features/<feature>/
    domain/              # entities, repository interfaces, use cases — pure Dart, no Flutter, no data imports
    data/                # data sources, models, repository implementations
    presentation/        # bloc/, pages/, widgets/
```

Dependencies point inward only: presentation → domain ← data. A feature never imports another feature's `data/` or `presentation/`; shared types move to `core/`.

## Workflow

- One feature or fix per commit; push after each commit.
- Definition of done before committing:
  ```bash
  dart format --set-exit-if-changed .
  flutter analyze --fatal-infos
  flutter test
  ```
  Never report a change as done or verified without running these. If Flutter isn't available in the environment, say so explicitly.
- Keep `README.md` (features + roadmap) in sync with what's actually implemented.
