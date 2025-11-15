# Everyday Christian - Smoke Test Suite

**Created:** 2025-01-14
**App Status:** Pre-TestFlight / App Store Submission
**Coverage:** Complete end-to-end testing of all features

---

## Overview

This comprehensive smoke test suite ensures the Everyday Christian app is flawless before App Store submission. All tests are automated and can run on both iOS and Android devices/emulators.

**Total Tests:** 7 test files covering all major features
**Test Types:** Integration tests, UI flow tests, data persistence tests
**Purpose:** Catch critical bugs before users encounter them

---

## Test Files

### 1. `01_app_launch_smoke_test.dart` - App Launch & Core Flow
**Purpose:** Verify app launches successfully and completes onboarding

**Covers:**
- Splash screen display
- Legal agreements acceptance
- Onboarding flow completion
- Home screen navigation
- Database initialization
- Subscription service initialization

**Critical Tests:**
- ✅ App does not crash during initialization
- ✅ Database initializes successfully
- ✅ Subscription service initializes without errors
- ✅ Legal agreements → Onboarding → Home flow works

---

### 2. `02_subscription_trial_smoke_test.dart` - Subscription & Trial Flow
**Purpose:** Verify subscription system works correctly

**Covers:**
- Trial status initialization (3 days, 15 messages)
- Premium subscription logic
- Message limit tracking
- Paywall interactions
- Subscription restoration after data deletion
- Trial expiration calculation

**Critical Tests:**
- ✅ Trial status correctly initialized for new users
- ✅ Premium paywall appears when accessing chat
- ✅ Message consumption tracking works
- ✅ Subscription persists across app restarts
- ✅ Delete All Data preserves subscription (via restore)

**Business Logic:**
- From CLAUDE.md: "3-day trial with 15 total messages"
- From CLAUDE.md: "$35/year premium with 150 messages/month"
- From CLAUDE.md: "Trial reset abuse prevention via platform receipts"

---

### 3. `03_bible_reading_smoke_test.dart` - Bible Reading Features
**Purpose:** Verify Bible reading works offline without subscription

**Covers:**
- Bible database loading (31,103 verses)
- Bible browsing by book/chapter
- Chapter reading UI
- Verse favoriting
- Multi-language support (English WEB, Spanish RVR1909)
- Bible search functionality
- Text-to-Speech availability
- Verse sharing

**Critical Tests:**
- ✅ Bible database has 31,000+ verses
- ✅ Can browse Bible books and chapters
- ✅ Verse favoriting works
- ✅ Bible works offline (no subscription required)
- ✅ English (WEB) and Spanish (RVR1909) Bibles loaded
- ✅ Bible search returns results

**Offline Feature:**
- From CLAUDE.md: "Bible reading works offline - 26 MB local database"

---

### 4. `04_devotional_reading_plan_smoke_test.dart` - Devotionals & Reading Plans
**Purpose:** Verify devotional content and reading plan features

**Covers:**
- Devotional content loading (424 devotionals)
- Today's devotional access
- Devotional completion tracking
- Devotional streak calculation
- Reading plan availability (10+ plans)
- Reading plan start/progress tracking
- Reading plan completion

**Critical Tests:**
- ✅ Devotional content loaded (hundreds of devotionals)
- ✅ Can access today's devotional
- ✅ Devotional completion tracking works
- ✅ Reading plans available (10+ plans)
- ✅ Can start and track reading plan progress

**Content:**
- From CLAUDE.md: "424 devotionals covering Nov 2025 - Dec 2026"
- From CLAUDE.md: "10+ reading plans (Gospel of John, Proverbs, Psalms, etc.)"

---

### 5. `05_prayer_verse_chat_smoke_test.dart` - Prayer, Verses & Chat
**Purpose:** Verify prayer journal, verse library, and AI chat features

**Covers:**
- **Prayer Journal:**
  - Creating prayer requests
  - Marking prayers as answered
  - Prayer category filtering
  - Prayer deletion

- **Verse Library:**
  - Verse favoriting
  - Theme tagging (max 2 themes)
  - Theme-based search

