import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../components/gradient_background.dart';
import '../components/frosted_glass_card.dart';
import '../components/glass_button.dart';
import '../components/glass/static_liquid_glass_lens.dart';
import '../components/animations/blur_fade.dart';
import '../components/dark_glass_container.dart';
import '../core/services/preferences_service.dart';
import '../core/navigation/navigation_service.dart';
import '../core/navigation/app_routes.dart';
import '../theme/app_theme.dart';
import '../utils/responsive_utils.dart';

/// Unified interactive onboarding screen combining legal agreements and feature tour
class UnifiedInteractiveOnboardingScreen extends StatefulWidget {
  const UnifiedInteractiveOnboardingScreen({super.key});

  @override
  State<UnifiedInteractiveOnboardingScreen> createState() =>
      _UnifiedInteractiveOnboardingScreenState();
}

class _UnifiedInteractiveOnboardingScreenState
    extends State<UnifiedInteractiveOnboardingScreen> {
  final PageController _pageController = PageController();
  final GlobalKey _backgroundKey = GlobalKey();
  final TextEditingController _nameController = TextEditingController();

  // Page 1: Legal agreements
  bool _termsChecked = false;
  bool _privacyChecked = false;
  bool _ageChecked = false;

  // Page 2: Devotional demo
  bool _devotionalCompleted = false;

  // Page 3: AI chat demo
  bool _chatDemoSent = false;
  String _aiResponse = '';

  // Navigation state
  bool _isNavigating = false;
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  bool get _canProceedFromLegal =>
      _termsChecked && _privacyChecked && _ageChecked;

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: AppAnimations.normal,
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: AppAnimations.normal,
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    if (_isNavigating) return;
    _isNavigating = true;

    final prefsService = await PreferencesService.getInstance();

    // Save legal agreements
    await prefsService.saveLegalAgreementAcceptance(true);

    // Save name if provided
    final firstName = _nameController.text.trim();
    if (firstName.isNotEmpty) {
      await prefsService.saveFirstName(firstName);
    }

    // Mark onboarding as completed
    await prefsService.setOnboardingCompleted();

    // Navigate to home
    if (mounted) {
      NavigationService.pushReplacementNamed(AppRoutes.home);
    }
  }

  void _animateAIChatResponse() {
    setState(() {
      _aiResponse = 'Great question! The Bible offers beautiful wisdom on overcoming worry. '
          'In Philippians 4:6-7, we\'re reminded to bring our concerns to God through prayer '
          'with thanksgiving, and His peace will guard our hearts...';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          RepaintBoundary(
            key: _backgroundKey,
            child: const GradientBackground(),
          ),
          SafeArea(
            child: Column(
              children: [
                // Header with back button (hidden on first page)
                if (_currentPage > 0)
                  Padding(
                    padding: AppSpacing.screenPadding,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios,
                              color: AppColors.primaryText),
                          onPressed: _previousPage,
                        ),
                        const SizedBox(width: 48), // Balance layout
                      ],
                    ),
                  ),

                // PageView
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    children: [
                      _buildLegalPage(),
                      _buildDevotionalDemoPage(),
                      _buildAIChatDemoPage(),
                      _buildPersonalizationPage(),
                    ],
                  ),
                ),

                // Page indicator
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                  child: SmoothPageIndicator(
                    controller: _pageController,
                    count: 4,
                    effect: WormEffect(
                      dotColor: AppColors.primaryText.withValues(alpha: 0.3),
                      activeDotColor: AppTheme.goldColor,
                      dotHeight: 8,
                      dotWidth: 8,
                      spacing: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // PAGE 1: Legal Agreements
  Widget _buildLegalPage() {
    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.xl),

          // Logo with liquid glass lens
          StaticLiquidGlassLens(
            backgroundKey: _backgroundKey,
            width: 150,
            height: 150,
            effectSize: 3.0,
            dispersionStrength: 0.3,
            blurIntensity: 0.05,
            child: Image.asset(
              'assets/images/logo_transparent.png',
              width: 150,
              height: 150,
              fit: BoxFit.contain,
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),

          // Welcome title
          Text(
            'Welcome to Everyday Christian',
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 28,
                  minSize: 24, maxSize: 32),
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpacing.md),

          // Subtitle
          Text(
            'Bible Study, Prayer, & Devotionals',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.goldColor,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpacing.xxl),

          Text(
            'Before we begin, please review:',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.primaryText,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // Legal checkboxes
          _buildCheckboxRow(
            value: _termsChecked,
            onChanged: (value) {
              setState(() => _termsChecked = value ?? false);
              HapticFeedback.lightImpact();
            },
            label: 'I accept the Terms of Service',
            onViewTapped: () => _openLegalDoc('terms'),
          ),
          const SizedBox(height: 12),
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.0),
                  Colors.white.withValues(alpha: 0.2),
                  Colors.white.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildCheckboxRow(
            value: _privacyChecked,
            onChanged: (value) {
              setState(() => _privacyChecked = value ?? false);
              HapticFeedback.lightImpact();
            },
            label: 'I accept the Privacy Policy',
            onViewTapped: () => _openLegalDoc('privacy'),
          ),
          const SizedBox(height: 12),
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.0),
                  Colors.white.withValues(alpha: 0.2),
                  Colors.white.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildCheckboxRow(
            value: _ageChecked,
            onChanged: (value) {
              setState(() => _ageChecked = value ?? false);
              HapticFeedback.lightImpact();
            },
            label: 'I confirm I am 13+ years old',
          ),

          const SizedBox(height: AppSpacing.xl),

          // Crisis resources (collapsible)
          DarkGlassContainer(
            child: ExpansionTile(
              title: Row(
                children: [
                  Icon(Icons.health_and_safety,
                      color: AppTheme.goldColor, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Crisis Resources',
                    style: TextStyle(
                      color: AppColors.primaryText,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              iconColor: AppColors.primaryText,
              collapsedIconColor: AppColors.secondaryText,
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Text(
                    'If you\'re in crisis, please contact:\n\n'
                    '988 Suicide & Crisis Lifeline\n'
                    'Call or text 988\n\n'
                    'This app provides spiritual guidance but is not a substitute for professional help.',
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),

          // Next button
          GlassButton(
            text: 'Accept & Continue',
            onPressed: _canProceedFromLegal ? _nextPage : null,
          ),

          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildCheckboxRow({
    required bool value,
    required ValueChanged<bool?>? onChanged,
    required String label,
    VoidCallback? onViewTapped,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => onChanged?.call(!value),
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: value
                    ? AppTheme.goldColor
                    : AppColors.primaryBorder,
                width: 2,
              ),
              color: value ? AppTheme.goldColor : Colors.transparent,
            ),
            child: value
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : null,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: AppColors.primaryText,
                    fontSize: 15,
                  ),
                ),
              ),
              if (onViewTapped != null) ...[
                const SizedBox(width: AppSpacing.sm),
                GestureDetector(
                  onTap: onViewTapped,
                  child: Text(
                    'View',
                    style: TextStyle(
                      color: AppTheme.goldColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _openLegalDoc(String type) async {
    // Open legal documents (simplified - you can enhance this)
    final url = type == 'terms'
        ? 'https://everydaychristian.app/terms'
        : 'https://everydaychristian.app/privacy';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  // PAGE 2: Devotional Demo
  Widget _buildDevotionalDemoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(
        top: AppSpacing.xl,
        left: AppSpacing.xl,
        right: AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header (scrollable, like devotional_screen.dart)
          Column(
            children: [
              Text(
                'Try Your First Devotional',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 24,
                      minSize: 20, maxSize: 28),
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Daily devotionals help you start each day with hope',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Devotional Title (scrollable, like devotional_screen.dart)
          Text(
            'Cultivating a',
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 24,
                  minSize: 20, maxSize: 28),
              fontWeight: FontWeight.w800,
              color: AppColors.primaryText,
              height: 1.2,
            ),
            textAlign: TextAlign.left,
          ),
          Text(
            'Thankful Heart',
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 24,
                  minSize: 20, maxSize: 28),
              fontWeight: FontWeight.w800,
              color: AppColors.primaryText,
              height: 1.2,
            ),
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: AppSpacing.xl),

          // Opening Scripture section
                Row(
                  children: [
                    Icon(Icons.menu_book,
                        size: ResponsiveUtils.iconSize(context, 20),
                        color: AppTheme.goldColor),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Opening Scripture',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, 14,
                            minSize: 12, maxSize: 16),
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                DarkGlassContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '"Give thanks to the LORD, for he is good, for his loving kindness endures forever."',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.fontSize(context, 16,
                              minSize: 14, maxSize: 18),
                          color: AppColors.primaryText,
                          height: 1.5,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Psalm 107:1',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.fontSize(context, 13,
                              minSize: 11, maxSize: 15),
                          color: AppTheme.goldColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Reflection preview
                Text(
                  'Gratitude doesn\'t always come naturally—especially when life feels overwhelming. Yet Psalm 107 opens with a powerful invitation: give thanks...',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.primaryText,
                    height: 1.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

          const SizedBox(height: AppSpacing.xl),

          // Mark complete button
          GlassButton(
            text: _devotionalCompleted ? '✓ Completed!' : 'Mark as Complete',
            onPressed: () {
              if (!_devotionalCompleted) {
                setState(() => _devotionalCompleted = true);
                HapticFeedback.mediumImpact();
              }
            },
            borderColor: _devotionalCompleted
                ? AppTheme.goldColor
                : AppColors.accentBorder,
          ),

          const SizedBox(height: AppSpacing.md),

          // Next button
          GlassButton(
            text: 'Next',
            onPressed: _nextPage,
            borderColor: AppColors.subtleBorder,
          ),

          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  // PAGE 3: AI Chat Demo
  Widget _buildAIChatDemoPage() {
    return Column(
      children: [
        // Fixed header
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xl,
          ),
          child: Column(
            children: [
              Text(
                'Ask Me Anything',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 24,
                      minSize: 20, maxSize: 28),
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Get biblical guidance 24/7',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
        ),

        // Chat messages (matching chat_screen.dart design)
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                if (_chatDemoSent) ...[
                  // User message bubble (only shows after send is tapped)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Flexible(
                          child: Container(
                            padding: AppSpacing.cardPadding,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.primaryColor.withValues(alpha: 0.8),
                                  AppTheme.primaryColor.withValues(alpha: 0.6),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(8),
                                bottomLeft: Radius.circular(AppRadius.lg),
                                bottomRight: Radius.circular(AppRadius.lg),
                              ),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Text(
                              'How do I overcome worry?',
                              style: TextStyle(
                                fontSize: ResponsiveUtils.fontSize(context, 15,
                                    minSize: 13, maxSize: 17),
                                color: AppColors.primaryText,
                                height: 1.4,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Container(
                          width: 40,
                          height: 40,
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.goldColor.withValues(alpha: 0.3),
                                AppTheme.goldColor.withValues(alpha: 0.1),
                              ],
                            ),
                            borderRadius: AppRadius.mediumRadius,
                            border: Border.all(
                              color: AppTheme.goldColor.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            child: Image.asset(
                              'assets/images/logo_cropped.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                if (_chatDemoSent) ...[
                  // AI message bubble (matching chat_screen.dart lines 2062-2117)
                  BlurFade(
                    delay: const Duration(milliseconds: 300),
                    isVisible: _chatDemoSent,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.goldColor.withValues(alpha: 0.3),
                                  AppTheme.goldColor.withValues(alpha: 0.1),
                                ],
                              ),
                              borderRadius: AppRadius.mediumRadius,
                            ),
                            child: Icon(
                              Icons.auto_awesome,
                              color: AppColors.secondaryText,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Flexible(
                            child: Container(
                              padding: AppSpacing.cardPadding,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withValues(alpha: 0.2),
                                    Colors.white.withValues(alpha: 0.1),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  topRight: Radius.circular(20),
                                  bottomLeft: Radius.circular(AppRadius.lg),
                                  bottomRight: Radius.circular(AppRadius.lg),
                                ),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Text(
                                _aiResponse,
                                style: TextStyle(
                                  fontSize: ResponsiveUtils.fontSize(context, 15,
                                      minSize: 13, maxSize: 17),
                                  color: AppColors.primaryText,
                                  height: 1.4,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                if (_chatDemoSent) ...[
                  const SizedBox(height: AppSpacing.xl),

                  // Next button (only shows after demo is triggered)
                  BlurFade(
                    delay: const Duration(milliseconds: 500),
                    isVisible: _chatDemoSent,
                    child: GlassButton(
                      text: 'Next',
                      borderColor: AppTheme.goldColor,
                      onPressed: _nextPage,
                    ),
                  ),
                ],

                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),

        // Input field (matching chat_screen.dart lines 2189-2263)
        Container(
          padding: const EdgeInsets.only(
            left: AppSpacing.md,
            right: AppSpacing.md,
            top: AppSpacing.md,
            bottom: AppSpacing.md,
          ),
          child: Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.xl + 1),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.2),
                            Colors.white.withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.xl + 1),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: TextField(
                        enabled: false, // Disabled for demo
                        controller: TextEditingController(
                          text: _chatDemoSent ? '' : 'How do I overcome worry?',
                        ),
                        style: TextStyle(
                          color: AppColors.primaryText,
                          fontSize: ResponsiveUtils.fontSize(context, 15,
                              minSize: 13, maxSize: 17),
                        ),
                        decoration: InputDecoration(
                          hintText: 'Scripture Chat...',
                          hintStyle: TextStyle(
                            color: AppColors.tertiaryText,
                            fontSize: ResponsiveUtils.fontSize(context, 15,
                                minSize: 13, maxSize: 17),
                          ),
                          border: InputBorder.none,
                          filled: true,
                          fillColor: Colors.transparent,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              GestureDetector(
                onTap: _chatDemoSent ? null : () {
                  setState(() {
                    _chatDemoSent = true;
                    _animateAIChatResponse();
                  });
                  HapticFeedback.mediumImpact();
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.goldColor.withValues(alpha: _chatDemoSent ? 0.2 : 0.3),
                        AppTheme.goldColor.withValues(alpha: _chatDemoSent ? 0.05 : 0.1),
                      ],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.goldColor.withValues(alpha: _chatDemoSent ? 0.2 : 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    Icons.send,
                    color: AppTheme.goldColor.withValues(alpha: _chatDemoSent ? 0.5 : 1.0),
                    size: 20,
                  ),
                ).animate(
                  onPlay: (controller) => _chatDemoSent ? null : controller.repeat(),
                ).scale(
                  duration: const Duration(milliseconds: 1000),
                  begin: const Offset(1.0, 1.0),
                  end: const Offset(1.08, 1.08),
                  curve: Curves.easeInOut,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // PAGE 4: Personalization
  Widget _buildPersonalizationPage() {
    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.xxl),

          // Logo again
          StaticLiquidGlassLens(
            backgroundKey: _backgroundKey,
            width: 150,
            height: 150,
            effectSize: 3.0,
            dispersionStrength: 0.3,
            blurIntensity: 0.05,
            child: Image.asset(
              'assets/images/logo_transparent.png',
              width: 150,
              height: 150,
              fit: BoxFit.contain,
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),

          Text(
            'You\'re All Set!',
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 28,
                  minSize: 24, maxSize: 32),
              fontWeight: FontWeight.w800,
              color: AppColors.primaryText,
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          Text(
            'One last thing...',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.secondaryText,
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),

          Text(
            'What should we call you?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryText,
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Name input (styled like your existing onboarding)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.2),
                  Colors.white.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(AppRadius.xl + 1),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: TextField(
              controller: _nameController,
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize:
                    ResponsiveUtils.fontSize(context, 15, minSize: 13, maxSize: 17),
              ),
              decoration: InputDecoration(
                hintText: 'First name (optional)',
                hintStyle: TextStyle(
                  color: AppColors.tertiaryText,
                  fontSize: ResponsiveUtils.fontSize(context, 15,
                      minSize: 13, maxSize: 17),
                ),
                border: InputBorder.none,
                filled: true,
                fillColor: Colors.transparent,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
              ),
              textCapitalization: TextCapitalization.words,
              maxLength: 20,
              buildCounter: (context,
                      {required currentLength, required isFocused, maxLength}) =>
                  null,
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          Text(
            'Your spiritual journey starts now!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: AppColors.secondaryText,
              height: 1.4,
            ),
          ),

          const SizedBox(height: AppSpacing.xxxl),

          // Get started button
          GlassButton(
            text: 'Begin Your Journey',
            onPressed: _completeOnboarding,
          ),

          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

