import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:everyday_christian/components/calendar_heatmap_widget.dart';

void main() {
  group('CalendarHeatmapWidget', () {
    testWidgets('should render without activity data', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CalendarHeatmapWidget(
              activityData: {},
            ),
          ),
        ),
      );

      expect(find.byType(CalendarHeatmapWidget), findsOneWidget);
    });

    testWidgets('should display activity data', (WidgetTester tester) async {
      final activityData = {
        DateTime(2025, 10, 1): 2,
        DateTime(2025, 10, 2): 1,
        DateTime(2025, 10, 3): 3,
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarHeatmapWidget(
              activityData: activityData,
            ),
          ),
        ),
      );

      expect(find.byType(CalendarHeatmapWidget), findsOneWidget);

      // Should render the grid
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should display legend', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CalendarHeatmapWidget(
              activityData: {},
            ),
          ),
        ),
      );

      // Check for "Less" and "More" labels
      expect(find.text('Less'), findsOneWidget);
      expect(find.text('More'), findsOneWidget);
    });

    testWidgets('should display day labels', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CalendarHeatmapWidget(
              activityData: {},
            ),
          ),
        ),
      );

      // Check for M, W, F labels
      expect(find.text('M'), findsOneWidget);
      expect(find.text('W'), findsOneWidget);
      expect(find.text('F'), findsOneWidget);
    });

    testWidgets('should use custom color function if provided', (WidgetTester tester) async {
      Color customColorFunction(int count) {
        if (count == 0) return Colors.grey;
        return Colors.blue;
      }

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarHeatmapWidget(
              activityData: const {},
              colorForCount: customColorFunction,
            ),
          ),
        ),
      );

      expect(find.byType(CalendarHeatmapWidget), findsOneWidget);
    });

    testWidgets('should handle horizontal scrolling', (WidgetTester tester) async {
      final activityData = <DateTime, int>{};

      // Add many days of data to trigger horizontal scrolling
      for (int i = 0; i < 100; i++) {
        activityData[DateTime(2025, 10, 1).add(Duration(days: i))] = 1;
      }

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarHeatmapWidget(
              activityData: activityData,
              columns: 20,
            ),
          ),
        ),
      );

      // Should have a horizontal scroll view
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });
}
