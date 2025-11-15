import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../components/gradient_background.dart';
import '../components/glass_button.dart';
import '../components/glass/static_liquid_glass_lens.dart';
import '../components/animations/blur_fade.dart';
import '../components/dark_glass_container.dart';
import '../core/services/preferences_service.dart';
import '../core/navigation/navigation_service.dart';
import '../core/navigation/app_routes.dart';
import '../theme/app_theme.dart';
import '../utils/responsive_utils.dart';
import '../l10n/app_localizations.dart';

/// Unified interactive onboarding screen combini1ng legal agreements and feature tour
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
  final ScrollController _chatScrollController = ScrollController();

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
    _chatScrollController.dispose();
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
    final l10n = AppLocalizations.of(context);
    setState(() {
      _aiResponse = l10n.demoChatAIResponse;
    });

    // Wait for the frame to build with the new AI response, then scroll
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Add a short delay to ensure animation is smooth
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_chatScrollController.hasClients && mounted) {
          // Scroll to position that leaves "Siguiente" button prominently visible
          // From screenshot: button should be visible with some spacing above it
          final targetPosition =
              _chatScrollController.position.maxScrollExtent - 180;
          _chatScrollController.animateTo(
            targetPosition > 0 ? targetPosition : 0,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
                      _buildLegalPage(l10n),
                      _buildDevotionalDemoPage(l10n),
                      _buildAIChatDemoPage(l10n),
                      _buildPersonalizationPage(l10n),
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
  Widget _buildLegalPage(AppLocalizations l10n) {
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
              l10n.localeName == 'es'
                  ? 'assets/images/logo_spanish.png'
                  : 'assets/images/logo_transparent.png',
              width: 150,
              height: 150,
              fit: BoxFit.contain,
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),

          // Welcome title
          Text(
            l10n.welcomeToEverydayChristian,
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
            l10n.dailyScriptureGuidance,
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.goldColor,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpacing.xxl),

          Text(
            l10n.beforeWeBeginReview,
            style: const TextStyle(
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
            label: l10n.acceptTermsOfService,
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
            label: l10n.acceptPrivacyPolicy,
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
            label: l10n.confirmAge13Plus,
          ),

          const SizedBox(height: AppSpacing.xl),

          // Crisis resources (collapsible)
          DarkGlassContainer(
            child: ExpansionTile(
              title: Row(
                children: [
                  const Icon(Icons.health_and_safety,
                      color: AppTheme.goldColor, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    l10n.crisisResources,
                    style: const TextStyle(
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
                    l10n.crisisResourcesText,
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
            text: l10n.acceptAndContinue,
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
    final l10n = AppLocalizations.of(context);
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
                color: value ? AppTheme.goldColor : AppColors.primaryBorder,
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
                  style: const TextStyle(
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
                    l10n.view,
                    style: const TextStyle(
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
  Widget _buildDevotionalDemoPage(AppLocalizations l10n) {
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
                l10n.tryYourFirstDevotional,
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
                l10n.devotionalPreviewDesc,
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
            l10n.demoDevotionalTitle1,
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
            l10n.demoDevotionalTitle2,
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
                l10n.openingScripture,
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
                  l10n.demoDevotionalVerseText,
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
                  l10n.demoDevotionalVerseReference,
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
            l10n.demoReflectionText,
            style: const TextStyle(
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
            text: _devotionalCompleted
                ? l10n.completedExclamation
                : l10n.markAsCompleted,
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
            text: l10n.next,
            onPressed: _nextPage,
            borderColor: AppColors.subtleBorder,
          ),

          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  // PAGE 3: AI Chat Demo
  Widget _buildAIChatDemoPage(AppLocalizations l10n) {
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
                l10n.askMeAnything,
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
                l10n.intelligentScriptureChat,
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
            controller: _chatScrollController,
            padding: const EdgeInsets.only(
                left: 20, right: 20, top: 10, bottom: 140),
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
                              l10n.demoChatUserMessage,
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
                                  fontSize: ResponsiveUtils.fontSize(
                                      context, 15,
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
                      text: l10n.next,
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
          clipBehavior: Clip.none,
          padding: const EdgeInsets.only(
            left: AppSpacing.md,
            right: AppSpacing.md,
            top: AppSpacing.md,
            bottom: AppSpacing.xl, // Extra padding for glow
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
                          text: _chatDemoSent ? '' : l10n.demoChatUserMessage,
                        ),
                        maxLines: 3,
                        minLines: 1,
                        style: TextStyle(
                          color: AppColors.primaryText,
                          fontSize: ResponsiveUtils.fontSize(context, 15,
                              minSize: 13, maxSize: 17),
                        ),
                        decoration: InputDecoration(
                          hintText: l10n.scriptureChatPlaceholder,
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
              Padding(
                padding:
                    const EdgeInsets.all(8.0), // Extra space for glow overflow
                child: GestureDetector(
                  onTap: _chatDemoSent
                      ? null
                      : () {
                          setState(() {
                            _chatDemoSent = true;
                            _animateAIChatResponse();
                          });
                          HapticFeedback.mediumImpact();
                        },
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      // Ripple ring effect (outer)
                      if (!_chatDemoSent)
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.goldColor.withValues(alpha: 0.6),
                              width: 2,
                            ),
                          ),
                        )
                            .animate(
                              onPlay: (controller) => controller.repeat(),
                            )
                            .fadeOut(
                              duration: const Duration(milliseconds: 1500),
                              curve: Curves.easeOut,
                            )
                            .scale(
                              duration: const Duration(milliseconds: 1500),
                              begin: const Offset(1.0, 1.0),
                              end: const Offset(1.6, 1.6),
                              curve: Curves.easeOut,
                            ),

                      // Ripple ring effect (middle)
                      if (!_chatDemoSent)
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.goldColor.withValues(alpha: 0.5),
                              width: 2,
                            ),
                          ),
                        )
                            .animate(
                              onPlay: (controller) => controller.repeat(),
                            )
                            .fadeOut(
                              delay: const Duration(milliseconds: 500),
                              duration: const Duration(milliseconds: 1500),
                              curve: Curves.easeOut,
                            )
                            .scale(
                              delay: const Duration(milliseconds: 500),
                              duration: const Duration(milliseconds: 1500),
                              begin: const Offset(1.0, 1.0),
                              end: const Offset(1.6, 1.6),
                              curve: Curves.easeOut,
                            ),

                      // Main button with breathing glow
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.goldColor
                                  .withValues(alpha: _chatDemoSent ? 0.2 : 0.4),
                              AppTheme.goldColor.withValues(
                                  alpha: _chatDemoSent ? 0.05 : 0.2),
                            ],
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.goldColor
                                .withValues(alpha: _chatDemoSent ? 0.2 : 0.5),
                            width: 1.5,
                          ),
                          boxShadow: _chatDemoSent
                              ? null
                              : [
                                  BoxShadow(
                                    color: AppTheme.goldColor
                                        .withValues(alpha: 0.5),
                                    blurRadius: 16,
                                    spreadRadius: 3,
                                  ),
                                ],
                        ),
                        child: Icon(
                          Icons.send,
                          color: AppTheme.goldColor
                              .withValues(alpha: _chatDemoSent ? 0.5 : 1.0),
                          size: 20,
                        ),
                      )
                          .animate(
                            onPlay: (controller) => _chatDemoSent
                                ? null
                                : controller.repeat(reverse: true),
                          )
                          .boxShadow(
                            duration: const Duration(milliseconds: 1200),
                            begin: BoxShadow(
                              color: AppTheme.goldColor.withValues(alpha: 0.5),
                              blurRadius: 16,
                              spreadRadius: 3,
                            ),
                            end: BoxShadow(
                              color: AppTheme.goldColor.withValues(alpha: 0.8),
                              blurRadius: 24,
                              spreadRadius: 5,
                            ),
                            curve: Curves.easeInOut,
                          ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // PAGE 4: Personalization
  Widget _buildPersonalizationPage(AppLocalizations l10n) {
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
              l10n.localeName == 'es'
                  ? 'assets/images/logo_spanish.png'
                  : 'assets/images/logo_transparent.png',
              width: 150,
              height: 150,
              fit: BoxFit.contain,
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),

          Text(
            l10n.youreAllSet,
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 28,
                  minSize: 24, maxSize: 32),
              fontWeight: FontWeight.w800,
              color: AppColors.primaryText,
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          Text(
            l10n.oneLastThing,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.secondaryText,
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),

          Text(
            l10n.whatShouldWeCallYou,
            style: const TextStyle(
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
                fontSize: ResponsiveUtils.fontSize(context, 15,
                    minSize: 13, maxSize: 17),
              ),
              decoration: InputDecoration(
                hintText: l10n.firstNameOptional,
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
                      {required currentLength,
                      required isFocused,
                      maxLength}) =>
                  null,
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          Text(
            l10n.spiritualJourneyStartsNow,
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
            text: l10n.beginYourJourney,
            onPressed: _completeOnboarding,
          ),

          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}
