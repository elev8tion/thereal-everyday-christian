# Subscription Implementation Objective

**Date:** February 2025
**Status:** Planning Phase
**Priority:** P0 - Business Critical

---

## Business Model: Trial-to-Paid (NOT Freemium)

### Trial Period (3 Days Only)
- **Duration:** 3 days
- **Message Limit:** 5 messages/day × 3 days = **15 total messages**
- **Access:** ALL features including AI Biblical Chat
- **Cost:** FREE

### After Trial Ends

#### Option A: User Subscribes ✅
- **Cost:** ~$35/year (varies by region)
- **Benefits:** 150 messages/month, all features unlocked
- **Renewal:** Auto-renewing yearly subscription

#### Option B: User Doesn't Subscribe/Cancels ❌
- **AI Biblical Chat:** BLOCKED (core premium feature)
- **Still Available:**
  - ✅ Bible reading
  - ✅ Prayer journal
  - ✅ Verse library
  - ✅ Reading plans
  - ✅ Devotionals

**This is NOT a freemium model** - It's trial-to-paid for the AI chat feature.

---

## The Critical Problem: Trial Abuse

### Without Receipt Validation

```
User starts 3-day trial → Uses 15 messages
  ↓
Day 4: Trial expires → "Subscribe for $35/year?"
  ↓
User: "No thanks, I'll just delete my data"
  ↓
Settings → Delete All Data → Reinstall/reopen
  ↓
NEW 3-day trial starts → Another 15 messages
  ↓
Repeat infinitely → NEVER pays $35
```

### Why This is Catastrophic

1. **Core revenue feature (AI chat) is bypassable**
2. **User gets unlimited access by gaming the 3-day trial**
3. **You're paying Gemini API costs while they pay $0**
4. **Destroys the entire business model**

---

## The Solution: Receipt Validation (ESSENTIAL)

### How It Protects the Business

```
User starts 3-day trial (Apple ID: john@icloud.com)
  ↓
Trial ends
  ↓
User deletes data → Tries to start "new" trial
  ↓
App calls restorePurchases()
  ↓
Apple returns: {
  "original_purchase_date": "2024-10-16",
  "is_trial_period": true,  // ← Already used!
  "trial_start_date": "2024-10-16"
}
  ↓
App: "Trial already used on this Apple ID. Subscribe or use free features."
  ↓
User CANNOT access AI chat without paying ✅
```

---

## User Experience After Trial Ends

### Scenario 1: User Subscribes ✅

```
Trial ends → Paywall appears
  ↓
User: "Subscribe for $35/year" → Purchase
  ↓
150 messages/month, all features unlocked ✅
```

### Scenario 2: User Doesn't Subscribe

```
Trial ends → Paywall appears
  ↓
User: "Maybe later" → Closes paywall
  ↓
App: "You can still use Bible reading, prayer journal, verse library"
  ↓
User tries to open AI chat
  ↓
Paywall appears again: "Subscribe to continue using Biblical Chat"
```

### Scenario 3: User Tries to Game the System ❌

```
Trial ends → User deletes data
  ↓
Reopens app → Goes through onboarding
  ↓
Tries to use AI chat
  ↓
App checks Apple receipt: "Trial already used"
  ↓
Immediate paywall: "Subscribe to access Biblical Chat"
  ↓
NO new trial granted ✅
```

---

## Implementation Specifics

### 1. Subscription Status Enum

```dart
enum SubscriptionStatus {
  neverStarted,      // Brand new user
  inTrial,           // Days 1-3
  trialExpired,      // Trial used, not subscribed
  premiumActive,     // Paid subscriber
  premiumCancelled,  // Cancelled but still has time
  premiumExpired     // Subscription fully expired
}
```

### 2. Feature Gating (ChatScreen)

```dart
// In ChatScreen (and anywhere messages are sent)
Future<void> _sendMessage() async {
  final subService = SubscriptionService.instance;
  final status = subService.getSubscriptionStatus();

  if (status == SubscriptionStatus.trialExpired ||
      status == SubscriptionStatus.premiumExpired) {
    // Show paywall - NO messaging allowed
    _showPaywall();
    return;
  }

  if (status == SubscriptionStatus.inTrial) {
    // Check if they have messages left
    if (!subService.canSendMessage()) {
      _showPaywall(message: "Trial limit reached. Subscribe for 150/month.");
      return;
    }
  }

  // Send the message
  await _sendMessageToGemini();
}
```

### 3. Receipt Validation with Trial Detection

```dart
Future<void> _verifyAndActivatePurchase(PurchaseDetails purchase) async {
  // Decode receipt
  final receipt = _decodeReceipt(purchase.verificationData.serverVerificationData);

  // Check if this was a trial purchase
  final wasTrialPurchase = receipt['is_trial_period'] == 'true';
  final originalPurchaseDate = DateTime.parse(receipt['original_purchase_date']);

  if (wasTrialPurchase) {
    // Mark trial as used for this Apple ID
    await _prefs?.setBool(_keyTrialEverUsed, true);
    await _prefs?.setString(_keyTrialUsedDate, originalPurchaseDate.toIso8601String());
  }

  // Check expiry
  final expiryDate = DateTime.parse(receipt['expires_date']);
  final isActive = DateTime.now().isBefore(expiryDate);

  if (isActive) {
    await _prefs?.setBool(_keyPremiumActive, true);
    await _prefs?.setString(_keyPremiumExpiryDate, expiryDate.toIso8601String());
  } else {
    await _prefs?.setBool(_keyPremiumActive, false);
  }
}
```

