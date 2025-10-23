# Task 3.2: Trial Cancellation Detection Research

**Status:** Research Complete
**Date:** 2025-01-19
**Priority:** P1
**Context:** Privacy-first app with no backend server

---

## Executive Summary

**Key Finding:** Platform-native cancellation detection requires server-side infrastructure, which conflicts with our privacy-first architecture.

**Recommended Approach:** Client-side workarounds using `restorePurchases()` and subscription expiry validation.

**Trade-off:** Cancellation detection will be eventual (on next app launch) rather than real-time.

---

## Platform Research Findings

### iOS (StoreKit 2)

**Cancellation Detection:**
- ❌ No real-time "subscription cancelled" event
- ❌ On-device purchase doesn't automatically update App Store receipt
- ✅ Cancelled subscriptions continue until period ends
- ✅ `currentEntitlements` API shows active entitlements only
- ✅ App Store Server API available (requires backend)

**Key Insights:**
- StoreKit 2 doesn't provide client-side cancellation events
- Subscriptions remain active until expiry even after user cancels
- Receipt validation shifted from `verifyReceipt` (StoreKit 1) to App Store Server API
- `transactionId` can be validated via Get Transaction Info endpoint (server-side)

**Client-Side Options:**
1. Check `currentEntitlements` - only shows active subscriptions
2. Parse local receipt for `expires_date` and `auto_renew_status`
3. Use `restorePurchases()` - cancelled subscriptions won't restore after expiry

**Sources:**
- Apple Developer Documentation (WWDC 2023)
- Stack Overflow discussions (2024-2025)
- Medium article on StoreKit 2 validation

---

### Android (Google Play Billing)

**Cancellation Detection:**
- ❌ Cannot detect unsubscribe event in mobile app alone
- ❌ Billing Library doesn't provide real-time cancellation notifications
- ✅ Real-time Developer Notifications (RTDNs) available (requires backend)
- ✅ `purchases.subscriptionsv2.get` API provides subscription state
- ✅ Billing Library 7+ required by Aug 31, 2025

**Key Insights:**
- Proper detection requires backend server with Google PubSub webhooks
- RTDNs send `SubscriptionNotification` messages on state changes
- Subscription states: ACTIVE, PAUSED, CANCELED, EXPIRED
- `purchases.subscriptionsv2.get` is source of truth for subscription management

**Client-Side Options:**
1. Use `restorePurchases()` - cancelled subscriptions won't appear once expired
2. Check `purchasesList` for active subscriptions
3. Validate subscription locally based on `purchaseTime` and `expirationDate`

**Sources:**
- Google Play Developer API Documentation
- Android Developers: Subscription Lifecycle
- Stack Overflow discussions (2024-2025)

---

### Flutter `in_app_purchase` Plugin

**Limitations:**
- ❌ Built-in listener doesn't fire for cancellations
- ❌ No cross-platform cancellation event
- ✅ `restorePurchases()` returns current active purchases only
- ✅ Cancelled subscriptions disappear from `restoredPurchases` after expiry

**Community Challenges:**
- GitHub Issue #43720: "detecting subscription lapse client-side"
- GitHub Issue #58834: "cancel subscription and restore cancelled subscription"
- Common complaint: "Listener doesn't fire when subscription cancelled"

**Third-Party Solutions:**
- **RevenueCat:** Provides `expirationDate` via server-side infrastructure
- **Qonversion:** Provides `renewState` (nonRenewable, willRenew, canceled, etc.)
- **Trade-off:** Adds dependency, potential cost, complexity

**Sources:**
- Flutter GitHub Issues
- Stack Overflow discussions
- RevenueCat/Qonversion documentation

---

## Implementation Options

### Option 1: Server-Side (Industry Standard) ❌

**Pros:**
- Real-time cancellation detection
- Accurate subscription status
- Handles billing issues and grace periods
- Industry best practice

**Cons:**
- ❌ **Violates privacy-first architecture**
- Requires backend infrastructure
- Adds operational complexity
- Monthly server costs

**Verdict:** Not viable for our privacy-first requirements

---

### Option 2: Third-Party SDK (RevenueCat/Qonversion) ⚠️

**Pros:**
- Handles server-side infrastructure
- Unified API for iOS/Android
- Accurate cancellation detection
- Professional support

**Cons:**
- ⚠️ **May conflict with privacy-first approach**
- Adds external dependency
- Potential monthly costs ($0-$10k+ based on MAU)
- Data flows through third-party servers

**Verdict:** Possible but requires privacy policy review

---

### Option 3: Client-Side Workarounds (Pragmatic) ✅

**Approach:**
Use `restorePurchases()` on app launch to detect expired/cancelled subscriptions.

**Implementation:**
```dart
Future<bool> _checkTrialCancellation() async {
  try {
    // Restore purchases from platform
    final Stream<List<PurchaseDetails>> purchaseUpdated = _iap.purchaseStream;
    await _iap.restorePurchases();

    // Wait briefly for restore to complete
    await Future.delayed(Duration(seconds: 2));

    // Check if user has active subscription
    final pastPurchases = await _iap.queryPastPurchases();
    final hasActiveSubscription = pastPurchases.pastPurchases.any((purchase) {
      return purchase.productID == premiumYearlyProductId &&
             purchase.status == PurchaseStatus.purchased;
    });

    // If no active subscription found, assume cancelled
    return !hasActiveSubscription;
  } catch (e) {
    // On error, assume not cancelled (fail-safe)
    return false;
  }
}
```

