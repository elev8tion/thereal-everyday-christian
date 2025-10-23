/// Paywall Screen
/// Shown when trial expires or when user needs to upgrade to premium
///
/// Displays:
/// - Trial status or expired message
/// - Premium features list
/// - Pricing ($35/year, 150 messages/month)
/// - Purchase and restore buttons

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../components/gradient_background.dart';
import '../components/frosted_glass_card.dart';
import '../components/glass_button.dart';
import '../components/glass_section_header.dart';
import '../components/category_badge.dart';
import '../components/glassmorphic_fab_menu.dart';
import '../theme/app_theme.dart';
import '../core/providers/app_providers.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  /// Optional: show trial info (true) or expired message (false)
  final bool showTrialInfo;

  /// Optional: show message usage stats (messages left, used, days)
  final bool showMessageStats;

  const PaywallScreen({
    Key? key,
    this.showTrialInfo = true,
    this.showMessageStats = false,
  }) : super(key: key);

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final subscriptionService = ref.watch(subscriptionServiceProvider);
    final isInTrial = ref.watch(isInTrialProvider);
    final trialDaysRemaining = ref.watch(trialDaysRemainingProvider);
    final premiumProduct = subscriptionService.premiumProduct;
    final isPremium = ref.watch(isPremiumProvider);
    final remainingMessages = ref.watch(remainingMessagesProvider);
    final messagesUsed = ref.watch(messagesUsedProvider);

    return Scaffold(
      body: Stack(
        children: [
          const GradientBackground(),
          SafeArea(
            child: Column(
              children: [
                // App Bar with FAB
                Container(
                  padding: AppSpacing.screenPadding,
                  child: Row(
                    children: [
                      const GlassmorphicFABMenu(),
                      Expanded(child: Container()),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: AppSpacing.screenPadding,
                    child: Column(
                      children: [
                        // Title
                      const Text(
                        'Everyday Christian\nPremium',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryText,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Subtitle - Trial or Expired
                      if (widget.showTrialInfo && isInTrial)
                        Center(
                          child: CategoryBadge(
                            text: '$trialDaysRemaining days left in trial',
                            icon: Icons.schedule,
                            badgeColor: Colors.blue,
                            isSelected: true,
                          ),
                        )
                      else
                        Text(
                          'Your trial has ended.\nUpgrade to continue using AI chat.',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.secondaryText,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      const SizedBox(height: AppSpacing.xxl),

                      // Message Stats (if enabled)
                      if (widget.showMessageStats) ...[
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                icon: Icons.chat_bubble_outline,
                                value: '$remainingMessages',
                                label: 'Messages\nLeft',
                                color: Colors.purple,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: _buildStatCard(
                                icon: Icons.check_circle_outline,
                                value: '$messagesUsed',
                                label: isPremium ? 'Used This\nMonth' : 'Used\nToday',
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: _buildStatCard(
                                icon: isPremium ? Icons.all_inclusive : Icons.schedule,
                                value: isPremium ? '150' : '$trialDaysRemaining',
                                label: isPremium ? 'Monthly\nLimit' : 'Trial Days\nLeft',
                                color: isPremium ? AppTheme.goldColor : Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                      ],

                      // Pricing Card (Tappable)
                      GestureDetector(
                        onTap: _isProcessing ? null : _handlePurchase,
                        child: FrostedGlassCard(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          intensity: GlassIntensity.strong,
                          borderColor: AppTheme.goldColor.withValues(alpha: 0.8),
                          child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '\$',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.goldColor,
                                    height: 1.5,
                                  ),
                                ),
                                Text(
                                  premiumProduct?.price ?? '35',
                                  style: const TextStyle(
                                    fontSize: 56,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.goldColor,
                                    height: 1,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              'per year',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.secondaryText,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.lg,
                                vertical: AppSpacing.sm,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.goldColor.withValues(alpha: 0.2),
                                borderRadius: AppRadius.cardRadius,
                                border: Border.all(
                                  color: AppTheme.goldColor.withValues(alpha: 0.4),
                                  width: 1,
                                ),
                              ),
                              child: const Text(
                                '150 AI messages per month',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryText,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              'Less than \$3 per month',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.secondaryText,
                              ),
                            ),
                          ],
                        ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),

                      // Features Section
                      const GlassSectionHeader(
                        title: 'What\'s Included',
                        icon: Icons.check_circle_outline,
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Feature List
                      _buildFeatureItem(
                        icon: Icons.chat_bubble_outline,
                        title: 'Intelligent Scripture Chat',
                        subtitle: 'Custom Real World Pastoral Training',
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildFeatureItem(
                        icon: Icons.all_inclusive,
                        title: '150 Messages Monthly',
                        subtitle: 'More than enough for daily conversations',
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildFeatureItem(
                        icon: Icons.psychology,
                        title: 'Context-Aware Responses',
                        subtitle: 'Biblical intelligence tailored to provide insight',
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildFeatureItem(
                        icon: Icons.shield_outlined,
                        title: 'Crisis Detection',
                        subtitle: 'Built-in safeguards and professional referrals',
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildFeatureItem(
                        icon: Icons.book_outlined,
                        title: 'Full Bible Access',
                        subtitle: 'All free features remain available',
                      ),
                      const SizedBox(height: AppSpacing.xxl),

                      // Purchase Button
                      GlassButton(
                        text: _isProcessing
                            ? 'Processing...'
                            : 'Start Premium - ${premiumProduct?.price ?? "\$35"}/year',
                        onPressed: _isProcessing ? null : _handlePurchase,
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Restore Button
                      GestureDetector(
                        onTap: _isProcessing ? null : _handleRestore,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.md,
                          ),
                          child: const Center(
                            child: Text(
                              'Restore Previous Purchase',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.goldColor,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Terms
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
                            Text(
                              'Payment will be charged to your App Store account. Subscription automatically renews unless auto-renew is turned off at least 24 hours before the end of the current period. Cancel anytime in your App Store account settings.',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.secondaryText,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
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

  /// Build a stat card (for message stats display)
  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return FrostedGlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      intensity: GlassIntensity.medium,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, size: 24, color: color),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
              shadows: AppTheme.textShadowStrong,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.9),
              shadows: AppTheme.textShadowSubtle,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  /// Build a feature list item
  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return FrostedGlassCard(
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
              icon,
              size: 24,
              color: AppTheme.goldColor,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.secondaryText,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Handle purchase button
  Future<void> _handlePurchase() async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    final subscriptionService = ref.read(subscriptionServiceProvider);

    // Set up purchase callback
    subscriptionService.onPurchaseUpdate = (success, error) {
      if (!mounted) return;

      setState(() => _isProcessing = false);

      if (success) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
            margin: const EdgeInsets.all(16),
            padding: EdgeInsets.zero,
            content: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1E293B), // slate-800
                    Color(0xFF0F172A), // slate-900
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.goldColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: AppTheme.goldColor,
                    size: 20,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Premium activated! 150 Messages Monthly.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        // Close paywall
        Navigator.of(context).pop();
      } else {
        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
            margin: const EdgeInsets.all(16),
            padding: EdgeInsets.zero,
            content: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1E293B), // slate-800
                    Color(0xFF0F172A), // slate-900
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.red.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red.shade300,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      error ?? 'Purchase failed. Please try again.',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    };

    // Initiate purchase
    await subscriptionService.purchasePremium();
  }

  /// Handle restore button
  Future<void> _handleRestore() async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    final subscriptionService = ref.read(subscriptionServiceProvider);

    // Set up restore callback
    subscriptionService.onPurchaseUpdate = (success, error) {
      if (!mounted) return;

      setState(() => _isProcessing = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
            margin: const EdgeInsets.all(16),
            padding: EdgeInsets.zero,
            content: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1E293B), // slate-800
                    Color(0xFF0F172A), // slate-900
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.goldColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: AppTheme.goldColor,
                    size: 20,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Purchase restored successfully!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
            margin: const EdgeInsets.all(16),
            padding: EdgeInsets.zero,
            content: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1E293B), // slate-800
                    Color(0xFF0F172A), // slate-900
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.orange.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.orange.shade300,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'No previous purchase found.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    };

    // Initiate restore
    await subscriptionService.restorePurchases();
  }

  @override
  void dispose() {
    // Clear callback (check if mounted to avoid using ref after dispose)
    if (mounted) {
      final subscriptionService = ref.read(subscriptionServiceProvider);
      subscriptionService.onPurchaseUpdate = null;
    }
    super.dispose();
  }
}
