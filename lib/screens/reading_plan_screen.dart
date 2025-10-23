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
import '../components/calendar_heatmap_widget.dart';
import '../components/reading_progress_stats_widget.dart';
import '../theme/app_theme.dart';
import '../core/providers/app_providers.dart';
import '../core/models/reading_plan.dart';
import '../core/navigation/navigation_service.dart';
import '../utils/responsive_utils.dart';
import '../utils/reading_reference_parser.dart';

class ReadingPlanScreen extends ConsumerStatefulWidget {
  const ReadingPlanScreen({super.key});

  @override
  ConsumerState<ReadingPlanScreen> createState() => _ReadingPlanScreenState();
}

class _ReadingPlanScreenState extends ConsumerState<ReadingPlanScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const GradientBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildTabBar(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTodayTab(),
                      _buildProgressTab(),
                      _buildMyPlansTab(),
                      _buildExplorePlansTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: AppSpacing.screenPadding,
      child: Row(
        children: [
          const GlassmorphicFABMenu(),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AutoSizeText(
                  'Reading Plans',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, 24, minSize: 20, maxSize: 28),
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ).animate().fadeIn(duration: AppAnimations.slow).slideX(begin: -0.3),
                const SizedBox(height: 4),
                AutoSizeText(
                  'Grow in God\'s word daily',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                    color: AppColors.secondaryText,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ).animate().fadeIn(duration: AppAnimations.slow, delay: AppAnimations.fast),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: AppSpacing.horizontalXl,
      child: FrostedGlassCard(
        padding: const EdgeInsets.all(4),
        child: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.center,
          indicator: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            borderRadius: AppRadius.mediumRadius,
            border: Border.all(
              color: AppTheme.primaryColor,
              width: 1,
            ),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
          labelStyle: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
          ),
          tabs: const [
            Tab(text: 'Today'),
            Tab(text: 'Progress'),
            Tab(text: 'My Plans'),
            Tab(text: 'Explore'),
          ],
        ),
      ),
    ).animate().fadeIn(duration: AppAnimations.slow, delay: AppAnimations.normal);
  }

  Widget _buildProgressTab() {
    final currentPlanAsync = ref.watch(currentReadingPlanProvider);

    return currentPlanAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(error.toString()),
      data: (currentPlan) {
        if (currentPlan == null) {
          return _buildEmptyState(
            icon: Icons.insights,
            title: 'No Progress to Track',
            subtitle: 'Start a reading plan to see your progress and statistics',
            action: () => _tabController.animateTo(3),
            actionText: 'Explore Plans',
          );
        }

        final statsAsync = ref.watch(planCompletionStatsProvider(currentPlan.id));
        final heatmapAsync = ref.watch(planHeatmapDataProvider(currentPlan.id));
        final estimatedDateAsync = ref.watch(planEstimatedCompletionDateProvider(currentPlan.id));

        return SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Plan header
              Text(
                currentPlan.title,
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 24, minSize: 20, maxSize: 28),
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryText,
                ),
              ).animate().fadeIn(duration: AppAnimations.slow),
              const SizedBox(height: 8),
              Text(
                'Your Progress & Statistics',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                  color: AppColors.secondaryText,
                ),
              ).animate().fadeIn(duration: AppAnimations.slow, delay: AppAnimations.fast),
              const SizedBox(height: AppSpacing.xxl),

              // Statistics
              statsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Text('Error loading stats: $error'),
                data: (stats) {
                  return estimatedDateAsync.when(
                    loading: () => ReadingProgressStatsWidget(stats: stats),
                    error: (_, __) => ReadingProgressStatsWidget(stats: stats),
                    data: (estimatedDate) => ReadingProgressStatsWidget(
                      stats: stats,
                      estimatedCompletionDate: estimatedDate,
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Calendar heatmap
              Text(
                'Reading Activity',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 20, minSize: 18, maxSize: 24),
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                ),
              ).animate().fadeIn(duration: AppAnimations.slow, delay: 600.ms),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Days with completed readings in the last 90 days',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 12, minSize: 10, maxSize: 14),
                  color: AppColors.secondaryText,
                ),
              ).animate().fadeIn(duration: AppAnimations.slow, delay: 700.ms),
              const SizedBox(height: AppSpacing.lg),
              heatmapAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Text('Error loading activity data: $error'),
                data: (heatmapData) {
                  return FrostedGlassCard(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: CalendarHeatmapWidget(
                      activityData: heatmapData,
                      columns: 13,
                    ),
                  ).animate().fadeIn(duration: AppAnimations.slow, delay: 800.ms);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTodayTab() {
    final currentPlanAsync = ref.watch(currentReadingPlanProvider);

    return currentPlanAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(error.toString()),
      data: (currentPlan) {
        if (currentPlan == null) {
          return _buildEmptyState(
            icon: Icons.book_outlined,
            title: 'No Active Reading Plan',
            subtitle: 'Start a reading plan to see today\'s readings here',
            action: () => _tabController.animateTo(3),
            actionText: 'Explore Plans',
          );
        }

        final todaysReadingsAsync =
            ref.watch(todaysReadingsProvider(currentPlan.id));

        return todaysReadingsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _buildErrorState(error.toString()),
          data: (todaysReadings) {
            return SingleChildScrollView(
              padding: AppSpacing.screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCurrentPlanCard(currentPlan),
                  const SizedBox(height: AppSpacing.xxl),
                  Text(
                    'Today\'s Readings',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.fontSize(context, 20, minSize: 18, maxSize: 24),
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryText,
                    ),
                  ).animate().fadeIn(duration: AppAnimations.slow, delay: AppAnimations.slow),
                  const SizedBox(height: AppSpacing.lg),
                  if (todaysReadings.isEmpty)
                    _buildEmptyReadingsMessage()
                  else
                    ...List.generate(todaysReadings.length, (index) {
                      final reading = todaysReadings[index];
                      return _buildReadingCard(reading, index)
                          .animate()
                          .fadeIn(duration: AppAnimations.slow, delay: (700 + index * 100).ms)
                          .slideY(begin: 0.3);
                    }),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMyPlansTab() {
    final activePlansAsync = ref.watch(activeReadingPlansProvider);

    return activePlansAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(error.toString()),
      data: (activePlans) {
        if (activePlans.isEmpty) {
          return _buildEmptyState(
            icon: Icons.library_books_outlined,
            title: 'No Active Plans',
            subtitle: 'Start a reading plan to track your progress',
            action: () => _tabController.animateTo(3),
            actionText: 'Explore Plans',
          );
        }

        return ListView.builder(
          padding: AppSpacing.screenPadding,
          itemCount: activePlans.length,
          itemBuilder: (context, index) {
            final plan = activePlans[index];
            return _buildPlanCard(plan, index, isActive: true)
                .animate()
                .fadeIn(duration: AppAnimations.slow, delay: (600 + index * 100).ms)
                .slideY(begin: 0.3);
          },
        );
      },
    );
  }

  Widget _buildExplorePlansTab() {
    final allPlansAsync = ref.watch(allReadingPlansProvider);

    return allPlansAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(error.toString()),
      data: (allPlans) {
        return ListView.builder(
          padding: AppSpacing.screenPadding,
          itemCount: allPlans.length,
          itemBuilder: (context, index) {
            final plan = allPlans[index];
            return _buildPlanCard(plan, index, isActive: false)
                .animate()
                .fadeIn(duration: AppAnimations.slow, delay: (600 + index * 100).ms)
                .slideY(begin: 0.3);
          },
        );
      },
    );
  }

  Widget _buildCurrentPlanCard(ReadingPlan plan) {
    final progressAsync = ref.watch(planProgressPercentageProvider(plan.id));
    final currentDayAsync = ref.watch(planCurrentDayProvider(plan.id));
    final streakAsync = ref.watch(planStreakProvider(plan.id));

    final progress = (plan.completedReadings / plan.totalReadings).clamp(0.0, 1.0);

    return FrostedGlassCard(
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
                      plan.title,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, 18, minSize: 16, maxSize: 20),
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      plan.category.displayName,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              CategoryBadge(
                text: plan.difficulty.displayName,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                fontSize: ResponsiveUtils.fontSize(context, 12, minSize: 10, maxSize: 14),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Icon(
                Icons.schedule,
                size: ResponsiveUtils.iconSize(context, 16),
                color: Colors.white.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 6),
              Text(
                plan.estimatedTimePerDay,
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                  color: AppColors.secondaryText,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              currentDayAsync.when(
                data: (day) => Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: ResponsiveUtils.iconSize(context, 16),
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Day $day',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
                loading: () => const SizedBox(),
                error: (_, __) => const SizedBox(),
              ),
              const Spacer(),
              streakAsync.when(
                data: (streak) => streak > 0
                    ? Row(
                        children: [
                          Icon(
                            Icons.local_fire_department,
                            size: ResponsiveUtils.iconSize(context, 16),
                            color: Colors.orange.withValues(alpha: 0.9),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$streak day${streak > 1 ? 's' : ''}',
                            style: TextStyle(
                              fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                              color: Colors.orange.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    : const SizedBox(),
                loading: () => const SizedBox(),
                error: (_, __) => const SizedBox(),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText,
                ),
              ),
              Text(
                '${plan.completedReadings} / ${plan.totalReadings}',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            borderRadius: BorderRadius.circular(AppRadius.xs / 2),
          ),
          const SizedBox(height: AppSpacing.sm),
          progressAsync.when(
            data: (percentage) => Text(
              '${percentage.toStringAsFixed(1)}% complete',
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(context, 12, minSize: 10, maxSize: 14),
                color: Colors.white.withValues(alpha: 0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),
        ],
      ),
    ).animate().fadeIn(duration: AppAnimations.slow, delay: 500.ms);
  }

  Widget _buildReadingCard(DailyReading reading, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () => _openChapterReader(context, reading),
        child: FrostedGlassCard(
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.25),
                      Colors.white.withValues(alpha: 0.15),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: AppRadius.mediumRadius,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: reading.isCompleted
                          ? Colors.green.withValues(alpha: 0.2)
                          : AppTheme.primaryColor.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  reading.isCompleted ? Icons.check_circle : Icons.book,
                  color: reading.isCompleted ? Colors.green : AppTheme.primaryColor,
                  size: ResponsiveUtils.iconSize(context, 24),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reading.title,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      reading.description,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                        color: AppColors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: ResponsiveUtils.iconSize(context, 14),
                          color: AppColors.tertiaryText,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          reading.estimatedTime,
                          style: TextStyle(
                            fontSize: ResponsiveUtils.fontSize(context, 12, minSize: 10, maxSize: 14),
                            color: AppColors.tertiaryText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _toggleReadingComplete(reading),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: reading.isCompleted
                        ? Colors.green.withValues(alpha: 0.2)
                        : AppTheme.primaryColor.withValues(alpha: 0.2),
                    borderRadius: AppRadius.smallRadius,
                  ),
                  child: Icon(
                    reading.isCompleted ? Icons.check : Icons.circle_outlined,
                    color: AppColors.primaryText,
                    size: ResponsiveUtils.iconSize(context, 20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard(ReadingPlan plan, int index, {required bool isActive}) {
    final progressPercentageAsync = plan.isStarted
        ? ref.watch(planProgressPercentageProvider(plan.id))
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: FrostedGlassCard(
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
                        plan.title,
                        style: TextStyle(
                          fontSize: ResponsiveUtils.fontSize(context, 18, minSize: 16, maxSize: 20),
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        plan.category.displayName,
                        style: TextStyle(
                          fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                CategoryBadge(
                  text: plan.difficulty.displayName,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              plan.description,
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                color: Colors.white.withValues(alpha: 0.9),
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                _buildPlanStat(Icons.schedule, plan.estimatedTimePerDay),
                const SizedBox(width: AppSpacing.lg),
                _buildPlanStat(Icons.calendar_today, plan.duration),
              ],
            ),
            if (plan.isStarted) ...[
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progress',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryText,
                    ),
                  ),
                  Text(
                    '${plan.completedReadings} / ${plan.totalReadings}',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              LinearProgressIndicator(
                value: (plan.completedReadings / plan.totalReadings).clamp(0.0, 1.0),
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                borderRadius: BorderRadius.circular(AppRadius.xs / 2),
              ),
              if (progressPercentageAsync != null) ...[
                const SizedBox(height: AppSpacing.sm),
                progressPercentageAsync.when(
                  data: (percentage) => Text(
                    '${percentage.toStringAsFixed(1)}% complete',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.fontSize(context, 12, minSize: 10, maxSize: 14),
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  loading: () => const SizedBox(),
                  error: (_, __) => const SizedBox(),
                ),
              ],
            ],
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: GlassButton(
                    text: plan.isStarted ? 'Continue Reading' : 'Start Plan',
                    height: 48,
                    onPressed: () => _handlePlanAction(plan),
                  ),
                ),
                if (plan.isStarted) ...[
                  const SizedBox(width: AppSpacing.md),
                  GestureDetector(
                    onTap: () => _showResetConfirmation(plan),
                    child: Container(
                      height: 48,
                      padding: AppSpacing.horizontalLg,
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.2),
                        borderRadius: AppRadius.mediumRadius,
                        border: Border.all(
                          color: Colors.red.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Icon(
                        Icons.restart_alt,
                        color: AppColors.primaryText,
                        size: ResponsiveUtils.iconSize(context, 20),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanStat(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: ResponsiveUtils.iconSize(context, 16),
          color: Colors.white.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
            color: AppColors.secondaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? action,
    String? actionText,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClearGlassCard(
              padding: AppSpacing.screenPaddingLarge,
              child: Icon(
                icon,
                size: ResponsiveUtils.iconSize(context, 48),
                color: AppColors.tertiaryText,
              ),
            ).animate().fadeIn(duration: AppAnimations.slow).scale(begin: const Offset(0.8, 0.8)),
            const SizedBox(height: AppSpacing.xxl),
            Text(
              title,
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(context, 20, minSize: 18, maxSize: 24),
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(duration: AppAnimations.slow, delay: AppAnimations.fast),
            const SizedBox(height: AppSpacing.md),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                color: AppColors.secondaryText,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(duration: AppAnimations.slow, delay: AppAnimations.normal),
            if (action != null && actionText != null) ...[
              const SizedBox(height: AppSpacing.xxl),
              GlassButton(
                text: actionText,
                onPressed: action,
              ).animate().fadeIn(duration: AppAnimations.slow, delay: AppAnimations.slow),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: ResponsiveUtils.iconSize(context, 48),
              color: Colors.red,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(context, 20, minSize: 18, maxSize: 24),
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              error,
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

  Widget _buildEmptyReadingsMessage() {
    return FrostedGlassCard(
      child: Column(
        children: [
          Icon(
            Icons.celebration,
            size: ResponsiveUtils.iconSize(context, 48),
            color: AppColors.tertiaryText,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'All caught up!',
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 18, minSize: 16, maxSize: 20),
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'No readings scheduled for today',
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  /// Opens the chapter reader for a specific daily reading
  void _openChapterReader(BuildContext context, DailyReading reading) {
    try {
      final parsed = ReadingReferenceParser.fromDailyReading(
        reading.book,
        reading.chapters,
      );

      NavigationService.goToChapterReading(
        book: parsed.book,
        startChapter: parsed.startChapter,
        endChapter: parsed.endChapter,
        readingId: reading.id,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open reading: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _toggleReadingComplete(DailyReading reading) async {
    final progressService = ref.read(readingPlanProgressServiceProvider);

    try {
      if (reading.isCompleted) {
        await progressService.markDayIncomplete(reading.id);
      } else {
        await progressService.markDayComplete(reading.id);
      }

      // Refresh providers
      ref.invalidate(currentReadingPlanProvider);
      ref.invalidate(todaysReadingsProvider(reading.planId));
      ref.invalidate(planProgressPercentageProvider(reading.planId));
      ref.invalidate(planStreakProvider(reading.planId));
      ref.invalidate(activeReadingPlansProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              reading.isCompleted
                  ? 'Marked as incomplete'
                  : 'Great job! Keep up the good work!',
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: reading.isCompleted
                ? Colors.orange
                : Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handlePlanAction(ReadingPlan plan) async {
    if (plan.isStarted) {
      // Navigate to today's tab
      _tabController.animateTo(0);
    } else {
      // Start the plan
      final planService = ref.read(readingPlanServiceProvider);
      final progressService = ref.read(readingPlanProgressServiceProvider);

      try {
        await planService.startPlan(plan.id);

        // Check if readings exist, if not create sample ones
        final readings = await progressService.getTodaysReadings(plan.id);
        if (readings.isEmpty) {
          await progressService.createSampleReadings(
            plan.id,
            plan.totalReadings,
          );
        }

        // Refresh providers
        ref.invalidate(currentReadingPlanProvider);
        ref.invalidate(activeReadingPlansProvider);
        ref.invalidate(allReadingPlansProvider);

        // Navigate to today's tab
        _tabController.animateTo(0);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reading plan started! Let\'s begin your journey.'),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error starting plan: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _showResetConfirmation(ReadingPlan plan) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Reading Plan?'),
        content: Text(
          'Are you sure you want to reset "${plan.title}"? All progress will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final progressService = ref.read(readingPlanProgressServiceProvider);

      try {
        await progressService.resetPlan(plan.id);

        // Refresh all providers
        ref.invalidate(currentReadingPlanProvider);
        ref.invalidate(activeReadingPlansProvider);
        ref.invalidate(allReadingPlansProvider);
        ref.invalidate(planProgressPercentageProvider(plan.id));
        ref.invalidate(planStreakProvider(plan.id));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reading plan has been reset'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error resetting plan: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
