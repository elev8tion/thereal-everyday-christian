# Current Subscription Implementation - Codebase Analysis

**Date:** February 2025
**Commit:** b6b2e0ff

---

## Executive Summary

### What Currently Works ✅
1. **Paywall UI exists** - `PaywallScreen` with FrostedGlassCard design
2. **Basic trial tracking** - 3-day trial with 5 messages/day
3. **Message consumption** - `consumeMessage()` tracks usage
4. **Purchase flow** - `purchasePremium()` and `restorePurchases()` implemented
5. **Providers setup** - Multiple subscription-related providers available

### Critical Gaps ❌
1. **NO receipt validation** - Trial can be reset by deleting app data
2. **NO trial cancellation logic** - When user cancels, trial continues until day 3
3. **NO chat history lockout** - Users can still view past chats after trial expires
4. **NO subscription status enum** - Just boolean flags (`isPremium`, `isInTrial`)
5. **NO auto-purchase on day 3** - No logic to convert trial to paid

---

## Current Implementation Details

### 1. SubscriptionService (lib/core/services/subscription_service.dart)

#### What Exists:

**Constants:**
```dart
static const int trialDurationDays = 3;
static const int trialMessagesPerDay = 5;
static const int premiumMessagesPerMonth = 150;
static const String premiumYearlyProductId = 'everyday_christian_premium_yearly';
```

**SharedPreferences Keys:**
```dart
_keyTrialStartDate        // When trial started
_keyTrialMessagesUsed     // Messages used today
_keyTrialLastResetDate    // Last daily reset
_keyPremiumActive         // Boolean - is premium active?
_keyPremiumMessagesUsed   // Premium messages used this month
_keyPremiumLastResetDate  // Last monthly reset
_keySubscriptionReceipt   // Receipt data (BUT not validated!)
```

**Key Methods:**
- `initialize()` - Sets up IAP connection
- `isInTrial` getter - Checks if < 3 days since start
- `canSendMessage()` getter - Returns true if debug OR has messages left
- `consumeMessage()` - Decrements message count
- `purchasePremium()` - Initiates purchase
- `restorePurchases()` - Restores from App Store
- `_verifyAndActivatePurchase()` - Activates premium (NO receipt parsing!)

#### What's Missing:

**NO Trial Cancellation Tracking:**
```dart
// Should exist but doesn't:
static const String _keyTrialCancelled = 'trial_cancelled';
static const String _keyTrialCancellationDate = 'trial_cancellation_date';
```

**NO Receipt Validation:**
```dart
// Current code just saves receipt, doesn't parse it:
await _prefs?.setString(_keySubscriptionReceipt, purchase.verificationData.serverVerificationData);
// Should decode and extract:
// - is_trial_period
// - original_purchase_date
// - expires_date
// - cancellation_date
```

**NO Subscription Status Enum:**
```dart
// Doesn't exist, but should:
enum SubscriptionStatus {
  neverStarted,      // Brand new user
  trialActive,       // Currently in 3-day trial
  trialCancelled,    // User cancelled before day 3 ends
  trialExpired,      // Trial ended, no subscription
  premiumActive,     // Paid subscriber
  premiumCancelled,  // Cancelled but still has time
  premiumExpired,    // Subscription expired
}
```

---

### 2. PaywallScreen (lib/screens/paywall_screen.dart)

#### What Exists:

**Visual Design:** ✅
- FrostedGlassCard styling (matches settings screen aesthetic)
- Gold accent color (AppTheme.goldColor)
- Circular premium icon with gradient
- Feature list with icons
- Pricing card ($35/year, 150 messages/month)
- Purchase and Restore buttons

**Current Text (Line 123-124):**
```dart
'Your trial has ended.\nUpgrade to continue using AI chat.'
```

**Behavior:**
- Shows trial countdown if `isInTrial` is true
- Shows expired message if trial ended
- `_handlePurchase()` - Calls `purchasePremium()`
- `_handleRestore()` - Calls `restorePurchases()`
- Closes on successful purchase

#### What's Missing:

**NO Trial Cancellation State:**
- Paywall shows same message for "trial expired" and "trial cancelled"
- Should differentiate: "Your trial has ended" vs "You cancelled your trial"

**NO Lockout Logic:**
- Paywall is only shown when trying to SEND a message
- Users can still VIEW past chat history
- Should lock entire chat screen behind paywall

---

### 3. ChatScreen (lib/screens/chat_screen.dart)

#### What Exists:

