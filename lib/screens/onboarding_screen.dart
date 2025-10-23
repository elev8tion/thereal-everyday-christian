import 'package:flutter/material.dart';
import '../core/navigation/navigation_service.dart';
import '../core/navigation/app_routes.dart';
import '../core/services/preferences_service.dart';
import '../components/gradient_background.dart';
import '../components/animations/blur_fade.dart';
import '../components/glass_button.dart';
import '../components/glass/static_liquid_glass_lens.dart';
import '../theme/app_theme.dart';
import '../utils/responsive_utils.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  bool _showFeatures = false;
  final GlobalKey _backgroundKey = GlobalKey();
  bool _hasInitialized = false;
  bool _isNavigating = false;
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Guard against double initialization
    if (_hasInitialized) return;
    _hasInitialized = true;

    // Smoothly show features after screen loads
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _showFeatures = true;
        });
      }
    });
  }

  void _triggerFeatureAnimations() {
    setState(() {
      _showFeatures = false;
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                final screenHeight = constraints.maxHeight;
                // More aggressive small screen detection
                final isSmallScreen = screenHeight < 750;
                final isVerySmallScreen = screenHeight < 650;

                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: isVerySmallScreen ? 12.0 : (isSmallScreen ? 16.0 : 24.0),
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: isVerySmallScreen ? 8 : (isSmallScreen ? 16 : 32)),
                      // Logo section - just liquid glass and logo
                      StaticLiquidGlassLens(
                        backgroundKey: _backgroundKey,
                        width: isVerySmallScreen ? 140 : (isSmallScreen ? 170 : 200),
                        height: isVerySmallScreen ? 140 : (isSmallScreen ? 170 : 200),
                        effectSize: 3.0,
                        dispersionStrength: 0.3,
                        blurIntensity: 0.05,
                        child: Image.asset(
                          'assets/images/logo_transparent.png',
                          width: isVerySmallScreen ? 140 : (isSmallScreen ? 170 : 200),
                          height: isVerySmallScreen ? 140 : (isSmallScreen ? 170 : 200),
                          fit: BoxFit.contain,
                        ),
                      ),

                      SizedBox(height: isVerySmallScreen ? 12 : (isSmallScreen ? 16 : AppSpacing.xxl)),

                      Text(
                        'Your faith-guided companion for life\'s moments',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: ResponsiveUtils.fontSize(context, 18, minSize: 14, maxSize: 20),
                          color: AppColors.secondaryText,
                          height: 1.3,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      SizedBox(height: isVerySmallScreen ? 16 : (isSmallScreen ? 20 : 32)),

                      // Features preview
                      BlurFade(
                        delay: const Duration(milliseconds: 100),
                        isVisible: _showFeatures,
                        child: _buildFeatureItem(
                          icon: Icons.chat_bubble_outline,
                          title: 'AI Biblical Guidance',
                          description: 'Get personalized Bible verses and wisdom for any situation',
                        ),
                      ),
                      SizedBox(height: isVerySmallScreen ? 12 : (isSmallScreen ? 16 : AppSpacing.xl)),
                      BlurFade(
                        delay: const Duration(milliseconds: 300),
                        isVisible: _showFeatures,
                        child: _buildFeatureItem(
                          icon: Icons.auto_stories,
                          title: 'Daily Verses',
                          description: 'Receive encouraging Scripture at 9:30 AM or your preferred time',
                        ),
                      ),
                      SizedBox(height: isVerySmallScreen ? 12 : (isSmallScreen ? 16 : AppSpacing.xl)),
                      BlurFade(
                        delay: const Duration(milliseconds: 500),
                        isVisible: _showFeatures,
                        child: _buildFeatureItem(
                          icon: Icons.lock_outline,
                          title: 'Complete Privacy',
                          description: 'All your spiritual conversations stay on your device',
                        ),
                      ),

                      SizedBox(height: isVerySmallScreen ? 16 : (isSmallScreen ? 20 : 32)),

                      // Name input field (styled like chat input)
                      BlurFade(
                        delay: const Duration(milliseconds: 700),
                        isVisible: _showFeatures,
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
                              width: 1,
                            ),
                          ),
                          child: TextField(
                            controller: _nameController,
                            style: TextStyle(
                              color: AppColors.primaryText,
                              fontSize: ResponsiveUtils.fontSize(context, 15, minSize: 13, maxSize: 17),
                            ),
                            decoration: InputDecoration(
                              hintText: 'First name (optional)',
                              hintStyle: TextStyle(
                                color: AppColors.tertiaryText,
                                fontSize: ResponsiveUtils.fontSize(context, 15, minSize: 13, maxSize: 17),
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
                            buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                          ),
                        ),
                      ),

                      SizedBox(height: isVerySmallScreen ? 12 : (isSmallScreen ? AppSpacing.md : AppSpacing.lg)),

                      // Get started button
                      GlassButton(
                        text: 'Begin Your Journey',
                        onPressed: () async {
                          // Prevent double navigation
                          if (_isNavigating) return;
                          _isNavigating = true;

                          final prefsService = await PreferencesService.getInstance();

                          // Save first name if provided
                          final firstName = _nameController.text.trim();
                          if (firstName.isNotEmpty) {
                            await prefsService.saveFirstName(firstName);
                          }

                          // Mark onboarding as completed
                          await prefsService.setOnboardingCompleted();

                          _triggerFeatureAnimations();
                          // Navigate after a short delay to let animations play
                          Future.delayed(const Duration(milliseconds: 1200), () {
                            if (mounted) {
                              NavigationService.pushNamed(AppRoutes.home);
                            }
                          });
                        },
                      ),

                      SizedBox(height: isVerySmallScreen ? 16 : (isSmallScreen ? 24 : 40)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isVerySmallScreen = screenHeight < 650;
    final iconSize = isVerySmallScreen ? 40.0 : 48.0;

    return Row(
      children: [
        Container(
          width: iconSize,
          height: iconSize,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: AppRadius.mediumRadius,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: AppColors.primaryText,
            size: ResponsiveUtils.iconSize(context, isVerySmallScreen ? 20 : 24),
          ),
        ),
        SizedBox(width: isVerySmallScreen ? AppSpacing.md : AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 13, maxSize: 18),
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText,
                ),
              ),
              SizedBox(height: isVerySmallScreen ? 2 : 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 11, maxSize: 16),
                  color: Colors.black,
                  height: 1.25,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}