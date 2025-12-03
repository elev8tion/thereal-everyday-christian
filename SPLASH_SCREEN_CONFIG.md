# Splash Screen Configuration

This document explains the platform-specific splash screen configuration to prevent accidental changes.

## ⚠️ IMPORTANT: Platform-Specific Splash Screens

**iOS** and **Android** have DIFFERENT splash screen configurations by design. Do NOT run `flutter pub run flutter_native_splash:create` without understanding the consequences, as it will overwrite platform-specific settings.

---

## iOS Configuration

### Native Launch Screen
**Location:** `ios/Runner/Assets.xcassets/LaunchBackground.imageset/background.png`

**Configuration:**
- Uses **gradient background image** (491KB, 1290x2796px)
- Gradient colors: Navy (#1A1A2E) → Indigo → Purple → Deep Blue (#0F3460)
- Matches the app's `GradientBackground` widget for seamless transition

**DO NOT:**
- Replace with solid color
- Change to purple (#6B5FCF)
- Regenerate using flutter_native_splash (will overwrite with solid color)

**To Restore (if accidentally changed):**
```bash
git show 9d068f2:ios/Runner/Assets.xcassets/LaunchBackground.imageset/background.png > ios/Runner/Assets.xcassets/LaunchBackground.imageset/background.png
```

---

## Android Configuration

### Android 12+ Splash Screen
**Location:** `android/app/src/main/res/values-v31/styles.xml`

**Configuration:**
```xml
<item name="android:windowSplashScreenBackground">#6B5FCF</item>
<item name="android:windowSplashScreenIconBackgroundColor">#6B5FCF</item>
```

**Colors:**
- Background: Purple `#6B5FCF` (matches app icon)
- Icon background: Purple `#6B5FCF`

**DO NOT:**
- Change to gradient (Android doesn't support it well)
- Change to dark navy (#1A1A2E)
- Use background image (causes issues on some devices)

---

## flutter_native_splash.yaml

**Current Configuration:**
```yaml
flutter_native_splash:
  image: assets/images/logo_transparent.png
  background_image: assets/images/gradient_background.png
  color: "#1A1A2E"  # Fallback for iOS

  android_12:
    image: assets/images/logo_transparent.png
    color: "#1A1A2E"  # This gets overridden by styles.xml
    icon_background_color: "#1A1A2E"

  ios: true
  android: true
  web: false
  fullscreen: true
```

**⚠️ WARNING:**
- The `color` values in this file are fallbacks
- Android 12+ uses `styles.xml` for actual purple color
- iOS uses the gradient background image
- Running `flutter pub run flutter_native_splash:create` will:
  - ✅ Correctly update iOS with gradient
  - ❌ INCORRECTLY change Android to dark navy (must restore manually)

---

## Manual Configuration Steps

### If you need to regenerate splash screens:

1. **Run flutter_native_splash:**
   ```bash
   flutter pub run flutter_native_splash:create
   ```

2. **Restore Android purple colors:**
   ```bash
   git restore android/app/src/main/res/values-v31/styles.xml
   git restore android/app/src/main/res/values-night-v31/styles.xml
   ```

3. **Verify iOS gradient:**
   ```bash
   ls -lh ios/Runner/Assets.xcassets/LaunchBackground.imageset/background.png
   # Should be ~491KB, not 69 bytes
   ```

4. **If iOS was changed to solid color, restore it:**
   ```bash
   git show 9d068f2:ios/Runner/Assets.xcassets/LaunchBackground.imageset/background.png > ios/Runner/Assets.xcassets/LaunchBackground.imageset/background.png
   ```

---

## Summary

| Platform | Splash Type | Color/Image | File Location |
|----------|-------------|-------------|---------------|
| **iOS** | Native Launch | Gradient Image | `ios/Runner/Assets.xcassets/LaunchBackground.imageset/background.png` |
| **iOS** | Flutter Splash | Gradient Widget | `lib/components/gradient_background.dart` |
| **Android** | Native Splash | Purple #6B5FCF | `android/app/src/main/res/values-v31/styles.xml` |
| **Android** | Flutter Splash | Gradient Widget | `lib/components/gradient_background.dart` |

---

## Git Commits Reference

- **9d068f2** - Original iOS gradient background implementation (good reference)
- **96c7c65** - Purple splash for both platforms (broke iOS gradient)
- **7ba0709** - Restored iOS gradient, kept Android purple (current correct state)

---

## Testing

### iOS:
1. Clean build: `flutter clean`
2. Delete app from simulator
3. Run: `flutter run -d <ios-device>`
4. **Expected:** Gradient background from app icon tap through to home screen

### Android:
1. Clean build: `flutter clean`
2. Uninstall app from device
3. Run: `flutter run -d <android-device>`
4. **Expected:** Purple background on Android 12+ splash, then gradient Flutter splash