**Message Send Flow (Line 143-195):**
```dart
Future<void> sendMessage(String text) async {
  // 1. Check canSendMessage
  final canSend = subscriptionService.canSendMessage;

  // 2. If can't send (and not debug mode), show paywall
  if (!canSend && !kDebugMode) {
    await Navigator.push(PaywallScreen(...));
    return;
  }

  // 3. Consume message
  final consumed = await subscriptionService.consumeMessage();

  // 4. Send to Gemini
  await _sendMessageToGemini();
}
```

**Paywall Trigger (Line 158-160):**
```dart
builder: (context) => PaywallScreen(
  showTrialInfo: !subscriptionService.hasTrialExpired,
),
```

#### What's Missing:

**NO Chat History Lockout:**
- Current: Users can scroll through past conversations after trial expires
- Should: Entire chat screen should show paywall overlay (like you described)

**NO Trial Cancellation Detection:**
- Current: Only checks `canSendMessage` (which is true/false)
- Should: Check if trial was **cancelled** vs just **expired**

**NO Screen-Level Protection:**
```dart
// Doesn't exist but should (in ChatScreen build):
@override
Widget build(BuildContext context) {
  final subscriptionService = ref.watch(subscriptionServiceProvider);
  final status = subscriptionService.getSubscriptionStatus();

  // Lock entire screen if trial cancelled or expired
  if (status == SubscriptionStatus.trialCancelled ||
      status == SubscriptionStatus.trialExpired ||
      status == SubscriptionStatus.premiumExpired) {
    return _buildPaywallOverlay(); // Full-screen paywall
  }

  // Otherwise show normal chat
  return _buildChatInterface();
}
```

---

### 4. Providers (lib/core/providers/app_providers.dart)

#### What Exists:

**Line 788-864: Subscription Providers**
```dart
final subscriptionServiceProvider = Provider<SubscriptionService>
final isPremiumProvider = Provider<bool>
final isInTrialProvider = Provider<bool>
final hasTrialExpiredProvider = Provider<bool>
final remainingMessagesProvider = Provider<int>
final messagesUsedProvider = Provider<int>
final canSendMessageProvider = Provider<bool>
final trialDaysRemainingProvider = Provider<int>
final premiumMessagesRemainingProvider = Provider<int>
final trialMessagesRemainingTodayProvider = Provider<int>
final subscriptionStatusProvider = Provider<Map<String, dynamic>>
```

**Initialization (Line 186):**
```dart
await subscription.initialize();
```

#### What's Missing:

**NO subscriptionStatusEnumProvider:**
```dart
// Doesn't exist but should:
final subscriptionStatusEnumProvider = Provider<SubscriptionStatus>((ref) {
  final service = ref.watch(subscriptionServiceProvider);
  return service.getSubscriptionStatus();
});
```

**NO trialCancelledProvider:**
```dart
// Doesn't exist but should:
final trialCancelledProvider = Provider<bool>((ref) {
  final service = ref.watch(subscriptionServiceProvider);
  return service.isTrialCancelled;
});
```

---

## User Requirement Clarifications (From Your Input)

### 1. Trial Cancellation Behavior ✅ CLEAR
**Your Rule:**
> "If user cancels anytime before end of 3rd day, then 5 message/day for 3 days is automatically revoked and no access."

**What This Means:**
- Trial starts: User gets 3 days, 5 messages/day
- User cancels on Day 2 (or any time before Day 3 ends)
- **IMMEDIATELY:** All messaging access revoked
- Trial does NOT continue to Day 3
- Paywall appears instantly on next app open

**Implementation Gap:**
```dart
// Currently missing in SubscriptionService:
bool get isTrialCancelled {
  // Check if receipt shows cancellation_date
  // OR check if restorePurchases returns cancelled status
  return false; // Not implemented!
}
```

---

### 2. Auto-Purchase on Day 3 ✅ CLEAR
**Your Rule:**
> "It is 3 days from the moment user chooses to start free trial, if trial expires while user is offline and user did not cancel then it goes to automatic purchase."

**What This Means:**
- Day 1, 2, 3: User has trial access
- End of Day 3: If user hasn't cancelled, Apple/Google **automatically charges**
- This is handled by App Store/Play Store (NOT your app code)
- Your app just needs to detect the purchase and activate premium

**Implementation Gap:**
```dart
// _verifyAndActivatePurchase() should detect auto-renewal:
final isAutoRenewal = receipt['is_trial_period'] == 'false' &&
                      receipt['cancellation_date'] == null;

if (isAutoRenewal) {
  // Activate premium subscription
  await _prefs?.setBool(_keyPremiumActive, true);
}
```

