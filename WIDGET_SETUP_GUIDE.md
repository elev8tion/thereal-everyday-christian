# iOS Widget Extension Setup Guide

This guide walks through the Xcode configuration required for Phase 1: Verse of the Day Widget.

## Prerequisites

- Xcode 15.0 or later
- iOS 16.0+ deployment target
- Apple Developer account (for App Groups capability)

---

## Step 1: Add Widget Extension Target

1. Open `/ios/Runner.xcworkspace` in Xcode
2. File → New → Target
3. Select "Widget Extension"
4. Configuration:
   - Product Name: `VerseWidget`
   - Team: [Your development team]
   - Organization Identifier: `com.edcfaith`
   - Bundle Identifier: `com.edcfaith.EverydayChristian.VerseWidget`
   - Language: Swift
   - ✅ Include Configuration Intent (not needed, uncheck)
5. Click "Finish"
6. When prompted "Activate 'VerseWidget' scheme?", click "Activate"

---

## Step 2: Configure App Groups

App Groups allow the main app and widget extension to share data.

### 2.1 Enable App Groups for Main App

1. Select **Runner** target in Xcode
2. Go to **Signing & Capabilities** tab
3. Click **+ Capability**
4. Select **App Groups**
5. Click **+** under App Groups
6. Enter: `group.com.edcfaith.shared`
7. Click **OK**

### 2.2 Enable App Groups for Widget Extension

1. Select **VerseWidget** target
2. Go to **Signing & Capabilities** tab
3. Click **+ Capability**
4. Select **App Groups**
5. Click **+** under App Groups
6. Enter: `group.com.edcfaith.shared` (same as main app!)
7. Click **OK**

---

## Step 3: Add URL Scheme for Deep Linking

### 3.1 Configure URL Types

1. Select **Runner** target
2. Go to **Info** tab
3. Expand **URL Types** section
4. Click **+** to add a new URL type
5. Configuration:
   - Identifier: `com.edcfaith.EverydayChristian`
   - URL Schemes: `edcfaith`
   - Role: Editor

---

## Step 4: Copy App Logos to Widget Target

Your app uses language-specific logos (English and Spanish). We'll add the same logo assets used by your FAB menu.

### 4.1 Add AppLogo Image Set

1. Select `VerseWidget/Assets.xcassets` in Project Navigator
2. Click **+** at bottom left
3. Select **Image Set**
4. Name it: `AppLogo`

### 4.2 Add English Logo

1. In Finder, navigate to: `/assets/images/logo_cropped.png`
2. Drag `logo_cropped.png` into the **Any** slot in the AppLogo image set

**Alternative:** You can also use the iOS app icon:
- Copy from: `/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-1024.png`

### 4.3 (Optional) Add Spanish Logo

If you want language-specific logos in the widget (currently the widget uses one logo for both languages):

1. Create a new **Image Set** named `AppLogoSpanish`
2. Drag `/assets/images/logo_spanish.png` into the **Any** slot

**Note:** The widget currently uses one logo for simplicity. If you want language-aware logos, you'll need to pass the user's language from Flutter to the widget via App Groups UserDefaults.

---

## Step 5: Update Widget Extension Info.plist

1. Select `VerseWidget/Info.plist`
2. Verify these keys exist (Xcode should have added them):
   - `NSExtension`
   - `NSExtensionPointIdentifier` = `com.apple.widgetkit-extension`
3. Add App Group configuration (if not present):
   - Right-click → Add Row
   - Key: `com.apple.security.application-groups`
   - Type: Array
   - Add item: `group.com.edcfaith.shared`

---

## Step 6: Add Widget Localizations (English & Spanish)

Your app supports English (WEB) and Spanish (RVR1909) translations. The widget needs localized strings.

### 6.1 Create English Localization

