# Current State

_Last updated: 2025-10-22 (UTC)_

## Build Targets
- Flutter 3.0+ application shipping to iOS, Android, and macOS; version `1.0.0+1` in `pubspec.yaml`.
- Preferred tooling: Xcode 14+ for iOS, Android Studio for Android; see `ENV_SETUP_GUIDE.md` for platform prerequisites.
- Track the most recent `flutter analyze`, targeted widget tests, and manual smoke runs in `status/BUILD_STATUS.md` to keep this snapshot actionable.

## Active Feature Set
- **AI Pastoral Chat:** Gemini 2.0 Flash backed experience with daily/seasonal verse recommendations, lockout escalation, and AppSnackBar confirmations.
- **Daily Verse & Devotionals:** Offline-first SQLite content; verse schedule aligned with the 366-day database and surfaced on Home + Devotional screens.
- **Verse Library:** Saved favorites plus share history tracking with clear-all actions and glass-bottom-sheet iconography aligned to the rest of the system.
- **Prayer Journal & Reading Plans:** Progress tracking with streaks, theming, and Riverpod-driven state plus quick actions on Home.
- **Security + Access Control:** Biometric auth, local data persistence, and chat lockouts triggered when message quotas are exceeded.

## Feature Flags & Configuration
- `.env` provides `GEMINI_API_KEY`; never commit secrets. Use `.env.example` as the onboarding template.
- Debug scaffolding lives behind `kDebugMode` checks; message quota bypass remains debug-only and should stay disabled in release.
- Subscription messaging counts and trial lengths are defined in `SubscriptionService` constants—coordinate product changes before editing.

## Known Gaps / Open Work
- Subscription receipts remain unvalidated; trial cancellation states and chat history lockouts still pending (`CURRENT_STATE_ANALYSIS.md`).
- Paywall polish: restructure `SubscriptionSettingsScreen` to surface free-trial CTA first, unify pricing cards, and ensure single-screen flow.
- Devotional “minutes read” badge needs higher contrast; apply the same treatment anywhere the muted pill appears.
- Profile achievements panel should report meaningful stats or be toned down until gamification tracking lands.
- Splash-to-auth transition shows inconsistent sizing on first launch—align splash artwork sizing with loading scaffold.
- Testing hygiene: only HomeScreen widget suite re-run today; broader suites (`flutter test --coverage`) remain outstanding.

## Immediate Next Steps
- Iterate on paywall layout + snackbar usage per latest product conversation, then validate the flow on iOS simulator.
- Validate the refreshed Verse Library shared-history flow (saved + shared clearing, unified icons) across phone/tablet breakpoints.
- Schedule expanded automated test run (full `flutter test`) once UI polishing tasks land, and update `status/BUILD_STATUS.md` accordingly.
- Keep this document current after each release branch cut or major architectural change; append any new findings from work logs or audits.
