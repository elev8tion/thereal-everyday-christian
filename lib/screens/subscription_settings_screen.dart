/// Subscription Settings Screen
/// Shows current subscription status, message usage, and upgrade options
///
/// Displays:
/// - Subscription status (Free/Trial/Premium)
/// - Message usage (trial daily or premium monthly)
/// - Trial days remaining or renewal info
/// - Upgrade button (if not premium)
/// - Manage subscription link

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../components/gradient_background.dart';
import '../components/frosted_glass_card.dart';
import '../components/glass_button.dart';
import '../components/glass_section_header.dart';
import '../components/glassmorphic_fab_menu.dart';
import '../theme/app_theme.dart';
import '../theme/app_gradients.dart';
import '../core/providers/app_providers.dart';
import '../utils/responsive_utils.dart';
import 'paywall_screen.dart';

class SubscriptionSettingsScreen extends ConsumerWidget {
  const SubscriptionSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(isPremiumProvider);
    final isInTrial = ref.watch(isInTrialProvider);
    final hasTrialExpired = ref.watch(hasTrialExpiredProvider);
    final remainingMessages = ref.watch(remainingMessagesProvider);
    final messagesUsed = ref.watch(messagesUsedProvider);
    final trialDaysRemaining = ref.watch(trialDaysRemainingProvider);

