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
import '../components/dancing_logo_loader.dart';
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
  bool _isNavigating = false;

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
              padding: const EdgeInsets.only(
                top: AppSpacing.xl,
                bottom: AppSpacing.xxxl, // Extra bottom padding for button visibility
              ),
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
                  const SizedBox(height: AppSpacing.xl), // Extra space at bottom
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

    // Scale height based on BOTH screen size AND text scale factor
    final textScaleFactor = MediaQuery.textScalerOf(context).scale(1.0);
    final baseHeight = ResponsiveUtils.scaleSize(context, 110,
        minScale: 0.8, maxScale: 1.2);
    // Apply text scale factor with damping (not full 1.5x, but enough to prevent overflow)
    final scaledHeight = baseHeight * (1.0 + (textScaleFactor - 1.0) * 0.5);

    return LayoutBuilder(
      builder: (context, constraints) => SizedBox(
        height: scaledHeight.clamp(88.0, 165.0), // Min 88px, max 165px
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
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
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
        // FittedBox scales down entire content to fit container (Rule 2)
        child: FittedBox(
          fit: BoxFit.scaleDown,
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
                child: ExcludeSemantics(
                  child: Icon(
                    icon,
                    size: ResponsiveUtils.iconSize(context, 20),
                    color: AppColors.secondaryText,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              // Value text
              Text(
                value,
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 20,
                      minSize: 16, maxSize: 22),
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryText,
                  shadows: AppTheme.textShadowStrong,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              // Label text
              Text(
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
                  overflow: TextOverflow.ellipsis,
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
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
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
              child: ExcludeSemantics(
                child: Icon(
                  icon,
                  size: ResponsiveUtils.iconSize(context, 20),
                  color: AppColors.secondaryText,
                ),
              ),
            ),
            const SizedBox(height: 6),
            // Placeholder text instead of infinite spinner (fixes test timeouts)
            AutoSizeText(
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
            const SizedBox(height: 4),
            Padding(
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

    // Calculate dynamic height using unified responsive scale
    final cardHeight = ResponsiveUtils.scaleSize(context, 160, minScale: 0.8, maxScale: 1.5);

    return Padding(
      padding: AppSpacing.horizontalXl,
      child: Column(
        children: [
          SizedBox(
            height: cardHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: FrostedGlassCard(
                    padding: const EdgeInsets.all(14),
                    onTap: () => NavigationService.goToChat(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
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
                        AutoSizeText(
                          l10n.biblicalChat,
                          style: TextStyle(
                            fontSize: ResponsiveUtils.fontSize(context, 16,
                                minSize: 14, maxSize: 18),
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryText,
                          ),
                          maxLines: 1,
                          minFontSize: 12,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Flexible(
                          child: AutoSizeText(
                            l10n.biblicalChatDesc,
                            style: TextStyle(
                              fontSize: ResponsiveUtils.fontSize(context, 12,
                                  minSize: 10, maxSize: 14),
                              color: AppColors.secondaryText,
                              height: 1.3,
                            ),
                            maxLines: 3,
                            minFontSize: 9,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: FrostedGlassCard(
                    padding: const EdgeInsets.all(14),
                    onTap: () => NavigationService.goToDevotional(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
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
                        AutoSizeText(
                          l10n.dailyDevotional,
                          style: TextStyle(
                            fontSize: ResponsiveUtils.fontSize(context, 16,
                                minSize: 14, maxSize: 18),
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryText,
                          ),
                          maxLines: 1,
                          minFontSize: 12,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Flexible(
                          child: AutoSizeText(
                            l10n.dailyDevotionalDesc,
                            style: TextStyle(
                              fontSize: ResponsiveUtils.fontSize(context, 12,
                                  minSize: 10, maxSize: 14),
                              color: AppColors.secondaryText,
                              height: 1.3,
                            ),
                            maxLines: 3,
                            minFontSize: 9,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 1000.ms).scale(delay: 1000.ms),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: cardHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: FrostedGlassCard(
                    padding: const EdgeInsets.all(14),
                    onTap: () => NavigationService.goToPrayerJournal(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
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
                        AutoSizeText(
                          l10n.prayerJournal,
                          style: TextStyle(
                            fontSize: ResponsiveUtils.fontSize(context, 16,
                                minSize: 14, maxSize: 18),
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryText,
                          ),
                          maxLines: 1,
                          minFontSize: 12,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Flexible(
                          child: AutoSizeText(
                            l10n.prayerJournalDesc,
                            style: TextStyle(
                              fontSize: ResponsiveUtils.fontSize(context, 12,
                                  minSize: 10, maxSize: 14),
                              color: AppColors.secondaryText,
                              height: 1.3,
                            ),
                            maxLines: 3,
                            minFontSize: 9,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: FrostedGlassCard(
                    padding: const EdgeInsets.all(14),
                    onTap: () => NavigationService.goToReadingPlan(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
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
                        AutoSizeText(
                          l10n.readingPlans,
                          style: TextStyle(
                            fontSize: ResponsiveUtils.fontSize(context, 16,
                                minSize: 14, maxSize: 18),
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryText,
                          ),
                          maxLines: 1,
                          minFontSize: 12,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Flexible(
                          child: AutoSizeText(
                            l10n.readingPlansDesc,
                            style: TextStyle(
                              fontSize: ResponsiveUtils.fontSize(context, 12,
                                  minSize: 10, maxSize: 14),
                              color: AppColors.secondaryText,
                              height: 1.3,
                            ),
                            maxLines: 3,
                            minFontSize: 9,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 1100.ms).scale(delay: 1100.ms),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final l10n = AppLocalizations.of(context);
    final textSize = ref.watch(textSizeProvider);
    final useShortLabel = textSize >= 1.3;
    // Scale height based on BOTH screen size AND text scale factor
    final textScaleFactor = MediaQuery.textScalerOf(context).scale(1.0);
    final baseHeight = ResponsiveUtils.scaleSize(context, 110,
        minScale: 0.8, maxScale: 1.2);
    final scaledHeight = baseHeight * (1.0 + (textScaleFactor - 1.0) * 0.5);

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
            height: scaledHeight.clamp(88.0, 165.0), // Min 88px, max 165px
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
                  onTap: () async {
                    if (_isNavigating) return;
                    _isNavigating = true;
                    await NavigationService.pushNamedImmediate(AppRoutes.bibleBrowser);
                    Future.delayed(const Duration(milliseconds: 300), () {
                      if (mounted) setState(() => _isNavigating = false);
                    });
                  },
                ),
                const SizedBox(width: AppSpacing.lg),
                _buildQuickActionCard(
                  label: useShortLabel ? l10n.verseLibraryShort : l10n.verseLibrary,
                  icon: Icons.search,
                  color: Colors.blue,
                  onTap: () async {
                    if (_isNavigating) return;
                    _isNavigating = true;
                    await NavigationService.pushNamedImmediate(AppRoutes.verseLibrary);
                    Future.delayed(const Duration(milliseconds: 300), () {
                      if (mounted) setState(() => _isNavigating = false);
                    });
                  },
                ),
                const SizedBox(width: AppSpacing.lg),
                _buildQuickActionCard(
                  label: useShortLabel ? l10n.addPrayerShort : l10n.addPrayer,
                  icon: Icons.add,
                  color: Colors.green,
                  onTap: () async {
                    if (_isNavigating) return;
                    _isNavigating = true;
                    await NavigationService.pushNamedImmediate(AppRoutes.prayerJournal);
                    Future.delayed(const Duration(milliseconds: 300), () {
                      if (mounted) setState(() => _isNavigating = false);
                    });
                  },
                ),
                const SizedBox(width: AppSpacing.lg),
                _buildQuickActionCard(
                  label: l10n.settings,
                  icon: Icons.settings,
                  color: Colors.grey[300]!,
                  onTap: () async {
                    if (_isNavigating) return;
                    _isNavigating = true;
                    await NavigationService.pushNamedImmediate(AppRoutes.settings);
                    Future.delayed(const Duration(milliseconds: 300), () {
                      if (mounted) setState(() => _isNavigating = false);
                    });
                  },
                ),
                const SizedBox(width: AppSpacing.lg),
                _buildQuickActionCard(
                  label: l10n.profile,
                  icon: Icons.person,
                  color: Colors.purple,
                  onTap: () async {
                    if (_isNavigating) return;
                    _isNavigating = true;
                    await NavigationService.pushNamedImmediate(AppRoutes.profile);
                    Future.delayed(const Duration(milliseconds: 300), () {
                      if (mounted) setState(() => _isNavigating = false);
                    });
                  },
                ),
              ],
            ),
          ),
        ).animate().fadeIn(delay: 1400.ms).slideY(begin: 0.1, delay: 1400.ms),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: ResponsiveUtils.scaleSize(context, 100,
              minScale: 0.9, maxScale: 1.2),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
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
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
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
              Expanded(
                child: Align(
                  alignment: Alignment.center,
                  child: AutoSizeText(
                  label,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, 11,
                        minSize: 9, maxSize: 11),
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.9),
                    shadows: AppTheme.textShadowSubtle,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  minFontSize: 7,
                  maxFontSize: 11,
                  overflow: TextOverflow.ellipsis,
                ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
            child: DancingLogoLoader(),
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
