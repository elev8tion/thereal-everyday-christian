import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:everyday_christian/screens/auth_screen.dart';
import 'package:everyday_christian/core/database/database_helper.dart';

void main() {
  setUpAll(() async {
    // Initialize Flutter bindings for widget tests
    TestWidgetsFlutterBinding.ensureInitialized();

    // Initialize sqflite for testing
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    // Use in-memory database for testing
    DatabaseHelper.setTestDatabasePath(inMemoryDatabasePath);
  });

  tearDownAll(() async {
    // Clean up database resources
    await DatabaseHelper.instance.close();
  });

  testWidgets('AuthScreen renders without crashing', (WidgetTester tester) async {
    // Build AuthScreen wrapped in necessary providers
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: AuthScreen(),
        ),
      ),
    );

    // Initial pump - widget should build
    expect(find.byType(AuthScreen), findsOneWidget);

    // Wait for initial animations (300ms delay + animation time)
    await tester.pump(const Duration(milliseconds: 500));

    // Pump frames until animations settle (with timeout)
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Verify screen rendered successfully
    expect(find.byType(Scaffold), findsOneWidget);

    // Ensure all pending timers complete before test ends
    await tester.pumpAndSettle();
  });

  testWidgets('AuthScreen displays welcome message after animations', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: AuthScreen(),
        ),
      ),
    );

    // Wait for content to appear (controlled by _showContent flag with 300ms delay)
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Verify welcome text appears after animations
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Sign in to continue your spiritual journey'), findsOneWidget);

    // Ensure all pending timers complete before test ends
    await tester.pumpAndSettle();
  });

  testWidgets('AuthScreen has sign in and sign up tabs', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: AuthScreen(),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Verify tabs are present
    expect(find.text('Sign In'), findsWidgets); // Tab and potentially button
    expect(find.text('Sign Up'), findsAtLeastNWidgets(1)); // At least the tab

    // Ensure all pending timers complete before test ends
    await tester.pumpAndSettle();
  });

  testWidgets('AuthScreen contains authentication form', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: AuthScreen(),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Verify authentication UI elements are present
    expect(find.byType(TextFormField), findsAtLeastNWidgets(2));

    // Ensure all pending timers complete before test ends
    await tester.pumpAndSettle();
  });

  testWidgets('Email and password fields are present after animations', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: AuthScreen(),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Verify input fields exist
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);

    // Verify TextFormField widgets are rendered
    final textFields = find.byType(TextFormField);
    expect(textFields, findsAtLeastNWidgets(2)); // At least email and password

    // Ensure all pending timers complete before test ends
    await tester.pumpAndSettle();
  });
}
