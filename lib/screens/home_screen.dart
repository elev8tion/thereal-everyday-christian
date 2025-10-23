import 'dart:io';
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
import '../core/navigation/app_routes.dart';
import '../core/providers/app_providers.dart';
import '../core/navigation/navigation_service.dart';
import '../utils/responsive_utils.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late String greeting;
  late String userName;
  final GlobalKey _backgroundKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _setGreeting();
    userName = "Friend"; // In production, get from user preferences
  }

  void _setGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      greeting = "Rise and shine";
    } else if (hour < 17) {
      greeting = "Good afternoon";
    } else {
      greeting = "Good evening";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          RepaintBoundary(
            key: _backgroundKey,
            child: const GradientBackground(),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: AppSpacing.xl),
              // Optimize scrolling performance
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: AppSpacing.xxl),
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
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final profilePicturePath = ref.watch(profilePicturePathProvider);

    return Padding(
      padding: AppSpacing.horizontalXl,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // FAB on left
          const GlassmorphicFABMenu(),
          // Greeting centered
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$greeting,',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.fontSize(context, 24, minSize: 20, maxSize: 28),
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$userName!',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.fontSize(context, 24, minSize: 20, maxSize: 28),
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryText,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          // Profile on right
          profilePicturePath.when(
            data: (path) => _buildAvatarCircle(path),
            loading: () => _buildAvatarCircle(null),
            error: (_, __) => _buildAvatarCircle(null),
          ),
        ],
      ),
    ).animate().fadeIn(duration: AppAnimations.slow).slideY(begin: -0.3);
  }

  Widget _buildAvatarCircle(String? imagePath) {
    final hasImage = imagePath != null && File(imagePath).existsSync();

    return Container(
      width: ResponsiveUtils.scaleSize(context, 40, minScale: 0.85, maxScale: 1.2),
      height: ResponsiveUtils.scaleSize(context, 40, minScale: 0.85, maxScale: 1.2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppTheme.goldColor.withValues(alpha: 0.6),
          width: 1.5,
        ),
        color: hasImage ? null : AppTheme.primaryColor.withValues(alpha: 0.3),
      ),
      child: hasImage
          ? ClipOval(
              child: Image.file(
                File(imagePath),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.person,
                    color: AppColors.primaryText,
                    size: ResponsiveUtils.iconSize(context, 20),
                  );
                },
              ),
            )
          : Icon(
              Icons.person,
              color: AppColors.primaryText,
              size: ResponsiveUtils.iconSize(context, 20),
            ),
    );
  }

  Widget _buildStatsRow() {
    final streakAsync = ref.watch(devotionalStreakProvider);
    final totalCompletedAsync = ref.watch(totalDevotionalsCompletedProvider);
    final prayersCountAsync = ref.watch(activePrayersCountProvider);
    final versesCountAsync = ref.watch(savedVersesCountProvider);

    return LayoutBuilder(
      builder: (context, constraints) => SizedBox(
        height: ResponsiveUtils.scaleSize(context, 130, minScale: 0.9, maxScale: 1.3),
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
              label: "Day Streak",
              icon: Icons.local_fire_department,
              color: Colors.orange,
              delay: 600,
            ),
            loading: () => _buildStatCardLoading(
              label: "Day Streak",
              icon: Icons.local_fire_department,
              color: Colors.orange,
              delay: 600,
            ),
            error: (_, __) => _buildStatCard(
              value: "0",
              label: "Day Streak",
              icon: Icons.local_fire_department,
              color: Colors.orange,
              delay: 600,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          prayersCountAsync.when(
            data: (count) => _buildStatCard(
              value: "$count",
              label: "Prayers",
              icon: Icons.favorite,
              color: Colors.red,
              delay: 700,
            ),
            loading: () => _buildStatCardLoading(
              label: "Prayers",
              icon: Icons.favorite,
              color: Colors.red,
              delay: 700,
            ),
            error: (_, __) => _buildStatCard(
              value: "0",
              label: "Prayers",
              icon: Icons.favorite,
              color: Colors.red,
              delay: 700,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          versesCountAsync.when(
            data: (count) => _buildStatCard(
              value: "$count",
              label: "Saved Verses",
              icon: Icons.menu_book,
              color: AppTheme.goldColor,
              delay: 800,
            ),
            loading: () => _buildStatCardLoading(
              label: "Saved Verses",
              icon: Icons.menu_book,
              color: AppTheme.goldColor,
              delay: 800,
            ),
            error: (_, __) => _buildStatCard(
              value: "0",
              label: "Saved Verses",
              icon: Icons.menu_book,
              color: AppTheme.goldColor,
              delay: 800,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          totalCompletedAsync.when(
            data: (total) => _buildStatCard(
              value: "$total",
              label: "Devotionals",
              icon: Icons.auto_stories,
              color: Colors.green,
              delay: 900,
            ),
            loading: () => _buildStatCardLoading(
              label: "Devotionals",
              icon: Icons.auto_stories,
              color: Colors.green,
              delay: 900,
            ),
            error: (_, __) => _buildStatCard(
              value: "0",
              label: "Devotionals",
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
        width: ResponsiveUtils.scaleSize(context, 140, minScale: 0.9, maxScale: 1.2),
        padding: AppSpacing.screenPadding,
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
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: AppRadius.mediumRadius,
            ),
            child: Icon(
              icon,
              size: ResponsiveUtils.iconSize(context, 20),
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          // Value text with auto-sizing to prevent overflow
          Flexible(
            child: AutoSizeText(
              value,
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(context, 20, minSize: 16, maxSize: 22),
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
                  fontSize: ResponsiveUtils.fontSize(context, 9, minSize: 8, maxSize: 11),
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
    ).animate().fadeIn(delay: Duration(milliseconds: delay)).scale(delay: Duration(milliseconds: delay));
  }

  Widget _buildStatCardLoading({
    required String label,
    required IconData icon,
    required Color color,
    required int delay,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) => Container(
        width: ResponsiveUtils.scaleSize(context, 140, minScale: 0.9, maxScale: 1.2),
        padding: AppSpacing.screenPadding,
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
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: AppRadius.mediumRadius,
            ),
            child: Icon(
              icon,
              size: ResponsiveUtils.iconSize(context, 20),
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          // Placeholder text instead of infinite spinner (fixes test timeouts)
          Flexible(
            child: AutoSizeText(
              "...",
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(context, 20, minSize: 16, maxSize: 22),
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
                  fontSize: ResponsiveUtils.fontSize(context, 9, minSize: 8, maxSize: 11),
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
    ).animate().fadeIn(delay: Duration(milliseconds: delay)).scale(delay: Duration(milliseconds: delay));
  }

  Widget _buildMainFeatures() {
    return Padding(
      padding: AppSpacing.horizontalXl,
      child: Column(
        children: [
        Row(
          children: [
            Expanded(
              child: FrostedGlassCard(
                onTap: () => NavigationService.goToChat(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClearGlassCard(
                      padding: const EdgeInsets.all(10),
                      child: Icon(
                        Icons.chat_bubble_outline,
                        size: ResponsiveUtils.iconSize(context, 24),
                        color: AppColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      "Biblical Chat",
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Get biblical wisdom for any situation you're facing",
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, 12, minSize: 10, maxSize: 14),
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
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: FrostedGlassCard(
                onTap: () => NavigationService.goToDevotional(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClearGlassCard(
                      padding: const EdgeInsets.all(10),
                      child: Icon(
                        Icons.auto_stories,
                        size: ResponsiveUtils.iconSize(context, 24),
                        color: AppColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      "Daily Devotional",
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Grow closer to God with daily reflections",
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, 12, minSize: 10, maxSize: 14),
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
          ],
        ).animate().fadeIn(delay: 1000.ms).scale(delay: 1000.ms),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: FrostedGlassCard(
                onTap: () => NavigationService.goToPrayerJournal(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClearGlassCard(
                      padding: const EdgeInsets.all(10),
                      child: Icon(
                        Icons.favorite_outline,
                        size: ResponsiveUtils.iconSize(context, 24),
                        color: AppColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      "Prayer Journal",
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Track your prayers and see God's faithfulness",
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, 12, minSize: 10, maxSize: 14),
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
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: FrostedGlassCard(
                onTap: () => NavigationService.goToReadingPlan(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClearGlassCard(
                      padding: const EdgeInsets.all(10),
                      child: Icon(
                        Icons.library_books_outlined,
                        size: ResponsiveUtils.iconSize(context, 24),
                        color: AppColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      "Reading Plans",
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Structured Bible reading with daily guidance",
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, 12, minSize: 10, maxSize: 14),
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
          ],
        ).animate().fadeIn(delay: 1100.ms).scale(delay: 1100.ms),
      ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: AppSpacing.horizontalXl,
          child: Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 20, minSize: 18, maxSize: 24),
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText,
              shadows: AppTheme.textShadowStrong,
            ),
          ),
        ).animate().fadeIn(delay: 1200.ms).slideY(begin: 0.3, delay: 1200.ms),
        const SizedBox(height: AppSpacing.lg),
        LayoutBuilder(
          builder: (context, constraints) => SizedBox(
            height: ResponsiveUtils.scaleSize(context, 120, minScale: 0.9, maxScale: 1.3),
            child: ListView(
            scrollDirection: Axis.horizontal,
            padding: AppSpacing.horizontalXl,
            // Optimize horizontal scrolling performance
            physics: const BouncingScrollPhysics(),
            cacheExtent: 200,
            children: [
              _buildQuickActionCard(
                label: "Read Bible",
                icon: Icons.menu_book,
                color: AppTheme.goldColor,
                onTap: () => NavigationService.goToBibleBrowser(),
                delay: 1400,
              ),
              const SizedBox(width: AppSpacing.lg),
              _buildQuickActionCard(
                label: "Verse Library",
                icon: Icons.search,
                color: Colors.blue,
                onTap: () => Navigator.pushNamed(context, AppRoutes.verseLibrary),
                delay: 1500,
              ),
              const SizedBox(width: AppSpacing.lg),
              _buildQuickActionCard(
                label: "Add Prayer",
                icon: Icons.add,
                color: Colors.green,
                onTap: () => NavigationService.goToPrayerJournal(),
                delay: 1600,
              ),
              const SizedBox(width: AppSpacing.lg),
              _buildQuickActionCard(
                label: "Settings",
                icon: Icons.settings,
                color: Colors.grey[300]!,
                onTap: () => NavigationService.goToSettings(),
                delay: 1700,
              ),
              const SizedBox(width: AppSpacing.lg),
              _buildQuickActionCard(
                label: "Profile",
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
          width: ResponsiveUtils.scaleSize(context, 100, minScale: 0.9, maxScale: 1.2),
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
                color: color,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Flexible(
              child: AutoSizeText(
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
                maxFontSize: 13,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: delay)).scale(delay: Duration(milliseconds: delay));
  }

  Widget _buildDailyVerse() {
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
            decoration: BoxDecoration(
              gradient: AppGradients.glassStrong,
              borderRadius: AppRadius.cardRadius,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
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
                        'Verse of the Day',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.fontSize(context, 18, minSize: 16, maxSize: 20),
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryText,
                          shadows: AppTheme.textShadowStrong,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                Container(
                  padding: AppSpacing.cardPadding,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.1),
                    borderRadius: AppRadius.mediumRadius,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Reference ABOVE text
                      AutoSizeText(
                        reference,
                        style: TextStyle(
                          fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
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
                          fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
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
    return GlassButton(
      text: 'Start Spiritual Conversation',
      onPressed: () => NavigationService.goToChat(),
    ).animate().fadeIn(delay: 2000.ms).scale(delay: 2000.ms);
  }
}