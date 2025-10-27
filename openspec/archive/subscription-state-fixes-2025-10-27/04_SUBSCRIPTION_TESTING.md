# Subscription & Trial Flow Testing

**Priority:** P0 (Critical business logic - must work perfectly)
**Est. Time:** 2-3 days (includes automated + manual testing)
**Owner:** Developer + QA Tester

---

## 🎯 Overview

The subscription model is the core revenue driver. **Every edge case must be tested** to prevent:
- Revenue loss (trial abuse, failed purchases)
- User frustration (incorrect limits, failed restores)
- App Store rejection (non-compliant subscription handling)

**Business Model:**
- 3-day trial: 5 messages/day (15 total)
- Premium: $34.99/year, 150 messages/month
- Auto-renewable subscription via App Store

---

## 📋 Trial Flow Testing

### Trial Configuration
```dart
// lib/core/services/subscription_service.dart:54-60
Trial Duration: 3 days
Trial Messages: 5 per day (15 total)
Premium Messages: 150 per month
Product ID: everyday_christian_premium_yearly
Price: ~$35/year (varies by region)
```

---

### Test Case 1: First-Time User (Trial Start)

**Preconditions:**
- Fresh app install OR "Delete All Data" completed
- No previous trial history for this Apple ID

**Steps:**
1. Complete onboarding
2. Navigate to AI Chat screen
3. Send first message

**Expected Behavior:**
```
✅ Trial starts automatically on first message
✅ Message sends successfully
✅ Trial countdown begins: "Day 1 of 3"
✅ Messages remaining: 4/5 for today
✅ SharedPreferences stores:
   - trial_start_date: <current_date>
   - trial_messages_used: 1
   - trial_last_reset_date: <current_date>
```

**Verification:**
```bash
# Check SharedPreferences (iOS Simulator)
xcrun simctl get_app_container booted com.yourcompany.everydaychristian data
# Navigate to Library/Preferences and inspect plist file
```

**Pass Criteria:**
- Trial starts on first message ✅
- Date tracking accurate ✅
- Message counter increments ✅

---

### Test Case 2: Daily Message Limit (Trial Day 1)

**Preconditions:**
- Trial started (Test Case 1 completed)
- Same calendar day

**Steps:**
1. Send messages 2, 3, 4, 5 (total: 5 for the day)
2. Attempt to send message 6

**Expected Behavior:**
```
Messages 2-5:
✅ Send successfully
✅ Counter decrements: 3/5, 2/5, 1/5, 0/5

Message 6 (limit reached):
✅ Message input blocked OR shows warning
✅ Dialog appears: "Daily Limit Reached"
✅ Dialog message: "You've used all 5 messages today. Subscribe now for 150 messages/month?"
✅ Actions: "Subscribe Now" | "Maybe Later"
```

**User Actions to Test:**

**A. Click "Subscribe Now":**
```
✅ Navigates to PaywallScreen
✅ Shows subscription options
✅ "Continue" button enabled
```

**B. Click "Maybe Later":**
```
✅ Dialog closes
✅ Chat history remains viewable (Days 1-2)
✅ Cannot send messages until next day
✅ No error messages or crashes
```

**Pass Criteria:**
- Limit enforced correctly ✅
- Dialog appears as expected ✅
- Both actions work properly ✅

---

### Test Case 3: Daily Reset (Trial Day 2)

**Preconditions:**
- Day 1 completed (5 messages sent)
- Now it's Day 2 (24 hours later)

**Steps:**
1. Open app on Day 2
2. Navigate to AI Chat
3. Send a message

**Expected Behavior:**
```
✅ Message counter resets: 5/5 messages available
✅ Trial status: "Day 2 of 3"
✅ trial_last_reset_date updates to Day 2
✅ trial_messages_used resets to 0, then increments to 1
```

**Edge Case Testing:**
- **Test at 11:59 PM Day 1 → 12:01 AM Day 2**: Counter should reset at midnight
- **Test with app closed**: Counter resets based on stored date, not app uptime

