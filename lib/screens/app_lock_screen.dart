import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../components/frosted_glass_card.dart';
import '../components/glass_button.dart';
import '../features/auth/services/biometric_service.dart';
import '../l10n/app_localizations.dart';

/// Custom app lock screen with glassmorphic design and biometric authentication
///
/// Features:
/// - Beautiful glassmorphic design matching app theme
/// - Biometric authentication (Face ID/Touch ID)
/// - Fallback to passcode if biometrics fail
/// - Loading states and animations
/// - Error handling with user-friendly messages
class AppLockScreen extends StatefulWidget {
  const AppLockScreen({super.key});

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen> {
  final BiometricService _biometricService = BiometricService();

  bool _isAuthenticating = false;
  bool _authenticationFailed = false;
  String? _errorMessage;
  BiometricSettings? _biometricSettings;

  @override
  void initState() {
    super.initState();
    _initializeBiometrics();

    // Auto-trigger biometric authentication on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authenticateWithBiometrics();
    });
  }

  Future<void> _initializeBiometrics() async {
    try {
      final settings = await _biometricService.getSettings();
      if (mounted) {
        setState(() {
          _biometricSettings = settings;
        });
      }
    } catch (e) {
      debugPrint('Error initializing biometrics: $e');
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
      _authenticationFailed = false;
      _errorMessage = null;
    });

    try {
      // Trigger haptic feedback
      HapticFeedback.mediumImpact();

      final authenticated = await _biometricService.authenticate(
        localizedFallbackTitle: 'Use Passcode',
        androidSignInTitle: 'Unlock EDC Faith',
        androidCancelButton: 'Cancel',
        androidGoToSettingsDescription: 'Please set up biometric authentication in Settings',
        biometricOnly: false,
        stickyAuth: true,
      );

      if (mounted) {
        if (authenticated) {
          // Success! Navigate to home
          HapticFeedback.lightImpact();
          await Future.delayed(const Duration(milliseconds: 300));
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/home');
          }
        } else {
          // Authentication failed
          setState(() {
            _authenticationFailed = true;
            _errorMessage = 'Authentication failed. Please try again.';
          });
          HapticFeedback.heavyImpact();
        }
      }
    } on BiometricException catch (e) {
      if (mounted) {
        setState(() {
          _authenticationFailed = true;
          _errorMessage = e.message;
        });
        HapticFeedback.heavyImpact();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _authenticationFailed = true;
          _errorMessage = 'An unexpected error occurred. Please try again.';
        });
        HapticFeedback.heavyImpact();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAuthenticating = false;
        });
      }
    }
  }

  String _getBiometricTypeText() {
    if (_biometricSettings == null) return 'Biometric Authentication';

    if (_biometricSettings!.hasType(BiometricType.face)) {
      return 'Face ID';
    } else if (_biometricSettings!.hasType(BiometricType.fingerprint)) {
      return 'Touch ID';
    } else {
      return 'Biometric Authentication';
    }
  }

  IconData _getBiometricIcon() {
    if (_biometricSettings == null) return Icons.fingerprint;

    if (_biometricSettings!.hasType(BiometricType.face)) {
      return Icons.face;
    } else if (_biometricSettings!.hasType(BiometricType.fingerprint)) {
      return Icons.fingerprint;
    } else {
      return Icons.lock;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final isSpanish = l10n.localeName == 'es';

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF1a1a2e),
                    const Color(0xFF16213e),
                    const Color(0xFF0f3460),
                  ]
                : [
                    const Color(0xFF667eea),
                    const Color(0xFF764ba2),
                    const Color(0xFFf093fb),
                  ],
          ),
        ),
        child: Stack(
          children: [
            // Main content
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // App logo (no animation)
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            isSpanish
                                ? 'assets/images/logo_spanish.png'
                                : 'assets/images/logo_cropped.png',
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Welcome text
                      Text(
                        'Welcome Back',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 32,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Subtitle
                      Text(
                        'Unlock to continue your journey',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 60),

                      // Glass card with biometric info
                      FrostedGlassCard(
                        intensity: GlassIntensity.medium,
                        padding: const EdgeInsets.all(32),
                        borderRadius: 24,
                        child: Column(
                          children: [
                            // Biometric icon
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white.withValues(alpha: 0.2),
                                    Colors.white.withValues(alpha: 0.05),
                                  ],
                                ),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                _getBiometricIcon(),
                                size: 40,
                                color: _authenticationFailed
                                    ? Colors.red.withValues(alpha: 0.8)
                                    : Colors.white.withValues(alpha: 0.9),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Status text
                            if (_isAuthenticating)
                              Column(
                                children: [
                                  CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white.withValues(alpha: 0.8),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Authenticating...',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: Colors.white.withValues(alpha: 0.9),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              )
                            else if (_authenticationFailed && _errorMessage != null)
                              Column(
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    size: 32,
                                    color: Colors.red.withValues(alpha: 0.8),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    _errorMessage!,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: Colors.red.withValues(alpha: 0.9),
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              )
                            else
                              Text(
                                'Tap to unlock with ${_getBiometricTypeText()}',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),

                            const SizedBox(height: 32),

                            // Unlock button
                            GlassButton(
                              text: _isAuthenticating
                                  ? 'Authenticating...'
                                  : _authenticationFailed
                                      ? 'Try Again'
                                      : 'Unlock',
                              onPressed: _isAuthenticating
                                  ? null
                                  : _authenticateWithBiometrics,
                              isLoading: _isAuthenticating,
                              height: 56,
                              width: double.infinity,
                              enablePressAnimation: true,
                              enableHaptics: true,
                              blurStrength: 40,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Fallback text
                      if (!_isAuthenticating && _biometricSettings?.isAvailable == true)
                        TextButton(
                          onPressed: () {
                            // TODO: Implement passcode fallback
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Passcode fallback not implemented yet'),
                                backgroundColor: Colors.orange.withValues(alpha: 0.9),
                              ),
                            );
                          },
                          child: Text(
                            'Use Passcode Instead',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.7),
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                        ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