---

### 3. Chat History Lockout ✅ CLEAR
**Your Rule:**
> "No they should not be able to [view past chat history]. Let's lock behind a paywall, let's use the same design behind the paywall that is within use from the settings screen."

**What This Means:**
- If trial cancelled OR expired OR premium expired:
  - Entire ChatScreen shows paywall overlay
  - Cannot scroll through past messages
  - Cannot see chat history
  - Full-screen FrostedGlassCard paywall (like PaywallScreen design)

**Implementation Gap:**
```dart
// ChatScreen needs wrapper:
if (status == SubscriptionStatus.trialCancelled || ...) {
  return Stack([
    _buildGreyedOutChatHistory(), // Show blurred chat behind
    _buildPaywallOverlay(),        // Show paywall on top
  ]);
}
```

---

### 4. Paywall Messaging Tone ✅ CLEAR
**Your Rule:**
> "I already have paywall messaging in my app use the same tone."

**Current Tone (from PaywallScreen line 123-124):**
```dart
'Your trial has ended.\nUpgrade to continue using AI chat.'
```

**Analysis:**
- ✅ Direct and clear
- ✅ No fluff or hype
- ✅ Factual statement
- Use this same tone for trial cancellation message

**Suggested Additions:**
```dart
// For trial cancelled:
'Your trial was cancelled.\nSubscribe to access AI chat.'

// For premium expired:
'Your subscription has ended.\nRenew to continue using AI chat.'
```

---

### 5. Other Features Unlimited ✅ CLEAR
**Your Rule:**
> "Prayer journal, Bible reading, Verse library are all unlimited, it is locally stored so no worry for tech debt."

**What This Means:**
- After trial expires:
  - ✅ Prayer journal: Unlimited (local storage)
  - ✅ Bible reading: Unlimited (local storage)
  - ✅ Verse library: Unlimited (local storage)
  - ✅ Reading plans: Unlimited (local storage)
  - ✅ Devotionals: Unlimited (local storage)
  - ❌ AI Biblical Chat: LOCKED (requires API calls)

**No Code Changes Needed:**
- These features are already unrestricted
- Only ChatScreen needs lockout logic

---

## Critical Implementation Gaps Summary

### Gap 1: Receipt Validation (HIGHEST PRIORITY)
**Problem:** Users can reset trial by deleting app data and reinstalling.

**Current Code (Line 370-373 in subscription_service.dart):**
```dart
// Just saves receipt, doesn't parse:
await _prefs?.setString(_keySubscriptionReceipt,
  purchase.verificationData.serverVerificationData);
```

**What's Needed:**
```dart
// Decode and extract key fields:
final receipt = _decodeReceipt(purchase.verificationData.serverVerificationData);
final wasTrialPurchase = receipt['is_trial_period'] == 'true';
final originalPurchaseDate = receipt['original_purchase_date'];
final expiryDate = receipt['expires_date'];
final cancellationDate = receipt['cancellation_date'];

// Store these dates to detect abuse
await _prefs?.setString(_keyTrialUsedDate, originalPurchaseDate);
await _prefs?.setBool(_keyTrialEverUsed, true);
```

---

### Gap 2: Trial Cancellation Detection (HIGH PRIORITY)
**Problem:** App doesn't detect when user cancels trial.

**Current Behavior:**
- User cancels trial in App Store settings
- App continues to allow messaging until Day 3
- **WRONG** - Should revoke immediately

**What's Needed:**
```dart
// In restorePurchases() or initialize():
final receipt = await _getLatestReceipt();
final cancellationDate = receipt['cancellation_date'];

if (cancellationDate != null) {
  // Trial was cancelled
  await _prefs?.setBool(_keyTrialCancelled, true);
  await _prefs?.setString(_keyTrialCancellationDate, cancellationDate);

  // Revoke access
  await _prefs?.setBool(_keyPremiumActive, false);
}
```

---

### Gap 3: Chat History Lockout (HIGH PRIORITY)
**Problem:** Users can still view past chats after trial expires.

**Current Behavior:**
- Paywall only shows when trying to SEND a message
- Past chat history is still readable

**What's Needed:**
```dart
// In ChatScreen build():
if (subscriptionLocked) {
  return _buildPaywallOverlay();
}
```

---

### Gap 4: Subscription Status Enum (MEDIUM PRIORITY)
**Problem:** Multiple boolean flags make logic complex and error-prone.