**Pass Criteria:**
- Daily reset works correctly ✅
- Midnight boundary handled properly ✅
- Works when app closed/reopened ✅

---

### Test Case 4: Trial Expiration (Day 3 → Day 4)

**Preconditions:**
- Trial Day 3 completed (all 5 messages used)
- Now it's Day 4 (trial expired)

**Steps:**
1. Open app on Day 4
2. Navigate to AI Chat
3. Observe chat screen

**Expected Behavior:**
```
✅ Paywall overlay covers chat screen
✅ Lock icon visible
✅ Message: "AI Chat Requires Subscription"
✅ Subtext: "Subscribe to view your chat history and continue conversations"
✅ "Subscribe Now" button → Opens PaywallScreen
✅ Cannot view chat history (locked behind paywall)
✅ Cannot send messages
```

**Critical Check:**
```
❌ User should NOT see chat history after trial expires
✅ Bible reading, prayer journal, verses still work (unlimited)
```

**Pass Criteria:**
- Chat screen locked after trial expires ✅
- Other features remain accessible ✅
- Paywall overlay design matches settings screen lockout ✅

---

### Test Case 5: Trial Abuse Prevention

**Preconditions:**
- User completed trial and it expired
- User clicks "Delete All Data" in settings

**Steps:**
1. Complete "Delete All Data"
2. Restart app
3. Complete onboarding again
4. Send first message

**Expected Behavior (Post-Implementation):**
```
✅ App calls restorePurchases() on initialization
✅ Checks Apple receipt for trial history
✅ If trial_ever_used flag found in receipt → No new trial
✅ Shows paywall instead of allowing 5 messages
```

**Current Behavior (Pre-Implementation):**
```
⚠️ User gets a new trial (BUG - infinite trials possible)
⚠️ trial_start_date resets to new date
⚠️ 5 messages/day granted again
```

**Pass Criteria (After Fix):**
- Trial history tracked via Apple receipt ✅
- Cannot reset trial by deleting data ✅
- `trial_ever_used` flag persists across data deletions ✅

---

## 💳 Purchase Flow Testing

### Test Case 6: Trial → Premium Purchase (Day 1-2)

**Preconditions:**
- Trial active (Day 1 or 2)
- User has messages remaining (e.g., 3/5)

**Steps:**
1. Click "Subscribe Now" from anywhere (paywall, settings, etc.)
2. Review subscription details in PaywallScreen
3. Click "Continue" to purchase
4. Complete Apple payment (use Sandbox account)

**Expected Behavior:**
```
Apple Payment Sheet:
✅ Shows: "$34.99/year after 3-day trial"
✅ "Subscribe" button enabled
✅ Shows auto-renewal disclosure

After Purchase Success:
✅ premium_active = true stored
✅ Premium messages: 150/150 available
✅ Trial messages no longer tracked
✅ Paywall screen closes
✅ Returns to previous screen
✅ Can send message immediately (premium active)
```

**Verification:**
```dart
// Check stored values:
premium_active: true
premium_messages_used: 0
premium_last_reset_date: <purchase_date>
subscription_receipt: <base64_receipt>
premium_expiry_date: <1_year_from_now>
```

**Pass Criteria:**
- Purchase completes successfully ✅
- Premium status activated ✅
- Message limits updated to premium ✅
- Receipt stored for restoration ✅

---

### Test Case 7: Trial → Premium Purchase (Day 3, Limit Reached)

**Preconditions:**
- Trial Day 3
- All 5 messages used
- Dialog shows "Subscribe Now?" | "Maybe Later"

**Steps:**
1. Click "Subscribe Now" in dialog
2. Complete purchase (Sandbox account)

**Expected Behavior:**
```
✅ Same as Test Case 6
✅ Premium activated immediately
✅ Can send messages right away (150/month)
```

**Pass Criteria:**
- Purchase from dialog works ✅
- Immediate premium access granted ✅

---

### Test Case 8: Purchase Cancellation Flow

**Preconditions:**
- User opens PaywallScreen
- Clicks "Continue" to purchase

