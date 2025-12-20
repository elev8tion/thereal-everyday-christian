# 🚨 Quick Rejection Check Guide

Your API key is ready! Here's how to check your rejections:

## Step 1: Get Your Issuer ID

1. Visit: https://appstoreconnect.apple.com/access/api
2. Look for **"Issuer ID"** at the top of the page (UUID format like `12345678-1234-1234-1234-123456789012`)
3. Copy it

## Step 2: Run the Query Script

```bash
cd /Users/kcdacre8tor/thereal-everyday-christian/ios/fastlane
ruby query_app_store.rb
```

When prompted, paste your Issuer ID.

## What You'll See

The script will show:
- ✅ Current app status
- ✅ Live version (if any)
- ✅ Version in review or rejected
- ✅ **Rejection details** (if rejected)
- ✅ TestFlight builds
- ✅ In-App Purchases / Subscriptions configured
- ✅ Subscription product IDs and statuses

## Alternative: Use Fastlane Directly

If the Ruby script doesn't work, use Fastlane:

```bash
cd /Users/kcdacre8tor/thereal-everyday-christian/ios

# Replace YOUR_ISSUER_ID with actual Issuer ID
fastlane run deliver \
  api_key_path:"~/private_keys/AuthKey_T9L7G79827.p8" \
  issuer_id:"YOUR_ISSUER_ID" \
  key_id:"T9L7G79827" \
  app_identifier:"com.elev8tion.everydaychristian"
```

## Files Created

✅ API Key: `~/private_keys/AuthKey_T9L7G79827.p8`  
✅ Query Script: `fastlane/query_app_store.rb`  
✅ Key ID: `T9L7G79827`

## Need Help?

If you get errors:
1. Verify API key has **Admin** or **App Manager** role
2. Check Issuer ID is correct (from https://appstoreconnect.apple.com/access/api)
3. Ensure API key file exists: `ls -l ~/private_keys/AuthKey_T9L7G79827.p8`
