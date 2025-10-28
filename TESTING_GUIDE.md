# Testing Guide - Everyday Christian App

## Overview

This guide explains how to verify that **all frontend (UI) screens are correctly bound to backend (services/database)** throughout your app.

---

## Quick Start

### 1. Run Backend Integration Tests (No Device Needed)

```bash
flutter test test/integration/user_flow_test.dart
```

**What this tests:**
- ✅ Database operations (chat, prayers, devotionals)
- ✅ Service layer logic
- ✅ Data persistence
- ✅ Cross-feature integration
- ⏱️ Fast (~10 seconds)

### 2. Run Full Screen Binding Tests (Requires Device)

```bash
# Step 1: List available devices
flutter devices

# Step 2: Copy device ID and run tests
./test_screen_bindings.sh "iPhone 16"
```

**What this tests:**
- ✅ UI elements exist on every screen
- ✅ Data displays correctly from backend
- ✅ User interactions trigger backend operations
- ✅ Navigation flows work correctly
- ✅ State management updates UI
- ⏱️ Slower (~2-3 minutes)

---

## Test Files & Structure

```
test/
├── integration/
│   ├── README.md                        # Integration test documentation
│   ├── user_flow_test.dart              # Backend service tests (496 lines)
│   └── screen_binding_verification_test.dart  # UI binding tests
│
integration_test/
└── app_test.dart                        # Full app integration test (runs on device)

test_screen_bindings.sh                  # Automated test runner script
TESTING_GUIDE.md                         # This file
```

---

## What Gets Tested

### ✅ HomeScreen
- Stats cards display data from database (streak, prayers, verses, devotionals)
- Feature cards exist and navigate correctly
- Verse of the day loads from backend
- FAB menu opens and navigates

### ✅ ChatScreen
- Message input field exists
- Send button triggers backend AI service
- Subscription info displays from SubscriptionService
- Message history loads from database
- Regenerate consumes subscription quota

### ✅ Prayer Journal
- Tab bar switches between Active/Answered/All
- FAB opens add prayer dialog
- Created prayers save to database
- Prayers appear in correct tab
- Mark answered updates database
- Filter by category queries correctly

### ✅ Verse Library
- Saved verses load from favorites table
- Search filters verses from database
- Theme tags display correctly
- Tab switching works (Saved Verses / Shared)

### ✅ Bible Browser
- Book list loads from bible.db
- Chapter navigation works
- Verse display renders correctly
- Translation toggle (KJV ↔ RVR1909)
- Favorite verse saves to database

### ✅ Settings Screen
- Theme mode toggle updates PreferencesService
- Text size slider persists to SharedPreferences
- Language selector updates app locale
- Subscription info displays from SubscriptionService
- "Delete All Data" clears database

### ✅ Profile Screen
- Profile picture loads and displays
- Edit name updates PreferencesService
- Photo upload saves correctly

---

## Running Tests

### Option 1: Automated Script (Recommended)

```bash
# Show available devices
flutter devices

# Run on iOS Simulator
./test_screen_bindings.sh "iPhone 16"

# Run on Android Emulator
./test_screen_bindings.sh "emulator-5554"

# Run on Physical Device
./test_screen_bindings.sh "00008030-001234567890123A"
```

### Option 2: Manual Commands

```bash
# Backend tests only (fast)
flutter test test/integration/user_flow_test.dart

# Screen binding tests on device
flutter test integration_test/app_test.dart --device-id="iPhone 16"
```

### Option 3: Using Flutter Drive (Advanced)

```bash
# Create test driver (if not exists)
mkdir -p test_driver
echo "import 'package:integration_test/integration_test_driver.dart';" > test_driver/integration_test.dart
echo "Future<void> main() => integrationDriver();" >> test_driver/integration_test.dart

# Run with flutter drive
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/app_test.dart \
  --device-id="iPhone 16"
```

---

## Manual Verification Checklist

If you prefer manual testing, follow this checklist:

### HomeScreen
- [ ] Streak stat shows number ≥ 0
- [ ] Prayers stat shows number ≥ 0
- [ ] Saved verses stat shows number ≥ 0
- [ ] Devotionals stat shows number ≥ 0
- [ ] Tap "Biblical Chat" → Opens ChatScreen
- [ ] Tap "Daily Devotional" → Opens DevotionalScreen
- [ ] Tap "Prayer Journal" → Opens PrayerJournalScreen
- [ ] Tap "Reading Plans" → Opens ReadingPlanScreen
- [ ] Verse of the day displays text + reference
- [ ] "Start Spiritual Conversation" button → Opens ChatScreen

### ChatScreen
- [ ] Shows "X messages remaining today/month"
- [ ] Type message → Text appears in input field
- [ ] Tap send → Message appears in history
- [ ] Subscription count decreases after send
- [ ] Tap regenerate → New AI response generated
- [ ] Regenerate consumes 1 message
- [ ] When out of messages → Paywall appears
- [ ] Trial expired → Lockout overlay appears

### Prayer Journal
- [ ] "Active" tab shows active prayers
- [ ] "Answered" tab shows answered prayers
- [ ] "All" tab shows all prayers
- [ ] Tap FAB → Add prayer dialog opens
- [ ] Create prayer → Appears in "Active" tab
- [ ] Mark prayer answered → Moves to "Answered" tab
- [ ] Filter by category → Shows only that category
- [ ] Delete prayer → Removes from list
- [ ] Swipe to delete → Works correctly