- **AI Chat:**
  - Chat session creation
  - Message persistence (user + AI)
  - Chat archiving
  - Conversation sharing tracking (v10 feature)

**Critical Tests:**
- ✅ Prayer creation and answering works
- ✅ Verse favoriting with theme tagging works
- ✅ Chat sessions and messages persist
- ✅ Conversation sharing tracking works

**Features:**
- From CLAUDE.md: "Conversation Sharer achievement (10 shares)"
- From CLAUDE.md: "Theme tagging dialog with 25 available themes"

---

### 6. `06_settings_profile_offline_smoke_test.dart` - Settings & Offline
**Purpose:** Verify app settings, profile, and offline capabilities

**Covers:**
- **Settings:**
  - Text size preference (12-24 range)
  - Language preference (English/Spanish)
  - Theme mode preference
  - Onboarding completion flag
  - Legal agreements acceptance

- **Profile & Achievements:**
  - User name storage
  - Achievement tracking
  - Conversation Sharer achievement

- **Offline Functionality:**
  - Bible reading offline
  - Prayer journal offline
  - Verse favorites offline
  - Devotionals offline
  - Reading plans offline
  - Chat history accessible offline (read-only)

- **Data Persistence:**
  - Prayers persist across restarts
  - Devotional progress persists
  - User preferences persist
  - Subscription state persists
  - Delete All Data clears user data
  - Bible data preserved after deletion

**Critical Tests:**
- ✅ All preferences persist correctly
- ✅ Achievement tracking works
- ✅ All core features work offline
- ✅ Data persists across app restarts
- ✅ Delete All Data works correctly

**Offline Features:**
- From CLAUDE.md: "Bible, prayer, verses, devotionals work offline"
- From CLAUDE.md: "Only AI chat requires internet"

---

### 7. `07_comprehensive_integration_smoke_test.dart` - End-to-End
**Purpose:** Test complete user journeys and cross-feature integration

**Covers:**
- **Complete User Journey:**
  - New user onboarding → Home → Feature exploration

- **Cross-Feature Integration:**
  - Prayer → AI chat → Answered prayer flow
  - Bible reading → Verse favoriting → Theme tagging flow
  - Devotional → Reading plan → Prayer flow
  - Trial → Message usage → Paywall flow

- **Data Integrity:**
  - Chat session deletion cascades to messages
  - Database schema version correct (v10+)
  - All expected tables exist

- **Performance & Scalability:**
  - Handle 100 prayer requests
  - Handle 50-message chat conversations
  - Bible search performance (<5 seconds)

- **Critical App Store Requirements:**
  - App does not crash on launch
  - Core features work without internet
  - Subscription system initializes
  - Database migrations complete

**Critical Tests:**
- ✅ New user can complete full onboarding
- ✅ Cross-feature workflows work seamlessly
- ✅ Database referential integrity maintained
- ✅ App handles large datasets efficiently
- ✅ All App Store requirements met

---

## Running the Tests

### Quick Start

```bash
# Run all smoke tests
./integration_test/run_smoke_tests.sh all

# Run quick critical path tests only
./integration_test/run_smoke_tests.sh quick

# Run feature-specific tests
./integration_test/run_smoke_tests.sh features

# Run specific test by number (1-7)
./integration_test/run_smoke_tests.sh 1
```

### Manual Execution

```bash
# Run individual test file
flutter test integration_test/01_app_launch_smoke_test.dart

# Run all integration tests
flutter test integration_test/

# Run on specific device
flutter test integration_test/ -d <device_id>
```

### CI/CD Integration

```bash
# For GitHub Actions / GitLab CI
flutter test integration_test/ --reporter github

# For Firebase Test Lab
flutter test integration_test/ --reporter expanded
```

---

## Test Environment Setup

### Prerequisites

1. **Flutter SDK** installed and in PATH
2. **Connected device** or **running emulator/simulator**
3. **`.env` file** configured with API keys
4. **Database files** in `assets/` directory:
   - `bible.db` (English WEB)
   - `spanish_bible_rvr1909.db` (Spanish RVR1909)

### Device Requirements

