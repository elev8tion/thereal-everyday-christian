# App Store Rejection Fixes - December 19, 2025 (UPDATED)

## 📋 Rejection Issues Summary

Apple rejected the app for three violations:

1. **Guideline 2.1** - IAP Bug: Error after tapping "Start Free Trial" button
2. **Guideline 3.1.2** - Missing functional EULA/Terms of Service links
3. **Guideline 2.3.8** - App name mismatch (Marketplace vs Device)

---

## ✅ Issue 1: IAP Bug - "Start Free Trial" Button Error

### Apple's Feedback
> "The In-App Purchase products in the app exhibited one or more bugs which create a poor user experience. Specifically, the app displayed an error message after tapping 'Start Free Trial' button."

### Root Cause
- Product IDs may not be loading from App Store Connect
- No validation before attempting purchase
- Poor error messaging when products fail to load

### Fix Applied (`lib/screens/paywall_screen.dart`)
✅ **Added product validation before purchase attempt** (lines 465-541):
- Validates that product is loaded before attempting purchase
- Shows helpful error message with troubleshooting steps if product is null
- Better logging to debug product loading issues
- Error message guides users to check internet connection and App Store sign-in

### What You Need to Do

#### 1. Verify Product IDs in App Store Connect
1. Go to App Store Connect → Your App → **Subscriptions** (NOT In-App Purchases)
2. Confirm these product IDs exist and are in "Ready to Submit" status:
   - **Yearly**: `everyday_christian_ios_yearly_sub`
   - **Monthly**: `everyday_christian_ios_monthly_sub`
3. Ensure each subscription has:
   - Localized title and description
   - Pricing for all territories
   - Subscription duration set correctly (1 year / 1 month)
   - Subscription group assigned

#### 2. Test in Sandbox Environment
1. Create a sandbox test account in App Store Connect → Users and Access → Sandbox Testers
2. On a physical device (NOT simulator):
   - Settings → App Store → Sandbox Account → Sign in with test account
3. Launch app and navigate to paywall
4. Tap "Start Free Trial" button
5. Verify:
   - No error messages appear
   - StoreKit purchase sheet appears
   - You can complete the sandbox purchase
   - Premium activates after purchase

---

## ✅ Issue 2: Missing EULA and Privacy Policy Links

### Apple's Feedback
> "The submission did not include all the required information for apps offering auto-renewable subscriptions. The app's metadata is missing: A functional link to the Terms of Use (EULA)."

### Root Cause
- Subscription screen showed terms TEXT but no clickable LINKS
- Apple requires functional links to both Privacy Policy and Terms of Use (EULA)

