import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../theme/app_theme.dart';
import '../theme/app_gradients.dart';
import '../components/frosted_glass_card.dart';
import '../components/clear_glass_card.dart';
import '../components/glass_button.dart';
import '../components/gradient_background.dart';
import '../components/glassmorphic_fab_menu.dart';
import '../components/dark_glass_container.dart';
import '../components/fab_tooltip.dart';
import '../core/navigation/app_routes.dart';
import '../core/providers/app_providers.dart';
import '../core/navigation/navigation_service.dart';
import '../core/services/preferences_service.dart';
import '../core/services/subscription_service.dart';
import '../components/trial_welcome_dialog.dart';
import '../utils/responsive_utils.dart';
import '../l10n/app_localizations.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final GlobalKey _backgroundKey = GlobalKey();
  bool _showFabTooltip = false;

  @override
  void initState() {
    super.initState();
    _checkShowTrialWelcome();
    _checkShowFabTooltip();
  }

  Future<void> _checkShowTrialWelcome() async {
    // Wait for widget to build
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    final subscriptionService = SubscriptionService.instance;

    // Show dialog if:
    // 1. User hasn't started trial yet
    // 2. User isn't premium
    // 3. Haven't shown dialog before
    if (!subscriptionService.hasStartedTrial &&
        !subscriptionService.isPremium) {
      final prefsService = await PreferencesService.getInstance();
      final sharedPrefs = prefsService.prefs;
      final shownBefore = sharedPrefs?.getBool('trial_welcome_shown') ?? false;

      if (!shownBefore && mounted) {
        // Mark as shown
        await sharedPrefs?.setBool('trial_welcome_shown', true);

        // Show dialog
        // ignore: use_build_context_synchronously
        final result = await TrialWelcomeDialog.show(context);

        // If user clicked "Start Free Trial", navigate to chat
        if (result == true && mounted) {
          Navigator.of(context).pushNamed(AppRoutes.chat);
        }
      }
    }
  }

  Future<void> _checkShowFabTooltip() async {
    // Wait longer to ensure trial welcome dialog is shown/dismissed first
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    final prefsService = await PreferencesService.getInstance();

    // Check if FAB tutorial has been shown before
    if (!prefsService.hasFabTutorialShown() && mounted) {
      setState(() {
        _showFabTooltip = true;
      });
    }
  }

  void _dismissFabTooltip() async {
    setState(() {
      _showFabTooltip = false;
    });

    // Mark as shown so it doesn't appear again
    final prefsService = await PreferencesService.getInstance();
    await prefsService.setFabTutorialShown();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: Stack(
        children: [
          RepaintBoundary(
            key: _backgroundKey,
            child: const GradientBackground(),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: AppSpacing.xl), // Top padding
              // Optimize scrolling performance
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                      height: 56 +
                          AppSpacing.lg +
                          32), // Space for FAB + spacing + 32px padding
                  _buildStatsRow(),
                  const SizedBox(height: AppSpacing.xxl),
                  _buildMainFeatures(),
                  const SizedBox(height: AppSpacing.xxl),
                  _buildQuickActions(),
                  const SizedBox(height: AppSpacing.xxl),
                  _buildDailyVerse(),
                  const SizedBox(height: AppSpacing.xxl),
                  _buildStartChatButton(),
                ],
              ),
            ),
          ),
          // Pinned FAB
          Positioned(
            top: MediaQuery.of(context).padding.top + AppSpacing.xl,
            left: AppSpacing.xl,
            child: GlassmorphicFABMenu(
              onMenuOpened: _dismissFabTooltip,
            )
                .animate()
                .fadeIn(duration: AppAnimations.slow)
                .slideY(begin: -0.3),
          ),
          // FAB Tooltip for first-time users
          if (_showFabTooltip)
            Positioned(
              top: MediaQuery.of(context).padding.top +
                  AppSpacing.xl +
                  80, // Position below FAB
              left: AppSpacing.xl,
              child: FabTooltip(
                message: l10n.fabTooltipMessage,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    final l10n = AppLocalizations.of(context);
    final streakAsync = ref.watch(devotionalStreakProvider);
    final totalCompletedAsync = ref.watch(totalDevotionalsCompletedProvider);
    final prayersCountAsync = ref.watch(activePrayersCountProvider);
    final versesCountAsync = ref.watch(savedVersesCountProvider);

    return LayoutBuilder(
      builder: (context, constraints) => SizedBox(
        height: ResponsiveUtils.scaleSize(context, 100,
            minScale: 0.9, maxScale: 1.2),
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: AppSpacing.horizontalXl,
          // Optimize horizontal scrolling performance
          physics: const BouncingScrollPhysics(),
          cacheExtent: 300,
          children: [
            streakAsync.when(
              data: (streak) => _buildStatCard(
                value: "$streak",
                label: l10n.dayStreak,
                icon: Icons.local_fire_department,
                color: Colors.orange,
                delay: 600,
              ),
              loading: () => _buildStatCardLoading(
                label: l10n.dayStreak,
                icon: Icons.local_fire_department,
                color: Colors.orange,
                delay: 600,
              ),
              error: (_, __) => _buildStatCard(
                value: "0",
                label: l10n.dayStreak,
                icon: Icons.local_fire_department,
                color: Colors.orange,
                delay: 600,
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            prayersCountAsync.when(
              data: (count) => _buildStatCard(
                value: "$count",
                label: l10n.prayers,
                icon: Icons.favorite,
                color: Colors.red,
                delay: 700,
              ),
              loading: () => _buildStatCardLoading(
                label: l10n.prayers,
                icon: Icons.favorite,
                color: Colors.red,
                delay: 700,
              ),
              error: (_, __) => _buildStatCard(
                value: "0",
                label: l10n.prayers,
                icon: Icons.favorite,
                color: Colors.red,
                delay: 700,
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            versesCountAsync.when(
              data: (count) => _buildStatCard(
                value: "$count",
                label: l10n.savedVerses,
                icon: Icons.menu_book,
                color: AppTheme.goldColor,
                delay: 800,
              ),
              loading: () => _buildStatCardLoading(
                label: l10n.savedVerses,
                icon: Icons.menu_book,
                color: AppTheme.goldColor,
                delay: 800,
              ),
              error: (_, __) => _buildStatCard(
                value: "0",
                label: l10n.savedVerses,
                icon: Icons.menu_book,
                color: AppTheme.goldColor,
                delay: 800,
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            totalCompletedAsync.when(
              data: (total) => _buildStatCard(
                value: "$total",
                label: l10n.devotionals,
                icon: Icons.auto_stories,
                color: Colors.green,
                delay: 900,
              ),
              loading: () => _buildStatCardLoading(
                label: l10n.devotionals,
                icon: Icons.auto_stories,
                color: Colors.green,
                delay: 900,
              ),
              error: (_, __) => _buildStatCard(
                value: "0",
                label: l10n.devotionals,
                icon: Icons.auto_stories,
                color: Colors.green,
                delay: 900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
    required int delay,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) => Container(
        width: ResponsiveUtils.scaleSize(context, 120,
            minScale: 0.9, maxScale: 1.2),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: AppGradients.glassMedium,
          borderRadius: AppRadius.cardRadius,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: AppRadius.mediumRadius,
              ),
              child: Icon(
                icon,
                size: ResponsiveUtils.iconSize(context, 20),
                color: AppColors.secondaryText,
              ),
            ),
            const SizedBox(height: 4),
            // Value text with auto-sizing to prevent overflow
            Flexible(
              child: AutoSizeText(
                value,
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 20,
                      minSize: 16, maxSize: 22),
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryText,
                  shadows: AppTheme.textShadowStrong,
                ),
                maxLines: 1,
                minFontSize: 14,
                maxFontSize: 22,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 2),
            // Label text with auto-sizing
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: AutoSizeText(
                  label,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, 9,
                        minSize: 8, maxSize: 11),
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.9),
                    shadows: AppTheme.textShadowSubtle,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  minFontSize: 7,
                  maxFontSize: 11,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: delay))
        .scale(delay: Duration(milliseconds: delay));
  }

  Widget _buildStatCardLoading({
    required String label,
    required IconData icon,
    required Color color,
    required int delay,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) => Container(
        width: ResponsiveUtils.scaleSize(context, 120,
            minScale: 0.9, maxScale: 1.2),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: AppGradients.glassMedium,
          borderRadius: AppRadius.cardRadius,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: AppRadius.mediumRadius,
              ),
              child: Icon(
                icon,
                size: ResponsiveUtils.iconSize(context, 20),
                color: AppColors.secondaryText,
              ),
            ),
            const SizedBox(height: 4),
            // Placeholder text instead of infinite spinner (fixes test timeouts)
            Flexible(
              child: AutoSizeText(
                "...",
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 20,
                      minSize: 16, maxSize: 22),
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryText.withValues(alpha: 0.5),
                  shadows: AppTheme.textShadowStrong,
                ),
                maxLines: 1,
                minFontSize: 14,
                maxFontSize: 22,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 2),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: AutoSizeText(
                  label,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, 9,
                        minSize: 8, maxSize: 11),
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.9),
                    shadows: AppTheme.textShadowSubtle,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  minFontSize: 7,
                  maxFontSize: 11,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: delay))
        .scale(delay: Duration(milliseconds: delay));
  }

  Widget _buildMainFeatures() {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: AppSpacing.horizontalXl,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: ResponsiveUtils.scaleSize(context, 140,
                      minScale: 0.9, maxScale: 1.2),
                  child: FrostedGlassCard(
                    padding: const EdgeInsets.all(12),
                    onTap: () => NavigationService.goToChat(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClearGlassCard(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            Icons.chat_bubble_outline,
                            size: ResponsiveUtils.iconSize(context, 20),
                            color: AppColors.primaryText,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          l10n.biblicalChat,
                          style: TextStyle(
                            fontSize: ResponsiveUtils.fontSize(context, 16,
                                minSize: 14, maxSize: 18),
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.biblicalChatDesc,
                          style: TextStyle(
                            fontSize: ResponsiveUtils.fontSize(context, 12,
                                minSize: 10, maxSize: 14),
                            color: AppColors.secondaryText,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: SizedBox(
                  height: ResponsiveUtils.scaleSize(context, 140,
                      minScale: 0.9, maxScale: 1.2),
                  child: FrostedGlassCard(
                    padding: const EdgeInsets.all(12),
                    onTap: () => NavigationService.goToDevotional(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClearGlassCard(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            Icons.auto_stories,
                            size: ResponsiveUtils.iconSize(context, 20),
                            color: AppColors.primaryText,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          l10n.dailyDevotional,
                          style: TextStyle(
                            fontSize: ResponsiveUtils.fontSize(context, 16,
                                minSize: 14, maxSize: 18),
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.dailyDevotionalDesc,
                          style: TextStyle(
                            fontSize: ResponsiveUtils.fontSize(context, 12,
                                minSize: 10, maxSize: 14),
                            color: AppColors.secondaryText,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ).animate().fadeIn(delay: 1000.ms).scale(delay: 1000.ms),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: ResponsiveUtils.scaleSize(context, 140,
                      minScale: 0.9, maxScale: 1.2),
                  child: FrostedGlassCard(
                    padding: const EdgeInsets.all(12),
                    onTap: () => NavigationService.goToPrayerJournal(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClearGlassCard(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            Icons.favorite_outline,
                            size: ResponsiveUtils.iconSize(context, 20),
                            color: AppColors.primaryText,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          l10n.prayerJournal,
                          style: TextStyle(
                            fontSize: ResponsiveUtils.fontSize(context, 16,
                                minSize: 14, maxSize: 18),
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.prayerJournalDesc,
                          style: TextStyle(
                            fontSize: ResponsiveUtils.fontSize(context, 12,
                                minSize: 10, maxSize: 14),
                            color: AppColors.secondaryText,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: SizedBox(
                  height: ResponsiveUtils.scaleSize(context, 140,
                      minScale: 0.9, maxScale: 1.2),
                  child: FrostedGlassCard(
                    padding: const EdgeInsets.all(12),
                    onTap: () => NavigationService.goToReadingPlan(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClearGlassCard(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            Icons.library_books_outlined,
                            size: ResponsiveUtils.iconSize(context, 20),
                            color: AppColors.primaryText,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          l10n.readingPlans,
                          style: TextStyle(
                            fontSize: ResponsiveUtils.fontSize(context, 16,
                                minSize: 14, maxSize: 18),
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.readingPlansDesc,
                          style: TextStyle(
                            fontSize: ResponsiveUtils.fontSize(context, 12,
                                minSize: 10, maxSize: 14),
                            color: AppColors.secondaryText,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ).animate().fadeIn(delay: 1100.ms).scale(delay: 1100.ms),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: AppSpacing.horizontalXl,
          child: Text(
            l10n.quickActions,
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 20,
                  minSize: 18, maxSize: 24),
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText,
              shadows: AppTheme.textShadowStrong,
            ),
          ),
        ).animate().fadeIn(delay: 1200.ms).slideY(begin: 0.3, delay: 1200.ms),
        const SizedBox(height: AppSpacing.lg),
        LayoutBuilder(
          builder: (context, constraints) => SizedBox(
            height: ResponsiveUtils.scaleSize(context, 100,
                minScale: 0.9, maxScale: 1.2),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: AppSpacing.horizontalXl,
              // Optimize horizontal scrolling performance
              physics: const BouncingScrollPhysics(),
              cacheExtent: 200,
              children: [
                _buildQuickActionCard(
                  label: l10n.readBible,
                  icon: Icons.menu_book,
                  color: AppTheme.goldColor,
                  onTap: () => NavigationService.goToBibleBrowser(),
                  delay: 1400,
                ),
                const SizedBox(width: AppSpacing.lg),
                _buildQuickActionCard(
                  label: l10n.verseLibrary,
                  icon: Icons.search,
                  color: Colors.blue,
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.verseLibrary),
                  delay: 1500,
                ),
                const SizedBox(width: AppSpacing.lg),
                _buildQuickActionCard(
                  label: l10n.addPrayer,
                  icon: Icons.add,
                  color: Colors.green,
                  onTap: () => NavigationService.goToPrayerJournal(),
                  delay: 1600,
                ),
                const SizedBox(width: AppSpacing.lg),
                _buildQuickActionCard(
                  label: l10n.settings,
                  icon: Icons.settings,
                  color: Colors.grey[300]!,
                  onTap: () => NavigationService.goToSettings(),
                  delay: 1700,
                ),
                const SizedBox(width: AppSpacing.lg),
                _buildQuickActionCard(
                  label: l10n.profile,
                  icon: Icons.person,
                  color: Colors.purple,
                  onTap: () => NavigationService.goToProfile(),
                  delay: 1800,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required int delay,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: ResponsiveUtils.scaleSize(context, 100,
              minScale: 0.9, maxScale: 1.2),
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: AppRadius.mediumRadius,
                ),
                child: Icon(
                  icon,
                  size: ResponsiveUtils.iconSize(context, 24),
                  color: AppColors.secondaryText,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Flexible(
                child: AutoSizeText(
                  label,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, 11,
                        minSize: 9, maxSize: 13),
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.9),
                    shadows: AppTheme.textShadowSubtle,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  minFontSize: 7,
                  maxFontSize: 13,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: delay))
        .scale(delay: Duration(milliseconds: delay));
  }

  Widget _buildDailyVerse() {
    final l10n = AppLocalizations.of(context);
    final todaysVerseAsync = ref.watch(todaysVerseProvider);

    return todaysVerseAsync.when(
      data: (verseData) {
        if (verseData == null) {
          return const SizedBox.shrink(); // Hide if no verse available
        }

        final reference = verseData['reference'] as String? ?? '';
        final text = verseData['text'] as String? ?? '';

        return Padding(
          padding: AppSpacing.horizontalXl,
          child: Container(
            padding: AppSpacing.screenPaddingLarge,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: AppGradients.goldAccent,
                        borderRadius: AppRadius.mediumRadius,
                        border: Border.all(
                          color: AppTheme.goldColor.withValues(alpha: 0.4),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.auto_awesome,
                        color: AppColors.primaryText,
                        size: ResponsiveUtils.iconSize(context, 20),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Text(
                        l10n.verseOfTheDay,
                        style: TextStyle(
                          fontSize: ResponsiveUtils.fontSize(context, 18,
                              minSize: 16, maxSize: 20),
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryText,
                          shadows: AppTheme.textShadowStrong,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                DarkGlassContainer(
                  borderRadius: AppRadius.md,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Reference ABOVE text
                      AutoSizeText(
                        reference,
                        style: TextStyle(
                          fontSize: ResponsiveUtils.fontSize(context, 14,
                              minSize: 12, maxSize: 16),
                          color: AppTheme.goldColor,
                          fontWeight: FontWeight.w700,
                          shadows: AppTheme.textShadowSubtle,
                        ),
                        maxLines: 1,
                        minFontSize: 10,
                        maxFontSize: 16,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      // Verse text
                      AutoSizeText(
                        text,
                        style: TextStyle(
                          fontSize: ResponsiveUtils.fontSize(context, 16,
                              minSize: 14, maxSize: 18),
                          color: AppColors.primaryText,
                          fontStyle: FontStyle.italic,
                          height: 1.6,
                          fontWeight: FontWeight.w500,
                          shadows: AppTheme.textShadowSubtle,
                        ),
                        maxLines: 6,
                        minFontSize: 12,
                        maxFontSize: 18,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ).animate().fadeIn(delay: 1900.ms).slideY(begin: 0.3, delay: 1900.ms);
      },
      loading: () => Padding(
        padding: AppSpacing.horizontalXl,
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            gradient: AppGradients.glassStrong,
            borderRadius: AppRadius.cardRadius,
          ),
          child: const Center(
            child: CircularProgressIndicator(
              color: AppTheme.goldColor,
            ),
          ),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildStartChatButton() {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassButton(
        text: l10n.startSpiritualConversation,
        onPressed: () => NavigationService.goToChat(),
      ).animate().fadeIn(delay: 2000.ms).scale(delay: 2000.ms),
    );
  }
}
