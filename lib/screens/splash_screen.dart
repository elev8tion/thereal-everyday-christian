import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../theme/app_theme.dart';
import '../components/gradient_background.dart';
import '../core/navigation/navigation_service.dart';
import '../core/navigation/app_routes.dart';
import '../core/widgets/app_initializer.dart';
import '../core/services/preferences_service.dart';
import '../hooks/animation_hooks.dart';
import '../utils/responsive_utils.dart';

class SplashScreen extends HookConsumerWidget {
  const SplashScreen({super.key});

  // Static flag to prevent double navigation
  static bool _hasNavigated = false;

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    // Use custom hook for combined fade and scale animations
    final animations = useFadeAndScale(
      fadeDuration: const Duration(milliseconds: 1500),
      scaleDuration: const Duration(milliseconds: 2000),
    );

    // Create animations with curves
    final fadeAnimation = useAnimation(
      CurvedAnimation(
        parent: animations.fade,
        curve: Curves.easeInOut,
      ),
    );

    final scaleAnimation = useAnimation(
      CurvedAnimation(
        parent: animations.scale,
        curve: Curves.elasticOut,
      ),
    );

    // Navigate to next screen after delay and check legal agreements
    useEffect(() {
      // Guard against double navigation
      if (_hasNavigated) return null;

      Future.delayed(const Duration(seconds: 3), () async {
        // Double-check before navigation
        if (_hasNavigated) return;

        // Check if user has accepted all legal agreements
        final prefsService = await PreferencesService.getInstance();
        final hasAcceptedLegalAgreements = prefsService.hasAcceptedLegalAgreements();

        if (!hasAcceptedLegalAgreements) {
          // Show legal agreements screen
          if (_hasNavigated) return;
          _hasNavigated = true;
          NavigationService.pushReplacementNamed(AppRoutes.legalAgreements);
          return;
        }

        // Check if user has completed onboarding
        final hasCompletedOnboarding = prefsService.hasCompletedOnboarding();

        if (!hasCompletedOnboarding) {
          // First time user - show onboarding
          if (_hasNavigated) return;
          _hasNavigated = true;
          NavigationService.pushReplacementNamed(AppRoutes.onboarding);
          return;
        }

        // Returning user - go directly to home
        if (_hasNavigated) return;
        _hasNavigated = true;
        NavigationService.pushReplacementNamed(AppRoutes.home);
      });
      return null;
    }, []);

    // Wrap the splash screen UI with AppInitializer
    return AppInitializer(
      child: Scaffold(
        body: Stack(
          children: [
            // Existing gradient background
            const GradientBackground(),
            SafeArea(
              child: Center(
                child: FadeTransition(
                  opacity: AlwaysStoppedAnimation(fadeAnimation),
                  child: ScaleTransition(
                    scale: AlwaysStoppedAnimation(scaleAnimation),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo (appropriately sized)
                        Image.asset(
                          'assets/images/logo_transparent.png',
                          width: 140,
                          height: 140,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            // Fallback icon if logo not found
                            return Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    AppTheme.goldColor.withValues(alpha: 0.3),
                                    AppTheme.goldColor.withValues(alpha: 0.1),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Icon(
                                Icons.auto_stories,
                                size: ResponsiveUtils.iconSize(context, 60),
                                color: AppTheme.goldColor,
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 32),

                        // App name (clean, no card)
                        Text(
                          'EVERYDAY',
                          style: TextStyle(
                            fontSize: ResponsiveUtils.fontSize(context, 26, minSize: 22, maxSize: 30),
                            fontWeight: FontWeight.w300,
                            letterSpacing: 8,
                            color: AppTheme.goldColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'CHRISTIAN',
                          style: TextStyle(
                            fontSize: ResponsiveUtils.fontSize(context, 36, minSize: 32, maxSize: 40),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 4,
                            color: AppColors.primaryText,
                          ),
                        ),

                        const SizedBox(height: 80),

                        // Simple loading indicator
                        const SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.goldColor,
                            ),
                            strokeWidth: 3,
                          ),
                        ),

                        const SizedBox(height: AppSpacing.xxl),

                        // Loading text (simplified)
                        Text(
                          'Loading...',
                          style: TextStyle(
                            fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Bottom branding
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: AlwaysStoppedAnimation(fadeAnimation),
                child: Column(
                  children: [
                    Text(
                      'Version 1.0.0',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, 12, minSize: 10, maxSize: 14),
                        color: AppColors.secondaryText.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Built with ',
                          style: TextStyle(
                            fontSize: ResponsiveUtils.fontSize(context, 12, minSize: 10, maxSize: 14),
                            color: AppColors.secondaryText.withValues(alpha: 0.7),
                          ),
                        ),
                        Icon(
                          Icons.favorite,
                          size: ResponsiveUtils.iconSize(context, 12),
                          color: Colors.red.withValues(alpha: 0.7),
                        ),
                        Text(
                          ' for faith',
                          style: TextStyle(
                            fontSize: ResponsiveUtils.fontSize(context, 12, minSize: 10, maxSize: 14),
                            color: AppColors.secondaryText.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
