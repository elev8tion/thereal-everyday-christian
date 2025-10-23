import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:everyday_christian/components/reading_progress_stats_widget.dart';

void main() {
  group('ReadingProgressStatsWidget', () {
    testWidgets('should display all statistics', (WidgetTester tester) async {
      final stats = {
        'total_readings': 100,
        'completed_readings': 50,
        'incomplete_readings': 50,
        'progress_percentage': 50.0,
        'current_streak': 5,
        'longest_streak': 10,
        'total_days_active': 25,
        'average_per_day': 2.0,
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReadingProgressStatsWidget(stats: stats),
          ),
        ),
      );

      expect(find.byType(ReadingProgressStatsWidget), findsOneWidget);

      // Check for streak values
      expect(find.text('5'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);

      // Check for active days
      expect(find.text('25'), findsOneWidget);

      // Check for completed readings
      expect(find.text('50'), findsOneWidget);
    });

    testWidgets('should display estimated completion date when provided',
        (WidgetTester tester) async {
      final stats = {
        'total_readings': 100,
        'completed_readings': 50,
        'incomplete_readings': 50,
        'progress_percentage': 50.0,
        'current_streak': 5,
        'longest_streak': 10,
        'total_days_active': 25,
        'average_per_day': 2.0,
      };

      final estimatedDate = DateTime(2025, 12, 31);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReadingProgressStatsWidget(
              stats: stats,
              estimatedCompletionDate: estimatedDate,
            ),
          ),
        ),
      );

      expect(find.byType(ReadingProgressStatsWidget), findsOneWidget);

      // Should display the estimated completion card
      expect(find.text('Estimated Completion'), findsOneWidget);
      expect(find.text('December 31, 2025'), findsOneWidget);
    });

    testWidgets('should not display estimated completion when not provided',
        (WidgetTester tester) async {
      final stats = {
        'total_readings': 100,
        'completed_readings': 50,
        'incomplete_readings': 50,
        'progress_percentage': 50.0,
        'current_streak': 5,
        'longest_streak': 10,
        'total_days_active': 25,
        'average_per_day': 2.0,
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReadingProgressStatsWidget(stats: stats),
          ),
        ),
      );

      expect(find.byType(ReadingProgressStatsWidget), findsOneWidget);

      // Should not display the estimated completion card
      expect(find.text('Estimated Completion'), findsNothing);
    });

    testWidgets('should display icons for each stat category',
        (WidgetTester tester) async {
      final stats = {
        'total_readings': 100,
        'completed_readings': 50,
        'incomplete_readings': 50,
        'progress_percentage': 50.0,
        'current_streak': 5,
        'longest_streak': 10,
        'total_days_active': 25,
        'average_per_day': 2.0,
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReadingProgressStatsWidget(stats: stats),
          ),
        ),
      );

      // Check for various icons
      expect(find.byIcon(Icons.local_fire_department), findsOneWidget);
      expect(find.byIcon(Icons.emoji_events), findsOneWidget);
      expect(find.byIcon(Icons.event_available), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('should handle singular and plural day labels correctly',
        (WidgetTester tester) async {
      final statsWithSingular = {
        'total_readings': 10,
        'completed_readings': 1,
        'incomplete_readings': 9,
        'progress_percentage': 10.0,
        'current_streak': 1,
        'longest_streak': 1,
        'total_days_active': 1,
        'average_per_day': 1.0,
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReadingProgressStatsWidget(stats: statsWithSingular),
          ),
        ),
      );

      // Should use singular form
      expect(find.textContaining('day'), findsWidgets);
      expect(find.textContaining('days'), findsNothing);
    });

    testWidgets('should show overdue message for past estimated dates',
        (WidgetTester tester) async {
      final stats = {
        'total_readings': 100,
        'completed_readings': 50,
        'incomplete_readings': 50,
        'progress_percentage': 50.0,
        'current_streak': 5,
        'longest_streak': 10,
        'total_days_active': 25,
        'average_per_day': 2.0,
      };

      final pastDate = DateTime.now().subtract(const Duration(days: 5));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReadingProgressStatsWidget(
              stats: stats,
              estimatedCompletionDate: pastDate,
            ),
          ),
        ),
      );

      expect(find.byType(ReadingProgressStatsWidget), findsOneWidget);

      // Should show overdue message
      expect(find.textContaining('overdue'), findsOneWidget);
    });

    testWidgets('should handle zero values gracefully', (WidgetTester tester) async {
      final statsWithZeros = {
        'total_readings': 10,
        'completed_readings': 0,
        'incomplete_readings': 10,
        'progress_percentage': 0.0,
        'current_streak': 0,
        'longest_streak': 0,
        'total_days_active': 0,
        'average_per_day': 0.0,
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReadingProgressStatsWidget(stats: statsWithZeros),
          ),
        ),
      );

      expect(find.byType(ReadingProgressStatsWidget), findsOneWidget);
      expect(find.text('0'), findsWidgets);
    });
  });
}
