import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../components/gradient_background.dart';
import '../components/frosted_glass_card.dart';
import '../components/clear_glass_card.dart';
import '../components/glass_button.dart';
import '../components/glassmorphic_fab_menu.dart';
import '../components/category_badge.dart';
import '../components/standard_screen_header.dart';
import '../theme/app_theme.dart';
import '../theme/app_gradients.dart';
import '../core/providers/app_providers.dart';
import '../core/models/devotional.dart';
import '../utils/responsive_utils.dart';
import 'chapter_reading_screen.dart';

class DevotionalScreen extends ConsumerStatefulWidget {
  const DevotionalScreen({super.key});

  @override
  ConsumerState<DevotionalScreen> createState() => _DevotionalScreenState();
}

class _DevotionalScreenState extends ConsumerState<DevotionalScreen> {
  int _currentDay = 0;
  bool _isInitialized = false;

  void _initializeCurrentDay(List<Devotional> devotionals) {
    final firstIncomplete = devotionals.indexWhere((d) => !d.isCompleted);
    setState(() {
      _currentDay = firstIncomplete != -1 ? firstIncomplete : devotionals.length - 1;
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final devotionalsAsync = ref.watch(allDevotionalsProvider);
    final streakAsync = ref.watch(devotionalStreakProvider);
    final totalCompletedAsync = ref.watch(totalDevotionalsCompletedProvider);

    return Scaffold(
      body: Stack(
        children: [
          const GradientBackground(),
          SafeArea(
            child: devotionalsAsync.when(
              data: (devotionals) {
                if (devotionals.isEmpty) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.only(top: AppSpacing.xl), // Top padding
                    child: Column(
                      children: [
                        _buildHeader(streakAsync, totalCompletedAsync),
                        const SizedBox(height: AppSpacing.xxl),
                        _buildEmptyState(),
                      ],
                    ),
                  );
                }

                // Initialize current day to first uncompleted or last completed
                if (!_isInitialized && devotionals.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _initializeCurrentDay(devotionals);
                  });
                }

                // Ensure current day is within bounds
                if (_currentDay >= devotionals.length) {
                  _currentDay = devotionals.length - 1;
                }

                final currentDevotional = devotionals[_currentDay];

                return SingleChildScrollView(
                  padding: const EdgeInsets.only(
                    top: AppSpacing.xl,
                    left: AppSpacing.xl,
                    right: AppSpacing.xl,
                  ),
                  child: Column(
                    children: [
                      _buildHeader(streakAsync, totalCompletedAsync),
                      const SizedBox(height: AppSpacing.xxl),

                      // Devotional Title Card
                      _buildTitleCard(currentDevotional),
                      const SizedBox(height: AppSpacing.xl),

                      // 1. Opening Scripture
                      _buildOpeningScripture(currentDevotional),
                      _buildSectionDivider(),

                      // 2. Key Verse Spotlight
                      _buildKeyVerse(currentDevotional),
                      _buildSectionDivider(),

                      // 3. Reflection
                      _buildReflection(currentDevotional),
                      _buildSectionDivider(),

                      // 4. Life Application
                      _buildLifeApplication(currentDevotional),
                      _buildSectionDivider(),

                      // 5. Prayer
                      _buildPrayer(currentDevotional),
                      _buildSectionDivider(),

                      // 6. Action Step (with checkbox)
                      _buildActionStep(currentDevotional),
                      _buildSectionDivider(),

                      // 7. Going Deeper
                      _buildGoingDeeper(currentDevotional),
                      _buildSectionDivider(),

                      // 8. Reading Time
                      _buildReadingTime(currentDevotional),
                      const SizedBox(height: AppSpacing.xl),

                      // Completion Button
                      _buildCompletionButton(currentDevotional),
                      const SizedBox(height: AppSpacing.xl),

                      // Navigation Buttons
                      _buildNavigationButtons(devotionals.length),
                      const SizedBox(height: AppSpacing.xl),

                      // Progress Indicator
                      _buildProgressIndicator(devotionals),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                  ),
                );
              },
              loading: () => SingleChildScrollView(
                padding: const EdgeInsets.only(top: AppSpacing.xl), // Top padding
                child: Column(
                  children: [
                    _buildHeader(streakAsync, totalCompletedAsync),
                    const SizedBox(height: AppSpacing.xxl),
                    const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryText,
                      ),
                    ),
                  ],
                ),
              ),
              error: (error, stack) => SingleChildScrollView(
                padding: const EdgeInsets.only(top: AppSpacing.xl), // Top padding
                child: Column(
                  children: [
                    _buildHeader(streakAsync, totalCompletedAsync),
                    const SizedBox(height: AppSpacing.xxl),
                    _buildErrorState(error),
                  ],
                ),
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

  Widget _buildHeader(
    AsyncValue<int> streakAsync,
    AsyncValue<int> totalCompletedAsync,
  ) {
    return StandardScreenHeader(
      title: 'Daily Devotional',
      subtitle: '', // Not used because we provide customSubtitle
      showFAB: false, // FAB is positioned separately
      customSubtitle: Row(
        children: [
          Flexible(
            child: streakAsync.when(
              data: (streak) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.local_fire_department,
                    color: streak > 0 ? Colors.orange : Colors.white.withValues(alpha: 0.5),
                    size: ResponsiveUtils.iconSize(context, 16),
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: AutoSizeText(
                      '$streak day streak',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, 12, minSize: 8, maxSize: 14),
                        color: AppColors.secondaryText,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      minFontSize: 8,
                    ),
                  ),
                ],
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: totalCompletedAsync.when(
              data: (total) => AutoSizeText(
                '$total completed',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 12, minSize: 8, maxSize: 14),
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                minFontSize: 8,
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),
        ],
      ).animate().fadeIn(duration: AppAnimations.slow, delay: AppAnimations.fast),
    );
  }

  Widget _buildDay() {
    return Row(
      children: [
        const SizedBox(width: AppSpacing.md),
        ClearGlassCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: AutoSizeText(
              'Day ${_currentDay + 1}',
              style: TextStyle(
                color: AppColors.primaryText,
                fontWeight: FontWeight.w600,
                fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ).animate().fadeIn(duration: AppAnimations.slow, delay: AppAnimations.normal),
      ],
    );
  }

  // Section Divider (gradient line like bible browser)
  Widget _buildSectionDivider() {
    return Column(
      children: [
        const SizedBox(height: 12),
        Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.0),
                Colors.white.withValues(alpha: 0.2),
                Colors.white.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  // Title Card
  Widget _buildTitleCard(Devotional devotional) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Text(
        devotional.title,
        style: TextStyle(
          fontSize: ResponsiveUtils.fontSize(context, 24, minSize: 20, maxSize: 28),
          fontWeight: FontWeight.w800,
          color: AppColors.primaryText,
        ),
        softWrap: true,
        overflow: TextOverflow.visible,
      ),
    ).animate().fadeIn(duration: AppAnimations.slow).slideY(begin: 0.2);
  }

  // 1. Opening Scripture
  Widget _buildOpeningScripture(Devotional devotional) {
    return Padding(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.menu_book,
                color: AppTheme.goldColor,
                size: ResponsiveUtils.iconSize(context, 20),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Opening Scripture',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '"${devotional.openingScriptureText}"',
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
              color: AppColors.primaryText,
              height: 1.5,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
            ),
            softWrap: true,
            overflow: TextOverflow.visible,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            devotional.openingScriptureReference,
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
              color: AppTheme.goldColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: AppAnimations.slow).slideY(begin: 0.2);
  }

  // 2. Key Verse Spotlight
  Widget _buildKeyVerse(Devotional devotional) {
    return Padding(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.star,
                color: AppTheme.goldColor,
                size: ResponsiveUtils.iconSize(context, 20),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Key Verse Spotlight',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '"${devotional.keyVerseText}"',
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 17, minSize: 15, maxSize: 19),
              color: AppColors.primaryText,
              height: 1.5,
              fontWeight: FontWeight.w600,
            ),
            softWrap: true,
            overflow: TextOverflow.visible,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            devotional.keyVerseReference,
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
              color: AppTheme.goldColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: AppAnimations.slow).slideY(begin: 0.2);
  }

  // 3. Reflection
  Widget _buildReflection(Devotional devotional) {
    return Padding(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reflection',
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 18, minSize: 16, maxSize: 20),
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            devotional.reflection,
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 15, minSize: 13, maxSize: 17),
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.6,
              fontWeight: FontWeight.w400,
            ),
            softWrap: true,
            overflow: TextOverflow.visible,
          ),
        ],
      ),
    ).animate().fadeIn(duration: AppAnimations.slow).slideY(begin: 0.2);
  }

  // 4. Life Application
  Widget _buildLifeApplication(Devotional devotional) {
    return Padding(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: Colors.blue.shade300,
                size: ResponsiveUtils.iconSize(context, 20),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Life Application',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            devotional.lifeApplication,
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 15, minSize: 13, maxSize: 17),
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.6,
              fontWeight: FontWeight.w400,
            ),
            softWrap: true,
            overflow: TextOverflow.visible,
          ),
        ],
      ),
    ).animate().fadeIn(duration: AppAnimations.slow).slideY(begin: 0.2);
  }

  // 5. Prayer
  Widget _buildPrayer(Devotional devotional) {
    return Padding(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.favorite_border,
                color: Colors.purple.shade200,
                size: ResponsiveUtils.iconSize(context, 20),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Prayer',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            devotional.prayer,
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 15, minSize: 13, maxSize: 17),
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.6,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w400,
            ),
            softWrap: true,
            overflow: TextOverflow.visible,
          ),
        ],
      ),
    ).animate().fadeIn(duration: AppAnimations.slow).slideY(begin: 0.2);
  }

  // 6. Action Step (with checkbox)
  Widget _buildActionStep(Devotional devotional) {
    return Padding(
      padding: AppSpacing.screenPadding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: devotional.actionStepCompleted,
            onChanged: (value) async {
              final service = ref.read(devotionalServiceProvider);
              await service.toggleActionStepCompleted(
                devotional.id,
                value ?? false,
              );
              ref.invalidate(allDevotionalsProvider);
            },
            fillColor: WidgetStateProperty.resolveWith<Color>((states) {
              if (states.contains(WidgetState.selected)) {
                return Colors.green;
              }
              return Colors.white.withValues(alpha: 0.3);
            }),
            checkColor: Colors.white,
            shape: const CircleBorder(),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Text(
                  'Today\'s Action Step',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                    fontWeight: FontWeight.w700,
                    color: Colors.green.shade300,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  devotional.actionStep,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, 15, minSize: 13, maxSize: 17),
                    color: Colors.white.withValues(alpha: 0.9),
                    height: 1.6,
                    fontWeight: FontWeight.w400,
                  ),
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: AppAnimations.slow).slideY(begin: 0.2);
  }

  // 7. Going Deeper
  Widget _buildGoingDeeper(Devotional devotional) {
    return Padding(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.explore,
                color: AppTheme.goldColor,
                size: ResponsiveUtils.iconSize(context, 20),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Going Deeper',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: devotional.goingDeeper.map((reference) {
              return GestureDetector(
                onTap: () => _navigateToVerse(reference),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppGradients.glassVeryStrong,
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                    border: Border.all(
                      color: AppTheme.goldColor.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.arrow_forward,
                        color: AppTheme.goldColor,
                        size: ResponsiveUtils.iconSize(context, 16),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Flexible(
                        child: Text(
                          reference,
                          style: TextStyle(
                            fontSize: ResponsiveUtils.fontSize(context, 13, minSize: 11, maxSize: 15),
                            color: AppColors.primaryText,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    ).animate().fadeIn(duration: AppAnimations.slow).slideY(begin: 0.2);
  }

  // 8. Reading Time
  Widget _buildReadingTime(Devotional devotional) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Icon(
            Icons.schedule,
            color: Colors.white.withValues(alpha: 0.5),
            size: ResponsiveUtils.iconSize(context, 16),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            devotional.readingTime,
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 12, minSize: 10, maxSize: 14),
              color: AppColors.secondaryText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: AppAnimations.slow).slideY(begin: 0.2);
  }

  Widget _buildCompletionButton(Devotional devotional) {
    final progressService = ref.read(devotionalProgressServiceProvider);

    return !devotional.isCompleted
        ? GlassButton(
            text: 'Mark as Completed',
            onPressed: () async {
              await progressService.markAsComplete(devotional.id);
              // Refresh the providers
              ref.invalidate(allDevotionalsProvider);
              ref.invalidate(devotionalStreakProvider);
              ref.invalidate(totalDevotionalsCompletedProvider);
              ref.invalidate(completedDevotionalsProvider);
            },
          )
        : Container(
            width: double.infinity,
            padding: AppSpacing.cardPadding,
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.2),
              borderRadius: AppRadius.mediumRadius,
              border: Border.all(
                color: Colors.green.withValues(alpha: 0.6),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: ResponsiveUtils.iconSize(context, 20),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Devotional Completed',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                                fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
                              ),
                            ),
                            if (devotional.completedDate != null)
                              Text(
                                _formatCompletedDate(devotional.completedDate!),
                                style: TextStyle(
                                  color: Colors.green.withValues(alpha: 0.8),
                                  fontSize: ResponsiveUtils.fontSize(context, 12, minSize: 10, maxSize: 14),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    await progressService.markAsIncomplete(devotional.id);
                    // Refresh the providers
                    ref.invalidate(allDevotionalsProvider);
                    ref.invalidate(devotionalStreakProvider);
                    ref.invalidate(totalDevotionalsCompletedProvider);
                    ref.invalidate(completedDevotionalsProvider);
                  },
                  child: Icon(
                    Icons.close,
                    color: Colors.green.withValues(alpha: 0.6),
                    size: ResponsiveUtils.iconSize(context, 20),
                  ),
                ),
              ],
            ),
          );
  }

  Widget _buildNavigationButtons(int totalDevotionals) {
    return Row(
      children: [
        Expanded(
          child: _currentDay > 0
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentDay--;
                    });
                  },
                  child: ClearGlassCard(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.arrow_back_ios,
                          color: AppColors.primaryText,
                          size: ResponsiveUtils.iconSize(context, 16),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        const Text(
                          'Previous Day',
                          style: TextStyle(
                            color: AppColors.primaryText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : const SizedBox(),
        ),
        if (_currentDay > 0 && _currentDay < totalDevotionals - 1)
          const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: _currentDay < totalDevotionals - 1
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentDay++;
                    });
                  },
                  child: ClearGlassCard(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Next Day',
                          style: TextStyle(
                            color: AppColors.primaryText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: AppColors.primaryText,
                          size: ResponsiveUtils.iconSize(context, 16),
                        ),
                      ],
                    ),
                  ),
                )
              : const SizedBox(),
        ),
      ],
    ).animate().fadeIn(duration: AppAnimations.slow, delay: 800.ms);
  }

  Widget _buildProgressIndicator(List<Devotional> devotionals) {
    // Get current devotional's date to determine the month
    final currentDevotional = devotionals[_currentDay];
    final currentDate = DateTime.parse(currentDevotional.date);

    // Filter devotionals for the current month
    final monthlyDevotionals = devotionals.where((d) {
      final date = DateTime.parse(d.date);
      return date.year == currentDate.year && date.month == currentDate.month;
    }).toList();

    // Find the current day's index within the monthly devotionals
    final monthlyIndex = monthlyDevotionals.indexWhere((d) => d.id == currentDevotional.id);

    // Get month name
    final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final monthName = monthNames[currentDate.month - 1];

    return Padding(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$monthName ${currentDate.year} Progress',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                ),
              ),
              Text(
                '${monthlyIndex + 1} of ${monthlyDevotionals.length}',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          LinearProgressIndicator(
            value: (monthlyIndex + 1) / monthlyDevotionals.length,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            borderRadius: BorderRadius.circular(AppRadius.xs / 2),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Responsive 7-column grid using LayoutBuilder for precise sizing
          LayoutBuilder(
            builder: (context, constraints) {
              const columns = 7;
              const spacing = 8.0;
              const runSpacing = 8.0;
              // Calculate item width based on available space and column count
              const totalSpacing = spacing * (columns - 1);
              final itemWidth = (constraints.maxWidth - totalSpacing) / columns;

              return Wrap(
                spacing: spacing,
                runSpacing: runSpacing,
                children: List.generate(monthlyDevotionals.length, (index) {
                  final devotional = monthlyDevotionals[index];
                  final isCompleted = devotional.isCompleted;
                  final isCurrent = index == monthlyIndex;
                  final dayOfMonth = DateTime.parse(devotional.date).day;

                  return Container(
                    width: itemWidth,
                    height: ResponsiveUtils.scaleSize(context, 40, minScale: 0.9, maxScale: 1.2),
                decoration: BoxDecoration(
                  color: isCurrent
                      ? AppTheme.primaryColor.withValues(alpha: 0.3)
                      : isCompleted
                          ? Colors.green.withValues(alpha: 0.2)
                          : Colors.white.withValues(alpha: 0.1),
                  borderRadius: AppRadius.smallRadius,
                  border: Border.all(
                    color: isCurrent
                        ? AppTheme.primaryColor
                        : isCompleted
                            ? Colors.green.withValues(alpha: 0.5)
                            : Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                    child: Center(
                      child: isCompleted
                          ? Icon(
                              Icons.check,
                              color: Colors.green,
                              size: ResponsiveUtils.iconSize(context, 20),
                            )
                          : Text(
                              '$dayOfMonth',
                              style: TextStyle(
                                color: isCurrent
                                    ? AppTheme.primaryColor
                                    : Colors.white.withValues(alpha: 0.7),
                                fontWeight: FontWeight.w600,
                                fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                              ),
                            ),
                    ),
                  );
                }),
              );
            },
          ),
        ],
      ),
    ).animate().fadeIn(duration: AppAnimations.slow, delay: 1000.ms);
  }

  Widget _buildEmptyState() {
    return Center(
      child: FrostedGlassCard(
        padding: AppSpacing.screenPaddingLarge,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_stories,
              color: Colors.white.withValues(alpha: 0.5),
              size: ResponsiveUtils.iconSize(context, 64),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No Devotionals Available',
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(context, 20, minSize: 18, maxSize: 24),
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Check back later for daily devotionals',
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                color: AppColors.secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: FrostedGlassCard(
        padding: AppSpacing.screenPaddingLarge,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red.withValues(alpha: 0.8),
              size: ResponsiveUtils.iconSize(context, 64),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Error Loading Devotionals',
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(context, 20, minSize: 18, maxSize: 24),
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              error.toString(),
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                color: AppColors.secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatCompletedDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateDay = DateTime(date.year, date.month, date.day);

    if (dateDay == today) {
      return 'Completed today';
    } else if (dateDay == yesterday) {
      return 'Completed yesterday';
    } else {
      final difference = today.difference(dateDay).inDays;
      return 'Completed $difference days ago';
    }
  }

  /// Navigate to a Bible verse from a reference string
  /// Examples: "John 3:16", "1 Thessalonians 5:18 - Give thanks", "Psalm 136:1 - His loving kindness"
  void _navigateToVerse(String reference) {
    try {
      // Remove any text after " - " (e.g., "Psalm 136:1 - His loving kindness" -> "Psalm 136:1")
      final cleanReference = reference.split(' - ').first.trim();

      // Parse the reference (e.g., "1 Thessalonians 5:18")
      final parts = cleanReference.split(':');
      if (parts.length != 2) {
        debugPrint('⚠️ Invalid reference format: $cleanReference');
        return;
      }

      final verseNumber = int.tryParse(parts[1].trim());
      if (verseNumber == null) {
        debugPrint('⚠️ Invalid verse number: ${parts[1]}');
        return;
      }

      // Split book and chapter (e.g., "1 Thessalonians 5")
      final bookChapterParts = parts[0].trim().split(RegExp(r'\s+'));
      if (bookChapterParts.isEmpty) {
        debugPrint('⚠️ Invalid book/chapter format: ${parts[0]}');
        return;
      }

      // Get chapter number (last part)
      final chapterNumber = int.tryParse(bookChapterParts.last);
      if (chapterNumber == null) {
        debugPrint('⚠️ Invalid chapter number: ${bookChapterParts.last}');
        return;
      }

      // Get book name (everything except the last part)
      final book = bookChapterParts.sublist(0, bookChapterParts.length - 1).join(' ');

      // Navigate to ChapterReadingScreen with auto-scroll to verse
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChapterReadingScreen(
            book: book,
            startChapter: chapterNumber,
            endChapter: chapterNumber,
            initialVerseNumber: verseNumber,
          ),
        ),
      );
    } catch (e) {
      debugPrint('⚠️ Error navigating to verse $reference: $e');
    }
  }
}
