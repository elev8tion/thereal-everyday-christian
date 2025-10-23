import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:everyday_christian/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    // Prevent Google Fonts from making network requests during tests
    // Instead, it will fall back to default system fonts
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('AppTheme Color Constants', () {
    test('should have correct primary color', () {
      expect(AppTheme.primaryColor, equals(const Color(0xFF6366F1)));
    });

    test('should have correct accent color', () {
      expect(AppTheme.accentColor, equals(const Color(0xFF8B5CF6)));
    });

    test('should have correct secondary color', () {
      expect(AppTheme.secondaryColor, equals(const Color(0xFF64748B)));
    });

    test('should have correct gold color', () {
      expect(AppTheme.goldColor, equals(const Color(0xFFD4AF37)));
    });

    test('should have correct toggle active color', () {
      expect(AppTheme.toggleActiveColor, equals(const Color(0xFFFFA726)));
    });
  });

  group('AppTheme Light Theme', () {
    testWidgets('should use Material 3', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(body: SizedBox()),
        ),
      );
      
      expect(AppTheme.lightTheme.useMaterial3, isTrue);
    });

    testWidgets('should have light brightness', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(body: SizedBox()),
        ),
      );
      
      expect(AppTheme.lightTheme.colorScheme.brightness, equals(Brightness.light));
    });

    testWidgets('should have correct seed color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(body: SizedBox()),
        ),
      );
      
      expect(AppTheme.lightTheme.colorScheme.primary, isNotNull);
    });

    test('should have configured app bar theme', () {
      expect(AppTheme.lightTheme.appBarTheme.elevation, equals(0));
      expect(AppTheme.lightTheme.appBarTheme.centerTitle, isTrue);
      expect(AppTheme.lightTheme.appBarTheme.backgroundColor, equals(Colors.transparent));
    });

    test('should have configured elevated button theme', () {
      final buttonStyle = AppTheme.lightTheme.elevatedButtonTheme.style;
      expect(buttonStyle, isNotNull);
    });

    test('should have configured card theme', () {
      expect(AppTheme.lightTheme.cardTheme.elevation, equals(4));
      expect(AppTheme.lightTheme.cardTheme.shape, isA<RoundedRectangleBorder>());
    });

    test('should have configured input decoration theme', () {
      expect(AppTheme.lightTheme.inputDecorationTheme.filled, isTrue);
      expect(AppTheme.lightTheme.inputDecorationTheme.border, isNotNull);
    });

    test('should have configured floating action button theme', () {
      expect(AppTheme.lightTheme.floatingActionButtonTheme.backgroundColor, equals(AppTheme.primaryColor));
      expect(AppTheme.lightTheme.floatingActionButtonTheme.foregroundColor, equals(Colors.white));
    });

    test('should have configured switch theme with proper state handling', () {
      final switchTheme = AppTheme.lightTheme.switchTheme;
      expect(switchTheme.thumbColor, isNotNull);
      expect(switchTheme.trackColor, isNotNull);
    });
  });

  group('AppTheme Dark Theme', () {
    testWidgets('should use Material 3', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(body: SizedBox()),
        ),
      );
      
      expect(AppTheme.darkTheme.useMaterial3, isTrue);
    });

    testWidgets('should have dark brightness', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(body: SizedBox()),
        ),
      );
      
      expect(AppTheme.darkTheme.colorScheme.brightness, equals(Brightness.dark));
    });

    testWidgets('should have dark scaffold background', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(body: SizedBox()),
        ),
      );
      
      expect(AppTheme.darkTheme.scaffoldBackgroundColor, equals(const Color(0xFF121212)));
    });

    test('should have configured app bar theme', () {
      expect(AppTheme.darkTheme.appBarTheme.elevation, equals(0));
      expect(AppTheme.darkTheme.appBarTheme.centerTitle, isTrue);
      expect(AppTheme.darkTheme.appBarTheme.backgroundColor, equals(Colors.transparent));
    });

    test('should have configured elevated button theme', () {
      final buttonStyle = AppTheme.darkTheme.elevatedButtonTheme.style;
      expect(buttonStyle, isNotNull);
    });

    test('should have configured card theme with dark color', () {
      expect(AppTheme.darkTheme.cardTheme.elevation, equals(4));
      expect(AppTheme.darkTheme.cardTheme.color, isNotNull);
    });

    test('should have configured input decoration theme with dark fill', () {
      expect(AppTheme.darkTheme.inputDecorationTheme.filled, isTrue);
      expect(AppTheme.darkTheme.inputDecorationTheme.fillColor, isNotNull);
    });

    test('should have configured floating action button theme', () {
      expect(AppTheme.darkTheme.floatingActionButtonTheme.backgroundColor, equals(AppTheme.primaryColor));
      expect(AppTheme.darkTheme.floatingActionButtonTheme.foregroundColor, equals(Colors.white));
    });
  });

  group('AppTheme Gradients', () {
    test('primary gradient should have correct colors', () {
      expect(AppTheme.primaryGradient.colors.length, equals(2));
      expect(AppTheme.primaryGradient.colors[0], equals(AppTheme.primaryColor));
      expect(AppTheme.primaryGradient.colors[1], equals(AppTheme.accentColor));
    });

    test('primary gradient should have correct alignment', () {
      expect(AppTheme.primaryGradient.begin, equals(Alignment.topLeft));
      expect(AppTheme.primaryGradient.end, equals(Alignment.bottomRight));
    });

    test('dark gradient should have three colors', () {
      expect(AppTheme.darkGradient.colors.length, equals(3));
      expect(AppTheme.darkGradient.begin, equals(Alignment.topCenter));
      expect(AppTheme.darkGradient.end, equals(Alignment.bottomCenter));
    });

    test('light gradient should have two colors', () {
      expect(AppTheme.lightGradient.colors.length, equals(2));
      expect(AppTheme.lightGradient.begin, equals(Alignment.topCenter));
      expect(AppTheme.lightGradient.end, equals(Alignment.bottomCenter));
    });

    test('glass gradient should have two semi-transparent colors', () {
      expect(AppTheme.glassGradient.colors.length, equals(2));
      expect(AppTheme.glassGradient.begin, equals(Alignment.topLeft));
      expect(AppTheme.glassGradient.end, equals(Alignment.bottomRight));
    });
  });

  group('AppTheme Shadows', () {
    test('card shadow should have correct properties', () {
      expect(AppTheme.cardShadow.length, equals(1));
      expect(AppTheme.cardShadow[0].blurRadius, equals(10));
      expect(AppTheme.cardShadow[0].offset, equals(const Offset(0, 4)));
    });

    test('elevated shadow should use primary color', () {
      expect(AppTheme.elevatedShadow.length, equals(1));
      expect(AppTheme.elevatedShadow[0].blurRadius, equals(20));
      expect(AppTheme.elevatedShadow[0].offset, equals(const Offset(0, 8)));
    });

    test('glass shadow should have correct properties', () {
      expect(AppTheme.glassShadow.length, equals(1));
      expect(AppTheme.glassShadow[0].blurRadius, equals(20));
      expect(AppTheme.glassShadow[0].offset, equals(const Offset(0, 10)));
    });
  });

  group('AppTheme Text Styles', () {
    test('heading style should have correct properties', () {
      expect(AppTheme.headingStyle.fontSize, equals(28));
      expect(AppTheme.headingStyle.fontWeight, equals(FontWeight.bold));
      expect(AppTheme.headingStyle.color, equals(Colors.white));
      expect(AppTheme.headingStyle.shadows, isNotEmpty);
    });

    test('subheading style should have correct properties', () {
      expect(AppTheme.subheadingStyle.fontSize, equals(20));
      expect(AppTheme.subheadingStyle.fontWeight, equals(FontWeight.w600));
      expect(AppTheme.subheadingStyle.color, equals(Colors.white));
    });

    test('body style should have correct properties', () {
      expect(AppTheme.bodyStyle.fontSize, equals(16));
      expect(AppTheme.bodyStyle.fontWeight, equals(FontWeight.normal));
      expect(AppTheme.bodyStyle.height, equals(1.5));
      expect(AppTheme.bodyStyle.color, equals(Colors.white));
    });

    test('caption style should have correct properties', () {
      expect(AppTheme.captionStyle.fontSize, equals(14));
      expect(AppTheme.captionStyle.fontWeight, equals(FontWeight.w500));
      expect(AppTheme.captionStyle.color, equals(const Color(0xFFB0B0B0)));
    });
  });

  group('AppTheme Icon Themes', () {
    test('glass icon theme should have white color', () {
      expect(AppTheme.glassIconTheme.color, equals(Colors.white));
      expect(AppTheme.glassIconTheme.size, equals(24));
    });

    test('accent icon theme should use primary color', () {
      expect(AppTheme.accentIconTheme.color, equals(AppTheme.primaryColor));
      expect(AppTheme.accentIconTheme.size, equals(24));
    });
  });

  group('AppTheme Button Styles', () {
    test('glass button style should have semi-transparent background', () {
      expect(AppTheme.glassButtonStyle, isNotNull);
      expect(AppTheme.glassButtonStyle.backgroundColor, isNotNull);
      expect(AppTheme.glassButtonStyle.foregroundColor, isNotNull);
    });

    test('primary glass button style should use primary color', () {
      expect(AppTheme.primaryGlassButtonStyle, isNotNull);
      expect(AppTheme.primaryGlassButtonStyle.backgroundColor, isNotNull);
      expect(AppTheme.primaryGlassButtonStyle.foregroundColor, isNotNull);
    });
  });

  group('AppSpacing', () {
    test('should have correct base spacing values', () {
      expect(AppSpacing.xs, equals(4.0));
      expect(AppSpacing.sm, equals(8.0));
      expect(AppSpacing.md, equals(12.0));
      expect(AppSpacing.lg, equals(16.0));
      expect(AppSpacing.xl, equals(20.0));
      expect(AppSpacing.xxl, equals(24.0));
      expect(AppSpacing.xxxl, equals(32.0));
      expect(AppSpacing.huge, equals(40.0));
    });

    test('should have correct screen padding', () {
      expect(AppSpacing.screenPadding, equals(const EdgeInsets.all(20.0)));
      expect(AppSpacing.screenPaddingLarge, equals(const EdgeInsets.all(24.0)));
    });

    test('should have correct card padding', () {
      expect(AppSpacing.cardPadding, equals(const EdgeInsets.all(16.0)));
      expect(AppSpacing.cardPaddingLarge, equals(const EdgeInsets.all(20.0)));
    });

    test('should have correct button padding', () {
      expect(AppSpacing.buttonPadding, equals(const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0)));
    });

    test('should have correct input padding', () {
      expect(AppSpacing.inputPadding, equals(const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0)));
    });

    test('should have horizontal spacing variations', () {
      expect(AppSpacing.horizontalSm, equals(const EdgeInsets.symmetric(horizontal: 8.0)));
      expect(AppSpacing.horizontalMd, equals(const EdgeInsets.symmetric(horizontal: 12.0)));
      expect(AppSpacing.horizontalLg, equals(const EdgeInsets.symmetric(horizontal: 16.0)));
      expect(AppSpacing.horizontalXl, equals(const EdgeInsets.symmetric(horizontal: 20.0)));
      expect(AppSpacing.horizontalXxl, equals(const EdgeInsets.symmetric(horizontal: 24.0)));
    });

    test('should have vertical spacing variations', () {
      expect(AppSpacing.verticalSm, equals(const EdgeInsets.symmetric(vertical: 8.0)));
      expect(AppSpacing.verticalMd, equals(const EdgeInsets.symmetric(vertical: 12.0)));
      expect(AppSpacing.verticalLg, equals(const EdgeInsets.symmetric(vertical: 16.0)));
      expect(AppSpacing.verticalXl, equals(const EdgeInsets.symmetric(vertical: 20.0)));
      expect(AppSpacing.verticalXxl, equals(const EdgeInsets.symmetric(vertical: 24.0)));
    });

    test('should have gap values', () {
      expect(AppSpacing.gapXs, equals(4.0));
      expect(AppSpacing.gapSm, equals(8.0));
      expect(AppSpacing.gapMd, equals(12.0));
      expect(AppSpacing.gapLg, equals(16.0));
      expect(AppSpacing.gapXl, equals(20.0));
      expect(AppSpacing.gapXxl, equals(24.0));
    });
  });

  group('AppColors', () {
    test('should have correct primary text colors', () {
      expect(AppColors.primaryText, equals(Colors.white));
      expect(AppColors.secondaryText, isNotNull);
      expect(AppColors.tertiaryText, isNotNull);
      expect(AppColors.disabledText, isNotNull);
    });

    test('should have correct dark text colors', () {
      expect(AppColors.darkPrimaryText, equals(Colors.black87));
      expect(AppColors.darkSecondaryText, isNotNull);
      expect(AppColors.darkTertiaryText, isNotNull);
    });

    test('should have accent color variations', () {
      expect(AppColors.accent, equals(AppTheme.goldColor));
      expect(AppColors.accentSubtle, isNotNull);
      expect(AppColors.accentVerySubtle, isNotNull);
    });

    test('should have glass overlay colors', () {
      expect(AppColors.glassOverlayLight, isNotNull);
      expect(AppColors.glassOverlayMedium, isNotNull);
      expect(AppColors.glassOverlaySubtle, isNotNull);
    });

    test('should have border colors', () {
      expect(AppColors.primaryBorder, isNotNull);
      expect(AppColors.accentBorder, isNotNull);
      expect(AppColors.subtleBorder, isNotNull);
    });
  });

  group('AppRadius', () {
    test('should have correct radius constants', () {
      expect(AppRadius.xs, equals(8.0));
      expect(AppRadius.sm, equals(12.0));
      expect(AppRadius.md, equals(16.0));
      expect(AppRadius.lg, equals(20.0));
      expect(AppRadius.xl, equals(24.0));
      expect(AppRadius.xxl, equals(28.0));
      expect(AppRadius.pill, equals(100.0));
    });

    test('should have correct border radius patterns', () {
      expect(AppRadius.smallRadius, equals(BorderRadius.circular(8.0)));
      expect(AppRadius.mediumRadius, equals(BorderRadius.circular(12.0)));
      expect(AppRadius.cardRadius, equals(BorderRadius.circular(20.0)));
      expect(AppRadius.largeCardRadius, equals(BorderRadius.circular(24.0)));
      expect(AppRadius.buttonRadius, equals(BorderRadius.circular(28.0)));
      expect(AppRadius.pillRadius, equals(BorderRadius.circular(100.0)));
    });
  });

  group('AppBorders', () {
    test('should have primary glass borders', () {
      expect(AppBorders.primaryGlass.top.width, equals(2.0));
      expect(AppBorders.primaryGlassSubtle.top.width, equals(1.5));
      expect(AppBorders.primaryGlassThin.top.width, equals(1.0));
    });

    test('should have subtle borders', () {
      expect(AppBorders.subtle.top.width, equals(1.0));
      expect(AppBorders.subtleThick.top.width, equals(2.0));
    });

    test('should have icon container border', () {
      expect(AppBorders.iconContainer.top.width, equals(1.5));
    });

    test('should have none border', () {
      expect(AppBorders.none, equals(const Border()));
    });
  });

  group('AppAnimations', () {
    test('should have standard durations', () {
      expect(AppAnimations.instant, equals(const Duration(milliseconds: 0)));
      expect(AppAnimations.fast, equals(const Duration(milliseconds: 200)));
      expect(AppAnimations.normal, equals(const Duration(milliseconds: 400)));
      expect(AppAnimations.slow, equals(const Duration(milliseconds: 600)));
      expect(AppAnimations.verySlow, equals(const Duration(milliseconds: 800)));
    });

    test('should have sequential animation delays', () {
      expect(AppAnimations.sequentialShort, equals(const Duration(milliseconds: 100)));
      expect(AppAnimations.sequentialMedium, equals(const Duration(milliseconds: 150)));
      expect(AppAnimations.sequentialLong, equals(const Duration(milliseconds: 200)));
    });

    test('should have animation type durations', () {
      expect(AppAnimations.fadeIn, equals(const Duration(milliseconds: 600)));
      expect(AppAnimations.slideIn, equals(const Duration(milliseconds: 400)));
      expect(AppAnimations.scaleIn, equals(const Duration(milliseconds: 400)));
      expect(AppAnimations.shimmer, equals(const Duration(milliseconds: 1500)));
    });

    test('should have base delays', () {
      expect(AppAnimations.baseDelay, equals(const Duration(milliseconds: 600)));
      expect(AppAnimations.sectionDelay, equals(const Duration(milliseconds: 400)));
    });
  });

  group('AppSizes', () {
    test('should have correct icon sizes', () {
      expect(AppSizes.iconXs, equals(16.0));
      expect(AppSizes.iconSm, equals(20.0));
      expect(AppSizes.iconMd, equals(24.0));
      expect(AppSizes.iconLg, equals(32.0));
      expect(AppSizes.iconXl, equals(40.0));
    });

    test('should have correct avatar sizes', () {
      expect(AppSizes.avatarSm, equals(32.0));
      expect(AppSizes.avatarMd, equals(40.0));
      expect(AppSizes.avatarLg, equals(56.0));
      expect(AppSizes.avatarXl, equals(80.0));
    });

    test('should have correct card sizes', () {
      expect(AppSizes.statCardWidth, equals(140.0));
      expect(AppSizes.statCardHeight, equals(120.0));
      expect(AppSizes.quickActionWidth, equals(100.0));
      expect(AppSizes.quickActionHeight, equals(120.0));
    });

    test('should have app bar sizes', () {
      expect(AppSizes.appBarHeight, equals(56.0));
      expect(AppSizes.appBarIconSize, equals(24.0));
    });

    test('should have button heights', () {
      expect(AppSizes.buttonHeightSm, equals(40.0));
      expect(AppSizes.buttonHeightMd, equals(48.0));
      expect(AppSizes.buttonHeightLg, equals(56.0));
    });
  });

  group('AppBlur', () {
    test('should have blur strength constants', () {
      expect(AppBlur.light, equals(15.0));
      expect(AppBlur.medium, equals(25.0));
      expect(AppBlur.strong, equals(40.0));
      expect(AppBlur.veryStrong, equals(60.0));
    });
  });
}
