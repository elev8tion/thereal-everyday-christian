# Sandbox Testing Guide - Everyday Christian

## Quick Start

Run the automated helper:
```bash
cd /Users/kcdacre8tor/thereal-everyday-christian/ios/fastlane
./setup_sandbox_testing.sh
```

This will:
- Open App Store Connect Sandbox page
- Guide you through account creation
- Provide testing credentials
- Show step-by-step testing instructions

---

## Manual Setup (If Script Doesn't Work)

### 1. Create Sandbox Test Account

**URL:** https://appstoreconnect.apple.com/access/testers

1. Click **Users and Access** (left sidebar)
2. Click **Sandbox** tab
3. Click **+** button
4. Fill in:
   - First Name: `Test`
   - Last Name: `User`
   - Email: `testuser+everyday1@gmail.com`
   - Password: `TestPass123!` (or your choice)
   - Region: `United States`
5. Click **Invite**

**Save these credentials!**

### 2. Sign Out of Real Apple ID

**On iPhone/iPad:**
1. Settings > App Store
2. Tap your Apple ID at top
3. Tap **Sign Out**

**CRITICAL:** Only sign out of App Store, NOT iCloud!

### 3. Install TestFlight Build

1. Open TestFlight app
2. Find "Everyday Christian"
3. Tap **Install** on build 2
4. Wait for download

### 4. Test In-App Purchase

1. Open Everyday Christian from TestFlight
2. Navigate to subscription/premium screen
3. Tap a subscription (yearly or monthly)
4. App Store dialog appears
5. **Sign in with Sandbox account:**
   - Email: `testuser+everyday1@gmail.com`
   - Password: `TestPass123!`
6. Look for **"Environment: Sandbox"** banner
7. Tap **Subscribe**
8. Purchase completes instantly

### 5. Verify Purchase

**In App:**
- Premium features should unlock
- AI chat shows unlimited messages
- No ads or limitations

**In Settings:**
1. Settings > App Store > Manage Subscriptions
2. Should show "Everyday Christian" subscription
3. Status: Active

---

## Testing Scenarios

### Scenario 1: New User Purchase
1. Fresh install from TestFlight
2. Complete onboarding
3. Tap "Upgrade to Premium"
4. Purchase with Sandbox account
5. Verify features unlock

### Scenario 2: Restore Purchases
1. Delete app
2. Reinstall from TestFlight
3. Skip to subscription screen
4. Tap "Restore Purchases"
5. Sign in with same Sandbox account
6. Verify subscription restores

### Scenario 3: Subscription Cancellation
1. Settings > App Store > Manage Subscriptions
2. Tap "Everyday Christian"
3. Tap "Cancel Subscription"
4. Reopen app
5. Should revert to free tier

### Scenario 4: Subscription Renewal
**Note:** Sandbox renewals happen every 5 minutes (not monthly/yearly)
1. Purchase subscription
2. Wait 5-6 minutes
3. Check if subscription auto-renewed
4. Verify app still shows premium access

---

## Sandbox Credentials Reference

**Account 1 (Primary):**
- Email: `testuser+everyday1@gmail.com`
- Password: `TestPass123!`
- Use for: Active subscriber testing

**Account 2 (Optional):**
- Email: `testuser+everyday2@gmail.com`
- Password: `TestPass123!`
- Use for: Cancelled subscriber testing

**Account 3 (Optional):**
- Email: `testuser+everyday3@gmail.com`
- Password: `TestPass123!`
- Use for: Fresh install testing

---

## Troubleshooting

### Purchase Dialog Doesn't Appear
**Solution:**
- Settings > App Store > Sign Out
- Force quit Everyday Christian app
- Reopen app and try again

### "Cannot Connect to App Store"
**Solution:**
- Make sure you're on WiFi
- Sign out of real Apple ID first
- Try different Sandbox account

### Subscription Not Activating
**Solution:**
- Check app logs for receipt validation errors
- Verify product IDs: `everyday_christian_ios_yearly_sub`
- Restart app completely

### "Invalid Product ID"
**Solution:**
- Verify subscriptions exist in App Store Connect
- Check they're in "Ready for Sale" status
- Wait 24 hours after creating subscriptions

### Purchase Stuck on "Processing"
**Solution:**
- Force quit app
- Settings > App Store > Sign Out (Sandbox)
- Sign back in and try again

---

## After Testing

### Clean Up
1. Settings > App Store
2. Sign out of Sandbox account
3. Sign in with your real Apple ID
4. Delete TestFlight build (optional)

### Report Results
Document what worked and what failed:
- Did subscriptions load correctly?
- Did purchase flow work smoothly?
- Did features unlock after purchase?
- Did restore purchases work?
- Any crashes or errors?

---

## Sandbox vs Production Differences

| Feature | Sandbox | Production |
|---------|---------|------------|
| Charges | None (free) | Real money |
| Renewal | Every 5 min | Monthly/Yearly |
| Trial Period | 5 min | 3 days |
| Receipt | Test receipt | Real receipt |
| Refunds | Automatic | Manual via Apple |

---

## Important Notes

1. **Sandbox accounts are NOT real Apple IDs**
   - Cannot sign into iCloud
   - Cannot download apps from App Store
   - Only work for IAP testing

2. **Subscriptions renew fast in Sandbox**
   - Monthly = 5 minutes
   - Yearly = 5 minutes
   - Can test 6 renewals max (30 min total)

3. **No email verification needed**
   - Email doesn't need to exist
   - No verification code sent
   - Just for testing purposes

4. **Separate from production**
   - Sandbox purchases don't affect real App Store
   - Can test unlimited times
   - No credit card needed

---

## Quick Commands

**Open Sandbox Testers Page:**
```bash
open "https://appstoreconnect.apple.com/access/testers"
```

**Open Subscriptions Page:**
```bash
open "https://appstoreconnect.apple.com/apps/6754500922/appstore/ios/iap/subscriptions"
```

**Open TestFlight Builds:**
```bash
open "https://appstoreconnect.apple.com/apps/6754500922/testflight/ios"
```

---

**Last Updated:** December 20, 2025
**Build:** 2
**Version:** 1.0.0
