/// Paywall Screen
/// Shown when trial expires or when user needs to upgrade to premium
///
/// Displays:
/// - Trial status or expired message
/// - Premium features list
/// - Pricing ($35.99/year, 150 messages/month)
/// - Purchase and restore buttons

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../components/gradient_background.dart';
import '../components/frosted_glass_card.dart';
import '../components/glass_button.dart';
import '../components/glass_section_header.dart';
import '../components/category_badge.dart';
import '../components/glassmorphic_fab_menu.dart';
import '../components/standard_screen_header.dart';
import '../theme/app_theme.dart';
import '../core/providers/app_providers.dart';
import '../l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context);
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                top: AppSpacing.xl,
                left: AppSpacing.xl,
                right: AppSpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with StandardScreenHeader
                  _buildAppBar(isInTrial, trialDaysRemaining, subscriptionService),
                  const SizedBox(height: AppSpacing.xl),

                  // Subtitle - Trial or Expired (centered below header)
                  if (widget.showTrialInfo && isInTrial)
                    Center(
                      child: CategoryBadge(
                        text: l10n.paywallTrialDaysLeft(trialDaysRemaining),
                        icon: Icons.schedule,
                        badgeColor: Colors.blue,
                        isSelected: true,
                      ),
                    )
                  else if (subscriptionService.isTrialBlocked)
                    // Trial was already used on this device (survives app uninstall)
                    Center(
                      child: Text(
                        l10n.paywallTrialBlockedMessage,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.secondaryText,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  else
                    Center(
                      child: Text(
                        l10n.paywallTrialEndedMessage,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.secondaryText,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
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
                                label: l10n.paywallMessagesLeft,
                                color: Colors.purple,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: _buildStatCard(
                                icon: Icons.check_circle_outline,
                                value: '$messagesUsed',
                                label: isPremium ? l10n.paywallUsedThisMonth : l10n.paywallUsedInTrial,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: _buildStatCard(
                                icon: isPremium ? Icons.all_inclusive : Icons.schedule,
                                value: isPremium ? '150' : '$trialDaysRemaining',
                                label: isPremium ? l10n.paywallMonthlyLimit : l10n.paywallTrialDaysLeft2,
                                color: isPremium ? AppTheme.goldColor : Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                      ],

                      // Pricing Card (Tappable)
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 280),
                          child: GestureDetector(
                            onTap: _isProcessing ? null : _handlePurchase,
                            child: FrostedGlassCard(
                              padding: const EdgeInsets.all(AppSpacing.lg),
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
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.goldColor,
                                    height: 1.5,
                                  ),
                                ),
                                Text(
                                  premiumProduct?.price ?? '35.99',
                                  style: const TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.goldColor,
                                    height: 1,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  l10n.paywallPerYear,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.secondaryText,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l10n.paywallPricingDisclaimer,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.secondaryText.withValues(alpha: 0.7),
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
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
                              child: Text(
                                l10n.paywall150MessagesPerMonth,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryText,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              l10n.paywallLessThan3PerMonth,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.secondaryText,
                              ),
                            ),
                          ],
                        ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),

                      // Features Section
                      GlassSectionHeader(
                        title: l10n.paywallWhatsIncluded,
                        icon: Icons.check_circle_outline,
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Feature List
                      _buildFeatureItem(
                        context: context,
                        icon: Icons.chat_bubble_outline,
                        title: l10n.paywallFeatureIntelligentChat,
                        subtitle: l10n.paywallFeatureIntelligentChatDesc,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildFeatureItem(
                        context: context,
                        icon: Icons.all_inclusive,
                        title: l10n.paywallFeature150Messages,
                        subtitle: l10n.paywallFeature150MessagesDesc,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildFeatureItem(
                        context: context,
                        icon: Icons.psychology,
                        title: l10n.paywallFeatureContextAware,
                        subtitle: l10n.paywallFeatureContextAwareDesc,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildFeatureItem(
                        context: context,
                        icon: Icons.shield_outlined,
                        title: l10n.paywallFeatureCrisisDetection,
                        subtitle: l10n.paywallFeatureCrisisDetectionDesc,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildFeatureItem(
                        context: context,
                        icon: Icons.book_outlined,
                        title: l10n.paywallFeatureFullBibleAccess,
                        subtitle: l10n.paywallFeatureFullBibleAccessDesc,
                      ),
                      const SizedBox(height: AppSpacing.xxl),

                      // Purchase Button
                      GlassButton(
                        text: _isProcessing
                            ? l10n.paywallProcessing
                            : l10n.paywallStartPremiumButton,
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
                          child: Center(
                            child: Text(
                              l10n.paywallRestorePurchase,
                              style: const TextStyle(
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
                              l10n.paywallSubscriptionTerms,
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
          // Pinned FAB
          Positioned(
            top: MediaQuery.of(context).padding.top + AppSpacing.xl,
            left: AppSpacing.xl,
            child: const GlassmorphicFABMenu().animate().fadeIn(duration: AppAnimations.slow).slideY(begin: -0.3),
          ),
        ],
      ),
    );
  }

  /// Build header using StandardScreenHeader
  Widget _buildAppBar(bool isInTrial, int trialDaysRemaining, dynamic subscriptionService) {
    final l10n = AppLocalizations.of(context);
    return StandardScreenHeader(
      title: l10n.paywallTitle,
      subtitle: l10n.paywallSubtitle,
      showFAB: false, // FAB is positioned separately
    ).animate().fadeIn(duration: AppAnimations.slow).slideY(begin: -0.3);
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
    required BuildContext context,
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
    final l10n = AppLocalizations.of(context);

    // Set up purchase callback
    subscriptionService.onPurchaseUpdate = (success, error) {
      if (!mounted) return;

      setState(() => _isProcessing = false);

      if (success) {
        // CRITICAL FIX: Invalidate provider to refresh UI with new premium status
        ref.invalidate(subscriptionSnapshotProvider);

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
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: AppTheme.goldColor,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.paywallPremiumActivatedSuccess,
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
                      error ?? l10n.paywallPurchaseFailed,
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
    final l10n = AppLocalizations.of(context);

    // Set up restore callback
    subscriptionService.onPurchaseUpdate = (success, error) {
      if (!mounted) return;

      setState(() => _isProcessing = false);

      if (success) {
        // CRITICAL FIX: Invalidate provider to refresh UI with restored premium status
        ref.invalidate(subscriptionSnapshotProvider);

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
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: AppTheme.goldColor,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.paywallPurchaseRestoredSuccess,
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
                  Expanded(
                    child: Text(
                      l10n.paywallNoPreviousPurchaseFound,
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

    // Initiate restore
    await subscriptionService.restorePurchases();
  }

  @override
  void dispose() {
    // Clear callback - use try-catch since ref may not be accessible after dispose starts
    try {
      final subscriptionService = ref.read(subscriptionServiceProvider);
      subscriptionService.onPurchaseUpdate = null;
    } catch (_) {
      // Widget already disposed, callback will be garbage collected
    }
    super.dispose();
  }
}