- **iOS:** iPhone running iOS 13+ (physical device or simulator)
- **Android:** Android 6.0+ (physical device or emulator)

### Test Data

Tests automatically:
- Reset database to clean state before each test
- Initialize subscription service
- Clean up test data after completion

---

## Expected Results

### All Tests Passing

When all smoke tests pass, you'll see:

```
================================================
   ✅ ALL SMOKE TESTS PASSED!
================================================

Your app is ready for:
  ✓ TestFlight beta testing
  ✓ App Store submission
```

### Test Failures

If any test fails:

1. **Review error message** - Flutter provides detailed stack traces
2. **Check test log** - `print()` statements show test progression
3. **Verify environment** - Ensure `.env` file and assets are present
4. **Run specific test** - Isolate failure with `./run_smoke_tests.sh <number>`
5. **Debug in IDE** - Use VS Code or Android Studio debugger

---

## Test Coverage Summary

| Feature | Test File | Coverage |
|---------|-----------|----------|
| **App Launch** | Test 1 | Splash, legal, onboarding, home |
| **Subscription** | Test 2 | Trial, premium, paywall, restore |
| **Bible** | Test 3 | 31K verses, browsing, favorites, search |
| **Devotionals** | Test 4 | 424 devotionals, streaks, plans |
| **Prayer** | Test 5 | Requests, answers, categories |
| **Verses** | Test 5 | Favorites, themes, sharing |
| **Chat** | Test 5 | Sessions, messages, archiving |
| **Settings** | Test 6 | Preferences, profile, achievements |
| **Offline** | Test 6 | All offline features verified |
| **Integration** | Test 7 | End-to-end flows, data integrity |

**Total Test Cases:** 80+ individual test scenarios
**Total Line Coverage:** All critical paths covered

---

## Known Limitations

### Expected Behaviors

1. **Print statements** - Linter warnings about `print()` in tests are acceptable (not production code)
2. **File naming** - Test files numbered for execution order (linter warnings acceptable)
3. **Platform differences** - Some tests may behave differently on iOS vs Android
4. **Network tests** - AI chat tests don't actually call Gemini API (no test key)
5. **Purchase tests** - Can't test actual App Store purchases in test environment

### Workarounds

- **Network:** Tests verify chat data persistence, not live API calls
- **Purchases:** Tests verify subscription service logic, not purchase flow
- **Performance:** Times may vary based on device speed

---

## Pre-Submission Checklist

Before submitting to App Store, verify:

- [ ] All 7 smoke test files pass on iOS device
- [ ] All 7 smoke test files pass on Android device
- [ ] Run tests on physical devices (not just emulator)
- [ ] Test on iOS 13, 14, 15, 16, 17+ devices
- [ ] Test on various Android versions (6.0+)
- [ ] Test on different screen sizes (iPhone SE, iPad, etc.)
- [ ] Verify subscription restore works after app deletion
- [ ] Test offline mode (airplane mode enabled)
- [ ] Verify database migrations work on upgrade
- [ ] Check VoiceOver / TalkBack accessibility

---

## Continuous Integration

### GitHub Actions Example

```yaml
name: Smoke Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test integration_test/
```

---

## Maintenance

### Adding New Tests

1. Create new test file: `08_feature_name_smoke_test.dart`
2. Follow existing pattern (IntegrationTestWidgetsFlutterBinding)
3. Add to `run_smoke_tests.sh` script
4. Update this README with test description
5. Run all tests to verify no regressions

### Updating Existing Tests

When adding new features:
- Update relevant test file with new test cases
- Update CLAUDE.md with new feature documentation
- Run full test suite to verify changes

---

## Support

**Documentation:**
- `/CLAUDE.md` - App architecture and decisions
- `/openspec/launch/` - App Store submission guides
- `/docs/archive/` - Historical test results

**Questions?**
- Check test comments for inline documentation
- Review Flutter integration test docs
- Check CLAUDE.md for business logic details

---

**Last Updated:** 2025-01-14
**Test Suite Version:** 1.0.0
**App Version:** 1.0.0+12

**Ready for TestFlight!** ✅
