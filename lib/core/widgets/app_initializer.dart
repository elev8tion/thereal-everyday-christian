import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/app_providers.dart';
import '../error/app_error.dart';
import '../../components/gradient_background.dart';
import '../../components/frosted_glass_card.dart';
import '../../theme/app_theme.dart';

class AppInitializer extends ConsumerWidget {
  final Widget child;

  const AppInitializer({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initializationAsync = ref.watch(appInitializationProvider);

    return initializationAsync.when(
      data: (_) => child,
      loading: () => _LoadingScreen(ref: ref),
      error: (error, stack) => _ErrorScreen(
        error: error,
        onRetry: () => ref.invalidate(appInitializationProvider),
      ),
    );
  }
}

class _LoadingScreen extends StatefulWidget {
  final WidgetRef ref;

  const _LoadingScreen({required this.ref});

  @override
  State<_LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<_LoadingScreen> {
  final List<String> _loadingMessages = [
    'Loading Bible...',
    'Restoring subscription...',
    'Preparing devotionals...',
    'Setting up your journey...',
  ];

  int _currentMessageIndex = 0;

  @override
  void initState() {
    super.initState();
    _cycleMessages();
  }

  void _cycleMessages() {
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        setState(() {
          _currentMessageIndex = (_currentMessageIndex + 1) % _loadingMessages.length;
        });
        _cycleMessages();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const GradientBackground(),
          // Radial glow effect
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [
                    AppTheme.primaryColor.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo container with glass effect
                  FrostedGlassCard(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo image
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: AppRadius.cardRadius,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryColor.withValues(alpha: 0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: AppRadius.cardRadius,
                            child: Image.asset(
                              'assets/images/logo.png',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  decoration: BoxDecoration(
                                    borderRadius: AppRadius.cardRadius,
                                    color: AppTheme.goldColor,
                                  ),
                                  child: const Icon(
                                    Icons.auto_stories,
                                    size: 50,
                                    color: Colors.white,
                                  ),
                                );
                              },
                            ),
                          ),
                        ).animate(
                          onPlay: (controller) => controller.repeat(),
                        ).shimmer(
                          duration: 2000.ms,
                          color: AppTheme.primaryColor.withValues(alpha: 0.3),
                        ),

                        const SizedBox(height: 24),

                        // App name
                        const Text(
                          'EVERYDAY',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 3,
                            color: AppTheme.primaryColor,
                          ),
                        ).animate().fadeIn(duration: 600.ms),
                        const Text(
                          'CHRISTIAN',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            color: Colors.white,
                          ),
                        ).animate().fadeIn(duration: 600.ms, delay: 200.ms),

                        const SizedBox(height: 32),

                        // Loading indicator
                        const SizedBox(
                          width: 50,
                          height: 50,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.primaryColor,
                            ),
                            strokeWidth: 3,
                          ),
                        ).animate(
                          onPlay: (controller) => controller.repeat(),
                        ).fadeIn(duration: 400.ms),

                        const SizedBox(height: 20),

                        // Dynamic loading text
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          transitionBuilder: (Widget child, Animation<double> animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.2),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                          child: Text(
                            _loadingMessages[_currentMessageIndex],
                            key: ValueKey<int>(_currentMessageIndex),
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Progress dots
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            _loadingMessages.length,
                            (index) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: index == _currentMessageIndex
                                    ? AppTheme.primaryColor
                                    : Colors.white.withValues(alpha: 0.3),
                              ),
                            ).animate(
                              target: index == _currentMessageIndex ? 1 : 0,
                            ).scale(
                              duration: 300.ms,
                              begin: const Offset(0.8, 0.8),
                              end: const Offset(1.2, 1.2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 800.ms).scale(
                    begin: const Offset(0.9, 0.9),
                    duration: 800.ms,
                  ),

                  const SizedBox(height: 40),

                  // Helpful tip
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: AppRadius.mediumRadius,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.lightbulb_outline,
                          color: AppTheme.goldColor,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            'First launch may take a moment to load Bible data',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 600.ms, delay: 1000.ms).slideY(
                    begin: 0.3,
                    duration: 600.ms,
                  ),
                ],
              ),
            ),
          ),

          // Bottom branding
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ).animate().fadeIn(duration: 600.ms, delay: 1200.ms),
          ),
        ],
      ),
    );
  }
}

class _ErrorScreen extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const _ErrorScreen({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final errorMessage = error is AppError
        ? (error as AppError).userMessage
        : 'Failed to initialize app';

    return Scaffold(
      body: Stack(
        children: [
          const GradientBackground(),
          // Radial glow effect
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [
                    Colors.red.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FrostedGlassCard(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Error icon with animation
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red.withValues(alpha: 0.1),
                              border: Border.all(
                                color: Colors.red.withValues(alpha: 0.3),
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 48,
                            ),
                          ).animate(
                            onPlay: (controller) => controller.repeat(reverse: true),
                          ).scale(
                            duration: 1000.ms,
                            begin: const Offset(1.0, 1.0),
                            end: const Offset(1.1, 1.1),
                          ),

                          const SizedBox(height: 24),

                          // Error title
                          const Text(
                            'Initialization Failed',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ).animate().fadeIn(duration: 600.ms),

                          const SizedBox(height: 16),

                          // Error message
                          Text(
                            errorMessage,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 15,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ).animate().fadeIn(duration: 600.ms, delay: 200.ms),

                          const SizedBox(height: 28),

                          // Retry button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: onRetry,
                              icon: const Icon(Icons.refresh),
                              label: const Text(
                                'Try Again',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: AppRadius.mediumRadius,
                                ),
                                elevation: 4,
                              ),
                            ),
                          ).animate().fadeIn(duration: 600.ms, delay: 400.ms).slideY(
                            begin: 0.2,
                            duration: 600.ms,
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 800.ms).scale(
                      begin: const Offset(0.9, 0.9),
                      duration: 800.ms,
                    ),

                    const SizedBox(height: 32),

                    // Troubleshooting tips
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: AppRadius.mediumRadius,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: AppTheme.goldColor,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Troubleshooting Tips',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '• Check your internet connection\n'
                            '• Ensure sufficient storage space\n'
                            '• Restart the app if issue persists',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.7),
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 600.ms, delay: 800.ms).slideY(
                      begin: 0.3,
                      duration: 600.ms,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}