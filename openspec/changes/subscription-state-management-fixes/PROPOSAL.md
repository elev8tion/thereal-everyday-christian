# Subscription State Management Fixes - Change Proposal

**Status:** Draft
**Priority:** P0 (Critical)
**Created:** 2025-10-27
**Author:** Senior Developer (via user bug report)

## Problem Statement

The subscription service has **9 critical production bugs** that cause:
1. **Stale UI data** - Riverpod providers cache old values after message consumption
2. **Race conditions** - Users can send unlimited messages by rapid tapping
3. **Silent failures** - SharedPreferences errors are ignored, leading to unlimited access
4. **State corruption** - Multi-step updates can partially fail, corrupting subscription state
5. **Provider architecture** - Using `Provider` instead of auto-refreshing pattern
6. **Missing validations** - No null checks on critical operations
7. **No background jobs** - Daily/monthly limits don't reset automatically
8. **Unused security features** - Trial abuse prevention code is commented out
9. **No expiry checks** - Expired subscriptions don't auto-restore

These bugs allow users to:
- Bypass message limits by sending messages quickly
- Get unlimited access if SharedPreferences fails
- Pay for subscription but not receive premium access
- See incorrect message counts in UI

## Proposed Solution

Implement a **defensive, transaction-safe subscription system** with:
1. **Riverpod provider invalidation** after all state changes
2. **Mutex locks** to prevent concurrent message consumption
3. **Fail-fast validation** - throw exceptions on null SharedPreferences
4. **Atomic transactions** for multi-step state updates
5. **StateNotifier pattern** for auto-refreshing providers
6. **Background WorkManager** for automatic limit resets
7. **Trial abuse prevention** via receipt validation
8. **Expiry monitoring** with automatic restoration checks

## Implementation Plan

### Phase 1: Critical State Synchronization (P0)
**Objective:** Fix stale provider data and race conditions

**Tasks:**

- [x] Task 1.1: Add provider invalidation after message consumption
  - File: `lib/screens/chat_screen.dart:214-220`
  - Changes:
    ```dart
    final consumed = await subscriptionService.consumeMessage();
    if (consumed && mounted) {
      ref.invalidate(subscriptionSnapshotProvider);
    }
    ```

- [ ] Task 1.2: Add mutex to consumeMessage()
  - File: `lib/core/services/subscription_service.dart:491-523`
  - Changes:
    ```dart
    final Lock _consumeLock = Lock();

    Future<bool> consumeMessage() async {
      return await _consumeLock.synchronized(() async {
        // Existing logic here
      });
    }
    ```
  - Dependency: Add `synchronized` package to pubspec.yaml

- [ ] Task 1.3: Add provider invalidation to all state-changing methods
  - File: `lib/core/services/subscription_service.dart`
  - Methods to update:
    - `startTrial()` (line 226)
    - `_verifyAndActivatePurchase()` (line 586)
    - `restorePurchases()` (line 555)
    - `_checkAndResetMessageLimits()` (line 667)
  - Changes: Add callback mechanism to notify providers of state changes

### Phase 2: Fail-Fast Validation & Error Handling (P0)
**Objective:** Prevent silent failures and state corruption

**Tasks:**

- [ ] Task 2.1: Add SharedPreferences null checks
  - File: `lib/core/services/subscription_service.dart`
  - Changes:
    ```dart
    Future<bool> consumeMessage() async {
      if (_prefs == null) {
        throw StateError('SubscriptionService not initialized');
      }
      // ... rest of logic
    }
    ```
  - Apply to all methods that use `_prefs`

- [ ] Task 2.2: Convert getters to throw on null prefs
  - File: `lib/core/services/subscription_service.dart`
  - Changes:
    ```dart
    int get premiumMessagesUsed {
      if (_prefs == null) {
        throw StateError('SubscriptionService not initialized');
      }
      return _prefs!.getInt(_keyPremiumMessagesUsed) ?? 0;
    }
    ```

