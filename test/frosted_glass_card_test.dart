import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:everyday_christian/components/frosted_glass_card.dart';

void main() {
  testWidgets('FrostedGlassCard should render with default properties', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FrostedGlassCard(
            child: Text('Frosted Glass Content'),
          ),
        ),
      ),
    );

    expect(find.text('Frosted Glass Content'), findsOneWidget);
    expect(find.byType(FrostedGlassCard), findsOneWidget);
  });

  testWidgets('FrostedGlassCard should handle onTap callback', (WidgetTester tester) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FrostedGlassCard(
            onTap: () => tapped = true,
            child: const Text('Tappable Frosted Card'),
          ),
        ),
      ),
    );

    expect(find.byType(GestureDetector), findsOneWidget);
    await tester.tap(find.byType(FrostedGlassCard));
    expect(tapped, isTrue);
  });

  testWidgets('FrostedGlassCard should not wrap in GestureDetector when onTap is null', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FrostedGlassCard(
            child: Text('Non-tappable Frosted Card'),
          ),
        ),
      ),
    );

    expect(find.byType(GestureDetector), findsNothing);
  });

  testWidgets('FrostedGlassCard should accept light intensity', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FrostedGlassCard(
            intensity: GlassIntensity.light,
            child: Text('Light Glass'),
          ),
        ),
      ),
    );

    expect(find.byType(FrostedGlassCard), findsOneWidget);
  });

  testWidgets('FrostedGlassCard should accept medium intensity', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FrostedGlassCard(
            intensity: GlassIntensity.medium,
            child: Text('Medium Glass'),
          ),
        ),
      ),
    );

    expect(find.byType(FrostedGlassCard), findsOneWidget);
  });

  testWidgets('FrostedGlassCard should accept strong intensity', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FrostedGlassCard(
            intensity: GlassIntensity.strong,
            child: Text('Strong Glass'),
          ),
        ),
      ),
    );

    expect(find.byType(FrostedGlassCard), findsOneWidget);
  });

  testWidgets('FrostedGlassCard should accept custom border color', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FrostedGlassCard(
            borderColor: Colors.blue,
            child: Text('Blue Border Card'),
          ),
        ),
      ),
    );

    expect(find.byType(FrostedGlassCard), findsOneWidget);
  });

  testWidgets('FrostedGlassCard should show inner border by default', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FrostedGlassCard(
            child: Text('Inner Border Card'),
          ),
        ),
      ),
    );

    expect(find.byType(FrostedGlassCard), findsOneWidget);
  });

  testWidgets('FrostedGlassCard should hide inner border when disabled', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FrostedGlassCard(
            showInnerBorder: false,
            child: Text('No Inner Border Card'),
          ),
        ),
      ),
    );

    expect(find.byType(FrostedGlassCard), findsOneWidget);
  });

  testWidgets('FrostedGlassCard should accept custom margin', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FrostedGlassCard(
            margin: EdgeInsets.all(20),
            child: Text('Margined Frosted Card'),
          ),
        ),
      ),
    );

    expect(find.byType(FrostedGlassCard), findsOneWidget);
  });

  testWidgets('FrostedGlassCard should accept custom padding', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FrostedGlassCard(
            padding: EdgeInsets.all(24),
            child: Text('Padded Frosted Card'),
          ),
        ),
      ),
    );

    expect(find.byType(FrostedGlassCard), findsOneWidget);
  });

  testWidgets('FrostedGlassCard should accept custom border radius', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FrostedGlassCard(
            borderRadius: 30,
            child: Text('Rounded Frosted Card'),
          ),
        ),
      ),
    );

    expect(find.byType(FrostedGlassCard), findsOneWidget);
  });

  testWidgets('FrostedGlassCard should accept custom blur strength', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FrostedGlassCard(
            blurStrength: 60.0,
            child: Text('Very Blurred Card'),
          ),
        ),
      ),
    );

    expect(find.byType(FrostedGlassCard), findsOneWidget);
    expect(find.byType(BackdropFilter), findsOneWidget);
  });
}
