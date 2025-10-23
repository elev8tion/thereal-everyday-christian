import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../components/gradient_background.dart';
import '../components/frosted_glass_card.dart';
import '../components/clear_glass_card.dart';
import '../components/glass_button.dart';
import '../components/category_badge.dart';
import '../components/blur_dropdown.dart';
import '../components/blur_popup_menu.dart';
import '../components/category_filter_chip.dart';
import '../components/glass_fab.dart';
import '../components/glassmorphic_fab_menu.dart';
import '../utils/responsive_utils.dart';
import '../theme/app_theme.dart';
import '../theme/app_gradients.dart';
import '../core/navigation/navigation_service.dart';
import '../core/models/prayer_request.dart';
import '../core/models/prayer_category.dart';
import '../core/providers/prayer_providers.dart';
import '../core/providers/category_providers.dart';
import '../core/widgets/skeleton_loader.dart';

class PrayerJournalScreen extends ConsumerStatefulWidget {
  const PrayerJournalScreen({super.key});

  @override
  ConsumerState<PrayerJournalScreen> createState() => _PrayerJournalScreenState();
}

class _PrayerJournalScreenState extends ConsumerState<PrayerJournalScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _prayerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _prayerController.dispose();
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
                _buildCategoryFilter(),
                _buildTabBar(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildActivePrayers(),
                      _buildAnsweredPrayers(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          GlassFab(
            onPressed: _showAddPrayerDialog,
            icon: Icons.add,
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
                Text(
                  'Prayer Journal',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, 24, minSize: 20, maxSize: 28),
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryText,
                  ),
                ).animate().fadeIn(duration: AppAnimations.slow).slideX(begin: -0.3),
                const SizedBox(height: 4),
                Text(
                  'Plan Pray Reflect',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                    color: AppColors.secondaryText,
                    fontWeight: FontWeight.w500,
                  ),
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
            Tab(text: 'Active'),
            Tab(text: 'Answered'),
          ],
        ),
      ),
    ).animate().fadeIn(duration: AppAnimations.slow, delay: AppAnimations.normal);
  }

  Widget _buildCategoryFilter() {
    final categoriesAsync = ref.watch(activeCategoriesProvider);
    final selectedCategory = ref.watch(selectedCategoryFilterProvider);

    return categoriesAsync.when(
      data: (categories) {
        if (categories.isEmpty) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Row(
                  children: [
                    Text(
                      'Filter by Category',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, 13, minSize: 11, maxSize: 15),
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondaryText,
                      ),
                    ),
                    const Spacer(),
                    Visibility(
                      visible: selectedCategory != null,
                      maintainSize: true,
                      maintainAnimation: true,
                      maintainState: true,
                      child: TextButton(
                        onPressed: () {
                          ref.read(selectedCategoryFilterProvider.notifier).state = null;
                        },
                        child: Text(
                          'Clear Filter',
                          style: TextStyle(
                            fontSize: ResponsiveUtils.fontSize(context, 12, minSize: 10, maxSize: 14),
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: ResponsiveUtils.scaleSize(context, 36, minScale: 0.9, maxScale: 1.2),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  children: [
                    // "All" filter chip
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          ref.read(selectedCategoryFilterProvider.notifier).state = null;
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: selectedCategory == null
                                ? LinearGradient(
                                    colors: [
                                      AppTheme.primaryColor.withValues(alpha: 0.4),
                                      AppTheme.primaryColor.withValues(alpha: 0.2),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : AppGradients.glassMedium,
                            borderRadius: AppRadius.largeCardRadius,
                            border: Border.all(
                              color: selectedCategory == null
                                  ? AppTheme.primaryColor
                                  : Colors.white.withValues(alpha: 0.2),
                              width: selectedCategory == null ? 2 : 1,
                            ),
                            boxShadow: selectedCategory == null
                                ? [
                                    BoxShadow(
                                      color: AppTheme.primaryColor.withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      spreadRadius: 0,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.grid_view,
                                size: ResponsiveUtils.iconSize(context, 16),
                                color: selectedCategory == null
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.7),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'All',
                                style: TextStyle(
                                  fontSize: ResponsiveUtils.fontSize(context, 13, minSize: 11, maxSize: 15),
                                  fontWeight: selectedCategory == null
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: selectedCategory == null
                                      ? Colors.white
                                      : Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Category chips
                    ...categories.map((category) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: CategoryFilterChip(
                        category: category,
                        isSelected: selectedCategory == category.id,
                        onTap: () {
                          if (selectedCategory == category.id) {
                            ref.read(selectedCategoryFilterProvider.notifier).state = null;
                          } else {
                            ref.read(selectedCategoryFilterProvider.notifier).state = category.id;
                          }
                        },
                      ),
                    )).toList(),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: AppAnimations.slow, delay: (400).ms);
      },
      loading: () => Container(
        margin: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.md),
        height: ResponsiveUtils.scaleSize(context, 36, minScale: 0.9, maxScale: 1.2),
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          children: List.generate(
            3,
            (i) => const Padding(
              padding: EdgeInsets.only(right: 8),
              child: SkeletonChip(),
            ),
          ),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildActivePrayers() {
    final activePrayersAsync = ref.watch(activePrayersProvider);

    return activePrayersAsync.when(
      data: (prayers) {
        if (prayers.isEmpty) {
          return _buildEmptyState(
            icon: Icons.favorite_outline,
            title: 'No Active Prayers',
            subtitle: 'Start your prayer journey by adding your first prayer request',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          itemCount: prayers.length,
          itemBuilder: (context, index) {
            final prayer = prayers[index];
            return _buildPrayerCard(prayer, index).animate()
                .fadeIn(duration: AppAnimations.slow, delay: (600 + index * 100).ms)
                .slideY(begin: 0.3);
          },
        );
      },
      loading: () => ListView.builder(
        padding: AppSpacing.screenPadding,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        itemBuilder: (_, __) => const SkeletonCard(),
      ),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: ResponsiveUtils.iconSize(context, 48), color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              'Unable to load prayers',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.primaryText),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => ref.refresh(activePrayersProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnsweredPrayers() {
    final answeredPrayersAsync = ref.watch(answeredPrayersProvider);

    return answeredPrayersAsync.when(
      data: (prayers) {
        if (prayers.isEmpty) {
          return _buildEmptyState(
            icon: Icons.check_circle_outline,
            title: 'No Answered Prayers Yet',
            subtitle: 'When God answers your prayers, mark them as answered to see them here',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          itemCount: prayers.length,
          itemBuilder: (context, index) {
            final prayer = prayers[index];
            return _buildPrayerCard(prayer, index).animate()
                .fadeIn(duration: AppAnimations.slow, delay: (600 + index * 100).ms)
                .slideY(begin: 0.3);
          },
        );
      },
      loading: () => ListView.builder(
        padding: AppSpacing.screenPadding,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        itemBuilder: (_, __) => const SkeletonCard(),
      ),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: ResponsiveUtils.iconSize(context, 48), color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              'Unable to load answered prayers',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.primaryText),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => ref.refresh(answeredPrayersProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
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
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerCard(PrayerRequest prayer, int index) {
    final categoriesAsync = ref.watch(activeCategoriesProvider);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: FrostedGlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                categoriesAsync.when(
                  data: (categories) {
                    final category = categories.firstWhere(
                      (c) => c.id == prayer.categoryId,
                      orElse: () => categories.isNotEmpty ? categories.first : _getDefaultCategory(),
                    );
                    return CategoryBadge(
                      text: category.name,
                      badgeColor: category.color,
                      icon: category.icon,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      fontSize: ResponsiveUtils.fontSize(context, 11, minSize: 9, maxSize: 13),
                    );
                  },
                  loading: () => CategoryBadge(
                    text: 'Loading...',
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    fontSize: ResponsiveUtils.fontSize(context, 11, minSize: 9, maxSize: 13),
                  ),
                  error: (_, __) => CategoryBadge(
                    text: 'General',
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    fontSize: ResponsiveUtils.fontSize(context, 11, minSize: 9, maxSize: 13),
                  ),
                ),
                const Spacer(),
                if (prayer.isAnswered)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.2),
                      borderRadius: AppRadius.smallRadius,
                    ),
                    child: Icon(
                      Icons.check_circle,
                      size: ResponsiveUtils.iconSize(context, 16),
                      color: Colors.green,
                    ),
                  )
                else
                  BlurPopupMenu(
                    items: const [
                      BlurPopupMenuItem(
                        value: 'mark_answered',
                        icon: Icons.check,
                        label: 'Answered',
                      ),
                      BlurPopupMenuItem(
                        value: 'delete',
                        icon: Icons.delete,
                        label: 'Delete',
                        iconColor: Colors.red,
                        textColor: Colors.red,
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'mark_answered') {
                        _markPrayerAnswered(prayer);
                      } else if (value == 'delete') {
                        _deletePrayer(prayer);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      child: Icon(
                        Icons.more_vert,
                        size: ResponsiveUtils.iconSize(context, 18),
                        color: AppColors.primaryText,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              prayer.title,
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              prayer.description,
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                color: Colors.white.withValues(alpha: 0.9),
                height: 1.4,
              ),
            ),
            if (prayer.isAnswered && prayer.answerDescription != null) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: AppRadius.smallRadius,
                  border: Border.all(
                    color: Colors.green.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How God Answered:',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, 12, minSize: 10, maxSize: 14),
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      prayer.answerDescription!,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, 13, minSize: 11, maxSize: 15),
                        color: Colors.white.withValues(alpha: 0.9),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: ResponsiveUtils.iconSize(context, 14),
                  color: AppColors.tertiaryText,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDate(prayer.dateCreated),
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, 12, minSize: 10, maxSize: 14),
                    color: AppColors.tertiaryText,
                  ),
                ),
                if (prayer.isAnswered && prayer.dateAnswered != null) ...[
                  const SizedBox(width: AppSpacing.lg),
                  Icon(
                    Icons.check_circle,
                    size: ResponsiveUtils.iconSize(context, 14),
                    color: Colors.green.withValues(alpha: 0.8),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Answered ${_formatDate(prayer.dateAnswered!)}',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.fontSize(context, 12, minSize: 10, maxSize: 14),
                      color: Colors.green.withValues(alpha: 0.8),
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

  void _showAddPrayerDialog() {
    final categoriesAsync = ref.read(activeCategoriesProvider);
    String? selectedCategoryId;
    String title = '';
    String description = '';

    // Get the first category or default to general
    categoriesAsync.whenData((categories) {
      if (categories.isNotEmpty) {
        selectedCategoryId = categories.first.id;
      }
    });

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return categoriesAsync.when(
            data: (categories) {
              // Set default category if not set
              if (selectedCategoryId == null && categories.isNotEmpty) {
                selectedCategoryId = categories.first.id;
              }

              return Dialog(
                backgroundColor: Colors.transparent,
                child: FrostedGlassCard(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add Prayer Request',
                          style: TextStyle(
                            fontSize: ResponsiveUtils.fontSize(context, 20, minSize: 18, maxSize: 24),
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryText,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        Text(
                          'Title',
                          style: TextStyle(
                            fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryText,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        TextField(
                          onChanged: (value) => title = value,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'What are you praying for?',
                            hintStyle: TextStyle(color: AppColors.tertiaryText),
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.1),
                            border: OutlineInputBorder(
                              borderRadius: AppRadius.mediumRadius,
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          'Category',
                          style: TextStyle(
                            fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryText,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        if (categories.isNotEmpty)
                          SizedBox(
                            height: ResponsiveUtils.scaleSize(context, 40, minScale: 0.9, maxScale: 1.2),
                            child: BlurDropdown(
                              value: categories.firstWhere((c) => c.id == selectedCategoryId, orElse: () => categories.first).name,
                              items: categories.map((category) => category.name).toList(),
                              hint: 'Select Category',
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    selectedCategoryId = categories.firstWhere((c) => c.name == value).id;
                                  });
                                }
                              },
                            ),
                          ),

                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Description',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    onChanged: (value) => description = value,
                    maxLines: 3,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Share more details about your prayer request...',
                      hintStyle: TextStyle(color: AppColors.tertiaryText),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.1),
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.mediumRadius,
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                        const SizedBox(height: AppSpacing.xxl),
                        Row(
                          children: [
                            Expanded(
                              child: GlassButton(
                                text: 'Cancel',
                                height: 48,
                                onPressed: () => NavigationService.pop(),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: GlassButton(
                                text: 'Add',
                                height: 48,
                                onPressed: () {
                                  if (title.isNotEmpty && description.isNotEmpty && selectedCategoryId != null) {
                                    _addPrayer(title, description, selectedCategoryId!);
                                    NavigationService.pop();
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            loading: () => const Dialog(
              backgroundColor: Colors.transparent,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => const Dialog(
              backgroundColor: Colors.transparent,
              child: Center(child: Text('Error loading categories')),
            ),
          );
        },
      ),
    );
  }

  Future<void> _addPrayer(String title, String description, String categoryId) async {
    final actions = ref.read(prayerActionsProvider);

    try {
      await actions.addPrayer(title, description, categoryId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Prayer added successfully'),
            backgroundColor: AppTheme.primaryColor,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding prayer: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _markPrayerAnswered(PrayerRequest prayer) {
    showDialog(
      context: context,
      builder: (context) {
        String answerDescription = '';

        return Dialog(
          backgroundColor: Colors.transparent,
          child: FrostedGlassCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Answered',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, 20, minSize: 18, maxSize: 24),
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                Text(
                  'How did God answer this prayer?',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  onChanged: (value) => answerDescription = value,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Share how God answered your prayer...',
                    hintStyle: TextStyle(color: AppColors.tertiaryText),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.1),
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.mediumRadius,
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xxl),
                Row(
                  children: [
                    Expanded(
                      child: GlassButton(
                        text: 'Cancel',
                        height: 48,
                        onPressed: () => NavigationService.pop(),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: GlassButton(
                        text: 'Answered',
                        height: 48,
                        onPressed: () async {
                          if (answerDescription.isNotEmpty) {
                            final actions = ref.read(prayerActionsProvider);

                            try {
                              await actions.markAnswered(prayer.id, answerDescription);
                              if (!context.mounted) return;

                              NavigationService.pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Prayer marked as answered! 🙏'),
                                  backgroundColor: AppTheme.primaryColor,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: $e'),
                                  backgroundColor: Colors.red,
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _deletePrayer(PrayerRequest prayer) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: FrostedGlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: ResponsiveUtils.iconSize(context, 48),
                color: Colors.orange,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Delete Prayer',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 20, minSize: 18, maxSize: 24),
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Are you sure you want to delete "${prayer.title}"?',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                  color: AppColors.secondaryText,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxl),
              Row(
                children: [
                  Expanded(
                    child: GlassButton(
                      text: 'Cancel',
                      height: 48,
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.2),
                        borderRadius: AppRadius.largeCardRadius,
                        border: Border.all(
                          color: Colors.red,
                          width: 2,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => Navigator.of(context).pop(true),
                          borderRadius: AppRadius.largeCardRadius,
                          child: Container(
                            height: 48,
                            alignment: Alignment.center,
                            child: Text(
                              'Delete',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w700,
                                fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true) {
      final actions = ref.read(prayerActionsProvider);

      try {
        await actions.deletePrayer(prayer.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Prayer deleted'),
              backgroundColor: AppTheme.primaryColor,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting prayer: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }


  PrayerCategory _getDefaultCategory() {
    return PrayerCategory(
      id: 'cat_general',
      name: 'General',
      iconCodePoint: 0xe3fc, // Icons.more_horiz
      colorValue: 0xFF9E9E9E, // Colors.grey
      dateCreated: DateTime.now(),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  
}
