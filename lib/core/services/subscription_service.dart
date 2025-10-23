import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Represents the user's current subscription standing.
enum SubscriptionStatus {
  unknown,
  trialActive,
  premiumActive,
  expired,
}

/// Snapshot of the subscription/trial information.
class SubscriptionSnapshot {
  const SubscriptionSnapshot({
    required this.status,
    this.trialStartedAt,
    this.trialEndsAt,
    this.premiumExpiresAt,
    this.originalPurchaseDate,
    this.autoRenewEnabled = false,
    this.lastSyncedAt,
  });

  factory SubscriptionSnapshot.initial({required DateTime now}) {
    return SubscriptionSnapshot(
      status: SubscriptionStatus.unknown,
      lastSyncedAt: now,
    );
  }

  final SubscriptionStatus status;
  final DateTime? trialStartedAt;
  final DateTime? trialEndsAt;
  final DateTime? premiumExpiresAt;
  final DateTime? originalPurchaseDate;
  final bool autoRenewEnabled;
  final DateTime? lastSyncedAt;

  bool get isTrialActive => status == SubscriptionStatus.trialActive;
  bool get isPremiumActive => status == SubscriptionStatus.premiumActive;
  bool get isExpired => status == SubscriptionStatus.expired;

  SubscriptionSnapshot evaluate(DateTime now) {
    if (isTrialActive && trialEndsAt != null && !trialEndsAt!.isAfter(now)) {
      return copyWith(
        status: SubscriptionStatus.expired,
        lastSyncedAt: now,
      );
    }

    if (isPremiumActive &&
        premiumExpiresAt != null &&
        !premiumExpiresAt!.isAfter(now)) {
      return copyWith(
        status: SubscriptionStatus.expired,
        lastSyncedAt: now,
      );
    }

    return copyWith(lastSyncedAt: now);
  }

  SubscriptionSnapshot applyReceipt(
    SubscriptionReceipt receipt,
    DateTime now,
  ) {
    final expires = receipt.expiresDate;

    SubscriptionStatus nextStatus = SubscriptionStatus.expired;

    if (expires != null && expires.isAfter(now)) {
      nextStatus = receipt.isTrialPeriod
          ? SubscriptionStatus.trialActive
          : SubscriptionStatus.premiumActive;
    }

    return copyWith(
      status: nextStatus,
      originalPurchaseDate: receipt.originalPurchaseDate,
      trialStartedAt:
          receipt.isTrialPeriod ? receipt.originalPurchaseDate : trialStartedAt,
      trialEndsAt:
          receipt.isTrialPeriod ? receipt.expiresDate : trialEndsAt,
      premiumExpiresAt:
          receipt.isTrialPeriod ? premiumExpiresAt : receipt.expiresDate,
      autoRenewEnabled: receipt.autoRenewEnabled,
      lastSyncedAt: now,
    );
  }

  SubscriptionSnapshot copyWith({
    SubscriptionStatus? status,
    DateTime? trialStartedAt,
    DateTime? trialEndsAt,
    DateTime? premiumExpiresAt,
    DateTime? originalPurchaseDate,
    bool? autoRenewEnabled,
    DateTime? lastSyncedAt,
  }) {
    return SubscriptionSnapshot(
      status: status ?? this.status,
      trialStartedAt: trialStartedAt ?? this.trialStartedAt,
      trialEndsAt: trialEndsAt ?? this.trialEndsAt,
      premiumExpiresAt: premiumExpiresAt ?? this.premiumExpiresAt,
      originalPurchaseDate:
          originalPurchaseDate ?? this.originalPurchaseDate,
      autoRenewEnabled: autoRenewEnabled ?? this.autoRenewEnabled,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'status': status.name,
      'trialStartedAt': trialStartedAt?.toIso8601String(),
      'trialEndsAt': trialEndsAt?.toIso8601String(),
      'premiumExpiresAt': premiumExpiresAt?.toIso8601String(),
      'originalPurchaseDate': originalPurchaseDate?.toIso8601String(),
      'autoRenewEnabled': autoRenewEnabled,
      'lastSyncedAt': lastSyncedAt?.toIso8601String(),
    };
  }

