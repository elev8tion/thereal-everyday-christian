import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/subscription_service.dart';

/// Provides access to the singleton SubscriptionService.
final subscriptionServiceProvider = Provider<SubscriptionService>((ref) {
  return SubscriptionService.instance;
});

/// Ensures subscription initialisation runs during bootstrap flows.
final subscriptionInitProvider = FutureProvider<void>((ref) async {
  final service = ref.read(subscriptionServiceProvider);
  await service.initialize();
});

/// Snapshot of the user's subscription state.
class SubscriptionSnapshot {
  const SubscriptionSnapshot({
    required this.status,
    required this.isPremium,
    required this.isInTrial,
    required this.hasTrialExpired,
    required this.canSendMessage,
    required this.remainingMessages,
    required this.messagesUsed,
    required this.trialDaysRemaining,
    required this.premiumMessagesRemaining,
    required this.trialMessagesRemainingToday,
  });

  final SubscriptionStatus status;
  final bool isPremium;
  final bool isInTrial;
  final bool hasTrialExpired;
  final bool canSendMessage;
  final int remainingMessages;
  final int messagesUsed;
  final int trialDaysRemaining;
  final int premiumMessagesRemaining;
  final int trialMessagesRemainingToday;
}

/// Memoises the latest subscription information for UI consumers.
final subscriptionSnapshotProvider = Provider<SubscriptionSnapshot>((ref) {
  final service = ref.watch(subscriptionServiceProvider);
  final status = service.getSubscriptionStatus();

  return SubscriptionSnapshot(
    status: status,
    isPremium: service.isPremium,
    isInTrial: service.isInTrial,
    hasTrialExpired: service.hasTrialExpired,
    canSendMessage: service.canSendMessage,
    remainingMessages: service.remainingMessages,
    messagesUsed: service.messagesUsed,
    trialDaysRemaining: service.trialDaysRemaining,
    premiumMessagesRemaining: service.premiumMessagesRemaining,
    trialMessagesRemainingToday: service.trialMessagesRemainingToday,
  );
});

final subscriptionStatusProvider = Provider<SubscriptionStatus>((ref) {
  return ref.watch(subscriptionSnapshotProvider).status;
});

final isPremiumProvider = Provider<bool>((ref) {
  return ref.watch(subscriptionSnapshotProvider).isPremium;
});

final isInTrialProvider = Provider<bool>((ref) {
  return ref.watch(subscriptionSnapshotProvider).isInTrial;
});

final hasTrialExpiredProvider = Provider<bool>((ref) {
  return ref.watch(subscriptionSnapshotProvider).hasTrialExpired;
});

final remainingMessagesProvider = Provider<int>((ref) {
  return ref.watch(subscriptionSnapshotProvider).remainingMessages;
});

final messagesUsedProvider = Provider<int>((ref) {
  return ref.watch(subscriptionSnapshotProvider).messagesUsed;
});

final canSendMessageProvider = Provider<bool>((ref) {
  return ref.watch(subscriptionSnapshotProvider).canSendMessage;
});

final trialDaysRemainingProvider = Provider<int>((ref) {
  return ref.watch(subscriptionSnapshotProvider).trialDaysRemaining;
});

final premiumMessagesRemainingProvider = Provider<int>((ref) {
  return ref.watch(subscriptionSnapshotProvider).premiumMessagesRemaining;
});

final trialMessagesRemainingTodayProvider = Provider<int>((ref) {
  return ref.watch(subscriptionSnapshotProvider).trialMessagesRemainingToday;
});
