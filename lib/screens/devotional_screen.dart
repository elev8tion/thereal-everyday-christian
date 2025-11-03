import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../components/gradient_background.dart';
import '../components/frosted_glass_card.dart';
import '../components/clear_glass_card.dart';
import '../components/glass_button.dart';
import '../theme/app_theme.dart';
import '../theme/app_gradients.dart';
import '../core/providers/app_providers.dart';
import '../core/models/devotional.dart';
import '../utils/responsive_utils.dart';
import '../core/navigation/app_routes.dart';

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

                if (!_isInitialized && devotionals.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _initializeCurrentDay(devotionals);
                  });
                }

                if (_currentDay >= devotionals.length) {
                  _currentDay = devotionals.length - 1;
                }

                final currentDevotional = devotionals[_currentDay];

                return SingleChildScrollView(
                  padding: const EdgeInsets.only(
                    top: AppSpacing.xl,
                    left: AppSpacing.xl,
                    right: AppSpacing.xl,
                    bottom: AppSpacing.xxl,
                  ),
                  child: Column(
                    children: [
                      _buildHeader(streakAsync, totalCompletedAsync),
                      const SizedBox(height: AppSpacing.xl),
                      _buildDateBadge(currentDevotional),
                      const SizedBox(height: AppSpacing.md),
                      _buildTitle(currentDevotional),
                      const SizedBox(height: AppSpacing.xxl),
                      _buildOpeningScripture(currentDevotional),
                      const SizedBox(height: AppSpacing.xl),
                      _buildKeyVerseSpotlight(currentDevotional),
                      const SizedBox(height: AppSpacing.xl),
                      _buildReflection(currentDevotional),
                      const SizedBox(height: AppSpacing.xl),
                      _buildLifeApplication(currentDevotional),
                      const SizedBox(height: AppSpacing.xl),
                      _buildPrayer(currentDevotional),
                      const SizedBox(height: AppSpacing.xl),
                      _buildActionStep(currentDevotional),
                      const SizedBox(height: AppSpacing.xl),
                      _buildGoingDeeper(currentDevotional),
                      const SizedBox(height: AppSpacing.xxl),
                      _buildCompletionButton(currentDevotional),
                      const SizedBox(height: AppSpacing.xl),
                      _buildNavigationButtons(devotionals.length),
                      const SizedBox(height: AppSpacing.xl),
                      _buildProgressIndicator(devotionals),
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error loading devotionals: $error'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(AsyncValue<int> streakAsync, AsyncValue<int> totalCompletedAsync) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        streakAsync.when(
          data: (streak) => _buildStatCard(
            value: "$streak",
            label: "Day Streak",
            icon: Icons.local_fire_department,
            color: Colors.orange,
          ),
          loading: () => _buildStatCard(value: "-", label: "Day Streak", icon: Icons.local_fire_department, color: Colors.orange),
          error: (_, __) => _buildStatCard(value: "0", label: "Day Streak", icon: Icons.local_fire_department, color: Colors.orange),
        ),
        totalCompletedAsync.when(
          data: (total) => _buildStatCard(
            value: "$total",
            label: "Completed",
            icon: Icons.check_circle,
            color: Colors.green,
          ),
          loading: () => _buildStatCard(value: "-", label: "Completed", icon: Icons.check_circle, color: Colors.green),
          error: (_, __) => _buildStatCard(value: "0", label: "Completed", icon: Icons.check_circle, color: Colors.green),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return ClearGlassCard(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        child: Column(
          children: [
            Icon(icon, color: color, size: ResponsiveUtils.iconSize(context, 24)),
            const SizedBox(height: AppSpacing.xs),
            Text(
              value,
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(context, 20, minSize: 18, maxSize: 24),
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(context, 12, minSize: 10, maxSize: 14),
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateBadge(Devotional devotional) {
    final date = DateTime.parse(devotional.date);
    final monthNames = ['January', 'February', 'March', 'April', 'May', 'June',
                       'July', 'August', 'September', 'October', 'November', 'December'];
    final dateString = '${monthNames[date.month - 1]} ${date.day}, ${date.year}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        gradient: AppGradients.glassStrong,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppTheme.goldColor.withValues(alpha: 0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_today, size: ResponsiveUtils.iconSize(context, 14), color: AppTheme.goldColor),
          const SizedBox(width: AppSpacing.xs),
          Text(
            dateString,
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 12, minSize: 10, maxSize: 14),
              fontWeight: FontWeight.w600,
              color: AppColors.primaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(Devotional devotional) {
    return Text(
      devotional.title,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: ResponsiveUtils.fontSize(context, 26, minSize: 22, maxSize: 30),
        fontWeight: FontWeight.w800,
        color: AppColors.primaryText,
        height: 1.2,
      ),
    );
  }

  Widget _buildOpeningScripture(Devotional devotional) {
    return FrostedGlassCard(
      borderColor: AppTheme.goldColor.withValues(alpha: 0.6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.menu_book, color: AppTheme.goldColor, size: ResponsiveUtils.iconSize(context, 20)),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Opening Scripture',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                  fontWeight: FontWeight.w700,
                  color: AppTheme.goldColor,
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
    );
  }

  Widget _buildKeyVerseSpotlight(Devotional devotional) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.goldColor.withValues(alpha: 0.2),
            AppTheme.goldColor.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppTheme.goldColor.withValues(alpha: 0.8), width: 2),
      ),
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star, color: AppTheme.goldColor, size: ResponsiveUtils.iconSize(context, 22)),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Key Verse Spotlight',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
                  fontWeight: FontWeight.w700,
                  color: AppTheme.goldColor,
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
              height: 1.6,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            devotional.keyVerseReference,
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 15, minSize: 13, maxSize: 17),
              color: AppTheme.goldColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReflection(Devotional devotional) {
    return ClearGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_stories, color: AppTheme.goldColor, size: ResponsiveUtils.iconSize(context, 20)),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Reflection',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 18, minSize: 16, maxSize: 20),
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            devotional.reflection,
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 15, minSize: 13, maxSize: 17),
              color: Colors.white.withValues(alpha: 0.95),
              height: 1.7,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLifeApplication(Devotional devotional) {
    return FrostedGlassCard(
      borderColor: Colors.blue.withValues(alpha: 0.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.blue[300], size: ResponsiveUtils.iconSize(context, 20)),
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
              color: Colors.white.withValues(alpha: 0.95),
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayer(Devotional devotional) {
    return FrostedGlassCard(
      borderColor: Colors.purple.withValues(alpha: 0.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.favorite, color: Colors.purple[300], size: ResponsiveUtils.iconSize(context, 20)),
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
              color: Colors.white.withValues(alpha: 0.95),
              height: 1.6,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionStep(Devotional devotional) {
    return FrostedGlassCard(
      borderColor: Colors.green.withValues(alpha: 0.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: devotional.actionStepCompleted,
            onChanged: (value) async {
              final service = ref.read(devotionalServiceProvider);
              await service.toggleActionStepCompleted(devotional.id, value ?? false);
              ref.invalidate(allDevotionalsProvider);
            },
            activeColor: Colors.green[400],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Action Step',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  devotional.actionStep,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, 15, minSize: 13, maxSize: 17),
                    color: Colors.white.withValues(alpha: 0.95),
                    height: 1.6,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoingDeeper(Devotional devotional) {
    return FrostedGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.school, color: AppTheme.goldColor, size: ResponsiveUtils.iconSize(context, 20)),
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
                onTap: () {
                  // Navigate to verse
                  Navigator.of(context).pushNamed(AppRoutes.verseLibrary);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    gradient: AppGradients.glassVeryStrong,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(color: AppTheme.goldColor.withValues(alpha: 0.4), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_forward, size: ResponsiveUtils.iconSize(context, 14), color: AppTheme.goldColor),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        reference,
                        style: TextStyle(
                          fontSize: ResponsiveUtils.fontSize(context, 13, minSize: 11, maxSize: 15),
                          color: AppColors.primaryText,
                          fontWeight: FontWeight.w600,
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
    );
  }

  Widget _buildCompletionButton(Devotional devotional) {
    return GlassButton(
      text: devotional.isCompleted ? 'Mark Incomplete' : 'Mark Complete',
      height: 56,
      onPressed: () async {
        final service = ref.read(devotionalServiceProvider);
        if (devotional.isCompleted) {
          await service.markDevotionalIncomplete(devotional.id);
        } else {
          await service.markDevotionalCompleted(devotional.id);
        }
        ref.invalidate(allDevotionalsProvider);
        ref.invalidate(devotionalStreakProvider);
        ref.invalidate(totalDevotionalsCompletedProvider);
      },
    );
  }

  Widget _buildNavigationButtons(int totalDays) {
    return Row(
      children: [
        Expanded(
          child: GlassButton(
            text: 'Previous',
            height: 48,
            onPressed: _currentDay > 0
                ? () => setState(() => _currentDay--)
                : null,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: GlassButton(
            text: 'Next',
            height: 48,
            onPressed: _currentDay < totalDays - 1
                ? () => setState(() => _currentDay++)
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator(List<Devotional> devotionals) {
    return Column(
      children: [
        Text(
          'Day ${_currentDay + 1} of ${devotionals.length}',
          style: TextStyle(
            fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
            color: Colors.white.withValues(alpha: 0.8),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: LinearProgressIndicator(
            value: ((_currentDay + 1) / devotionals.length),
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.goldColor),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return ClearGlassCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_stories,
            size: ResponsiveUtils.iconSize(context, 64),
            color: Colors.white.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'No Devotionals Available',
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 18, minSize: 16, maxSize: 20),
              fontWeight: FontWeight.w600,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Check back soon for daily inspiration',
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
              color: Colors.white.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
