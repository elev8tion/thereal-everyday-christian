import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:everyday_christian/components/theme_selection_dialog.dart';
import 'package:everyday_christian/theme/app_theme.dart';

void main() {
  group('ThemeSelectionDialog', () {
    testWidgets('should display dialog with all themes', (WidgetTester tester) async {
      List<String>? selectedThemes;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => ThemeSelectionDialog(
                      availableThemes: const ['Faith', 'Hope', 'Love'],
                      onThemesSelected: (themes) {
                        selectedThemes = themes;
                      },
                    ),
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      // Open dialog
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Verify dialog elements
      expect(find.text('Choose Themes'), findsOneWidget);
      expect(find.text('Select up to 2 themes (optional)'), findsOneWidget);
      expect(find.text('0/2 themes selected'), findsOneWidget);
      expect(find.text('Faith'), findsOneWidget);
      expect(find.text('Hope'), findsOneWidget);
      expect(find.text('Love'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
      expect(find.text('Select Themes'), findsOneWidget);
    });

    testWidgets('should allow selecting up to 2 themes', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => ThemeSelectionDialog(
                      availableThemes: const ['Faith', 'Hope', 'Love'],
                      onThemesSelected: (_) {},
                    ),
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Select first theme
      await tester.tap(find.text('Faith'));
      await tester.pumpAndSettle();
      expect(find.text('1/2 themes selected'), findsOneWidget);
      expect(find.text('Save with 1 theme'), findsOneWidget);

      // Select second theme
      await tester.tap(find.text('Hope'));
      await tester.pumpAndSettle();
      expect(find.text('Maximum themes selected'), findsOneWidget);
      expect(find.text('Save with 2 themes'), findsOneWidget);
    });

    testWidgets('should prevent selecting more than 2 themes', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => ThemeSelectionDialog(
                      availableThemes: const ['Faith', 'Hope', 'Love'],
                      onThemesSelected: (_) {},
                    ),
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Select 2 themes
      await tester.tap(find.text('Faith'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hope'));
      await tester.pumpAndSettle();

      // Try to select third theme - should have reduced opacity
      final loveWidget = find.ancestor(
        of: find.text('Love'),
        matching: find.byType(Opacity),
      );
      expect(loveWidget, findsOneWidget);
      final opacity = tester.widget<Opacity>(loveWidget);
      expect(opacity.opacity, 0.4); // Should be disabled
    });

    testWidgets('Skip button should save with empty themes', (WidgetTester tester) async {
      List<String>? selectedThemes;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => ThemeSelectionDialog(
                      availableThemes: const ['Faith', 'Hope'],
                      onThemesSelected: (themes) {
                        selectedThemes = themes;
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Tap Skip button
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      // Verify empty themes passed
      expect(selectedThemes, isNotNull);
      expect(selectedThemes, isEmpty);
    });

    testWidgets('Skip button should clear selected themes', (WidgetTester tester) async {
      List<String>? selectedThemes;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => ThemeSelectionDialog(
                      availableThemes: const ['Faith', 'Hope'],
                      onThemesSelected: (themes) {
                        selectedThemes = themes;
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Select a theme
      await tester.tap(find.text('Faith'));
      await tester.pumpAndSettle();
      expect(find.text('Save with 1 theme'), findsOneWidget);

      // Tap Skip button (should ignore selections)
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      // Verify empty themes passed (selections ignored)
      expect(selectedThemes, isNotNull);
      expect(selectedThemes, isEmpty);
    });

    testWidgets('Save button should be disabled when no themes selected', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => ThemeSelectionDialog(
                      availableThemes: const ['Faith', 'Hope'],
                      onThemesSelected: (_) {},
                    ),
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Save button should show "Select Themes" when disabled
      expect(find.text('Select Themes'), findsOneWidget);

      // Find the InkWell wrapping the save button text
      final saveButton = find.ancestor(
        of: find.text('Select Themes'),
        matching: find.byType(InkWell),
      );
      expect(saveButton, findsOneWidget);

      // Verify onTap is null (disabled)
      final inkWell = tester.widget<InkWell>(saveButton);
      expect(inkWell.onTap, isNull);
    });

    testWidgets('Save button should pass selected themes', (WidgetTester tester) async {
      List<String>? selectedThemes;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => ThemeSelectionDialog(
                      availableThemes: const ['Faith', 'Hope', 'Love'],
                      onThemesSelected: (themes) {
                        selectedThemes = themes;
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Select themes
      await tester.tap(find.text('Faith'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hope'));
      await tester.pumpAndSettle();

      // Tap Save button
      await tester.tap(find.text('Save with 2 themes'));
      await tester.pumpAndSettle();

      // Verify correct themes passed
      expect(selectedThemes, isNotNull);
      expect(selectedThemes, hasLength(2));
      expect(selectedThemes, containsAll(['Faith', 'Hope']));
    });

    testWidgets('should deselect theme when tapped again', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => ThemeSelectionDialog(
                      availableThemes: const ['Faith'],
                      onThemesSelected: (_) {},
                    ),
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Select theme
      await tester.tap(find.text('Faith'));
      await tester.pumpAndSettle();
      expect(find.text('1/2 themes selected'), findsOneWidget);

      // Deselect theme
      await tester.tap(find.text('Faith'));
      await tester.pumpAndSettle();
      expect(find.text('0/2 themes selected'), findsOneWidget);
      expect(find.text('Select Themes'), findsOneWidget);
    });

    testWidgets('should display circular checkboxes with gold color', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => ThemeSelectionDialog(
                      availableThemes: const ['Faith'],
                      onThemesSelected: (_) {},
                    ),
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Find checkbox (now using Checkbox widget, not CheckboxListTile)
      final checkbox = find.byType(Checkbox);
      expect(checkbox, findsOneWidget);

      final checkboxWidget = tester.widget<Checkbox>(checkbox);
      expect(checkboxWidget.shape, isA<CircleBorder>());
      expect(checkboxWidget.checkColor, AppTheme.goldColor);
      expect(checkboxWidget.activeColor, Colors.transparent);
    });
  });
}
