# Repository Guidelines

## Project Structure & Module Organization
- Source lives in `lib/`, grouped by `core/`, `features/`, `screens/`, `services/`, and `theme/`; mirror this hierarchy when adding code.
- Tests sit in `test/` and mirror the lib path; keep fixtures alongside their suites and archive retired references in `docs/archive/`.
- Native shells stay in `android/` and `ios/`; assets and databases belong in `assets/`; automation scripts live in `scripts/` and `tools/`.

## Knowledge Base & Documentation Workflow
- Treat this guide and `README.md` as canon; link out only to current references.
- Refresh `CURRENT_STATE.md` plus `docs/RECENT_DECISIONS.md` after every feature merge so they reflect today’s build.
- Capture the latest `flutter analyze`, `flutter test --coverage`, and smoke results in `status/BUILD_STATUS.md`, and run `scripts/sync_context.sh` before sharing context externally.

## Build, Test, and Development Commands
- `flutter pub get` installs dependencies; rerun after touching `pubspec.yaml`.
- `dart run build_runner build --delete-conflicting-outputs` regenerates codegen assets; pair with `flutter analyze` to surface lints.
- Use `flutter run -d <platform>` for local devices, `flutter test --coverage` plus `./analyze_coverage.sh` for verification snapshots.

## Coding Style & Naming Conventions
- Follow Dart defaults: 2-space indent, `UpperCamelCase` types, `lowerCamelCase` members, `snake_case.dart` filenames.
- Always format with `dart format .` (or `flutter format .`) before committing; respect analyzer rules in `analysis_options.yaml`.
- Centralize providers in `lib/core/providers/`, keep reusable UI in `lib/core/widgets/`, and avoid overgrown feature files.

## Testing Guidelines
- Name suites `*_test.dart` and mirror the lib structure (`lib/features/chat/...` → `test/features/chat/...`).
- Lean on `flutter_test` for widgets, reuse existing mocks in `test/`, and run `./count_tests.sh` when adding integration entries.
- Document unusual fixtures or datasets in `docs/` so results stay reproducible.

## Commit & Pull Request Guidelines
- Use the established emoji-prefix + imperative summary style (≤72 chars) visible in `git log`.
- PRs must outline motivation, summarize changes, list validation (`flutter test`, manual scenarios), and attach UI screenshots when relevant.
- Request reviews from domain owners and update `CURRENT_STATE.md`, `docs/RECENT_DECISIONS.md`, and `status/BUILD_STATUS.md` before merging.

## Agent Notes
- Run `scripts/sync_context.sh` ahead of major planning sessions and share its output with async collaborators.
- Do not overwrite `.db` assets or other large binaries without alignment; regenerating data sources is mandatory when they change.
- Capture environment or credential nuances in `ENV_SETUP_GUIDE.md` so future contributors stay unblocked.
