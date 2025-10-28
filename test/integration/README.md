# Integration Tests - Screen Binding Verification

## Overview

These tests verify that **all frontend UI elements are correctly bound to backend services** across every screen in the app.

## Test Types

### 1. Service Integration Tests (`user_flow_test.dart`)
- ✅ Tests backend logic and data flow
- ✅ Runs without device/simulator
- ✅ Fast execution (~10 seconds)
- ❌ Doesn't test UI screens

**Run:** `flutter test test/integration/user_flow_test.dart`

### 2. Screen Binding Tests (`screen_binding_verification_test.dart`)
- ✅ Tests UI → Backend binding
- ✅ Navigates through all screens
- ✅ Verifies data displays correctly
- ⚠️ Requires device or simulator
- ⏱️ Slower execution (~2-3 minutes)

**Run:** `flutter test test/integration/screen_binding_verification_test.dart --device-id=<device-id>`

## How to Run Full Screen Binding Tests

### Option 1: Using iOS Simulator (Recommended)

```bash
# 1. List available simulators
flutter devices

# 2. Copy the device ID (example: "iPhone 15 Pro" simulator ID)

# 3. Run tests on simulator
flutter test integration_test/app_test.dart --device-id=<device-id>
```

### Option 2: Using Android Emulator

```bash
# 1. Start emulator
emulator -avd Pixel_6_API_34

# 2. List devices
flutter devices

# 3. Run tests
flutter test integration_test/app_test.dart --device-id=<device-id>
```

### Option 3: Using Physical Device

```bash
# 1. Connect device via USB
# 2. Enable developer mode (iOS) or USB debugging (Android)
# 3. Run: flutter devices
# 4. Run tests with device ID
```

## Alternative: Manual Screen Verification Checklist

If you want to quickly verify screen bindings manually, use this checklist:

### HomeScreen
- [ ] Streak stat displays number (data binding works)
- [ ] Prayers stat displays number
- [ ] Saved verses stat displays number
- [ ] Devotionals stat displays number
- [ ] Tap "Biblical Chat" → Navigates to ChatScreen
- [ ] Verse of the day loads and displays

### ChatScreen
- [ ] Subscription info shows "X messages remaining"
- [ ] Type message → Send button enables
- [ ] Send message → Message appears in history
- [ ] Send message → Subscription count decreases

### Prayer Journal
- [ ] Tap FAB → Add prayer dialog opens
- [ ] Create prayer → Appears in list
- [ ] Mark prayer answered → Moves to "Answered" tab
- [ ] Delete prayer → Removes from list
- [ ] Filter by category → Shows only matching prayers

### Verse Library
- [ ] "Saved Verses" tab shows favorited verses
- [ ] Search field filters verses
- [ ] Tap verse → Opens verse detail
- [ ] Theme filter works

### Bible Browser
- [ ] Book list loads (Genesis visible)
- [ ] Tap book → Shows chapters
- [ ] Tap chapter → Shows verses
- [ ] Favorite verse → Appears in Verse Library
- [ ] Translation toggle works (KJV ↔ RVR1909)

### Settings Screen
- [ ] Theme mode toggle works (Light/Dark/System)
- [ ] Text size slider adjusts text
- [ ] Language selector changes language
- [ ] Subscription info displays correctly
- [ ] "Delete All Data" works

### Profile Screen
- [ ] Profile picture displays
- [ ] Edit name works
- [ ] Upload photo works

## What These Tests Verify

### ✅ Data Binding
- UI elements display backend data correctly
- User actions trigger backend operations
- Backend changes reflect in UI immediately

### ✅ Navigation Flow
- All navigation routes work
- Deep linking works
- Back navigation preserves state

### ✅ State Management
- Riverpod providers update correctly
- UI rebuilds when data changes
- No stale data displayed

### ✅ Error Handling
- Network errors show user-friendly messages
- Loading states display correctly
- Empty states handled gracefully

## CI/CD Integration

To run these tests in CI/CD (GitHub Actions, etc.):

```yaml
name: Integration Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test test/integration/user_flow_test.dart

      # Screen binding tests (requires simulator)
      - name: Start iOS Simulator
        run: |
          xcrun simctl boot "iPhone 15 Pro"

      - name: Run Screen Binding Tests
        run: flutter test integration_test/app_test.dart
```

## Troubleshooting

### "MissingPluginException"
- **Cause:** Tests need native plugins (path_provider, shared_preferences)
- **Fix:** Run tests on device/simulator instead of just `flutter test`

### "TimeoutException"
- **Cause:** App initialization takes too long
- **Fix:** Increase timeout in test: `await tester.pumpAndSettle(const Duration(seconds: 10))`

### "Finder found 0 widgets"
- **Cause:** Widget not visible or wrong finder used
- **Fix:** Use `find.textContaining()` instead of exact match, or check if widget is scrolled offscreen

## Recommended Testing Workflow

1. **During Development:** Manual testing in simulator
2. **Before Commit:** Run `flutter test test/integration/user_flow_test.dart`
3. **Before PR:** Run full screen binding tests on device
4. **Before Release:** Full manual checklist + automated tests

---

**Created:** October 28, 2025
**Last Updated:** October 28, 2025
