import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:everyday_christian/components/clear_glass_card.dart';

void main() {
  testWidgets('ClearGlassCard should render with default properties', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ClearGlassCard(
            child: Text('Clear Glass Content'),
          ),
        ),
      ),
    );

    expect(find.text('Clear Glass Content'), findsOneWidget);
    expect(find.byType(ClearGlassCard), findsOneWidget);
  });

  testWidgets('ClearGlassCard should handle onTap callback', (WidgetTester tester) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ClearGlassCard(
            onTap: () => tapped = true,
            child: const Text('Tappable Card'),
          ),
        ),
      ),
    );

    expect(find.byType(GestureDetector), findsOneWidget);
    await tester.tap(find.byType(ClearGlassCard));
    expect(tapped, isTrue);
  });

  testWidgets('ClearGlassCard should not wrap in GestureDetector when onTap is null', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ClearGlassCard(
            child: Text('Non-tappable Card'),
          ),
        ),
      ),
    );

    expect(find.byType(GestureDetector), findsNothing);
  });

  testWidgets('ClearGlassCard should accept custom margin', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ClearGlassCard(
            margin: EdgeInsets.all(20),
            child: Text('Margined Card'),
          ),
        ),
      ),
    );

    expect(find.byType(ClearGlassCard), findsOneWidget);
  });

  testWidgets('ClearGlassCard should accept custom padding', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ClearGlassCard(
            padding: EdgeInsets.all(24),
            child: Text('Padded Card'),
          ),
        ),
      ),
    );

    expect(find.byType(ClearGlassCard), findsOneWidget);
  });

  testWidgets('ClearGlassCard should accept custom border radius', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ClearGlassCard(
            borderRadius: 15,
            child: Text('Rounded Card'),
          ),
        ),
      ),
    );

    expect(find.byType(ClearGlassCard), findsOneWidget);
  });

  testWidgets('ClearGlassCard should accept custom blur strength', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ClearGlassCard(
            blurStrength: 25.0,
            child: Text('Blurred Card'),
          ),
        ),
      ),
    );

    expect(find.byType(ClearGlassCard), findsOneWidget);
    expect(find.byType(BackdropFilter), findsOneWidget);
  });
}