**Steps:**
1. Apple payment sheet appears
2. Click "Cancel" on payment sheet

**Expected Behavior:**
```
✅ Payment sheet closes
✅ Returns to PaywallScreen (still visible)
✅ No subscription activated
✅ No changes to trial status
✅ No error messages shown
✅ User can try again or close paywall
```

**Pass Criteria:**
- Cancellation handled gracefully ✅
- App state unchanged ✅
- No crashes or errors ✅

---

### Test Case 9: "Restore Purchases" After Data Deletion

**Preconditions:**
- User has ACTIVE premium subscription
- User clicks "Delete All Data" in settings

**Steps:**
1. Complete data deletion (confirms dialog)
2. App restarts (or manually restart)
3. App initializes

**Expected Behavior:**
```
App Initialization (app_providers.dart:180-186):
✅ SubscriptionService.initialize() called
✅ restorePurchases() called automatically
✅ Apple receipt queried
✅ Premium status restored from receipt
✅ premium_active = true set
✅ Expiry date extracted and stored
✅ User has premium access immediately (no paywall)
```

**Alternative: Manual Restore**
If automatic restore fails (network issue):
```
✅ User navigates to PaywallScreen
✅ Clicks "Restore Purchases" button
✅ restorePurchases() called manually
✅ Premium status restored
```

**Pass Criteria:**
- Automatic restoration works ✅
- Manual restoration available as fallback ✅
- No loss of premium access after data deletion ✅

---

### Test Case 10: Restore Purchases (No Active Subscription)

**Preconditions:**
- User never subscribed OR subscription expired
- User clicks "Restore Purchases" button

**Steps:**
1. Navigate to PaywallScreen
2. Click "Restore Purchases"

**Expected Behavior:**
```
✅ Shows loading indicator
✅ Queries Apple for receipts
✅ No active subscriptions found
✅ Shows message: "No active subscriptions found"
✅ Remains on paywall screen
✅ No premium status granted
```

**Pass Criteria:**
- Handles "no subscription" gracefully ✅
- Clear user messaging ✅
- No false premium activation ✅

---

## 📅 Monthly Reset Testing (Premium)

### Test Case 11: Premium Monthly Message Reset

**Preconditions:**
- User has active premium subscription
- Used 50/150 messages this month
- Now it's 30 days later (next month)

**Steps:**
1. Open app after 30 days
2. Send a message

**Expected Behavior:**
```
✅ Message counter resets: 150/150 available
✅ premium_last_reset_date updates to new month
✅ premium_messages_used resets to 0, then 1
✅ Subscription still active (not expired)
```

**Testing Approach:**
```
Option 1: Manually change device date (iOS Settings → General → Date & Time → Set Manually)
Option 2: Modify SharedPreferences reset date in debugger
Option 3: Wait 30 actual days (beta testing phase)
```

**Pass Criteria:**
- Monthly reset works correctly ✅
- Counter resets on calendar month change ✅

---

### Test Case 12: Premium Message Limit (150/month)

**Preconditions:**
- Premium active
- User has sent 149 messages this month

**Steps:**
1. Send message #150 (limit reached)
2. Attempt to send message #151

**Expected Behavior:**
```
Message 150:
✅ Sends successfully
✅ Counter: 0/150 remaining

Message 151 (limit reached):
✅ Dialog appears: "Monthly Limit Reached"
✅ Message: "You've used all 150 messages this month. Limit resets on [date]."
✅ Actions: "OK" (no purchase option, already premium)
✅ Cannot send message until next month
```

**Pass Criteria:**
- Premium limit enforced ✅
- Appropriate messaging shown ✅
- No paywall (already subscribed) ✅

---

## 🔄 Subscription Lifecycle Testing

### Test Case 13: Subscription Expiry Detection

**Preconditions:**
- Premium subscription purchased 1 year ago
- Subscription NOT renewed (cancelled or payment failed)
- App opens after expiry date

**Steps:**
1. Open app
2. Navigate to AI Chat

