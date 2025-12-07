import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import '../theme/app_theme.dart';
import '../components/gradient_background.dart';
import '../core/navigation/navigation_service.dart';
import '../core/navigation/app_routes.dart';
import '../core/widgets/app_initializer.dart';
import '../core/services/preferences_service.dart';
import '../core/providers/app_providers.dart';
import '../hooks/animation_hooks.dart';
import '../utils/responsive_utils.dart';
import '../l10n/app_localizations.dart';

class SplashScreen extends HookConsumerWidget {
  const SplashScreen({super.key});

  // Static flag to prevent double navigation
  static bool _hasNavigated = false;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    // Reset navigation flag on first build
    useEffect(() {
      _hasNavigated = false;
      return null;
    }, []);

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

    // Watch app initialization and navigate when ready (no more timer!)
    final initializationAsync = ref.watch(appInitializationProvider);

    // Get current route BEFORE useEffect (outside of initialization)
    final currentRoute = ModalRoute.of(context)?.settings.name;

    useEffect(() {
      // Guard against double navigation
      if (_hasNavigated) return null;

      // Only navigate when initialization completes successfully
      initializationAsync.whenData((_) async {
        if (_hasNavigated) return;

        // Check if we're still on splash screen before navigating
        if (currentRoute != AppRoutes.splash && currentRoute != '/') return;

        // Check if user has completed onboarding (which now includes legal agreements)
        final prefsService = await PreferencesService.getInstance();
        final hasCompletedOnboarding = prefsService.hasCompletedOnboarding();

        if (!hasCompletedOnboarding) {
          // First time user - show unified interactive onboarding
          if (_hasNavigated) return;
          _hasNavigated = true;
          NavigationService.pushReplacementNamed(AppRoutes.onboarding);
          return;
        }

        // Returning user - check if app lock is enabled
        final isAppLockEnabled = prefsService.isAppLockEnabled();

        if (isAppLockEnabled) {
          // App lock is enabled - require biometric authentication
          final localAuth = LocalAuthentication();

          try {
            final canCheckBiometrics = await localAuth.canCheckBiometrics;
            final isDeviceSupported = await localAuth.isDeviceSupported();

            if (canCheckBiometrics && isDeviceSupported) {
              final authenticated = await localAuth.authenticate(
                localizedReason: l10n.unlockAppPrompt,
                options: const AuthenticationOptions(
                  useErrorDialogs: true,
                  stickyAuth: true,
                  biometricOnly: false, // Allow PIN fallback
                ),
              );

              if (!authenticated) {
                // Authentication failed - exit app or stay on splash
                if (_hasNavigated) return;
                // User can try again by reopening the app
                return;
              }
            }
          } catch (e) {
            debugPrint('Biometric authentication error: $e');
            // On error, allow access (fail open for better UX)
          }
        }

        // Go directly to home (biometric check passed or not enabled)
        if (_hasNavigated) return;
        _hasNavigated = true;
        NavigationService.pushReplacementNamed(AppRoutes.home);
      });

      return null;
    }, [initializationAsync]);

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
                        Semantics(
                          label: l10n.appLogo,
                          image: true,
                          child: Image.asset(
                            Localizations.localeOf(context).languageCode == 'es'
                                ? 'assets/images/logo_spanish.png'
                                : 'assets/images/logo_transparent.png',
                            width: 200,
                            height: 200,
                            fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            // Fallback icon if logo not found
                            return Container(
                              width: 200,
                              height: 200,
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
                        ),

                        const SizedBox(height: 32),

                        // App name (clean, no card)
                        Text(
                          l10n.appName,
                          style: TextStyle(
                            fontSize: ResponsiveUtils.fontSize(context, 26, minSize: 22, maxSize: 30),
                            fontWeight: FontWeight.w300,
                            letterSpacing: 8,
                            color: AppTheme.goldColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.appNameSecond,
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
                          l10n.loadingJourney,
                          textAlign: TextAlign.center,
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
              bottom: MediaQuery.of(context).padding.bottom + 40,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: AlwaysStoppedAnimation(fadeAnimation),
                child: Column(
                  children: [
                    Text(
                      l10n.version,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, 12, minSize: 10, maxSize: 14),
                        color: AppColors.secondaryText.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      l10n.builtWithFaith,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, 12, minSize: 10, maxSize: 14),
                        color: AppColors.secondaryText.withValues(alpha: 0.7),
                      ),
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
