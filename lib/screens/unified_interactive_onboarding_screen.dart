import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  // Page 2: Topic selection
  final Set<String> _selectedTopics = {};

  // Page 3: Devotional demo
  bool _devotionalCompleted = false;

  // Page 4: AI chat demo
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
    if (_currentPage < 4) {
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

    // Save selected topics (stored as comma-separated string)
    if (_selectedTopics.isNotEmpty) {
      await prefsService.prefs?.setStringList('selected_topics', _selectedTopics.toList());
    }

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
                      _buildTopicSelectionPage(),
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
                    count: 5,
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
            'Bible study, prayer & devotionals',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.secondaryText,
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

  // PAGE 2: Topic Selection
  Widget _buildTopicSelectionPage() {
    final topics = [
      TopicData('Overcoming Anxiety', Icons.psychology),
      TopicData('Growing in Faith', Icons.auto_awesome),
      TopicData('Strengthening Relationships', Icons.favorite),
      TopicData('Deepening Prayer Life', Icons.wb_twilight),
      TopicData('Finding Purpose', Icons.explore),
      TopicData('Healing & Comfort', Icons.healing),
    ];

    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.xxl),

          Text(
            'What brings you here?',
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 24,
                  minSize: 20, maxSize: 28),
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText,
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          Text(
            'Select topics that matter to you',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: AppColors.secondaryText,
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),

          // Grid of topic cards
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            alignment: WrapAlignment.center,
            children: topics
                .map((topic) => _buildTopicCard(topic.title, topic.icon))
                .toList(),
          ),

          const SizedBox(height: AppSpacing.xxxl),

          // Buttons
          Row(
            children: [
              Expanded(
                child: GlassButton(
                  text: 'Skip',
                  onPressed: _nextPage,
                  borderColor: AppColors.subtleBorder,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: GlassButton(
                  text: 'Next',
                  onPressed: _nextPage,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildTopicCard(String title, IconData icon) {
    final isSelected = _selectedTopics.contains(title);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedTopics.remove(title);
          } else {
            _selectedTopics.add(title);
          }
        });
        HapticFeedback.lightImpact();
      },
      child: FrostedGlassCard(
        borderColor:
            isSelected ? AppTheme.goldColor : AppColors.subtleBorder,
        intensity: isSelected ? GlassIntensity.strong : GlassIntensity.light,
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.4,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected
                    ? AppTheme.goldColor
                    : AppColors.secondaryText,
                size: 36,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.primaryText,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // PAGE 3: Devotional Demo
  Widget _buildDevotionalDemoPage() {
    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.xxl),

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

          const SizedBox(height: AppSpacing.lg),

          Text(
            'Daily devotionals help you start each day with hope',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: AppColors.secondaryText,
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),

          // Devotional preview card
          FrostedGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cultivating a\nThankful Heart',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryText,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Icon(Icons.menu_book,
                        size: 16, color: AppTheme.goldColor),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'Psalm 107:1',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.goldColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '"Give thanks to the LORD, for he is good, for his loving kindness endures forever."',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.secondaryText,
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Gratitude doesn\'t always come naturally—especially when life feels overwhelming. Yet Psalm 107 opens with a powerful invitation: give thanks. Not because everything is perfect, but because God is good...',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.primaryText,
                    height: 1.5,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
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

  // PAGE 4: AI Chat Demo
  Widget _buildAIChatDemoPage() {
    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.xxl),

          Text(
            'Ask Me Anything',
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 24,
                  minSize: 20, maxSize: 28),
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText,
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          Text(
            'Get biblical guidance 24/7',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: AppColors.secondaryText,
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),

          // User message
          FrostedGlassCard(
            intensity: GlassIntensity.light,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor:
                          AppTheme.goldColor.withValues(alpha: 0.3),
                      child: Icon(Icons.person,
                          size: 18, color: AppTheme.goldColor),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'You:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryText,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'How do I overcome worry?',
                  style: TextStyle(
                    color: AppColors.primaryText,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),

          if (_chatDemoSent) ...[
            const SizedBox(height: AppSpacing.md),

            // AI Response
            BlurFade(
              delay: const Duration(milliseconds: 300),
              isVisible: _chatDemoSent,
              child: FrostedGlassCard(
                intensity: GlassIntensity.medium,
                borderColor: AppTheme.goldColor.withValues(alpha: 0.6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: AppTheme.goldColor,
                          child: const Icon(Icons.auto_awesome,
                              size: 18, color: Colors.white),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'AI Guide:',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryText,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      _aiResponse,
                      style: TextStyle(
                        color: AppColors.primaryText,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.xxl),

          // Premium badge
          FrostedGlassCard(
            intensity: GlassIntensity.light,
            borderColor: AppTheme.goldColor,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star, color: AppTheme.goldColor, size: 16),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Premium Feature - 3-Day Free Trial',
                  style: TextStyle(
                    color: AppTheme.goldColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // Action button
          GlassButton(
            text: _chatDemoSent ? 'Next' : 'Try It',
            onPressed: () {
              if (!_chatDemoSent) {
                setState(() {
                  _chatDemoSent = true;
                  _animateAIChatResponse();
                });
                HapticFeedback.mediumImpact();
              } else {
                _nextPage();
              }
            },
          ),

          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  // PAGE 5: Personalization
  Widget _buildPersonalizationPage() {
    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.xxl),

          // Logo again
          StaticLiquidGlassLens(
            backgroundKey: _backgroundKey,
            width: 120,
            height: 120,
            effectSize: 3.0,
            dispersionStrength: 0.3,
            blurIntensity: 0.05,
            child: Image.asset(
              'assets/images/logo_transparent.png',
              width: 120,
              height: 120,
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

// Helper class for topic data
class TopicData {
  final String title;
  final IconData icon;

  TopicData(this.title, this.icon);
}