- [ ] Task 2.3: Add transaction wrapper for multi-step updates
  - File: `lib/core/services/subscription_service.dart`
  - New method:
    ```dart
    Future<void> _executeTransaction(
      List<Future<void> Function()> operations,
    ) async {
      final backup = <String, dynamic>{};
      try {
        // Execute all operations
        for (final op in operations) {
          await op();
        }
      } catch (e) {
        // Rollback on failure
        for (final entry in backup.entries) {
          await _restorePreference(entry.key, entry.value);
        }
        rethrow;
      }
    }
    ```
  - Apply to: `_verifyAndActivatePurchase()`, `startTrial()`

### Phase 3: Provider Architecture Refactor (P1)
**Objective:** Auto-refreshing subscription state

**Tasks:**

- [ ] Task 3.1: Convert to StateNotifierProvider
  - File: `lib/core/providers/subscription_providers.dart:44-60`
  - Changes:
    ```dart
    class SubscriptionStateNotifier extends StateNotifier<SubscriptionSnapshot> {
      SubscriptionStateNotifier(this._service) : super(_buildSnapshot(_service)) {
        _service.onStateChange = () {
          state = _buildSnapshot(_service);
        };
      }

      final SubscriptionService _service;

      void refresh() {
        state = _buildSnapshot(_service);
      }
    }

    final subscriptionSnapshotProvider =
      StateNotifierProvider<SubscriptionStateNotifier, SubscriptionSnapshot>((ref) {
        final service = ref.watch(subscriptionServiceProvider);
        return SubscriptionStateNotifier(service);
      });
    ```

- [ ] Task 3.2: Add onStateChange callback to SubscriptionService
  - File: `lib/core/services/subscription_service.dart:89`
  - Changes:
    ```dart
    VoidCallback? onStateChange;

    void _notifyStateChange() {
      onStateChange?.call();
    }
    ```
  - Call `_notifyStateChange()` after every state mutation

### Phase 4: Background Jobs & Monitoring (P2)
**Objective:** Automatic limit resets and expiry checks

**Tasks:**

- [ ] Task 4.1: Implement WorkManager for daily resets
  - File: `lib/core/services/subscription_service.dart`
  - Dependency: Add `workmanager` package
  - Changes:
    ```dart
    Future<void> _scheduleDailyReset() async {
      await Workmanager().registerPeriodicTask(
        "subscription-daily-reset",
        "checkAndResetTrialLimits",
        frequency: Duration(days: 1),
        initialDelay: _getTimeUntilMidnight(),
      );
    }
    ```

- [ ] Task 4.2: Implement monthly reset job
  - Similar to Task 4.1 but for premium message resets

- [ ] Task 4.3: Add expiry monitoring
  - File: `lib/core/services/subscription_service.dart:96-145`
  - Changes in `initialize()`:
    ```dart
    final expiryDate = _getExpiryDate();
    if (expiryDate != null && DateTime.now().isAfter(expiryDate)) {
      developer.log('Subscription expired, restoring purchases');
      await restorePurchases();
    }
    ```

### Phase 5: Trial Abuse Prevention (P2)
**Objective:** Prevent infinite trials

**Tasks:**

- [ ] Task 5.1: Uncomment trial tracking
  - File: `lib/core/services/subscription_service.dart:615`
  - Changes: Uncomment line and implement logic
    ```dart
    await _prefs.setBool(_keyTrialEverUsed, wasTrialPurchase);
    ```

- [ ] Task 5.2: Check trial history on app launch
  - File: `lib/core/services/subscription_service.dart:136-145`
  - Changes in `isInTrial` getter:
    ```dart
    bool get isInTrial {
      if (isPremium) return false;
      if (_prefs?.getBool(_keyTrialEverUsed) ?? false) return false;
      // ... existing logic
    }
    ```

## Affected Files

