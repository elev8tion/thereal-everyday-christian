import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:intl/intl.dart';
import '../components/gradient_background.dart';
import '../components/frosted_glass_card.dart';
import '../components/clear_glass_card.dart';
import '../components/glassmorphic_fab_menu.dart';
import '../components/blur_popup_menu.dart';
import '../components/base_bottom_sheet.dart';
import '../components/glass_button.dart';
import '../theme/app_theme.dart';
import '../core/navigation/navigation_service.dart';
import '../models/bible_verse.dart';
import '../models/shared_verse_entry.dart';
import '../core/providers/app_providers.dart';
import '../utils/responsive_utils.dart';
import '../core/widgets/app_snackbar.dart';
import '../utils/blur_dialog_utils.dart';

// Provider for all saved verses
final filteredVersesProvider = FutureProvider.autoDispose<List<BibleVerse>>((ref) async {
  final service = ref.watch(unifiedVerseServiceProvider);
  return await service.getAllVerses(limit: 100);
});

class VerseLibraryScreen extends ConsumerStatefulWidget {
  const VerseLibraryScreen({super.key});

  @override
  ConsumerState<VerseLibraryScreen> createState() => _VerseLibraryScreenState();
}

class _VerseLibraryScreenState extends ConsumerState<VerseLibraryScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
                      _buildSavedVerses(),
                      _buildSharedVerses(),
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
                  'Verse Library',
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
                  'Everyday Verses',
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
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: AppRadius.mediumRadius,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: Icon(Icons.more_vert, color: Colors.white, size: ResponsiveUtils.iconSize(context, 24)),
              onPressed: _showVerseOptions,
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
            Tab(text: 'Saved Verses'),
            Tab(text: 'Shared'),
          ],
        ),
      ),
    ).animate().fadeIn(duration: AppAnimations.slow, delay: 800.ms);
  }

  Widget _buildSharedVerses() {
    final sharedAsync = ref.watch(sharedVersesProvider);

    return sharedAsync.when(
      data: (entries) {
        if (entries.isEmpty) {
          return _buildEmptyState(
            icon: Icons.history_toggle_off,
            title: 'No shared verses yet',
            subtitle: 'Share verses to keep a quick-access history here.',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(left: 50, right: 50, top: 20, bottom: 20),
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildSharedVerseCard(entry, index).animate()
                  .fadeIn(duration: AppAnimations.slow, delay: (100 + index * 50).ms)
                  .slideY(begin: 0.3),
            );
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(
          color: AppTheme.primaryColor,
        ),
      ),
      error: (error, stackTrace) => _buildErrorState(error.toString()),
    );
  }

  // Deprecated: Removed pre-populated "All Verses" tab
  // Widget _buildAllVerses() { ... }

  Widget _buildSavedVerses() {
    final favoritesAsync = ref.watch(favoriteVersesProvider);

    return favoritesAsync.when(
      data: (verses) {
        if (verses.isEmpty) {
          return _buildEmptyState(
            icon: Icons.favorite_outline,
            title: 'No saved verses yet',
            subtitle: '💡 Save verses while reading to build your collection',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(left: 50, right: 50, top: 20, bottom: 20),
          itemCount: verses.length,
          itemBuilder: (context, index) {
            final verse = verses[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildVerseCard(verse, index).animate()
                  .fadeIn(duration: AppAnimations.slow, delay: (100 + index * 50).ms)
                  .slideY(begin: 0.3),
            );
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(
          color: AppTheme.primaryColor,
        ),
      ),
      error: (error, stack) => _buildErrorState(error.toString()),
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
              color: Colors.red.withValues(alpha: 0.7),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(context, 20, minSize: 18, maxSize: 24),
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              error,
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                color: AppColors.secondaryText,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerseCard(BibleVerse verse, int index) {
    return FrostedGlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Book/Chapter/Verse on left
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.book,
                        size: ResponsiveUtils.iconSize(context, 16),
                        color: AppTheme.goldColor.withValues(alpha: 0.8),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Flexible(
                        child: Text(
                          verse.reference,
                          style: TextStyle(
                            fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                            color: Colors.white.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        '(${verse.translation})',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.fontSize(context, 12, minSize: 10, maxSize: 14),
                          color: Colors.white.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // 3-dot menu for actions
                BlurPopupMenu(
                  items: const [
                    BlurPopupMenuItem(
                      value: 'share',
                      icon: Icons.share,
                      label: 'Share',
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
                    if (value == 'share') {
                      _showShareOptions(verse);
                    } else if (value == 'delete') {
                      _deleteSavedVerse(verse);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: Icon(
                      Icons.more_vert,
                      size: ResponsiveUtils.iconSize(context, 20),
                      color: AppColors.primaryText,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              '"${verse.text}"',
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
                color: AppColors.primaryText,
                height: 1.5,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.italic,
              ),
            ),
            if (verse.themes.length > 1) ...[
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: verse.themes.skip(1).take(3).map((theme) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: AppRadius.smallRadius,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      theme.substring(0, 1).toUpperCase() + theme.substring(1),
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, 11, minSize: 9, maxSize: 13),
                        color: Colors.white.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
    );
  }

  Widget _buildSharedVerseCard(SharedVerseEntry entry, int index) {
    final verse = entry.toBibleVerse();
    final sharedTimestamp = DateFormat('MMM d, yyyy • h:mm a').format(entry.sharedAt);

    // Don't show internal channel names to users
    final channelLabel = entry.channel?.isNotEmpty == true && entry.channel != 'share_sheet'
        ? entry.channel!
        : '';

    return FrostedGlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.history,
                            size: ResponsiveUtils.iconSize(context, 16),
                            color: AppTheme.primaryColor.withValues(alpha: 0.8),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Flexible(
                            child: Text(
                              verse.reference,
                              style: TextStyle(
                                fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                                color: Colors.white.withValues(alpha: 0.9),
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            '(${verse.translation})',
                            style: TextStyle(
                              fontSize: ResponsiveUtils.fontSize(context, 12, minSize: 10, maxSize: 14),
                              color: Colors.white.withValues(alpha: 0.6),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        channelLabel.isNotEmpty
                            ? '$sharedTimestamp • $channelLabel'
                            : sharedTimestamp,
                        style: TextStyle(
                          fontSize: ResponsiveUtils.fontSize(context, 12, minSize: 10, maxSize: 14),
                          color: Colors.white.withValues(alpha: 0.55),
                        ),
                      ),
                    ],
                  ),
                ),
                // 3-dot menu for actions
                BlurPopupMenu(
                  items: const [
                    BlurPopupMenuItem(
                      value: 'share',
                      icon: Icons.share,
                      label: 'Share',
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
                    if (value == 'share') {
                      _showShareOptions(verse);
                    } else if (value == 'delete') {
                      _deleteSharedVerse(entry.id);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: Icon(
                      Icons.more_vert,
                      size: ResponsiveUtils.iconSize(context, 20),
                      color: AppColors.primaryText,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              '"${entry.text}"',
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
                color: AppColors.primaryText,
                height: 1.5,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.italic,
              ),
            ),
            if (entry.themes.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: entry.themes.take(3).map((theme) {
                  final displayTheme = theme.isNotEmpty
                      ? theme.substring(0, 1).toUpperCase() + theme.substring(1)
                      : 'General';
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: AppRadius.smallRadius,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      displayTheme,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, 11, minSize: 9, maxSize: 13),
                        color: Colors.white.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
    );
  }

  Future<void> _toggleFavorite(BibleVerse verse) async {
    if (verse.id == null) return;

    final service = ref.read(unifiedVerseServiceProvider);

    try {
      final newStatus = await service.toggleFavorite(verse.id!);

      // Refresh both tabs
      ref.invalidate(filteredVersesProvider);
      ref.invalidate(favoriteVersesProvider);
      ref.invalidate(savedVersesCountProvider);

      // Show feedback
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: newStatus ? 'Added to favorites' : 'Removed from favorites',
        icon: newStatus ? Icons.favorite : Icons.heart_broken,
      );
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.showError(
        context,
        message: 'Error updating favorite: $e',
      );
    }
  }

  void _showShareOptions(BibleVerse verse) {
    showCustomBottomSheet(
      context: context,
      title: 'Share Verse',
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: _buildSheetIcon(Icons.copy),
              title: const Text('Copy to Clipboard', style: TextStyle(color: Colors.white)),
              onTap: () {
                final text = '"${verse.text}"\n\n${verse.reference} (${verse.translation})';
                Clipboard.setData(ClipboardData(text: text));
                NavigationService.pop();
                if (!mounted) return;
                AppSnackBar.show(
                  context,
                  message: 'Verse copied to clipboard',
                );
              },
            ),
            ListTile(
              leading: _buildSheetIcon(Icons.share),
              title: const Text('Share with Friends', style: TextStyle(color: Colors.white)),
              onTap: () async {
                NavigationService.pop();
                final shareText = '"${verse.text}"\n\n— ${verse.reference}';
                try {
                  await SharePlus.instance.share(
                    ShareParams(
                      text: shareText,
                      subject: 'Bible Verse - ${verse.reference}',
                    ),
                  );

                  await ref.read(unifiedVerseServiceProvider).recordSharedVerse(verse);
                  ref.invalidate(sharedVersesProvider);
                  ref.invalidate(sharedVersesCountProvider);

                  if (!mounted) return;
                  AppSnackBar.show(
                    context,
                    message: 'Verse shared!',
                    icon: Icons.share,
                    iconColor: AppTheme.primaryColor,
                  );
                } catch (e) {
                  if (!mounted) return;
                  AppSnackBar.showError(
                    context,
                    message: 'Unable to share verse: $e',
                  );
                }
              },
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  void _showVerseOptions() {
    showCustomBottomSheet(
      context: context,
      title: 'Verse Library Options',
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: _buildSheetIcon(Icons.info_outline),
              title: const Text(
                'About Verse Library',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText,
                ),
              ),
              subtitle: Text(
                'Browse and manage your saved verses',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 12, minSize: 10, maxSize: 14),
                  color: AppColors.secondaryText,
                ),
              ),
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: AppSpacing.md),
            ListTile(
              leading: _buildSheetIcon(Icons.collections_bookmark),
              title: const Text(
                'View shared history',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText,
                ),
              ),
              subtitle: Text(
                'Jump to your recently shared verses',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 12, minSize: 10, maxSize: 14),
                  color: AppColors.secondaryText,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _tabController.animateTo(1);
              },
            ),
            const SizedBox(height: AppSpacing.md),
            ListTile(
              leading: _buildSheetIcon(Icons.delete_forever, iconColor: Colors.redAccent),
              title: const Text(
                'Clear saved verses',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText,
                ),
              ),
              subtitle: Text(
                'Remove all verses from your saved collection',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 12, minSize: 10, maxSize: 14),
                  color: AppColors.secondaryText,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _confirmClearSavedVerses();
              },
            ),
            const SizedBox(height: AppSpacing.md),
            ListTile(
              leading: _buildSheetIcon(Icons.delete_sweep, iconColor: Colors.redAccent),
              title: const Text(
                'Clear shared history',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText,
                ),
              ),
              subtitle: Text(
                'Remove every verse from shared activity',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 12, minSize: 10, maxSize: 14),
                  color: AppColors.secondaryText,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _confirmClearSharedVerses();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSheetIcon(IconData icon, {Color? iconColor}) {
    final baseColor = iconColor ?? AppTheme.primaryColor;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            baseColor.withValues(alpha: 0.24),
            baseColor.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: AppRadius.mediumRadius,
        border: Border.all(
          color: baseColor.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Icon(
        icon,
        color: baseColor,
      ),
    );
  }

  Future<void> _deleteSharedVerse(String shareId) async {
    try {
      final service = ref.read(unifiedVerseServiceProvider);
      await service.deleteSharedVerse(shareId);

      ref.invalidate(sharedVersesProvider);
      ref.invalidate(sharedVersesCountProvider);

      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: 'Removed from shared history',
        icon: Icons.delete_outline,
        iconColor: Colors.redAccent,
      );
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.showError(
        context,
        message: 'Unable to remove shared verse: $e',
      );
    }
  }

  Future<void> _deleteSavedVerse(BibleVerse verse) async {
    if (verse.id == null) return;

    try {
      final service = ref.read(unifiedVerseServiceProvider);
      await service.removeFromFavorites(verse.id!);

      // Invalidate providers to refresh UI counts
      ref.invalidate(favoriteVersesProvider);
      ref.invalidate(savedVersesCountProvider);

      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: 'Removed from Verse Library',
        icon: Icons.heart_broken,
      );
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.showError(
        context,
        message: 'Unable to remove verse: $e',
      );
    }
  }

  Future<void> _confirmClearSharedVerses() async {
    final shouldClear = await showBlurredDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: FrostedGlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.history_toggle_off,
                    color: Colors.redAccent,
                    size: ResponsiveUtils.iconSize(context, 32),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'Clear shared history?',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, 18, minSize: 16, maxSize: 20),
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryText,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'This removes every verse from your Shared tab. Future shares will continue to appear here.',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                  color: AppColors.secondaryText,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: GlassButton(
                      text: 'Cancel',
                      height: 48,
                      onPressed: () => Navigator.pop(context, false),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        'Clear All',
                        style: TextStyle(fontWeight: FontWeight.w600),
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

    if (shouldClear == true) {
      try {
        final service = ref.read(unifiedVerseServiceProvider);
        await service.clearSharedVerses();

        ref.invalidate(sharedVersesProvider);
        ref.invalidate(sharedVersesCountProvider);

        if (!mounted) return;
        AppSnackBar.show(
          context,
          message: 'Shared history cleared',
          icon: Icons.delete_sweep,
          iconColor: Colors.redAccent,
        );
      } catch (e) {
        if (!mounted) return;
        AppSnackBar.showError(
          context,
          message: 'Unable to clear shared history: $e',
        );
      }
    }
  }

  Future<void> _confirmClearSavedVerses() async {
    final shouldClear = await showBlurredDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: FrostedGlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.delete_sweep,
                    color: Colors.redAccent,
                    size: ResponsiveUtils.iconSize(context, 32),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'Clear saved verses?',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, 18, minSize: 16, maxSize: 20),
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryText,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'This will remove every verse from your Saved list. You can always add them again later.',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                  color: AppColors.secondaryText,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: GlassButton(
                      text: 'Cancel',
                      height: 48,
                      onPressed: () => Navigator.pop(context, false),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        'Clear All',
                        style: TextStyle(fontWeight: FontWeight.w600),
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

    if (shouldClear == true) {
      try {
        final service = ref.read(unifiedVerseServiceProvider);
        await service.clearFavoriteVerses();
        ref.invalidate(favoriteVersesProvider);
        ref.invalidate(filteredVersesProvider);
        ref.invalidate(savedVersesCountProvider);
        if (!mounted) return;
        AppSnackBar.show(
          context,
          message: 'Saved verses cleared',
          icon: Icons.delete_forever,
          iconColor: Colors.redAccent,
        );
      } catch (e) {
        if (!mounted) return;
        AppSnackBar.showError(
          context,
          message: 'Unable to clear saved verses: $e',
        );
      }
    }
  }
}
