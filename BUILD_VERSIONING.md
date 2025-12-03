# Build Versioning Guide

## Overview
This project uses **independent build numbers** for iOS and Android (industry standard practice for multi-platform apps).

## Current Version
- **User-facing version:** 1.0.0
- **iOS build number:** 14 (last TestFlight submission)
- **Android build number:** 20 (prepared for Play Store submission)

## Version Number Locations

### 1. User-Facing Version (pubspec.yaml)
```yaml
# pubspec.yaml
version: 1.0.0
```
- This is the version users see (e.g., "Version 1.0.0")
- Update when releasing new features or fixes
- **No build number** - platforms manage their own

### 2. iOS Build Number (Xcode)
```
File: ios/Runner.xcodeproj/project.pbxproj
Location: CURRENT_PROJECT_VERSION = 14;
```
- **Current:** 14
- Increment for each App Store Connect/TestFlight submission
- Must always increase (App Store rejects duplicate builds)
- Updated in 3 places (Debug, Release, Profile)

### 3. Android Build Number (Gradle)
```kotlin
// android/app/build.gradle.kts
versionCode = 20
versionName = "1.0.0"  // Must match pubspec.yaml
```
- **Current:** 20
- Increment for each Play Store submission
- Must always increase (Play Store rejects duplicate builds)

## Workflow for New Releases

### iOS Release (TestFlight/App Store)
1. Increment iOS build number in `project.pbxproj`:
   ```
   CURRENT_PROJECT_VERSION = 15;  // Was 14
   ```
2. Update in all 3 build configurations (Debug, Release, Profile)
3. Build: `flutter build ipa --release`
4. Upload to App Store Connect via Xcode or Transporter

### Android Release (Play Store)
1. Increment Android build number in `build.gradle.kts`:
   ```kotlin
   versionCode = 21  // Was 20
   ```
2. Build: `flutter build appbundle --release`
3. Upload to Play Console

### Both Platforms (Version Bump)
1. Update version in `pubspec.yaml`:
   ```yaml
   version: 1.1.0  # Was 1.0.0
   ```
2. Update `versionName` in Android `build.gradle.kts` to match:
   ```kotlin
   versionName = "1.1.0"
   ```
3. Follow platform-specific steps above

## Quick Reference

| Action | iOS | Android |
|--------|-----|---------|
| **Hotfix (same features)** | Build 15 | Build 21 |
| **New feature (1.1.0)** | Build 15, Version 1.1.0 | Build 21, Version 1.1.0 |
| **Major update (2.0.0)** | Build 15, Version 2.0.0 | Build 21, Version 2.0.0 |

## Why Independent Build Numbers?

✅ **Different release cycles** - iOS and Android can ship independently
✅ **Platform-specific fixes** - Android hotfix doesn't affect iOS build
✅ **Flexibility** - Each platform progresses at its own pace
✅ **Industry standard** - Used by WhatsApp, Instagram, Spotify, etc.

## Common Mistakes to Avoid

❌ Don't use `version: 1.0.0+20` in pubspec.yaml (old shared approach)
❌ Don't forget to increment build number before submission
❌ Don't use the same build number twice on same platform
❌ Don't forget to sync `versionName` with `pubspec.yaml` version

## Build Number History

### iOS (App Store Connect)
- Build 14: Last submission (Nov 25, 2025)
- Build 15: Next submission

### Android (Play Store)
- Build 20: Last submission (Dec 1, 2025)
- Build 21: Next submission

---

**Last Updated:** December 2, 2025