### Verse Library
- [ ] "Saved Verses" tab shows favorited verses
- [ ] "Shared" tab shows shared verses (future feature)
- [ ] Search field filters verses
- [ ] Theme filter button shows/hides themes
- [ ] Select theme → Filters verses by theme
- [ ] Tap verse → Opens verse detail

### Bible Browser
- [ ] Book list loads (Genesis visible)
- [ ] Tap Genesis → Shows 50 chapters
- [ ] Tap Chapter 1 → Shows verses 1-31
- [ ] Translation toggle → Switches KJV ↔ RVR1909
- [ ] Favorite verse → Appears in Verse Library
- [ ] Long press verse → Theme selection dialog

### Settings
- [ ] Theme Mode dropdown → Changes theme immediately
- [ ] Text size slider → Adjusts all text in app
- [ ] Language selector → Changes app language
- [ ] Subscription section → Shows correct status
- [ ] "View Subscription" → Opens PaywallScreen
- [ ] "Restore Purchases" → Works correctly
- [ ] "Delete All Data" → Shows confirmation dialog
- [ ] Delete confirmed → Clears database, resets app

### Profile
- [ ] Profile picture displays (or placeholder)
- [ ] Edit button → Opens edit mode
- [ ] Change name → Updates in PreferencesService
- [ ] Upload photo → Saves and displays
- [ ] Back button → Returns to home

---

## Test Output Examples

### ✅ Successful Test Run

```
════════════════════════════════════════════════
✅ ALL SCREEN BINDING TESTS PASSED
════════════════════════════════════════════════
✅ HomeScreen: Stats, features, verse of day
✅ ChatScreen: Input, send, subscription info
✅ Prayer Journal: Tabs, FAB, filters
✅ Verse Library: Tabs, search
✅ Bible Browser: Books, translation
✅ Settings: All sections and toggles
✅ Profile: Avatar, edit button
════════════════════════════════════════════════
```

### ❌ Failed Test Example

```
❌ Expected to find: Text "Prayers"
   But found: 0 widgets

This means: The Prayers stat card is missing or not rendering correctly.
Check: lib/screens/home_screen.dart line 161-182
```

---

## Troubleshooting

### "MissingPluginException"
**Problem:** Tests can't access native plugins (path_provider, SharedPreferences)

**Solution:** Run tests on device/simulator instead of just `flutter test`

```bash
# ❌ Won't work
flutter test integration_test/app_test.dart

# ✅ Works
flutter test integration_test/app_test.dart --device-id="iPhone 16"
```

### "TimeoutException"
**Problem:** App takes too long to initialize

**Solution:** Increase timeout in test

```dart
await tester.pumpAndSettle(const Duration(seconds: 10)); // Increase from 5 to 10
```

### "Finder found 0 widgets"
**Problem:** Widget not visible or finder incorrect

**Solutions:**
1. Use `find.textContaining()` instead of exact match
2. Check if widget is scrolled offscreen
3. Increase `pumpAndSettle` duration
4. Verify widget key/type is correct

### "Device not found"
**Problem:** Specified device ID doesn't exist

**Solution:**
```bash
# List all available devices
flutter devices

# Copy exact device ID from output
./test_screen_bindings.sh "<paste device ID here>"
```

---

## CI/CD Integration (GitHub Actions)

Add this to `.github/workflows/test.yml`:

```yaml
name: Integration Tests

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: macos-latest

    steps:
      - uses: actions/checkout@v3

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'
          channel: 'stable'

      - name: Install dependencies
        run: flutter pub get

      - name: Run backend integration tests
        run: flutter test test/integration/user_flow_test.dart

      - name: Start iOS Simulator
        run: |
          xcrun simctl boot "iPhone 16 Pro" || true
          xcrun simctl bootstatus "iPhone 16 Pro"

      - name: Run screen binding tests
        run: flutter test integration_test/app_test.dart --device-id="iPhone 16 Pro"
```

---

## Best Practices

### During Development
1. Manual testing in simulator after each feature
2. Run backend tests before committing: `flutter test test/integration/`

### Before Pull Request
1. Run full test suite: `./test_screen_bindings.sh "iPhone 16"`
2. Fix any failing tests
3. Review test output for warnings

### Before App Store Submission
1. Run tests on multiple devices (iPhone, iPad, different iOS versions)
2. Complete manual checklist above
3. Verify all data bindings work offline
4. Test subscription flows thoroughly

---

## Test Maintenance

### When to Update Tests

**Add new screen:**
- Add test case to `integration_test/app_test.dart`
- Add manual checklist item above

**Change screen layout:**
- Update finder queries if element names changed
- Re-run tests to verify still passing

**Add new feature:**
- Add backend test to `test/integration/user_flow_test.dart`
- Add UI test to `integration_test/app_test.dart`

---

## Performance Considerations

### Test Execution Times

| Test Type | Duration | Frequency |
|-----------|----------|-----------|
| Backend Integration | ~10s | Every commit |
| Screen Binding Tests | ~2-3min | Before PR |
| Manual Checklist | ~10min | Before release |

### Optimization Tips

1. **Parallel Test Execution:** Run backend tests and screen tests in parallel
2. **Selective Testing:** During dev, test only changed screens
3. **Mock Data:** Use test fixtures to speed up database operations
4. **Headless Testing:** Run Android emulator in headless mode

---

## Support & Documentation

- **Test Files:** `test/integration/README.md`
- **Code Coverage:** Run `flutter test --coverage`
- **GitHub Issues:** [Report test failures](https://github.com/your-repo/issues)

---

**Created:** October 28, 2025
**Last Updated:** October 28, 2025
**Version:** 1.0
