# How to Submit App with In-App Purchases for First Time

Based on Apple's requirements and App Store Connect API limitations.

## Important Discovery

**The App Store Connect API does NOT have an endpoint to attach subscriptions to app versions.**

Subscriptions are managed at the **app level**, not the **version level**. When you submit your app for the first time with IAPs, you must:

1. Create the subscriptions (already done ✅)
2. Submit the subscriptions for review **together with your app version** via the UI

## Current Status

✅ **Subscriptions Created:**
- Premium Annual (`everyday_christian_premium_yearly`) - Level 1
- Premium Monthly (`everyday_christian_premium_monthly`) - Level 2

⚠️ **Status:** "Waiting for Review" - Not yet submitted

⚠️ **Localizations:** "Prepare for Submission" - Not ready

## Steps to Submit (MUST DO IN UI)

### Step 1: Complete Subscription Localizations

For EACH subscription (Premium Annual AND Premium Monthly):

1. Go to **App Store Connect** → **My Apps** → **Everyday Christian**
2. Click **In-App Purchases** (left sidebar)
3. Click **Subscriptions**
4. Click on **Premium Annual**
5. For each localization (English, Spanish Mexico, Spanish Spain):
   - Verify **Display Name** is set
   - Verify **Description** is set (should say "150 messages monthly...")
   - Verify **Screenshot** is uploaded (if required)
6. Click **Save**
7. Click **Submit for Review** button
8. Repeat for **Premium Monthly**

### Step 2: Attach Subscriptions to App Version (UI ONLY)

1. Go to **App Store** tab (left sidebar)
2. Click on version **1.0** (your current version in "Prepare for Submission")
3. Scroll down to **"In-App Purchases and Subscriptions"** section
4. Click the **+ button**
5. **Select BOTH subscriptions:**
   - ✅ Premium Annual
   - ✅ Premium Monthly
6. Click **Done**
7. Verify both appear in the list

### Step 3: Submit App for Review

1. Still on the App Store → Version 1.0 page
2. Fill in any remaining required fields:
   - ✅ Screenshots
   - ✅ Description
   - ✅ Keywords
   - ✅ Privacy Policy URL
   - ✅ Build (select your uploaded build)
3. Scroll to bottom
4. Click **Add for Review** (or **Submit for Review**)

## What This Means

- **First submission:** Subscriptions MUST be included with your app binary
- **After approval:** You can submit new subscriptions independently
- **No API automation:** This step cannot be automated with Fastlane/API

## Alternative: Use Fastlane to Submit (But Still Need UI for IAPs)

You can use Fastlane to submit the app, but you MUST manually attach IAPs in the UI first:

```bash
# 1. Manually attach IAPs in App Store Connect UI (steps above)
# 2. Then run Fastlane to submit:
cd ios
fastlane submit
```

## Why the API Doesn't Support This

From the API specification (`docs/api/app-store-connect-api.oas.json`):

- `/v1/appStoreVersions/{id}/relationships/*` - NO subscription endpoint exists
- `/v1/apps/{id}/subscriptionGroups` - Subscriptions are managed at APP level
- Subscriptions are NOT version-specific resources

Apple requires the first IAP submission to go through their review UI to ensure proper setup.

## Next Actions

**You need to:**

1. **Open App Store Connect in browser**
2. **Complete Step 1:** Submit subscription localizations for review
3. **Complete Step 2:** Attach subscriptions to version 1.0
4. **Complete Step 3:** Submit version 1.0 for review

**Then optionally:**
- Use Fastlane for future updates: `fastlane submit`

---

**Created:** 2025-12-23
**Reason:** App Store Connect API has no endpoint to attach IAPs to versions programmatically
