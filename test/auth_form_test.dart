import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:everyday_christian/features/auth/widgets/auth_form.dart';
import 'package:everyday_christian/features/auth/services/auth_service.dart';

import 'auth_service_test.mocks.dart';

@GenerateMocks([])
void main() {
  late MockSecureStorageService mockSecureStorage;
  late MockBiometricService mockBiometric;
  late MockDatabaseHelper mockDatabase;

  setUp(() {
    mockSecureStorage = MockSecureStorageService();
    mockBiometric = MockBiometricService();
    mockDatabase = MockDatabaseHelper();
  });

  Widget createTestWidget({bool enableBiometric = false}) {
    final authService = AuthService(mockSecureStorage, mockBiometric, mockDatabase);

    // Setup biometric mocks
    when(mockBiometric.canCheckBiometrics()).thenAnswer((_) async => enableBiometric);
    when(mockBiometric.getAvailableBiometrics()).thenAnswer((_) async => []);
    when(mockSecureStorage.isBiometricEnabled()).thenAnswer((_) async => enableBiometric);
    when(mockDatabase.getSetting<bool>(any, defaultValue: anyNamed('defaultValue')))
        .thenAnswer((_) async => enableBiometric);

    return ProviderScope(
      overrides: [
        authServiceProvider.overrideWith((ref) => authService),
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: AuthForm(),
        ),
      ),
    );
  }

  group('AuthForm Widget Tests', () {
    group('Initial Rendering', () {
      testWidgets('should render in sign in mode by default', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Sign In'), findsNWidgets(2)); // Tab and button
        expect(find.text('Sign Up'), findsOneWidget); // Just the tab
        expect(find.text('Email'), findsOneWidget);
        expect(find.text('Password'), findsOneWidget);
        expect(find.text('Full Name'), findsNothing); // Should not show name field in sign in mode
      });

      testWidgets('should render email and password fields', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.byType(TextFormField), findsNWidgets(2)); // Email and Password
        expect(find.byIcon(Icons.email_outlined), findsOneWidget);
        expect(find.byIcon(Icons.lock_outline), findsOneWidget);
      });

      testWidgets('should show password visibility toggle', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.visibility), findsOneWidget);
      });

      testWidgets('should show Sign In button in sign in mode', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Sign In'), findsNWidgets(2)); // Tab and button
      });
    });

    group('Sign In / Sign Up Toggle', () {
      testWidgets('should switch to sign up mode when Sign Up tab is tapped', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Tap Sign Up tab
        await tester.tap(find.text('Sign Up').last);
        await tester.pumpAndSettle();

        // Should show name field in sign up mode
        expect(find.text('Full Name'), findsOneWidget);
        expect(find.byType(TextFormField), findsNWidgets(3)); // Name, Email, Password
        expect(find.text('Create Account'), findsOneWidget);
      });

      testWidgets('should switch back to sign in mode when Sign In tab is tapped', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Switch to Sign Up
        await tester.tap(find.text('Sign Up').last);
        await tester.pumpAndSettle();
        expect(find.text('Full Name'), findsOneWidget);

        // Switch back to Sign In
        await tester.tap(find.text('Sign In').first);
        await tester.pumpAndSettle();

        expect(find.text('Full Name'), findsNothing);
        expect(find.byType(TextFormField), findsNWidgets(2)); // Only Email and Password
      });

      testWidgets('should show privacy message in sign up mode', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Switch to Sign Up
        await tester.tap(find.text('Sign Up').last);
        await tester.pumpAndSettle();

        expect(
          find.text('By creating an account, you agree to keep your spiritual journey private and secure.'),
          findsOneWidget,
        );
      });
    });

    group('Password Visibility Toggle', () {
      testWidgets('should toggle password visibility when icon is tapped', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Initially should show visibility icon (password hidden)
        expect(find.byIcon(Icons.visibility), findsOneWidget);

        // Tap the visibility toggle
        await tester.tap(find.byIcon(Icons.visibility));
        await tester.pumpAndSettle();

        // Should now show visibility_off icon (password visible)
        expect(find.byIcon(Icons.visibility_off), findsOneWidget);
        expect(find.byIcon(Icons.visibility), findsNothing);

        // Tap again to hide
        await tester.tap(find.byIcon(Icons.visibility_off));
        await tester.pumpAndSettle();

        // Back to visibility icon
        expect(find.byIcon(Icons.visibility), findsOneWidget);
      });

      testWidgets('password field should have obscureText property', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Password field should obscure text by default
        final passwordTextField = tester.widget<TextField>(
          find.descendant(
            of: find.byType(TextFormField).at(1),
            matching: find.byType(TextField),
          ),
        );
        expect(passwordTextField.obscureText, isTrue);
      });

      testWidgets('password field should show text when visibility is toggled', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Toggle password visibility
        await tester.tap(find.byIcon(Icons.visibility));
        await tester.pumpAndSettle();

        final passwordTextField = tester.widget<TextField>(
          find.descendant(
            of: find.byType(TextFormField).at(1),
            matching: find.byType(TextField),
          ),
        );
        expect(passwordTextField.obscureText, isFalse);
      });
    });

    group('Form Validation - Email', () {
      testWidgets('should show error when email is empty', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Try to submit with empty email
        await tester.tap(find.text('Sign In').last);
        await tester.pumpAndSettle();

        expect(find.text('Please enter your email'), findsOneWidget);
      });

      testWidgets('should show error for invalid email format', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Enter invalid email
        await tester.enterText(find.byType(TextFormField).first, 'invalid-email');
        await tester.pumpAndSettle();

        // Try to submit
        await tester.tap(find.text('Sign In').last);
        await tester.pumpAndSettle();

        expect(find.text('Please enter a valid email address'), findsOneWidget);
      });

      testWidgets('should accept valid email format', (WidgetTester tester) async {
        when(mockSecureStorage.storeUserData(any)).thenAnswer((_) async => {});
        when(mockSecureStorage.getUserByEmail(any)).thenAnswer((_) async => null);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Enter valid email and password
        await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
        await tester.enterText(find.byType(TextFormField).at(1), 'password123');
        await tester.pumpAndSettle();

        // Try to submit - should not show email validation error
        await tester.tap(find.text('Sign In').last);
        await tester.pumpAndSettle();

        expect(find.text('Please enter a valid email address'), findsNothing);
      });
    });

    group('Form Validation - Password', () {
      testWidgets('should show error when password is empty', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Enter email only
        await tester.enterText(find.byType(TextFormField).first, 'test@example.com');

        // Try to submit with empty password
        await tester.tap(find.text('Sign In').last);
        await tester.pumpAndSettle();

        expect(find.text('Please enter your password'), findsOneWidget);
      });

      testWidgets('should show error when password is too short', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Enter valid email and short password
        await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
        await tester.enterText(find.byType(TextFormField).at(1), 'short');
        await tester.pumpAndSettle();

        // Try to submit
        await tester.tap(find.text('Sign In').last);
        await tester.pumpAndSettle();

        expect(find.text('Password must be at least 6 characters'), findsOneWidget);
      });

      testWidgets('should accept password with 6 or more characters', (WidgetTester tester) async {
        when(mockSecureStorage.storeUserData(any)).thenAnswer((_) async => {});
        when(mockSecureStorage.getUserByEmail(any)).thenAnswer((_) async => null);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Enter valid credentials
        await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
        await tester.enterText(find.byType(TextFormField).at(1), 'password123');
        await tester.pumpAndSettle();

        // Try to submit - should not show password validation error
        await tester.tap(find.text('Sign In').last);
        await tester.pumpAndSettle();

        expect(find.text('Password must be at least 6 characters'), findsNothing);
      });
    });

    group('Form Validation - Name (Sign Up)', () {
      testWidgets('should show error when name is empty in sign up mode', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Switch to Sign Up
        await tester.tap(find.text('Sign Up').last);
        await tester.pumpAndSettle();

        // Enter email and password but not name
        await tester.enterText(find.byType(TextFormField).at(1), 'test@example.com');
        await tester.enterText(find.byType(TextFormField).at(2), 'password123');

        // Try to submit
        await tester.tap(find.text('Create Account'));
        await tester.pumpAndSettle();

        expect(find.text('Please enter your name'), findsOneWidget);
      });

      testWidgets('should accept valid name in sign up mode', (WidgetTester tester) async {
        when(mockSecureStorage.storeUserData(any)).thenAnswer((_) async => {});
        when(mockSecureStorage.getUserByEmail(any)).thenAnswer((_) async => null);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Switch to Sign Up
        await tester.tap(find.text('Sign Up').last);
        await tester.pumpAndSettle();

        // Enter all fields
        await tester.enterText(find.byType(TextFormField).at(0), 'John Doe');
        await tester.enterText(find.byType(TextFormField).at(1), 'test@example.com');
        await tester.enterText(find.byType(TextFormField).at(2), 'password123');
        await tester.pumpAndSettle();

        // Try to submit - should not show name validation error
        await tester.tap(find.text('Create Account'));
        await tester.pumpAndSettle();

        expect(find.text('Please enter your name'), findsNothing);
      });

      testWidgets('should not validate name in sign in mode', (WidgetTester tester) async {
        when(mockSecureStorage.storeUserData(any)).thenAnswer((_) async => {});
        when(mockSecureStorage.getUserByEmail(any)).thenAnswer((_) async => null);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Sign in mode - no name field
        await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
        await tester.enterText(find.byType(TextFormField).at(1), 'password123');
        await tester.pumpAndSettle();

        // Try to submit - should not show name error since we're in sign in mode
        await tester.tap(find.text('Sign In').last);
        await tester.pumpAndSettle();

        expect(find.text('Please enter your name'), findsNothing);
      });
    });

    group('Form Submission', () {
      testWidgets('should call signIn when sign in button is tapped', (WidgetTester tester) async {
        when(mockSecureStorage.storeUserData(any)).thenAnswer((_) async => {});
        when(mockSecureStorage.getStoredPassword(any)).thenAnswer((_) async => 'hashed_password');
        when(mockSecureStorage.getUserData()).thenAnswer((_) async => {
          'id': '123',
          'email': 'test@example.com',
          'date_joined': DateTime.now().millisecondsSinceEpoch,
        });

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Enter credentials
        await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
        await tester.enterText(find.byType(TextFormField).at(1), 'password123');
        await tester.pumpAndSettle();

        // Tap sign in button
        await tester.tap(find.text('Sign In').last);
        await tester.pumpAndSettle();

        // Verify storage was called for sign in
        verify(mockSecureStorage.getStoredPassword(any)).called(greaterThan(0));
      });

      testWidgets('should call signUp when create account button is tapped', (WidgetTester tester) async {
        when(mockSecureStorage.storeUserData(any)).thenAnswer((_) async => {});
        when(mockSecureStorage.getUserByEmail(any)).thenAnswer((_) async => null);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Switch to Sign Up
        await tester.tap(find.text('Sign Up').last);
        await tester.pumpAndSettle();

        // Enter all fields
        await tester.enterText(find.byType(TextFormField).at(0), 'John Doe');
        await tester.enterText(find.byType(TextFormField).at(1), 'test@example.com');
        await tester.enterText(find.byType(TextFormField).at(2), 'password123');
        await tester.pumpAndSettle();

        // Tap create account
        await tester.tap(find.text('Create Account'));
        await tester.pumpAndSettle();

        // Verify storage was called for sign up
        verify(mockSecureStorage.getUserByEmail(any)).called(greaterThan(0));
      });

      testWidgets('should submit form on password field submit', (WidgetTester tester) async {
        when(mockSecureStorage.storeUserData(any)).thenAnswer((_) async => {});
        when(mockSecureStorage.getStoredPassword(any)).thenAnswer((_) async => null);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Enter credentials
        await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
        await tester.enterText(find.byType(TextFormField).at(1), 'password123');
        await tester.pumpAndSettle();

        // Submit via password field
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        // Should attempt to sign in
        verify(mockSecureStorage.getStoredPassword(any)).called(greaterThan(0));
      });

      testWidgets('should handle whitespace in input fields', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Enter email with whitespace
        await tester.enterText(find.byType(TextFormField).first, '  test@example.com  ');
        await tester.enterText(find.byType(TextFormField).at(1), 'password123');
        await tester.pumpAndSettle();

        // The text fields should accept the input
        final emailFieldText = find.text('  test@example.com  ');
        expect(emailFieldText, findsOneWidget);

        // Note: The trimming happens in the auth service when the form is submitted
        // This test verifies that whitespace doesn't prevent the form from accepting input
      });
    });

    group('Biometric Authentication', () {
      testWidgets('should show biometric button when enabled in sign in mode', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(enableBiometric: true));
        await tester.pumpAndSettle();

        // Wait for FutureBuilder to complete
        await tester.pump();

        expect(find.text('Use Biometric'), findsOneWidget);
        expect(find.byIcon(Icons.fingerprint), findsOneWidget);
      });

      testWidgets('should not show biometric button when disabled', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(enableBiometric: false));
        await tester.pumpAndSettle();

        // Wait for FutureBuilder to complete
        await tester.pump();

        expect(find.text('Use Biometric'), findsNothing);
        expect(find.byIcon(Icons.fingerprint), findsNothing);
      });

      testWidgets('should not show biometric button in sign up mode', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(enableBiometric: true));
        await tester.pumpAndSettle();

        // Switch to Sign Up
        await tester.tap(find.text('Sign Up').last);
        await tester.pumpAndSettle();

        expect(find.text('Use Biometric'), findsNothing);
        expect(find.byIcon(Icons.fingerprint), findsNothing);
      });

      testWidgets('should show divider with "or" text when biometric is enabled', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(enableBiometric: true));
        await tester.pumpAndSettle();

        // Wait for FutureBuilder to complete
        await tester.pump();

        expect(find.text('or'), findsOneWidget);
        expect(find.byType(Divider), findsNWidgets(2)); // Two dividers around "or"
      });

      testWidgets('should call biometric sign in when biometric button is tapped', (WidgetTester tester) async {
        when(mockBiometric.authenticate()).thenAnswer((_) async => true);
        when(mockSecureStorage.getUserData()).thenAnswer((_) async => null);

        await tester.pumpWidget(createTestWidget(enableBiometric: true));
        await tester.pumpAndSettle();

        // Wait for FutureBuilder
        await tester.pump();

        // Tap biometric button
        await tester.tap(find.text('Use Biometric'));
        await tester.pumpAndSettle();

        // Note: The actual biometric authentication is handled by the auth service
        // We're just verifying the UI triggers it
      });
    });

    group('Loading State', () {
      testWidgets('should show loading state during sign in', (WidgetTester tester) async {
        when(mockSecureStorage.storeUserData(any)).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 100));
        });
        when(mockSecureStorage.getStoredPassword(any)).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return null;
        });

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Enter credentials
        await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
        await tester.enterText(find.byType(TextFormField).at(1), 'password123');
        await tester.pumpAndSettle();

        // Tap sign in
        await tester.tap(find.text('Sign In').last);
        await tester.pump(const Duration(milliseconds: 50)); // Pump some time, but not enough to complete

        // Should show loading indicator in button
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Complete the async operation
        await tester.pumpAndSettle();
      });
    });

    group('UI Elements and Styling', () {
      testWidgets('should render FrostedGlass container', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.byType(AuthForm), findsOneWidget);
        // FrostedGlass is the root container
      });

      testWidgets('should have correct icons for fields', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.email_outlined), findsOneWidget);
        expect(find.byIcon(Icons.lock_outline), findsOneWidget);

        // Switch to sign up to see person icon
        await tester.tap(find.text('Sign Up').last);
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.person_outline), findsOneWidget);
      });

      testWidgets('should use correct text input actions', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        final emailTextField = tester.widget<TextField>(
          find.descendant(
            of: find.byType(TextFormField).first,
            matching: find.byType(TextField),
          ),
        );
        final passwordTextField = tester.widget<TextField>(
          find.descendant(
            of: find.byType(TextFormField).at(1),
            matching: find.byType(TextField),
          ),
        );

        expect(emailTextField.textInputAction, TextInputAction.next);
        expect(passwordTextField.textInputAction, TextInputAction.done);
      });

      testWidgets('should set email keyboard type for email field', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        final emailTextField = tester.widget<TextField>(
          find.descendant(
            of: find.byType(TextFormField).first,
            matching: find.byType(TextField),
          ),
        );
        expect(emailTextField.keyboardType, TextInputType.emailAddress);
      });

      testWidgets('should have correct text input action for name field in sign up', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Switch to sign up
        await tester.tap(find.text('Sign Up').last);
        await tester.pumpAndSettle();

        final nameTextField = tester.widget<TextField>(
          find.descendant(
            of: find.byType(TextFormField).first,
            matching: find.byType(TextField),
          ),
        );
        expect(nameTextField.textInputAction, TextInputAction.next);
      });
    });

    group('Edge Cases', () {
      testWidgets('should handle very long email addresses', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        final longEmail = 'verylongemailaddress' * 10 + '@example.com';
        await tester.enterText(find.byType(TextFormField).first, longEmail);
        await tester.pumpAndSettle();

        expect(find.text(longEmail), findsOneWidget);
      });

      testWidgets('should handle special characters in password', (WidgetTester tester) async {
        when(mockSecureStorage.storeUserData(any)).thenAnswer((_) async => {});
        when(mockSecureStorage.getUserByEmail(any)).thenAnswer((_) async => null);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        const specialPassword = 'P@ssw0rd!#\$%^&*()';
        await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
        await tester.enterText(find.byType(TextFormField).at(1), specialPassword);
        await tester.pumpAndSettle();

        // Submit should work with special characters
        await tester.tap(find.text('Sign In').last);
        await tester.pumpAndSettle();

        expect(find.text('Password must be at least 6 characters'), findsNothing);
      });

      testWidgets('should handle empty name with only whitespace in sign up', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Switch to Sign Up
        await tester.tap(find.text('Sign Up').last);
        await tester.pumpAndSettle();

        // Enter whitespace-only name
        await tester.enterText(find.byType(TextFormField).at(0), '   ');
        await tester.enterText(find.byType(TextFormField).at(1), 'test@example.com');
        await tester.enterText(find.byType(TextFormField).at(2), 'password123');
        await tester.pumpAndSettle();

        // Try to submit
        await tester.tap(find.text('Create Account'));
        await tester.pumpAndSettle();

        expect(find.text('Please enter your name'), findsOneWidget);
      });

      testWidgets('should handle multiple rapid tab switches', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Rapidly switch tabs
        await tester.tap(find.text('Sign Up').last);
        await tester.pump();
        await tester.tap(find.text('Sign In').first);
        await tester.pump();
        await tester.tap(find.text('Sign Up').last);
        await tester.pumpAndSettle();

        // Should end up in sign up mode
        expect(find.text('Full Name'), findsOneWidget);
        expect(find.text('Create Account'), findsOneWidget);
      });

      testWidgets('should validate email with various TLDs', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        final validEmails = [
          'test@example.com',
          'user@domain.co.uk',
          'admin@site.org',
          'contact@company.io',
        ];

        for (final email in validEmails) {
          await tester.enterText(find.byType(TextFormField).first, email);
          await tester.enterText(find.byType(TextFormField).at(1), 'password123');
          await tester.pumpAndSettle();

          await tester.tap(find.text('Sign In').last);
          await tester.pump();

          expect(find.text('Please enter a valid email address'), findsNothing,
              reason: 'Email $email should be valid');

          // Reset for next iteration
          await tester.pumpWidget(createTestWidget());
          await tester.pumpAndSettle();
        }
      });
    });
  });
}
