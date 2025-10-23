import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:everyday_christian/widgets/category_statistics_widget.dart';
import 'package:everyday_christian/core/models/prayer_category.dart';
import 'package:everyday_christian/core/providers/category_providers.dart';

void main() {
  group('CategoryStatisticsWidget Tests', () {
    testWidgets('should show loading indicator while loading', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            allCategoryStatisticsProvider.overrideWith(
              (ref) => Future.delayed(
                const Duration(seconds: 1),
                () => <CategoryStatistics>[],
              ),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: CategoryStatisticsWidget(),
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show statistics when loaded', (tester) async {
      final testCategory = PrayerCategory(
        id: 'test_id',
        name: 'Test Category',
        iconCodePoint: Icons.star.codePoint,
        colorValue: Colors.blue.toARGB32(),
        dateCreated: DateTime.now(),
      );

      final testStats = CategoryStatistics.fromCategory(
        testCategory,
        total: 10,
        active: 6,
        answered: 4,
        archived: 0,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            allCategoryStatisticsProvider.overrideWith(
              (ref) => Future.value([testStats]),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: CategoryStatisticsWidget(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Prayer Statistics by Category'), findsOneWidget);
      expect(find.text('Test Category'), findsOneWidget);
      expect(find.text('10 prayers'), findsOneWidget);
    });

    testWidgets('should show error message on error', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            allCategoryStatisticsProvider.overrideWith(
              (ref) => Future.error('Test error'),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: CategoryStatisticsWidget(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Error loading statistics'), findsOneWidget);
    });

    testWidgets('should hide widget when no statistics', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            allCategoryStatisticsProvider.overrideWith(
              (ref) => Future.value(<CategoryStatistics>[]),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: CategoryStatisticsWidget(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(CategoryStatisticsWidget), findsOneWidget);
      expect(find.text('Prayer Statistics by Category'), findsNothing);
    });
  });
}