### Modified Files:
- `lib/screens/chat_screen.dart` - Add provider invalidation after consumeMessage
- `lib/core/services/subscription_service.dart` - Add locks, validation, transactions, callbacks
- `lib/core/providers/subscription_providers.dart` - Convert to StateNotifierProvider
- `pubspec.yaml` - Add `synchronized` and `workmanager` dependencies

### New Files:
- None (all changes are modifications)

## Testing Plan

### Unit Tests:
- [ ] Test consumeMessage() race condition prevention
  - Spawn 100 concurrent calls, verify only 1 succeeds
- [ ] Test provider invalidation triggers refresh
  - Mock ref.invalidate, verify called after consumeMessage
- [ ] Test SharedPreferences failure handling
  - Mock prefs as null, verify StateError thrown
- [ ] Test transaction rollback on failure
  - Inject failure in middle of multi-step update, verify rollback
- [ ] Test trial abuse prevention
  - Set `trial_ever_used = true`, verify trial not granted

### Integration Tests:
- [ ] Test rapid message sending
  - Tap send button 10 times quickly, verify only allowed messages sent
- [ ] Test UI updates after consumption
  - Send message, verify UI message count decrements immediately
- [ ] Test offline limit reset
  - Set date to tomorrow, open app offline, verify limits reset
- [ ] Test subscription expiry handling
  - Set expiry to yesterday, open app, verify restorePurchases called

### Manual QA:
- [ ] Send messages rapidly, verify no bypass
- [ ] Monitor message counts in UI, verify accurate
- [ ] Delete app data, reinstall, verify subscription restores
- [ ] Test with airplane mode enabled

## Risks & Considerations

### Performance Impact:
- **Mutex locks** may slightly slow message sending (acceptable for correctness)
- **Provider invalidation** triggers rebuilds (Riverpod is optimized for this)
- **WorkManager** adds background task overhead (minimal)

### Breaking Changes:
- Converting to StateNotifierProvider **may** require UI updates (check all refs)
- Throwing exceptions on null prefs **will** crash app if initialization fails (add try-catch in UI)

### Migration Strategy:
- Phase 1 fixes can be deployed immediately (backward compatible)
- Phase 3 requires careful testing of all subscription UI consumers
- Phase 4 requires new permissions for WorkManager (add to AndroidManifest)

### Rollback Plan:
- All changes are in subscription_service.dart and providers
- Can revert single commit if issues arise
- Keep backup of current implementation in archive

## Success Criteria

- [ ] Zero race condition failures in stress test (100 concurrent calls)
- [ ] 100% provider refresh rate after state changes
- [ ] Zero silent SharedPreferences failures (all throw errors)
- [ ] Zero state corruption cases in transaction tests
- [ ] Daily/monthly limits reset automatically at correct times
- [ ] Trial abuse prevention blocks repeat trials
- [ ] Expired subscriptions trigger automatic restoration

## Timeline

- **Phase 1 (P0):** 2-3 hours
- **Phase 2 (P0):** 2-3 hours
- **Phase 3 (P1):** 3-4 hours
- **Phase 4 (P2):** 4-5 hours
- **Phase 5 (P2):** 1-2 hours
- **Testing:** 3-4 hours

**Total Estimated Time:** 15-21 hours over 2-3 days

## Dependencies

### Packages to Add:
```yaml
dependencies:
  synchronized: ^3.1.0  # For mutex locks
  workmanager: ^0.5.2   # For background jobs

dev_dependencies:
  mockito: ^5.4.6       # Already in project (for testing)
```

### Platform Permissions:
- Android: `RECEIVE_BOOT_COMPLETED` for WorkManager persistence
- iOS: Background fetch capability (optional, for consistency)

## Notes

- This is a **critical security fix** - prioritize P0 phases
- User reported the stale provider bug - that's Phase 1, Task 1.1
- Existing CLAUDE.md documentation shows this refactor was attempted before (subscription-refactor-completed-2025-01-19)
- Check archive for lessons learned from previous attempt

## Approval Required

**Awaiting approval to proceed with implementation.**

---
**End of Proposal**