**Expected Behavior:**
```
App Initialization:
✅ Checks premium_expiry_date in SharedPreferences
✅ Detects expiry date < current date
✅ Calls restorePurchases() to confirm with Apple
✅ Apple confirms: No active subscription
✅ Sets premium_active = false
✅ Shows paywall overlay on chat screen
```

**Pass Criteria:**
- Expiry detected on app launch ✅
- Premium status revoked ✅
- Chat locked behind paywall ✅

---

### Test Case 14: Subscription Auto-Renewal

**Preconditions:**
- Premium subscription purchased 1 year ago
- Auto-renew enabled in Apple account
- Subscription renewed successfully

**Steps:**
1. Open app after renewal date
2. Navigate to AI Chat

**Expected Behavior:**
```
✅ restorePurchases() called on init
✅ Apple receipt shows new expiry date (+1 year)
✅ premium_expiry_date updated
✅ premium_active remains true
✅ User has full access (no interruption)
```

**Pass Criteria:**
- Auto-renewal detected ✅
- Expiry date updated ✅
- Seamless user experience ✅

---

## 🧪 Edge Case Testing

### Test Case 15: Offline Trial Usage

**Scenario:** User starts trial offline, uses messages, then goes online

**Steps:**
1. Enable airplane mode
2. Open app
3. Navigate to chat
4. Attempt to send message

**Expected Behavior:**
```
✅ AI chat requires network (shows error)
✅ Trial counter NOT consumed (no message sent)
✅ Bible reading still works (local data)
✅ Prayer journal still works (local data)
```

**Pass Criteria:**
- Trial messages not consumed when offline ✅
- Offline features remain accessible ✅

---

### Test Case 16: Purchase During Network Interruption

**Scenario:** Network drops during purchase flow

**Steps:**
1. Initiate purchase (click "Subscribe")
2. Disable WiFi mid-purchase
3. Payment completes or fails

**Expected Behavior:**
```
If payment completed before network drop:
✅ Receipt stored locally (iOS handles this)
✅ Next app launch: restorePurchases() activates premium
✅ User receives "Purchase successful" message on reconnection

If payment failed:
✅ Shows error: "Network connection lost"
✅ No premium status granted
✅ User can retry purchase
```

**Pass Criteria:**
- Purchase resilient to network issues ✅
- Receipt validation happens on reconnection ✅

---

### Test Case 17: Multiple Device Subscription

**Scenario:** User subscribes on iPhone, then logs in on iPad with same Apple ID

**Steps:**
1. Purchase premium on iPhone
2. Install app on iPad (same Apple ID)
3. Open app on iPad

**Expected Behavior:**
```
iPad App Launch:
✅ SubscriptionService.initialize() runs
✅ restorePurchases() called
✅ Queries Apple for receipts (tied to Apple ID)
✅ Finds active subscription
✅ Activates premium on iPad
✅ User has full access on both devices
```

**Pass Criteria:**
- Cross-device subscription works ✅
- No re-purchase required ✅
- Apple ID is source of truth ✅

---

## 🔍 Test Environment Setup

### Sandbox Testing (Required)

**Apple Sandbox Account:**
1. Create sandbox tester in App Store Connect
2. Email: `tester1@example.com` (not real email)
3. Password: Strong password
4. Country: United States (or your primary market)

**Configure iOS Simulator/Device:**
```
Settings → App Store → Sandbox Account → Sign In
Use: tester1@example.com
```

**Important:**
- ⚠️ DO NOT use real Apple ID for testing
- ⚠️ DO NOT use sandbox account for real App Store
- ✅ Sandbox purchases are FREE (no real charges)
- ✅ Can test full purchase flow without cost

---

### StoreKit Configuration File (Optional)

**For local testing without server:**
```xml
<!-- EverydayChristian.storekit -->
<products>
  <subscription id="everyday_christian_premium_yearly">
    <price>34.99</price>
    <duration>1 year</duration>
    <trial>3 days</trial>
  </subscription>
</products>
```

**Usage:**
- Xcode → Edit Scheme → Run → Options → StoreKit Configuration
- Allows testing without App Store Connect (early development)

