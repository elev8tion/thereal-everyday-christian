/// Chat Screen Lockout Overlay
/// Displays when trial has expired or premium subscription has ended
/// Prevents viewing chat history and sending messages

import 'package:flutter/material.dart';
import '../components/frosted_glass_card.dart';
import '../components/glass_button.dart';
import '../theme/app_theme.dart';
import '../utils/responsive_utils.dart';

class ChatScreenLockoutOverlay extends StatelessWidget {
  final VoidCallback onSubscribePressed;

  const ChatScreenLockoutOverlay({
    Key? key,
    required this.onSubscribePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // Full screen overlay with blur effect
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black.withValues(alpha: 0.7),
            Colors.black.withValues(alpha: 0.85),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Container(
              constraints: BoxConstraints(
                maxWidth: ResponsiveUtils.maxContentWidth(context) * 0.9,
              ),
              child: FrostedGlassCard(
                intensity: GlassIntensity.strong,
                borderColor: AppTheme.goldColor.withValues(alpha: 0.6),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Lock Icon
                      Container(
                        width: 100,
                        height: 100,
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
                          border: Border.all(
                            color: AppTheme.goldColor.withValues(alpha: 0.5),
                            width: 3,
                          ),
                        ),
                        child: Icon(
                          Icons.lock_outline,
                          size: ResponsiveUtils.iconSize(context, 50),
                          color: AppTheme.goldColor,
                        ),
                      ),
                      SizedBox(height: ResponsiveUtils.spacing(context, AppSpacing.xl)),

                      // Title
                      Text(
                        'AI Chat Requires\nSubscription',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.fontSize(context, 28, minSize: 24, maxSize: 32),
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryText,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: ResponsiveUtils.spacing(context, AppSpacing.lg)),

                      // Message
                      Text(
                        'Subscribe to view your chat history and continue conversations with AI-powered Biblical guidance.',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
                          color: AppColors.secondaryText,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: ResponsiveUtils.spacing(context, AppSpacing.xxl)),

                      // Benefits list
                      _buildBenefitItem(
                        context,
                        icon: Icons.chat_bubble_outline,
                        text: '150 AI messages per month',
                      ),
                      SizedBox(height: ResponsiveUtils.spacing(context, AppSpacing.md)),
                      _buildBenefitItem(
                        context,
                        icon: Icons.history,
                        text: 'Access to all your chat history',
                      ),
                      SizedBox(height: ResponsiveUtils.spacing(context, AppSpacing.md)),
                      _buildBenefitItem(
                        context,
                        icon: Icons.auto_awesome,
                        text: 'Personalized Biblical guidance',
                      ),
                      SizedBox(height: ResponsiveUtils.spacing(context, AppSpacing.xxl)),

                      // Subscribe button
                      GlassButton(
                        text: 'Subscribe Now',
                        onPressed: onSubscribePressed,
                      ),
                      SizedBox(height: ResponsiveUtils.spacing(context, AppSpacing.lg)),

                      // Info text
                      Text(
                        'Prayer journal, Bible reading, and verses remain free and unlimited',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.fontSize(context, 12, minSize: 10, maxSize: 14),
                          color: AppColors.tertiaryText,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitItem(BuildContext context, {required IconData icon, required String text}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppTheme.goldColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(
              color: AppTheme.goldColor.withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            size: ResponsiveUtils.iconSize(context, 20),
            color: AppTheme.goldColor,
          ),
        ),
        SizedBox(width: ResponsiveUtils.spacing(context, AppSpacing.md)),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
              color: AppColors.primaryText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