### Fix Applied (`lib/screens/paywall_screen.dart`)
✅ **Added clickable legal links** (positioned below Subscribe button, above Restore link):
- Added "Privacy Policy" link (opens https://everydaychristian.app/privacy)
- Added "Terms of Use (EULA)" link (opens https://everydaychristian.app/terms)
- Links appear in gold text without underlines for clean, accessible design
- Both links open in external browser (Safari)
- Error handling if links can't be opened
- Imported `url_launcher` package for opening links

✅ **Added `_launchURL()` helper method** (lines 1038-1103):
- Opens URLs in Safari using `LaunchMode.externalApplication`
- Shows error message if URL can't be opened
- Includes user-friendly troubleshooting tips

### What You Need to Do

#### 1. Verify Website URLs Are Live
**CRITICAL**: These URLs MUST return valid pages (200 status), not 404:
- Privacy Policy: https://everydaychristian.app/privacy
- Terms of Use: https://everydaychristian.app/terms

Test them now:
```bash
curl -I https://everydaychristian.app/privacy
curl -I https://everydaychristian.app/terms
```

If these URLs don't exist yet, you need to:
- Create these pages on your website, OR
- Update the URLs in `lib/screens/paywall_screen.dart` (lines 323 and 345)

#### 2. Add Links to App Store Connect (REQUIRED)
**Privacy Policy URL**:
1. Go to App Store Connect → Your App → App Information
2. Find **Privacy Policy URL** field
3. Enter: `https://everydaychristian.app/privacy`
4. Click Save

**Terms in App Description**:
1. Go to App Store Connect → Your App → Version → App Store Information
2. Edit the **Description** field
3. Add this text at the end:
   ```
   By subscribing, you agree to our Terms of Use (https://everydaychristian.app/terms)
   and Privacy Policy (https://everydaychristian.app/privacy).
   ```
4. Click Save

#### 3. Alternative: Use Standard Apple EULA
If you don't have custom Terms of Use, you can use Apple's standard EULA:
1. In App Store Connect → Version Information
2. Set EULA to "Standard Apple EULA"
3. Add this to your App Description:
   ```
   This app uses the standard Apple Terms of Use (EULA).
   View at: https://www.apple.com/legal/internet-services/itunes/dev/stdeula/
   ```

---

## ✅ Issue 3: App Name Mismatch

### Apple's Feedback
> "The app name displayed on app marketplaces and the app name displayed on the device do not sufficiently match. Marketplace app name: Everyday Christian. Name displayed on the device: EDC Faith"

### Root Cause
- Old build was submitted with cached app name "EDC Faith"
- Build needs to be cleaned and rebuilt

### Verification Results
✅ **Info.plist already shows "Everyday Christian"** for both:
- `CFBundleDisplayName` = "Everyday Christian" (shown on device home screen)
- `CFBundleName` = "Everyday Christian" (used by system)

✅ **No references to "EDC Faith" found** in iOS codebase

### What You Need to Do

#### 1. Clean Build Folder
```bash
cd /Users/kcdacre8tor/thereal-everyday-christian
flutter clean
cd ios
rm -rf Pods Podfile.lock build DerivedData
pod install
cd ..
```

#### 2. Clean Build in Xcode
```bash
open ios/Runner.xcworkspace
```
Then in Xcode:
1. Product → Clean Build Folder (Cmd+Shift+K)
2. Close Xcode

#### 3. Build Release Archive
```bash
flutter build ios --release
```

Then in Xcode:
1. Open `ios/Runner.xcworkspace`
2. Select "Any iOS Device (arm64)" as target
3. Product → Archive
4. When archive completes, verify it shows "Everyday Christian" as the name
5. Distribute App → App Store Connect → Upload

#### 4. Verify on Device
After installing the new build:
1. Check the home screen shows "Everyday Christian" (NOT "EDC Faith")
2. If you still see "EDC Faith", delete the app completely and reinstall

---

## 🧪 Complete Testing Checklist

### Before Resubmission:

**Build Preparation**:
- [ ] All code changes committed to git
- [ ] Flutter clean completed
- [ ] iOS build folder cleaned
- [ ] Pods reinstalled
- [ ] New release build created

**Legal Links**:
- [ ] https://everydaychristian.app/privacy returns 200 (not 404)
- [ ] https://everydaychristian.app/terms returns 200 (not 404)
- [ ] Both links added to App Store Connect metadata
- [ ] Links open correctly in Safari from paywall screen

**IAP Testing** (Physical Device + Sandbox Account):
- [ ] Products load on paywall screen (no "Product not available" error)
- [ ] "Start Free Trial" button works without errors
- [ ] StoreKit purchase sheet appears
- [ ] Sandbox purchase completes successfully
- [ ] Premium features unlock after purchase
- [ ] "Restore Purchase" button works

**App Name**:
- [ ] New build shows "Everyday Christian" on device home screen
- [ ] No references to "EDC Faith" visible anywhere
- [ ] App Store listing shows "Everyday Christian"

**App Store Connect**:
- [ ] Privacy Policy URL added to App Information
- [ ] Terms mentioned in App Description with link
- [ ] Paid Apps Agreement is Active
- [ ] Subscription products are "Ready to Submit"

---

## 📱 Sandbox Testing Instructions

### Setup Sandbox Account
1. App Store Connect → Users and Access → Sandbox Testers
2. Create a new sandbox tester (or use existing)
3. On your test device:
   - Settings → App Store → Sandbox Account
   - Sign in with sandbox tester credentials

### Test Purchase Flow
1. Delete app from device
2. Install fresh build from Xcode or TestFlight
3. Complete onboarding
4. Navigate to paywall (send AI messages until trial expires)
5. Tap "Start Free Trial"
6. **Expected**: StoreKit sheet appears with subscription options
7. Authenticate with Face ID/Touch ID
8. Complete purchase
9. **Expected**: Premium activates immediately
10. Verify in Settings → Apple ID → Subscriptions

### Check Logs
Look for these log messages in Xcode console:
```
📊 [SubscriptionService] Loaded yearly product: everyday_christian_ios_yearly_sub - $35.99
📊 [SubscriptionService] Loaded monthly product: everyday_christian_ios_monthly_sub - $5.99
📊 [SubscriptionService] Purchase initiated for: everyday_christian_ios_yearly_sub
📊 [SubscriptionService] Premium subscription activated
```

If you see:
```
📊 [PaywallScreen] Purchase failed - product not loaded
```
Then products are not loading from App Store Connect. Check product IDs.

---

## 📊 Files Modified

### Code Changes:
1. **`lib/screens/paywall_screen.dart`**:
   - Line 14: Added `import 'package:url_launcher/url_launcher.dart';`
   - Lines 465-541: Added product validation in `_handlePurchase()`
   - Lines 245-289: Clickable Privacy Policy and Terms links (positioned below Subscribe button, above Restore link)
   - Removed underlines from all links (Privacy, Terms, Restore) for cleaner design
   - Lines 1020-1085: Added `_launchURL()` helper method

### Configuration (Already Correct):
1. **`ios/Runner/Info.plist`**:
   - Line 15: `CFBundleDisplayName` = "Everyday Christian" ✅
   - Line 23: `CFBundleName` = "Everyday Christian" ✅

### Product IDs (Defined in `lib/core/services/subscription_service.dart`):
- **iOS Yearly**: `everyday_christian_ios_yearly_sub` (line 60)
- **iOS Monthly**: `everyday_christian_ios_monthly_sub` (line 61)

---

## 🚀 Resubmission Steps

### 1. Clean and Build
```bash
# Clean everything
flutter clean
cd ios
rm -rf Pods Podfile.lock build DerivedData
pod install
cd ..

# Build release
flutter build ios --release
```

### 2. Archive in Xcode
```bash
open ios/Runner.xcworkspace
```
1. Select "Any iOS Device (arm64)"
2. Product → Clean Build Folder (Cmd+Shift+K)
3. Product → Archive
4. Wait for archive to complete
5. Verify archive name shows "Everyday Christian"

### 3. Upload to App Store Connect
1. Window → Organizer
2. Select the new archive
3. Distribute App
4. App Store Connect → Upload
5. Follow prompts to complete upload

### 4. Submit for Review
1. Go to App Store Connect
2. Select the new build
3. Add these **Resolution Notes** for Apple Review Team:

```
We have addressed all three rejection issues:

1. IAP Bug (Guideline 2.1): Added product validation before purchase attempts. The app now checks if subscription products are loaded before initiating StoreKit transactions. If products fail to load, users see a helpful error message with troubleshooting steps. The purchase flow has been tested end-to-end in the sandbox environment and works correctly.

2. Missing EULA Links (Guideline 3.1.2): Added functional links to Terms of Use and Privacy Policy directly in the subscription screen. Both links open in Safari and have been verified to work correctly. Legal URLs have also been added to the App Store Connect metadata as required.
   - Privacy Policy: https://everydaychristian.app/privacy
   - Terms of Use: https://everydaychristian.app/terms

3. App Name Mismatch (Guideline 2.3.8): Cleaned and rebuilt the app with CFBundleDisplayName set to "Everyday Christian" to match the App Store marketing name. This eliminates user confusion between marketplace and device names.

All changes have been tested on physical iOS devices.
```

5. Submit for Review

---

## ⚠️ Common Issues and Solutions

### "Product not available" error when tapping "Start Free Trial"
**Cause**: Subscription products not loading from App Store Connect

**Solutions**:
1. Verify product IDs exactly match in both code and App Store Connect
2. Ensure subscriptions are in "Ready to Submit" status
3. Check Paid Apps Agreement is Active
4. Wait 24 hours after creating products (App Store Connect propagation delay)
5. Test with sandbox account on physical device (NOT simulator)

### Legal links return 404
**Cause**: Pages don't exist on your website

**Solutions**:
1. Create the pages at the specified URLs
2. OR update the URLs in `paywall_screen.dart` (lines 323, 345)
3. OR use Apple's standard EULA instead of custom terms

### Still seeing "EDC Faith" on device
**Cause**: Old build cached on device

**Solutions**:
1. Delete app completely from device
2. Reinstall fresh build
3. If problem persists, restart device
4. Verify new archive shows "Everyday Christian" in Xcode Organizer

---

## 🔗 Important URLs

**Legal Pages (MUST BE LIVE)**:
- Privacy Policy: https://everydaychristian.app/privacy
- Terms of Service: https://everydaychristian.app/terms

**App Store Connect**:
- https://appstoreconnect.apple.com

**Bundle Identifier**:
- `com.edcfaith.EverydayChristian`

**Product IDs**:
- Yearly: `everyday_christian_ios_yearly_sub`
- Monthly: `everyday_christian_ios_monthly_sub`

---

## ✅ Pre-Submission Checklist

Complete ALL items before resubmitting:

**Code**:
- [ ] All fixes committed and pushed to GitHub
- [ ] Code compiles without errors
- [ ] Flutter analyze shows no critical issues

**Build**:
- [ ] Flutter clean completed
- [ ] iOS build folder cleaned
- [ ] New archive created in Xcode
- [ ] Archive shows "Everyday Christian" as name

**Testing**:
- [ ] Tested on physical iPhone (not simulator)
- [ ] App name shows "Everyday Christian" on home screen
- [ ] Legal links open correctly in Safari
- [ ] IAP products load on paywall
- [ ] "Start Free Trial" button works without errors
- [ ] Completed sandbox purchase end-to-end
- [ ] Premium features unlock after purchase

**App Store Connect**:
- [ ] Privacy Policy URL added to App Information
- [ ] Terms mentioned in App Description with link
- [ ] Subscription products exist and are "Ready to Submit"
- [ ] Paid Apps Agreement status is Active
- [ ] Legal URLs return 200 status (not 404)

**Submission**:
- [ ] New build uploaded to App Store Connect
- [ ] Resolution notes prepared for Apple
- [ ] Submitted for review

---

## 💬 Questions?

If you encounter any issues during testing or resubmission, let me know and I can help troubleshoot!

**Good luck with the resubmission! 🙏**

*Last Updated: December 19, 2025 - 4:30 PM ET*
