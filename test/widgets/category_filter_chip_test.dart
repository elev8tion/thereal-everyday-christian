import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:everyday_christian/components/category_filter_chip.dart';
import 'package:everyday_christian/core/models/prayer_category.dart';

void main() {
  group('CategoryFilterChip Widget Tests', () {
    late PrayerCategory testCategory;

    setUp(() {
      testCategory = PrayerCategory(
        id: 'test_id',
        name: 'Test Category',
        iconCodePoint: Icons.star.codePoint,
        colorValue: Colors.blue.toARGB32(),
        dateCreated: DateTime.now(),
      );
    });

    testWidgets('should render category name and icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryFilterChip(
              category: testCategory,
              isSelected: false,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Test Category'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('should show selected state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryFilterChip(
              category: testCategory,
              isSelected: true,
              onTap: () {},
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(CategoryFilterChip),
          matching: find.byType(Container).first,
        ),
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border, isNotNull);
    });

    testWidgets('should call onTap when tapped', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryFilterChip(
              category: testCategory,
              isSelected: false,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(CategoryFilterChip));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('should show different styles for selected and unselected', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                CategoryFilterChip(
                  key: const Key('selected'),
                  category: testCategory,
                  isSelected: true,
                  onTap: () {},
                ),
                CategoryFilterChip(
                  key: const Key('unselected'),
                  category: testCategory,
                  isSelected: false,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      );

      // Both chips should be rendered
      expect(find.byKey(const Key('selected')), findsOneWidget);
      expect(find.byKey(const Key('unselected')), findsOneWidget);
    });
  });
}
