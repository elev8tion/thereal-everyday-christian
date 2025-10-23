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
import '../theme/app_theme.dart';
import '../theme/app_gradients.dart';
import '../core/providers/app_providers.dart';
import '../core/models/devotional.dart';
import '../utils/responsive_utils.dart';

class DevotionalScreen extends ConsumerStatefulWidget {
  const DevotionalScreen({super.key});

  @override
  ConsumerState<DevotionalScreen> createState() => _DevotionalScreenState();
}

class _DevotionalScreenState extends ConsumerState<DevotionalScreen> {
  int _currentDay = 0;

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
                    padding: const EdgeInsets.only(top: AppSpacing.xl),
                    child: Column(
                      children: [
                        _buildHeader(streakAsync, totalCompletedAsync),
                        const SizedBox(height: AppSpacing.xxl),
                        _buildEmptyState(),
                      ],
                    ),
                  );
                }

                // Ensure current day is within bounds
                if (_currentDay >= devotionals.length) {
                  _currentDay = devotionals.length - 1;
                }

                final currentDevotional = devotionals[_currentDay];

                return SingleChildScrollView(
                  padding: const EdgeInsets.only(top: AppSpacing.xl),
                  child: Column(
                    children: [
                      _buildHeader(streakAsync, totalCompletedAsync),
                      const SizedBox(height: AppSpacing.xxl),
                      Padding(
                        padding: AppSpacing.horizontalXl,
                        child: Column(
                          children: [
                            _buildDevotionalCard(currentDevotional),
                            const SizedBox(height: AppSpacing.xl),
                            _buildNavigationButtons(devotionals.length),
                            const SizedBox(height: AppSpacing.xl),
                            _buildProgressIndicator(devotionals),
                            const SizedBox(height: AppSpacing.xl),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => SingleChildScrollView(
                padding: const EdgeInsets.only(top: AppSpacing.xl),
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
                padding: const EdgeInsets.only(top: AppSpacing.xl),
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
        ],
      ),
    );
  }

  Widget _buildHeader(
    AsyncValue<int> streakAsync,
    AsyncValue<int> totalCompletedAsync,
  ) {
    return Padding(
      padding: AppSpacing.screenPadding,
      child: Row(
        children: [
          const GlassmorphicFABMenu(),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                AutoSizeText(
                  'Daily Devotional',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, 24, minSize: 20, maxSize: 28),
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ).animate().fadeIn(duration: AppAnimations.slow).slideX(begin: -0.3),
                const SizedBox(height: 4),
                Row(
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
              ],
            ),
          ),
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
      ),
    );
  }

  Widget _buildDevotionalCard(Devotional devotional) {
    final progressService = ref.read(devotionalProgressServiceProvider);

    return FrostedGlassCard(
      padding: AppSpacing.screenPaddingLarge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      devotional.title,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, 24, minSize: 20, maxSize: 28),
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      devotional.subtitle,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              CategoryBadge(
                text: devotional.readingTime,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                fontSize: ResponsiveUtils.fontSize(context, 12, minSize: 10, maxSize: 14),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xxl),

          Container(
            padding: AppSpacing.screenPadding,
            decoration: BoxDecoration(
              gradient: AppGradients.glassVeryStrong,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.format_quote,
                      color: AppTheme.primaryColor,
                      size: ResponsiveUtils.iconSize(context, 20),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Today\'s Verse',
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
                  '"${devotional.verse}"',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
                    color: AppColors.primaryText,
                    height: 1.5,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  devotional.verseReference,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),

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
            devotional.content,
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 15, minSize: 13, maxSize: 17),
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.6,
              fontWeight: FontWeight.w400,
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),

          if (!devotional.isCompleted)
            GlassButton(
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
          else
            Container(
              width: double.infinity,
              padding: AppSpacing.cardPadding,
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.2),
                borderRadius: AppRadius.mediumRadius,
                border: Border.all(
                  color: Colors.green.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: ResponsiveUtils.iconSize(context, 20),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Column(
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
                    ],
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
            ),
        ],
      ),
    ).animate().fadeIn(duration: AppAnimations.slow, delay: AppAnimations.slow).slideY(begin: 0.3);
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
    return FrostedGlassCard(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                ),
              ),
              Text(
                '${_currentDay + 1} of ${devotionals.length}',
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
            value: (_currentDay + 1) / devotionals.length,
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
                children: List.generate(devotionals.length, (index) {
                  final devotional = devotionals[index];
                  final isCompleted = devotional.isCompleted;
                  final isCurrent = index == _currentDay;

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
                              '${index + 1}',
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
}