    return Scaffold(
      body: Stack(
        children: [
          const GradientBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: AppSpacing.screenPadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status Header
                        _buildStatusHeader(
                          context: context,
                          isPremium: isPremium,
                          isInTrial: isInTrial,
                          hasTrialExpired: hasTrialExpired,
                          trialDaysRemaining: trialDaysRemaining,
                        ),
                        const SizedBox(height: AppSpacing.xxl),

                        // Stats Cards
                        _buildStatsCards(
                          context: context,
                          isPremium: isPremium,
                          remainingMessages: remainingMessages,
                          messagesUsed: messagesUsed,
                          trialDaysRemaining: trialDaysRemaining,
                        ),
                        const SizedBox(height: AppSpacing.xxl),

                        // What You Get Section
                        GlassSectionHeader(
                          title: isPremium ? 'Your Premium Benefits' : 'Upgrade to Premium',
                          icon: Icons.workspace_premium,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _buildBenefitsList(isPremium),
                        const SizedBox(height: AppSpacing.xxl),

                        // Action Buttons
                        if (!isPremium) ...[
                          GlassButton(
                            text: hasTrialExpired
                                ? 'Subscribe Now - ~\$35/year*'
                                : 'Start Free Trial',
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => PaywallScreen(
                                    showTrialInfo: !hasTrialExpired,
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: AppSpacing.lg),
                        ] else ...[
                          GlassButton(
                            text: 'Manage Subscription',
                            onPressed: () => _openManageSubscription(context),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                        ],

                        // Info Card
                        FrostedGlassCard(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          intensity: GlassIntensity.light,
                          child: Column(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: AppColors.secondaryText,
                                size: 20,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              AutoSizeText(
                                isPremium
                                    ? 'Your subscription automatically renews unless cancelled at least 24 hours before the end of the current period. Manage your subscription in App Store account settings.'
                                    : 'Start your 3-day free trial with 5 AI messages per day. After trial: ~\$35/year (varies by region) for 150 messages per month. Cancel anytime in App Store settings.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.secondaryText,
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 5,
                                minFontSize: 10,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                      ],
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

  /// Build custom app bar
  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: AppSpacing.screenPadding,
      child: Row(
        children: [
          const GlassmorphicFABMenu(),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: AutoSizeText(
              'Subscription',
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(context, 24, minSize: 20, maxSize: 28),
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText,
                shadows: AppTheme.textShadowStrong,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: AppAnimations.slow).slideY(begin: -0.3);
  }

  /// Build status header
  Widget _buildStatusHeader({
    required BuildContext context,
    required bool isPremium,
    required bool isInTrial,
    required bool hasTrialExpired,
    required int trialDaysRemaining,
  }) {
    String status;
    String subtitle;
    if (isPremium) {
      status = 'Premium Active';
      subtitle = 'Enjoy unlimited AI guidance';
    } else if (isInTrial) {
      status = 'Free Trial';
      subtitle = '$trialDaysRemaining days remaining';
    } else if (hasTrialExpired) {
      status = 'Trial Expired';
      subtitle = 'Upgrade to continue using AI chat';
    } else {
      status = 'Free Version';
      subtitle = 'Start your free trial';
    }

    return Column(
      children: [
        AutoSizeText(
          status,
          style: TextStyle(
            fontSize: ResponsiveUtils.fontSize(context, 24, minSize: 20, maxSize: 28),
            fontWeight: FontWeight.bold,
            color: AppColors.primaryText,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          minFontSize: 18,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpacing.sm),
        AutoSizeText(
          subtitle,
          style: TextStyle(
            fontSize: 16,
            color: AppColors.secondaryText,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          minFontSize: 14,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ).animate().fadeIn(delay: 200.ms).scale(delay: 200.ms);
  }

  /// Build stats cards
  Widget _buildStatsCards({
    required BuildContext context,
    required bool isPremium,
    required int remainingMessages,
    required int messagesUsed,
    required int trialDaysRemaining,
  }) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context: context,
            value: '$remainingMessages',
            label: 'Messages\nLeft',
            icon: Icons.chat_bubble_outline,
            color: Colors.purple,
            delay: 400,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _buildStatCard(
            context: context,
            value: '$messagesUsed',
            label: isPremium ? 'Used This\nMonth' : 'Used\nToday',
            icon: Icons.check_circle_outline,
            color: Colors.green,
            delay: 500,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _buildStatCard(
            context: context,
            value: isPremium ? '150' : '$trialDaysRemaining',
            label: isPremium ? 'Monthly\nLimit' : 'Trial Days\nLeft',
            icon: isPremium ? Icons.all_inclusive : Icons.schedule,
            color: isPremium ? AppTheme.goldColor : Colors.blue,
            delay: 600,
          ),
        ),
      ],
    );
  }

  /// Build individual stat card
  Widget _buildStatCard({
    required BuildContext context,
    required String value,
    required String label,
    required IconData icon,
    required Color color,
    required int delay,
  }) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        gradient: AppGradients.glassMedium,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, size: ResponsiveUtils.iconSize(context, 24), color: color),
          ),
          const SizedBox(height: AppSpacing.sm),
          AutoSizeText(
            value,
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 20, minSize: 16, maxSize: 24),
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
              shadows: AppTheme.textShadowStrong,
            ),
            maxLines: 1,
            minFontSize: 14,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          AutoSizeText(
            label,
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 11, minSize: 9, maxSize: 13),
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.9),
              shadows: AppTheme.textShadowSubtle,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            minFontSize: 8,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: delay)).scale(delay: Duration(milliseconds: delay));
  }

  /// Build benefits list
  Widget _buildBenefitsList(bool isPremium) {
    final benefits = [
      {
        'icon': Icons.chat_bubble_outline,
        'title': 'Intelligent Scripture Chat',
        'subtitle': 'Custom Real World Pastoral Training',
      },
      {
        'icon': Icons.all_inclusive,
        'title': '150 Messages Monthly',
        'subtitle': 'More than enough for daily conversations',
      },
      {
        'icon': Icons.psychology,
        'title': 'Context-Aware Responses',
        'subtitle': 'Biblical intelligence tailored to provide insight',
      },
      {
        'icon': Icons.shield_outlined,
        'title': 'Crisis Detection',
        'subtitle': 'Built-in safeguards and referrals',
      },
      {
        'icon': Icons.book_outlined,
        'title': 'Full Bible Access',
        'subtitle': 'All free features remain available',
      },
    ];

    return Column(
      children: benefits
          .asMap()
          .entries
          .map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: FrostedGlassCard(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  intensity: GlassIntensity.medium,
                  borderColor: AppTheme.goldColor.withValues(alpha: 0.4),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppTheme.goldColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          border: Border.all(
                            color: AppTheme.goldColor.withValues(alpha: 0.4),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          entry.value['icon'] as IconData,
                          size: 24,
                          color: AppTheme.goldColor,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AutoSizeText(
                              entry.value['title'] as String,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryText,
                              ),
                              maxLines: 2,
                              minFontSize: 14,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            AutoSizeText(
                              entry.value['subtitle'] as String,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.secondaryText,
                                height: 1.3,
                              ),
                              maxLines: 3,
                              minFontSize: 12,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      if (isPremium)
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 24,
                        ),
                    ],
                  ),
                ).animate().fadeIn(delay: Duration(milliseconds: 700 + (entry.key * 100))).slideX(begin: 0.3, delay: Duration(milliseconds: 700 + (entry.key * 100))),
              ))
          .toList(),
    );
  }

  /// Open manage subscription (App Store)
  Future<void> _openManageSubscription(BuildContext context) async {
    final Uri url = Uri.parse('https://apps.apple.com/account/subscriptions');

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unable to open subscription settings'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
