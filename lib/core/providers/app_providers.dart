import 'package:everyday_christian/core/services/bible_service.dart';
import 'package:everyday_christian/core/services/subscription_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for BibleService
final bibleServiceProvider = Provider<BibleService>((ref) {
  return BibleService();
});

/// Provider for SubscriptionService
final subscriptionServiceProvider = Provider<SubscriptionService>((ref) {
  return SubscriptionService();
});

/// Listen to subscription state updates.
final subscriptionSnapshotProvider =
    ValueListenableProvider<SubscriptionSnapshot>((ref) {
  final service = ref.watch(subscriptionServiceProvider);
  return service.snapshotListenable;
});

/// Provider for ReadingPlanService (placeholder)
final readingPlanServiceProvider = Provider<ReadingPlanService>((ref) {
  return ReadingPlanService();
});

/// Placeholder reading plan service
class ReadingPlanService {
  Future<void> markReadingComplete(String readingId) async {
    // TODO: Implement actual reading plan completion logic
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
