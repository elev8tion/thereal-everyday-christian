# Widget Setup - Quick Start (Xcode Steps)

⏱️ **Estimated Time:** 20 minutes

## What You're Adding

The Verse of the Day widget with your glassmorphic FAB menu style logo (gold border + glass container).

---

## Steps (Follow in Order)

### 1. Open Xcode
```bash
open ios/Runner.xcworkspace
```

### 2. Add Widget Extension
1. **File → New → Target**
2. Select **Widget Extension**
3. Settings:
   - Product Name: `VerseWidget`
   - Bundle ID: `com.edcfaith.EverydayChristian.VerseWidget`
   - Language: **Swift**
   - ❌ Uncheck "Include Configuration Intent"
4. Click **Finish**
5. Click **Activate** when prompted

### 3. Configure App Groups
#### Main App (Runner):
1. Select **Runner** target
2. **Signing & Capabilities** tab
3. Click **+ Capability**
4. Add **App Groups**
5. Click **+**, enter: `group.com.edcfaith.shared`

#### Widget Extension:
1. Select **VerseWidget** target
2. **Signing & Capabilities** tab
3. Click **+ Capability**
4. Add **App Groups**
5. Click **+**, enter: `group.com.edcfaith.shared` ⚠️ (SAME as main app!)

### 4. Add URL Scheme (Deep Linking)
1. Select **Runner** target
2. **Info** tab
3. Expand **URL Types**
4. Click **+**
5. Settings:
   - Identifier: `com.edcfaith.EverydayChristian`
   - URL Schemes: `edcfaith`
   - Role: **Editor**

### 5. Add App Logo to Widget
1. Select **VerseWidget/Assets.xcassets**
2. Click **+** at bottom
3. Select **Image Set**
4. Name: `AppLogo`
5. **Drag** this file from Finder into the **Any** slot:
   ```
   /Users/kcdacre8tor/thereal-everyday-christian/assets/images/logo_cropped.png
   ```
   **OR** use the iOS icon:
   ```
   ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-1024.png
   ```

### 6. Add Swift Widget Code
1. In Xcode, **right-click** on `VerseWidget` folder
2. Select **Add Files to "Runner"...**
3. Navigate to and select: `ios/VerseWidget.swift`
4. ✅ Check **VerseWidget** target (NOT Runner!)
5. Click **Add**

**Verify:** `VerseWidget.swift` should now appear under the VerseWidget folder in Xcode.

### 7. Set iOS Deployment Target
#### Runner:
1. Select **Runner** target
2. **General** tab
3. **Minimum Deployments:** iOS **16.0**

#### VerseWidget:
1. Select **VerseWidget** target
2. **General** tab
3. **Minimum Deployments:** iOS **16.0**

### 8. Test Build
1. Select **Runner** scheme (top bar)
2. Choose **iPhone 16 Pro** simulator
3. Press **⌘B** (Build)
4. ✅ Should build without errors

---

## Testing the Widget

### Add to Home Screen (Simulator)
1. Run the app (**⌘R**)
2. Press **⌘⇧H** (go to home screen)
3. **Long-press** on home screen
4. Tap **+** (top-left)
5. Search for **Everyday Christian**
6. Select **Verse of the Day**
7. Choose **Medium** size
8. Tap **Add Widget**

### Verify Widget
- ✅ Shows app logo with gold border
- ✅ Displays verse text
- ✅ Shows "John 3:16" (or current verse)
- ✅ Has "KJV" badge
- ✅ Purple gradient background

### Test Deep Link
1. **Tap** the widget
2. ✅ App should open (currently to home screen)
3. *(Deep link to Verse Library will be added next)*

---

## Troubleshooting

### Widget Not Showing in Gallery
- Verify `VerseWidget.swift` is added to **VerseWidget** target (not Runner)
- Check **VerseWidget** target membership in File Inspector

### "AppLogo" Image Not Found
- Verify `AppLogo` image set exists in `VerseWidget/Assets.xcassets`
- Check that image was added to the widget's asset catalog (not Runner's)

### App Groups Not Working
- Ensure **exact same** identifier in both targets: `group.com.edcfaith.shared`
- Check Apple Developer account is signed in (Xcode → Settings → Accounts)

### Build Errors
- Check iOS deployment target is 16.0 for both targets
- Try: **Product → Clean Build Folder** (⌘⇧K)
- Then rebuild (⌘B)

---

## What's Next?

After widget works:
1. **Deep Link Integration** - Navigate to Verse Library when tapped
2. **Testing** - Verify midnight updates work
3. **Phase 2** - Prayer Time Live Activities
4. **Phase 3** - Siri Shortcuts

---

## Files Reference

**Created:**
- `lib/services/widget_service.dart` ✅
- `lib/services/daily_verse_service.dart` ✅
- `ios/VerseWidget.swift` ✅

**Modified:**
- `pubspec.yaml` ✅
- `lib/core/providers/app_providers.dart` ✅

**Asset Needed:**
- `assets/images/logo_cropped.png` → Copy to widget

---

**Questions?** Check the full guide: `WIDGET_SETUP_GUIDE.md`