**Pros:**
- ✅ No backend required
- ✅ Privacy-first (local only)
- ✅ Works with existing `in_app_purchase` plugin
- ✅ No additional costs

**Cons:**
- ⚠️ Detection is eventual (not real-time)
- ⚠️ Requires app to be online
- ⚠️ 2-second delay for restore operation

**Verdict:** **Best fit for privacy-first architecture**

---

### Option 4: Hybrid Approach ⚡

**Approach:**
Combine client-side detection with optional server-side validation for premium users.

**Implementation:**
1. Use client-side workarounds (Option 3) for all users
2. Offer optional "Enhanced Subscription Management" for users who opt-in
3. Server-side validation only for opted-in users with explicit consent

**Pros:**
- Privacy by default
- Enhanced accuracy for users who want it
- Monetization opportunity (premium tier)

**Cons:**
- Increased complexity
- Two code paths to maintain
- Server infrastructure still needed

**Verdict:** Future enhancement, not initial implementation

---

## Recommended Implementation Plan

### Phase 3.2a: Client-Side Detection (Immediate)

**Approach:** Use `restorePurchases()` to detect cancelled subscriptions.

**Changes Required:**
- `lib/core/services/subscription_service.dart`
- Update `_checkTrialCancellation()` method
- Add 2-second timeout for restore operation
- Handle offline scenarios gracefully

**Code Location:** Lines 331-342 (current placeholder)

**Testing Requirements:**
1. Cancel subscription via App Store/Play Store
2. Restart app after cancellation
3. Verify auto-subscribe doesn't trigger
4. Verify chat lockout appears immediately

---

### Phase 3.2b: Platform-Specific Enhancements (Future)

**iOS (StoreKit 2):**
- Parse local receipt for `auto_renew_status` field
- Check `currentEntitlements` API
- Validate `expires_date` against current time

**Android (Play Billing):**
- Use `BillingClient.queryPurchasesAsync()` directly
- Check subscription state in `purchasesList`
- Validate `expirationDate` from purchase details

**Dependencies:**
- May require `flutter_platform_interface` for native code
- Research StoreKit 2 API availability in Flutter

---

## Privacy Considerations

### Data Collection
- ✅ No user data sent to our servers
- ✅ Platform-native APIs only (Apple/Google)
- ✅ Subscription status stored locally only

### User Transparency
- Clearly document in Privacy Policy
- Explain subscription status checks happen locally
- Note that App Store/Play Store APIs are used

### GDPR/CCPA Compliance
- ✅ No personal data processing by us
- ✅ Apple/Google handle all subscription data
- ✅ Local-only storage meets privacy requirements

---

## Technical Constraints

### Offline Behavior
- Cancellation detection requires internet connection
- `restorePurchases()` fails silently when offline
- Fall back to "assume not cancelled" when offline
- User sees paywall on next online session if actually cancelled

### Platform Limitations
- iOS: Receipt updates may be delayed
- Android: Billing Library requires Play Services
- Both: Cancellation detected only on next app launch

### Performance
- `restorePurchases()` adds 1-2 seconds to app initialization
- Acceptable trade-off for privacy-first approach
- Can be optimized with caching and background refresh

---

## Next Steps

1. ✅ **Research Complete** - This document
2. ⏳ **Design Implementation** - Update PROPOSAL.md with findings
3. ⏳ **Implement Client-Side Detection** - Update `_checkTrialCancellation()`
4. ⏳ **Test on Real Devices** - iOS and Android
5. ⏳ **Update Documentation** - Privacy Policy, User Guide

---

## Decision Matrix

| Criteria | Server-Side | Third-Party | Client-Side | Hybrid |
|----------|-------------|-------------|-------------|--------|
| **Privacy-First** | ❌ No | ⚠️ Maybe | ✅ Yes | ⚠️ Partial |
| **Real-Time Detection** | ✅ Yes | ✅ Yes | ❌ No | ⚠️ Partial |
| **No Backend Required** | ❌ No | ❌ No | ✅ Yes | ❌ No |
| **No External Dependencies** | ❌ No | ❌ No | ✅ Yes | ❌ No |
| **Implementation Complexity** | High | Medium | Low | High |
| **Ongoing Costs** | $$$ | $$ | $0 | $$$ |
| **Maintenance Burden** | High | Low | Low | High |

**Recommended:** **Client-Side Detection** (Option 3)

---

## Conclusion

For a privacy-first app without backend infrastructure, **client-side cancellation detection using `restorePurchases()`** is the most pragmatic approach. While it doesn't provide real-time detection, it maintains our privacy commitments and requires no server infrastructure.

**Trade-off Accepted:**
- Cancellation detection is eventual (on next app launch)
- Users may see auto-subscribe attempt even if they cancelled
- Purchase will fail gracefully (user already cancelled)
- Acceptable user experience for privacy-first approach

**Implementation Priority:** Immediate (P1)
**Estimated Effort:** 2-4 hours
**Risk:** Low (fail-safe design)

---

**Last Updated:** 2025-01-19
**Next Review:** After implementation and testing