**Current State:**
```dart
bool isPremium
bool isInTrial
bool hasTrialExpired
// Logic scattered across multiple checks
```

**What's Needed:**
```dart
enum SubscriptionStatus {
  neverStarted, trialActive, trialCancelled, trialExpired,
  premiumActive, premiumCancelled, premiumExpired
}

SubscriptionStatus getSubscriptionStatus() {
  // Single source of truth
}
```

---

### Gap 5: App Launch Receipt Check (MEDIUM PRIORITY)
**Problem:** App doesn't check receipt on startup, only during purchase.

**Current Code (Line 68-102):**
```dart
Future<void> initialize() async {
  // ... setup IAP ...
  // Missing: Call restorePurchases() to check receipt
}
```

**What's Needed:**
```dart
Future<void> initialize() async {
  // ... existing setup ...

  // Always check receipt on app launch
  await restorePurchases();

  // Validate subscription status
  final status = _determineSubscriptionStatus();
  if (status == SubscriptionStatus.trialCancelled) {
    _blockMessaging = true;
  }
}
```

---

## Recommended Implementation Order

### Phase 1: Critical Fixes (P0) - BLOCKS TRIAL ABUSE
1. ✅ Initialize SubscriptionService on app startup (call in main.dart)
2. ✅ Add receipt validation to `_verifyAndActivatePurchase()`
3. ✅ Parse and store: trial_used_date, expiry_date, cancellation_date
4. ✅ Call `restorePurchases()` on app launch to check status

**Goal:** Prevent users from resetting trial by deleting data.

---

### Phase 2: Trial Cancellation Logic (P0) - USER REQUIREMENT
1. ✅ Add `isTrialCancelled` getter
2. ✅ Check cancellation_date in receipt
3. ✅ Revoke access immediately when detected
4. ✅ Update paywall message for cancelled trials

**Goal:** Block access instantly when user cancels trial.

---

### Phase 3: Chat History Lockout (P0) - USER REQUIREMENT
1. ✅ Create `_buildPaywallOverlay()` in ChatScreen
2. ✅ Check subscription status in ChatScreen build()
3. ✅ Show full-screen paywall if locked out
4. ✅ Use FrostedGlassCard design (matching settings)

**Goal:** Lock entire chat screen behind paywall.

---

### Phase 4: Subscription Status Enum (P1) - CODE QUALITY
1. ✅ Create `SubscriptionStatus` enum
2. ✅ Add `getSubscriptionStatus()` method
3. ✅ Refactor all boolean checks to use enum
4. ✅ Add provider for status enum

**Goal:** Cleaner, more maintainable code.

---

## Files That Need Modification

### Critical Changes:
1. `lib/main.dart` - Add SubscriptionService.initialize() call
2. `lib/core/services/subscription_service.dart` - Receipt validation logic
3. `lib/screens/chat_screen.dart` - Add paywall overlay for lockout
4. `lib/screens/paywall_screen.dart` - Update messages for cancellation

### Nice-to-Have Changes:
5. `lib/core/providers/app_providers.dart` - Add status enum provider

---

## Next Steps

1. **Answer remaining questions** (DONE - you already answered them!)
2. **Update SUBSCRIPTION_OBJECTIVE.md** with your answers
3. **Establish test baseline** (run `flutter test`)
4. **Implement Phase 1** (receipt validation)
5. **Test after Phase 1** (verify no regressions)
6. **Implement Phase 2** (cancellation logic)
7. **Test after Phase 2** (verify no regressions)
8. **Implement Phase 3** (chat lockout)
9. **Test after Phase 3** (verify no regressions)
10. **Commit when clean**

---

## Questions for You

Based on this analysis, I have a factual understanding of your codebase. Before implementing, I need confirmation:

1. **Receipt Validation Package:**
   - Do you want to use a package like `in_app_purchase_storekit` for receipt validation?
   - Or manually decode Base64 receipts and parse JSON?

2. **Offline Scenario:**
   - If user cancels trial while offline, app can't detect until they're online
   - Should we show paywall immediately on next app open (even if offline)?
   - Or wait until we can verify with App Store?

3. **Grace Period:**
   - When trial expires (Day 3), do users get a "last chance" session?
   - Or immediate lockout as soon as 72 hours pass?

4. **Cancellation Message:**
   - Keep it factual like current tone: "Your trial was cancelled. Subscribe to access AI chat."?
   - Or add context: "Your trial was cancelled. You can still access all free features, but AI chat requires a subscription."?

Please confirm these 4 points, and then I'll implement according to the phased plan above.