### 4. App Launch Check

```dart
Future<void> initialize() async {
  // ... existing initialization ...

  // Always restore purchases to check status
  await restorePurchases();

  // Determine subscription status
  final status = _determineSubscriptionStatus();

  // If trial was ever used but not subscribed → block messaging
  if (_prefs?.getBool(_keyTrialEverUsed) == true &&
      _prefs?.getBool(_keyPremiumActive) != true) {
    // Trial expired, not subscribed
    _blockMessaging = true;
  }
}
```

---

## Key Questions (MUST ANSWER BEFORE IMPLEMENTING)

### 1. Trial Expiry While Offline
**Question:** What happens if trial expires while user is offline for 3+ days?

**Options:**
- A) They get one last session to see the paywall
- B) Immediate block when they open the app (even if offline)

**Decision:** _[PENDING]_

---

### 2. Past Chat History Access
**Question:** Can users still VIEW past chat history after trial expires?

**Options:**
- A) YES - They can read past conversations but not send new messages
- B) NO - Entire chat screen locked behind paywall

**Decision:** _[PENDING]_

---

### 3. Grace Period Messaging
**Question:** What's the paywall message when trial expires?

**Options:**
- A) Direct: "Your 3-day trial has ended. Subscribe to continue chatting."
- B) Friendly: "Loving the AI guidance? Subscribe to keep the conversation going!"
- C) Value-focused: "Get 150 messages/month with Biblical Chat Premium"

**Decision:** _[PENDING]_

---

### 4. Other Feature Limits
**Question:** Do other features have limits after trial expires?

**Clarifications Needed:**
- Prayer journal: Unlimited entries? ✅ or limited?
- Bible reading: Unlimited chapters? ✅ or limited?
- Verse library: Unlimited saves? ✅ or limited?
- Reading plans: Can start new plans? ✅ or limited?
- Devotionals: Full access? ✅ or limited?

**Decision:** _[PENDING]_

---

## Implementation Phases

### Phase 1: Critical Subscription Fixes (P0)
**Goal:** Prevent trial abuse and ensure proper subscription tracking

**Tasks:**
- [ ] Task 1.1: Initialize SubscriptionService on app startup
- [ ] Task 1.2: Implement receipt validation and expiry tracking
- [ ] Task 1.3: Update `_verifyAndActivatePurchase()` to extract dates

**After Phase 1:**
- Auto-restore subscriptions on app launch ✅
- Receipt validation prevents trial abuse ✅
- Expiry dates properly tracked ✅

---

### Phase 2: Enhanced Trial & Paywall Logic (P0)
**Goal:** Implement trial-to-paid conversion flow with proper feature gating

**Tasks:**
- [ ] Task 2.1: Create `SubscriptionStatus` enum (9 states)
- [ ] Task 2.2: Add message limit dialog in ChatScreen
- [ ] Task 2.3: Update `sendMessage()` flow with subscription checks
- [ ] Task 2.4: Create paywall overlay for expired trials
- [ ] Task 2.5: Add "Restore Purchases" button in paywall

**After Phase 2:**
- Users can't bypass trial period ✅
- Paywall appears when trial expires ✅
- AI chat properly gated behind subscription ✅

---

### Phase 3: Polish & Edge Cases (P1)
**Goal:** Handle edge cases and improve UX

**Tasks:**
- [ ] Task 3.1: Handle offline trial expiry
- [ ] Task 3.2: Add subscription status indicator in UI
- [ ] Task 3.3: Implement "View past chats" for expired trials (if decided)
- [ ] Task 3.4: Add grace period notifications before trial expires
- [ ] Task 3.5: Analytics tracking for trial conversion rates

---

## Success Metrics

### Technical Goals
- ✅ Zero trial abuse (restorePurchases blocks repeat trials)
- ✅ 100% receipt validation accuracy
- ✅ Proper expiry tracking (no false negatives)

### Business Goals
- 🎯 Trial-to-paid conversion rate: Track and optimize
- 🎯 Reduce API costs from unpaid users: Measure Gemini usage
- 🎯 User retention after subscription: Monitor churn rate

---

## Risk Mitigation

### Risk 1: User Frustration
**Scenario:** User expects freemium, gets trial-to-paid
**Mitigation:** Clear messaging during onboarding about trial period

### Risk 2: Offline Users
**Scenario:** Trial expires while user offline, can't verify
**Mitigation:** Grace period + local timestamp validation

### Risk 3: Receipt Parsing Failures
**Scenario:** Apple receipt format changes or parsing errors
**Mitigation:** Fallback to local trial tracking, log errors for monitoring

---

## Next Steps

1. **Answer Key Questions** (see "Key Questions" section above)
2. **Review and approve this plan**
3. **Establish test baseline** (run `flutter test`, record results)
4. **Implement Phase 1** (following LESSONS_LEARNED.md workflow)
5. **Test after each phase** (no regressions beyond baseline)
6. **Commit when clean** (no new test failures)

---

## References

- **Main Implementation File:** `lib/core/services/subscription_service.dart`
- **Test Discipline:** See `LESSONS_LEARNED.md`
- **Current Baseline:** 994 passed, 5 skipped, 200 failed (pre-existing)
- **Product IDs:** `everyday_christian_premium_yearly`