1. Right-click on **VerseWidget** folder in Xcode
2. Select **New File...**
3. Choose **Strings File**
4. Name: `Localizable.strings`
5. Click **Create**
6. Select the file, then in **File Inspector** (right panel) click **Localize...**
7. Select **English**, click **Localize**

### 6.2 Add Spanish Localization

1. With `Localizable.strings` selected
2. In **File Inspector**, under **Localization**, click **+**
3. Select **Spanish (es)**, click **Finish**

### 6.3 Add Localized Content

#### English Version (en):
Open `en.lproj/Localizable.strings` and add:
```strings
"verseOfTheDay" = "Verse of the Day";
"widgetDescription" = "Daily inspirational Bible verse on your home screen.";
```

#### Spanish Version (es):
Open `es.lproj/Localizable.strings` and add:
```strings
"verseOfTheDay" = "Versículo del Día";
"widgetDescription" = "Versículo bíblico inspirador diario en tu pantalla de inicio.";
```

**See `ios/WidgetLocalizations.md` for detailed localization instructions.**

---

## Step 7: Configure iOS Deployment Target

### 7.1 Set Minimum iOS Version

1. Select **Runner** target
2. Go to **General** tab
3. Set **Minimum Deployments** to **iOS 16.0**

4. Select **VerseWidget** target
5. Go to **General** tab
6. Set **Minimum Deployments** to **iOS 16.0**

---

## Step 8: Verify Xcode Configuration

### Checklist

- [ ] VerseWidget extension target created
- [ ] App Groups enabled on Runner target: `group.com.edcfaith.shared`
- [ ] App Groups enabled on VerseWidget target: `group.com.edcfaith.shared`
- [ ] URL scheme added to Runner: `edcfaith://`
- [ ] App logo added to VerseWidget/Assets.xcassets
- [ ] Localizable.strings added with English & Spanish translations
- [ ] iOS deployment target = 16.0 for both targets
- [ ] Xcode can build both Runner and VerseWidget without errors

---

## Step 8: Test Build

1. Select **Runner** scheme in Xcode
2. Choose iOS simulator (iPhone 15 Pro or newer)
3. Build (⌘B)
4. Verify no compilation errors

---

## Next Steps

After completing this Xcode setup:

1. **Day 2:** Implement Swift code for widget timeline provider
2. **Day 2:** Add method channel in AppDelegate for Flutter ↔ Swift communication
3. **Day 3:** Create SwiftUI widget view
4. **Day 3:** Test widget on device home screen

---

## Troubleshooting

### App Groups Not Showing Up

- Ensure you're logged into your Apple Developer account in Xcode
- Xcode → Settings → Accounts → [Your Team]
- Download Manual Profiles if needed

### Widget Extension Won't Build

- Check that all Swift files have VerseWidget target membership
- Target Membership: Select file → File Inspector → Target Membership → ✅ VerseWidget

### Deep Linking Not Working

- Verify URL scheme is added to **Runner** target (not VerseWidget)
- Test with: `xcrun simctl openurl booted edcfaith://verse/daily`

---

## File Structure After Setup

```
ios/
├── Runner/
│   ├── AppDelegate.swift
│   ├── Assets.xcassets/
│   │   └── AppIcon.appiconset/
│   └── Info.plist (URL scheme added)
├── Runner.xcodeproj/
└── VerseWidget/                    # NEW
    ├── VerseWidget.swift           # Will create in Day 2
    ├── VerseWidgetBundle.swift     # Auto-generated
    ├── Assets.xcassets/
    │   └── AppLogo.imageset/       # App logo copied here
    └── Info.plist
```

---

## Summary

You've now completed the Xcode foundation for the Verse of the Day widget!

**What's configured:**
- ✅ Widget extension target
- ✅ App Groups for data sharing
- ✅ URL scheme for deep linking
- ✅ App logo asset in widget
- ✅ iOS 16.0 minimum deployment target

**Ready for Day 2:** Swift code implementation and Flutter integration.
