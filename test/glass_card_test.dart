import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:everyday_christian/components/glass_card.dart';

void main() {
  testWidgets('GlassContainer should render with default properties', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GlassContainer(
            child: Text('Test Content'),
          ),
        ),
      ),
    );

    expect(find.text('Test Content'), findsOneWidget);
    expect(find.byType(GlassContainer), findsOneWidget);
  });

  testWidgets('GlassContainer should accept custom width and height', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GlassContainer(
            width: 200,
            height: 100,
            child: Text('Test'),
          ),
        ),
      ),
    );

    final container = tester.widget<Container>(
      find.ancestor(
        of: find.byType(BackdropFilter),
        matching: find.byType(Container),
      ).first,
    );

    expect(container.constraints?.maxWidth ?? double.infinity, equals(200));
  });

  testWidgets('GlassContainer should apply custom border radius', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GlassContainer(
            borderRadius: 16,
            child: Text('Test'),
          ),
        ),
      ),
    );

    expect(find.byType(GlassContainer), findsOneWidget);
  });

  testWidgets('GlassContainer should accept custom gradient colors', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GlassContainer(
            gradientColors: [
              Colors.red.withValues(alpha: 0.2),
              Colors.blue.withValues(alpha: 0.1),
            ],
            child: const Text('Test'),
          ),
        ),
      ),
    );

    expect(find.byType(GlassContainer), findsOneWidget);
  });

  testWidgets('GlassContainer should accept custom gradient stops', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GlassContainer(
            gradientStops: [0.2, 0.8],
            child: Text('Test'),
          ),
        ),
      ),
    );

    expect(find.byType(GlassContainer), findsOneWidget);
  });

  testWidgets('GlassContainer should apply custom padding', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GlassContainer(
            padding: EdgeInsets.all(30),
            child: Text('Test'),
          ),
        ),
      ),
    );

    expect(find.byType(GlassContainer), findsOneWidget);
  });

  testWidgets('GlassContainer should apply custom margin', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GlassContainer(
            margin: EdgeInsets.all(15),
            child: Text('Test'),
          ),
        ),
      ),
    );

    expect(find.byType(GlassContainer), findsOneWidget);
  });

  testWidgets('GlassContainer should apply custom border', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GlassContainer(
            border: Border.all(color: Colors.white, width: 2),
            child: const Text('Test'),
          ),
        ),
      ),
    );

    expect(find.byType(GlassContainer), findsOneWidget);
  });

  testWidgets('GlassContainer should apply custom blur strength', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GlassContainer(
            blurStrength: 8.0,
            child: Text('Test'),
          ),
        ),
      ),
    );

    expect(find.byType(GlassContainer), findsOneWidget);
    expect(find.byType(BackdropFilter), findsOneWidget);
  });

  // GlassCard tests
  testWidgets('GlassCard should render with default properties', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GlassCard(
            child: Text('Card Content'),
          ),
        ),
      ),
    );

    expect(find.text('Card Content'), findsOneWidget);
    expect(find.byType(GlassCard), findsOneWidget);
  });

  testWidgets('GlassCard should render in dark theme', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: const Scaffold(
          body: GlassCard(
            child: Text('Dark Card'),
          ),
        ),
      ),
    );

    expect(find.text('Dark Card'), findsOneWidget);
    expect(find.byType(GlassCard), findsOneWidget);
  });

  testWidgets('GlassCard should render in light theme', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.light(),
        home: const Scaffold(
          body: GlassCard(
            child: Text('Light Card'),
          ),
        ),
      ),
    );

    expect(find.text('Light Card'), findsOneWidget);
    expect(find.byType(GlassCard), findsOneWidget);
  });

  testWidgets('GlassCard should accept custom dimensions', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GlassCard(
            width: 300,
            height: 200,
            child: Text('Sized Card'),
          ),
        ),
      ),
    );

    expect(find.byType(GlassCard), findsOneWidget);
  });

  testWidgets('GlassCard should accept custom blur sigma', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GlassCard(
            blurSigma: 20,
            child: Text('Blurred Card'),
          ),
        ),
      ),
    );

    expect(find.byType(GlassCard), findsOneWidget);
    expect(find.byType(BackdropFilter), findsWidgets);
  });

  testWidgets('GlassCard should accept custom border radius', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GlassCard(
            borderRadius: 12,
            child: Text('Rounded Card'),
          ),
        ),
      ),
    );

    expect(find.byType(GlassCard), findsOneWidget);
  });

  testWidgets('GlassCard should accept custom border color and width', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GlassCard(
            borderColor: Colors.blue,
            borderWidth: 3,
            child: Text('Bordered Card'),
          ),
        ),
      ),
    );

    expect(find.byType(GlassCard), findsOneWidget);
  });

  testWidgets('GlassCard should accept custom padding', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GlassCard(
            padding: EdgeInsets.all(24),
            child: Text('Padded Card'),
          ),
        ),
      ),
    );

    expect(find.byType(GlassCard), findsOneWidget);
  });

  testWidgets('GlassCard should accept custom margin', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GlassCard(
            margin: EdgeInsets.all(10),
            child: Text('Margined Card'),
          ),
        ),
      ),
    );

    expect(find.byType(GlassCard), findsOneWidget);
  });

  // GlassBottomSheet tests
  testWidgets('GlassBottomSheet should render with default properties', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GlassBottomSheet(
            child: Text('Sheet Content'),
          ),
        ),
      ),
    );

    expect(find.text('Sheet Content'), findsOneWidget);
    expect(find.byType(GlassBottomSheet), findsOneWidget);
  });

  testWidgets('GlassBottomSheet should render in dark theme', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: const Scaffold(
          body: GlassBottomSheet(
            child: Text('Dark Sheet'),
          ),
        ),
      ),
    );

    expect(find.text('Dark Sheet'), findsOneWidget);
    expect(find.byType(GlassBottomSheet), findsOneWidget);
  });

  testWidgets('GlassBottomSheet should render in light theme', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.light(),
        home: const Scaffold(
          body: GlassBottomSheet(
            child: Text('Light Sheet'),
          ),
        ),
      ),
    );

    expect(find.text('Light Sheet'), findsOneWidget);
    expect(find.byType(GlassBottomSheet), findsOneWidget);
  });

  testWidgets('GlassBottomSheet should accept custom border radius', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GlassBottomSheet(
            borderRadius: 16,
            child: Text('Rounded Sheet'),
          ),
        ),
      ),
    );

    expect(find.byType(GlassBottomSheet), findsOneWidget);
  });

  testWidgets('GlassBottomSheet should accept custom blur sigma', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GlassBottomSheet(
            blurSigma: 30,
            child: Text('Blurred Sheet'),
          ),
        ),
      ),
    );

    expect(find.byType(GlassBottomSheet), findsOneWidget);
    expect(find.byType(BackdropFilter), findsWidgets);
  });
}