---

## 📊 Test Coverage Checklist

### Trial Flow (9 tests)
- [ ] Trial starts on first message
- [ ] Daily message limit enforced (5/day)
- [ ] Daily reset works (midnight boundary)
- [ ] Trial expiration (Day 3 → Day 4)
- [ ] Trial abuse prevention (data deletion)
- [ ] Trial status UI updates correctly
- [ ] "Subscribe Now" dialog appears at limit
- [ ] "Maybe Later" allows viewing history (Days 1-2)
- [ ] Trial countdown displayed accurately

### Purchase Flow (7 tests)
- [ ] Purchase during trial (Day 1-2)
- [ ] Purchase on Day 3 (limit reached)
- [ ] Purchase cancellation handled gracefully
- [ ] Restore purchases after data deletion
- [ ] Restore purchases (no subscription found)
- [ ] Premium activation confirmed
- [ ] Receipt stored and validated

### Premium Subscription (5 tests)
- [ ] Monthly message reset (150/month)
- [ ] Premium message limit enforced
- [ ] Subscription expiry detected
- [ ] Auto-renewal processed
- [ ] Premium status persists across app restarts

### Edge Cases (6 tests)
- [ ] Offline trial usage
- [ ] Network interruption during purchase
- [ ] Multiple device subscription (same Apple ID)
- [ ] App backgrounded during purchase
- [ ] Rapid message sending (race conditions)
- [ ] Subscription status while app closed for weeks

### UI/UX (5 tests)
- [ ] Paywall screen layout (portrait/landscape)
- [ ] Message limit dialog design
- [ ] Chat screen lockout overlay
- [ ] Premium badge in settings (if applicable)
- [ ] Loading states during purchase

**Total: 32 Test Cases**
**Target: 100% pass rate before App Store submission**

---

## 🚨 Critical Bugs to Watch For

### High Severity
1. **Trial Reset Bug**: User can delete data → get infinite trials
   - Status: Known issue (fix in roadmap Phase 1)
   - Impact: Revenue loss, unfair usage

2. **Message Counter Race Condition**: Rapid taps send >5 messages
   - Test: Tap send button 10 times rapidly
   - Fix: Debounce send button, check limit before AND after send

3. **Subscription Not Restored**: Delete data → lose premium status
   - Test: Test Case 9
   - Fix: Call `restorePurchases()` in `initialize()`

### Medium Severity
4. **Expiry Date Not Tracked**: Subscription expires but user keeps access
   - Test: Test Case 13
   - Fix: Extract `expires_date` from receipt, check on init

5. **Monthly Reset Edge Case**: Message sent at 11:59 PM doesn't count
   - Test: Test Case 11 (midnight boundary)
   - Fix: Use UTC dates, proper timezone handling

---

## 🔧 Testing Tools & Commands

### Flutter DevTools
```bash
# Open DevTools for state inspection
flutter pub global activate devtools
flutter pub global run devtools
```

### SharedPreferences Inspection (iOS)
```bash
# Get app container on simulator
xcrun simctl get_app_container booted com.yourcompany.everydaychristian data

# Navigate to Library/Preferences/*.plist
# Open in Xcode or use `plutil` to view
```

### Receipt Validation Testing
```dart
// Add debug logging in subscription_service.dart
developer.log('Purchase receipt: ${productDetails.verificationData.localVerificationData}');
developer.log('Server verification: ${productDetails.verificationData.serverVerificationData}');
```

---

## 🚀 Next Steps

**After completing subscription testing:**
1. ✅ Fix critical bugs (trial reset, restoration, expiry tracking)
2. ✅ Implement automatic `restorePurchases()` in `initialize()`
3. ✅ Add receipt validation for trial abuse prevention
4. → Move to **05_PRIVACY_SECURITY.md** for privacy review
5. → Move to **06_CONTENT_REVIEW.md** for theological content audit

---

**Last Updated:** 2025-01-20
**Status:** Ready for testing
**Test Completion Target:** Before TestFlight beta release