  static SubscriptionSnapshot fromJson(
    Map<String, Object?> json, {
    required DateTime fallbackNow,
  }) {
    DateTime? parseDate(Object? value) {
      if (value is String) {
        return DateTime.tryParse(value);
      }
      return null;
    }

    SubscriptionStatus parseStatus(Object? value) {
      if (value is String) {
        return SubscriptionStatus.values.firstWhere(
          (status) => status.name == value,
          orElse: () => SubscriptionStatus.unknown,
        );
      }
      return SubscriptionStatus.unknown;
    }

    return SubscriptionSnapshot(
      status: parseStatus(json['status']),
      trialStartedAt: parseDate(json['trialStartedAt']),
      trialEndsAt: parseDate(json['trialEndsAt']),
      premiumExpiresAt: parseDate(json['premiumExpiresAt']),
      originalPurchaseDate: parseDate(json['originalPurchaseDate']),
      autoRenewEnabled: json['autoRenewEnabled'] as bool? ?? false,
      lastSyncedAt: parseDate(json['lastSyncedAt']) ?? fallbackNow,
    );
  }
}

/// Minimal receipt data required for local bookkeeping.
class SubscriptionReceipt {
  const SubscriptionReceipt({
    required this.productId,
    required this.originalPurchaseDate,
    required this.expiresDate,
    required this.isTrialPeriod,
    required this.autoRenewEnabled,
  });

  final String productId;
  final DateTime? originalPurchaseDate;
  final DateTime? expiresDate;
  final bool isTrialPeriod;
  final bool autoRenewEnabled;
}

/// Handles subscription receipts, trial windows, and cached state.
class SubscriptionService {
  SubscriptionService({
    SharedPreferences? preferences,
    DateTime Function()? now,
  })  : _preferences = preferences,
        _now = now ?? _defaultNow,
        _snapshot = ValueNotifier(
          SubscriptionSnapshot.initial(
            now: (now ?? _defaultNow)(),
          ),
        );

  static const _storageKey = 'subscription.snapshot.v1';

  final DateTime Function() _now;
  SharedPreferences? _preferences;
  final ValueNotifier<SubscriptionSnapshot> _snapshot;

  bool get isInitialized => _preferences != null;
  ValueListenable<SubscriptionSnapshot> get snapshotListenable => _snapshot;
  SubscriptionSnapshot get snapshot => _snapshot.value;

  Future<void> initialize() async {
    await _ensurePreferences();
    final prefs = _preferences!;

    final cached = prefs.getString(_storageKey);
    final now = _now();
    if (cached != null) {
      try {
        final map = Map<String, Object?>.from(
          jsonDecode(cached) as Map<String, dynamic>,
        );
        _snapshot.value = SubscriptionSnapshot.fromJson(
          map,
          fallbackNow: now,
        ).evaluate(now);
      } catch (_) {
        _snapshot.value = SubscriptionSnapshot.initial(now: now);
      }
    } else {
      _snapshot.value = SubscriptionSnapshot.initial(now: now);
    }

    await restorePurchases();
  }

  Future<void> restorePurchases() async {
    await _ensurePreferences();
    final now = _now();
    final receipt = await _fetchLatestReceipt();

    SubscriptionSnapshot nextSnapshot;
    if (receipt != null) {
      nextSnapshot = _snapshot.value.applyReceipt(receipt, now);
    } else {
      nextSnapshot = _snapshot.value.evaluate(now);
    }

    await _persistSnapshot(nextSnapshot);
    _snapshot.value = nextSnapshot;
  }

  Future<void> updateWithReceipt(SubscriptionReceipt receipt) async {
    await _ensurePreferences();
    final now = _now();
    final nextSnapshot = _snapshot.value.applyReceipt(receipt, now);
    await _persistSnapshot(nextSnapshot);
    _snapshot.value = nextSnapshot;
  }

  Future<void> clearCachedState() async {
    await _ensurePreferences();
    await _preferences!.remove(_storageKey);
    _snapshot.value = SubscriptionSnapshot.initial(now: _now());
  }

  Future<void> _persistSnapshot(SubscriptionSnapshot snapshot) async {
    final prefs = _preferences;
    if (prefs == null) return;
    await prefs.setString(_storageKey, jsonEncode(snapshot.toJson()));
  }

  Future<void> _ensurePreferences() async {
    _preferences ??= await SharedPreferences.getInstance();
  }

  Future<SubscriptionReceipt?> _fetchLatestReceipt() async {
    // TODO: Integrate with StoreKit/Play Billing restore APIs.
    return null;
  }
}

DateTime _defaultNow() => DateTime.now();
