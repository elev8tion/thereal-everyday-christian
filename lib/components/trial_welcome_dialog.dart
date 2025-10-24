import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../components/glass_button.dart';
import '../utils/responsive_utils.dart';

class TrialWelcomeDialog extends StatelessWidget {
  const TrialWelcomeDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const TrialWelcomeDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.15),
              Colors.white.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: AppRadius.largeCardRadius,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: AppRadius.largeCardRadius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.goldColor.withValues(alpha: 0.3),
                          AppTheme.goldColor.withValues(alpha: 0.1),
                        ],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.goldColor.withValues(alpha: 0.5),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.auto_awesome,
                      size: ResponsiveUtils.fontSize(context, 48, minSize: 40, maxSize: 56),
                      color: AppTheme.goldColor,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Title
                  Text(
                    'Welcome! Start Your Free Trial',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: ResponsiveUtils.fontSize(context, 24, minSize: 20, maxSize: 28),
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryText,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Description
                  Text(
                    'Experience AI-powered biblical guidance',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                      color: AppColors.secondaryText,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Features
                  _buildFeature(context, Icons.chat_bubble, '5 AI messages per day for 3 days'),
                  const SizedBox(height: AppSpacing.md),
                  _buildFeature(context, Icons.menu_book, 'Scripture interpretation & guidance'),
                  const SizedBox(height: AppSpacing.md),
                  _buildFeature(context, Icons.favorite, 'Prayer support & encouragement'),

                  const SizedBox(height: AppSpacing.xl),

                  // Pricing info
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: AppRadius.mediumRadius,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Text(
                      'After trial: ~\$35/year for 150 messages/month',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, 12, minSize: 10, maxSize: 14),
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Buttons
                  Column(
                    children: [
                      GlassButton(
                        text: 'Start Free Trial',
                        onPressed: () => Navigator.of(context).pop(true),
                        height: 50,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text(
                          'Maybe Later',
                          style: TextStyle(
                            fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeature(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: ResponsiveUtils.fontSize(context, 20, minSize: 18, maxSize: 24),
          color: AppTheme.goldColor,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
              color: AppColors.primaryText,
            ),
          ),
        ),
      ],
    );
  }
}
