import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import '../core/services/database_service.dart';
import '../services/conversation_service.dart';
import '../theme/app_theme.dart';
import '../theme/app_gradients.dart';
import '../components/gradient_background.dart';
import '../components/frosted_glass_card.dart';
import '../components/glassmorphic_fab_menu.dart';
import '../core/navigation/navigation_service.dart';
import '../core/providers/app_providers.dart';
import '../utils/responsive_utils.dart';
import '../widgets/time_picker/time_range_sheet.dart';
import '../widgets/time_picker/time_range_sheet_style.dart';
import '../components/glass_button.dart';
import 'paywall_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Stack(
          children: [
            const GradientBackground(),
            SafeArea(
              child: _buildSettingsContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
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
                  'Settings',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, 24, minSize: 20, maxSize: 28),
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryText,
                    shadows: AppTheme.textShadowStrong,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                AutoSizeText(
                  'Customize your app experience',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                    color: AppColors.secondaryText,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: AppAnimations.slow).slideY(begin: -0.3);
  }


  Widget _buildSettingsContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(
        top: AppSpacing.xl,
        left: AppSpacing.xl,
        right: AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAppBar(),
          const SizedBox(height: AppSpacing.xxl),
          _buildSettingsSection(
            'Notifications',
            Icons.notifications,
            [
              _buildSwitchTile(
                'Daily Devotional',
                'Receive daily devotional reminders',
                ref.watch(dailyNotificationsProvider),
                (value) => ref.read(dailyNotificationsProvider.notifier).toggle(value),
              ),
              if (ref.watch(dailyNotificationsProvider))
                Padding(
                  padding: const EdgeInsets.only(left: AppSpacing.lg, bottom: AppSpacing.sm),
                  child: _buildTimePicker(
                    'Time',
                    'Daily devotional reminder time',
                    ref.watch(devotionalTimeProvider),
                    (time) => ref.read(devotionalTimeProvider.notifier).setTime(time),
                  ),
                ),
              _buildSwitchTile(
                'Prayer Reminders',
                'Get reminded to pray throughout the day',
                ref.watch(prayerRemindersProvider),
                (value) => ref.read(prayerRemindersProvider.notifier).toggle(value),
              ),
              if (ref.watch(prayerRemindersProvider))
                Padding(
                  padding: const EdgeInsets.only(left: AppSpacing.lg, bottom: AppSpacing.sm),
                  child: _buildTimePicker(
                    'Time',
                    'Prayer reminder time',
                    ref.watch(prayerTimeProvider),
                    (time) => ref.read(prayerTimeProvider.notifier).setTime(time),
                  ),
                ),
              _buildSwitchTile(
                'Verse of the Day',
                'Daily Bible verse notifications',
                ref.watch(verseOfTheDayProvider),
                (value) => ref.read(verseOfTheDayProvider.notifier).toggle(value),
              ),
              if (ref.watch(verseOfTheDayProvider))
                Padding(
                  padding: const EdgeInsets.only(left: AppSpacing.lg, bottom: AppSpacing.sm),
                  child: _buildTimePicker(
                    'Time',
                    'Verse of the day time',
                    ref.watch(verseTimeProvider),
                    (time) => ref.read(verseTimeProvider.notifier).setTime(time),
                  ),
                ),
              _buildSwitchTile(
                'Reading Plan',
                'Get reminded to complete your daily reading',
                ref.watch(readingPlanRemindersProvider),
                (value) => ref.read(readingPlanRemindersProvider.notifier).toggle(value),
              ),
              if (ref.watch(readingPlanRemindersProvider))
                Padding(
                  padding: const EdgeInsets.only(left: AppSpacing.lg, bottom: AppSpacing.sm),
                  child: _buildTimePicker(
                    'Time',
                    'Reading plan reminder time',
                    ref.watch(readingPlanTimeProvider),
                    (time) => ref.read(readingPlanTimeProvider.notifier).setTime(time),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          _buildSettingsSection(
            'Subscription',
            Icons.workspace_premium,
            [
              _buildNavigationTile(
                'Manage Subscription',
                _getSubscriptionStatus(ref),
                Icons.arrow_forward_ios,
                () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const PaywallScreen(
                        showTrialInfo: true,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          _buildSettingsSection(
            'Bible Settings',
            Icons.menu_book,
            [
              _buildInfoTile('Bible Version', 'WEB'),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          _buildSettingsSection(
            'Appearance',
            Icons.palette,
            [
              _buildSliderTile(
                'Text Size',
                'Adjust text size throughout the app',
                ref.watch(textSizeProvider),
                0.8,
                1.5,
                (value) => ref.read(textSizeProvider.notifier).setTextSize(value),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          _buildSettingsSection(
            'Data & Privacy',
            Icons.security,
            [
              _buildActionTile(
                'Clear Cache',
                'Free up storage space',
                Icons.delete_outline,
                () => _showClearCacheDialog(),
              ),
              _buildActionTile(
                'Export Data',
                'Backup your prayers and notes',
                Icons.download,
                () => _exportUserData(),
              ),
              _buildActionTile(
                'Delete All Data',
                '⚠️ Permanently delete all your data',
                Icons.warning_amber_rounded,
                () => _showDeleteAllDataDialog(),
                isDestructive: true,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          _buildSettingsSection(
            'Support',
            Icons.help,
            [
              _buildActionTile(
                'Help & FAQ',
                'Get answers to common questions',
                Icons.help_outline,
                () => _showHelpDialog(),
              ),
              _buildActionTile(
                'Contact Support',
                'Get help with technical issues',
                Icons.email,
                () => _contactSupport(),
              ),
              _buildActionTile(
                'Rate App',
                'Share your feedback on the App Store',
                Icons.star_outline,
                () => _rateApp(),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          _buildSettingsSection(
            'About',
            Icons.info,
            [
              _buildInfoTile('Version', '1.0.0'),
              _buildActionTile(
                'Privacy Policy',
                'Read our privacy policy',
                Icons.privacy_tip,
                () => _showPrivacyPolicy(),
              ),
              _buildActionTile(
                'Terms of Service',
                'Read terms and conditions',
                Icons.description,
                () => _showTermsOfService(),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(String title, IconData icon, List<Widget> children) {
    return FrostedGlassCard(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  gradient: AppGradients.customColored(
                    AppTheme.primaryColor,
                    startAlpha: 0.3,
                    endAlpha: 0.1,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.xs + 2),
                  border: Border.all(
                    color: AppTheme.primaryColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primaryText,
                  size: ResponsiveUtils.iconSize(context, 20),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                title,
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 18, minSize: 16, maxSize: 20),
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                  shadows: AppTheme.textShadowSubtle,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          ...children,
        ],
      ),
    ).animate().fadeIn(duration: AppAnimations.slow).slideY(begin: 0.3);
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, Function(bool) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.1),
        borderRadius: AppRadius.mediumRadius,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, 13, minSize: 11, maxSize: 15),
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppTheme.primaryColor,
            activeTrackColor: AppTheme.toggleActiveColor.withValues(alpha: 0.5),
            inactiveThumbColor: Colors.white.withValues(alpha: 0.5),
            inactiveTrackColor: Colors.grey.withValues(alpha: 0.3),
            trackOutlineColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppTheme.toggleActiveColor;
              }
              return Colors.grey.withValues(alpha: 0.5);
            }),
            trackOutlineWidth: WidgetStateProperty.all(2.0),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderTile(String title, String subtitle, double value, double min, double max, Function(double) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, 13, minSize: 11, maxSize: 15),
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${(value * 100).round()}%',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.white,
              inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
              thumbColor: Colors.white,
              overlayColor: Colors.white.withValues(alpha: 0.2),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: ((max - min) / 0.1).round(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePicker(String title, String subtitle, String value, Function(String) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showTimePicker(value, onChanged),
          borderRadius: AppRadius.mediumRadius,
          child: Container(
            padding: AppSpacing.cardPadding,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.1),
              borderRadius: AppRadius.mediumRadius,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: AppRadius.smallRadius,
                  ),
                  child: Icon(
                    Icons.access_time,
                    color: AppColors.primaryText,
                    size: ResponsiveUtils.iconSize(context, 20),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: ResponsiveUtils.fontSize(context, 13, minSize: 11, maxSize: 15),
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Text(
                  _formatTimeTo12Hour(value),
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.tertiaryText,
                  size: ResponsiveUtils.iconSize(context, 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTimeTo12Hour(String time24) {
    final parts = time24.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    final period = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final minuteStr = minute.toString().padLeft(2, '0');

    return '$hour12:$minuteStr $period';
  }

  Future<void> _showTimePicker(String currentTime, Function(String) onChanged) async {
    final parts = currentTime.split(':');
    final initialTime = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );

    // Custom glassmorphic time picker style matching app theme components
    final customStyle = TimeRangeSheetStyle(
      // Match GlassBottomSheet - transparent background (blur from wrapper)
      sheetBackgroundColor: Colors.transparent,

      // Button styling matching GlassButton component
      buttonColor: Colors.transparent, // GlassButton uses gradient, not solid color
      cancelButtonColor: Colors.transparent,
      buttonTextColor: Colors.white,
      cancelButtonTextColor: Colors.white.withValues(alpha: 0.7),

      // Text colors for visibility
      labelTextColor: Colors.white.withValues(alpha: 0.9),
      selectedTimeTextColor: Colors.white,
      pickerTextColor: Colors.white.withValues(alpha: 0.3),
      selectedPickerTextColor: Colors.white,

      // Corner radius matching GlassButton (28) and GlassBottomSheet (24)
      cornerRadius: 24, // Sheet corner radius
      buttonCornerRadius: 28, // Button corner radius like GlassButton

      // Sheet dimensions
      sheetHeight: 450,
      pickerItemHeight: 45,
      buttonHeight: 56, // Match GlassButton height

      // Padding and spacing
      padding: const EdgeInsets.all(AppSpacing.lg),
      buttonPadding: const EdgeInsets.all(AppSpacing.md),

      // Use 12-hour format to match display
      use24HourFormat: false,

      // Custom button text
      confirmButtonText: 'Set Time',
      cancelButtonText: 'Cancel',

      // Enable haptic feedback
      enableHapticFeedback: true,
    );

    final result = await showTimeRangeSheet(
      context: context,
      initialStartTime: initialTime,
      style: customStyle,
      singlePicker: true,
      allowInvalidRange: true,
    );

    if (result != null) {
      final picked = result.startTime; // In single picker mode, use startTime
      final hour = picked.hour.toString().padLeft(2, '0');
      final minute = picked.minute.toString().padLeft(2, '0');
      onChanged('$hour:$minute');
    }
  }

  Widget _buildActionTile(String title, String subtitle, IconData icon, VoidCallback onTap, {bool isDestructive = false}) {
    const textColor = AppColors.primaryText;
    final subtitleColor = Colors.white.withValues(alpha: 0.7);
    final iconColor = isDestructive ? Colors.red : AppColors.primaryText;
    final borderColor = isDestructive ? Colors.red.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.1);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.mediumRadius,
          child: Container(
            padding: AppSpacing.cardPadding,
            decoration: BoxDecoration(
              color: isDestructive
                  ? Colors.red.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.1),
              borderRadius: AppRadius.mediumRadius,
              border: Border.all(
                color: borderColor,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: isDestructive
                        ? Colors.red.withValues(alpha: 0.1)
                        : Colors.white.withValues(alpha: 0.1),
                    borderRadius: AppRadius.smallRadius,
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: ResponsiveUtils.iconSize(context, 20),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: ResponsiveUtils.fontSize(context, 13, minSize: 11, maxSize: 15),
                          color: subtitleColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: isDestructive
                      ? Colors.red.withValues(alpha: 0.5)
                      : Colors.white.withValues(alpha: 0.5),
                  size: ResponsiveUtils.iconSize(context, 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.1),
        borderRadius: AppRadius.mediumRadius,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
              fontWeight: FontWeight.w600,
              color: AppColors.primaryText,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 15, minSize: 13, maxSize: 17),
              color: AppColors.secondaryText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }


  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: ResponsiveUtils.maxContentWidth(context),
          ),
          child: FrostedGlassCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryColor.withValues(alpha: 0.3),
                            AppTheme.primaryColor.withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.xs + 2),
                        border: Border.all(
                          color: AppTheme.primaryColor.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.cleaning_services,
                        color: AppColors.primaryText,
                        size: ResponsiveUtils.iconSize(context, 20),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      'Clear Cache',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, 20, minSize: 18, maxSize: 24),
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'This will free up storage space but may require re-downloading some content.',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, 13, minSize: 11, maxSize: 15),
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => NavigationService.pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.md,
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    TextButton(
                      onPressed: () async {
                        NavigationService.pop();
                        await _clearCache();
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.md,
                        ),
                        backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                      ),
                      child: Text(
                        'Clear',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _clearCache() async {
    try {
      // Clear Flutter image cache
      imageCache.clear();
      imageCache.clearLiveImages();

      // Clear temporary directory
      final tempDir = await getTemporaryDirectory();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
        await tempDir.create();
      }

      // Clear app cache directory (does not delete user data/database)
      try {
        final cacheDir = await getApplicationCacheDirectory();
        if (await cacheDir.exists()) {
          await cacheDir.delete(recursive: true);
          await cacheDir.create();
        }
      } catch (e) {
        debugPrint('Could not clear cache directory: $e');
      }

      _showSnackBar('✅ Cache cleared successfully');
    } catch (e) {
      _showSnackBar('❌ Failed to clear cache: $e');
    }
  }

  Future<void> _exportUserData() async {
    try {
      final buffer = StringBuffer();
      buffer.writeln('=' * 60);
      buffer.writeln('EVERYDAY CHRISTIAN - DATA EXPORT');
      buffer.writeln('Export Date: ${DateTime.now().toString()}');
      buffer.writeln('=' * 60);
      buffer.writeln();

      // Export Prayer Journal
      final prayerService = ref.read(prayerServiceProvider);
      final prayerExport = await prayerService.exportPrayerJournal();

      if (prayerExport.isNotEmpty) {
        buffer.writeln('📿 PRAYER JOURNAL');
        buffer.writeln('=' * 60);
        buffer.writeln(prayerExport);
        buffer.writeln();
      }

      // Export AI Chat Conversations
      final conversationService = ConversationService();
      final sessions = await conversationService.getSessions(includeArchived: true);

      if (sessions.isNotEmpty) {
        buffer.writeln('💬 AI CHAT CONVERSATIONS');
        buffer.writeln('=' * 60);
        buffer.writeln('Total Sessions: ${sessions.length}');
        buffer.writeln();

        for (final session in sessions) {
          final sessionId = session['id'] as String;
          final title = session['title'] as String;
          final isArchived = session['is_archived'] == 1;

          final conversationExport = await conversationService.exportConversation(sessionId);

          if (conversationExport.isNotEmpty) {
            buffer.writeln('-' * 60);
            buffer.writeln('Session: $title ${isArchived ? "(Archived)" : ""}');
            buffer.writeln('-' * 60);
            buffer.writeln(conversationExport);
            buffer.writeln();
          }
        }
      }

      final exportText = buffer.toString();

      if (exportText.isEmpty || exportText.length < 200) {
        _showSnackBar('No data to export');
        return;
      }

      await SharePlus.instance.share(
        ShareParams(
          text: exportText,
          subject: 'Everyday Christian - Data Export',
        ),
      );

      final prayerCount = prayerExport.isNotEmpty ? 1 : 0;
      final chatCount = sessions.length;
      _showSnackBar('📤 Exported $prayerCount prayer journal${prayerCount != 1 ? 's' : ''} and $chatCount conversation${chatCount != 1 ? 's' : ''}');
    } catch (e) {
      _showSnackBar('Failed to export: $e');
    }
  }

  void _showDeleteAllDataDialog() {
    final confirmController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
            maxWidth: ResponsiveUtils.maxContentWidth(context),
          ),
          child: FrostedGlassCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.red.withValues(alpha: 0.3),
                            Colors.red.withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.xs + 2),
                        border: Border.all(
                          color: Colors.red.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.red,
                        size: ResponsiveUtils.iconSize(context, 20),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      'Delete All Data',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, 20, minSize: 18, maxSize: 24),
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  '⚠️ THIS ACTION CANNOT BE UNDONE ⚠️',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Scrollable Content
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'This will permanently delete:',
                          style: TextStyle(
                            fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _buildDeleteItem('✝️ All prayer journal entries'),
                        _buildDeleteItem('💬 All AI chat conversations'),
                        _buildDeleteItem('📖 Reading plan progress'),
                        _buildDeleteItem('🌟 Favorite verses'),
                        _buildDeleteItem('📝 Devotional completion history'),
                        _buildDeleteItem('⚙️ All app settings and preferences'),
                        _buildDeleteItem('👤 Profile picture'),
                        _buildDeleteItem('📊 All statistics and progress'),
                        const SizedBox(height: AppSpacing.lg),
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '⚠️ This will delete all local data including:',
                                style: TextStyle(
                                  fontSize: ResponsiveUtils.fontSize(context, 13, minSize: 11, maxSize: 15),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                '• Prayer journal entries\n• Chat history\n• Saved verses\n• Settings and preferences',
                                style: TextStyle(
                                  fontSize: ResponsiveUtils.fontSize(context, 12, minSize: 10, maxSize: 14),
                                  color: Colors.white.withValues(alpha: 0.9),
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Container(
                                padding: const EdgeInsets.all(AppSpacing.sm),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(AppRadius.xs),
                                  border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      size: 16,
                                      color: Colors.blue.withValues(alpha: 0.9),
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    Expanded(
                                      child: Text(
                                        'Your subscription will remain active and will be automatically restored on next app launch.',
                                        style: TextStyle(
                                          fontSize: ResponsiveUtils.fontSize(context, 11, minSize: 9, maxSize: 13),
                                          color: Colors.white.withValues(alpha: 0.9),
                                          height: 1.3,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          'Type DELETE to confirm:',
                          style: TextStyle(
                            fontSize: ResponsiveUtils.fontSize(context, 13, minSize: 11, maxSize: 15),
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        TextField(
                          controller: confirmController,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                          ),
                          decoration: InputDecoration(
                            hintText: 'Type DELETE',
                            hintStyle: TextStyle(
                              color: Colors.white.withValues(alpha: 0.3),
                              fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.red, width: 2),
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                            contentPadding: const EdgeInsets.all(AppSpacing.md),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        confirmController.dispose();
                        NavigationService.pop();
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.md,
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    TextButton(
                      onPressed: () async {
                        if (confirmController.text.trim() == 'DELETE') {
                          confirmController.dispose();
                          NavigationService.pop();
                          await _deleteAllData();
                        } else {
                          _showSnackBar('❌ You must type DELETE to confirm');
                        }
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.md,
                        ),
                        backgroundColor: Colors.red.withValues(alpha: 0.2),
                      ),
                      child: Text(
                        'Delete Everything',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 6),
      child: Row(
        children: [
          const Icon(Icons.close, color: Colors.red, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAllData() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          child: FrostedGlassCard(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Text(
                    'Deleting all data...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // 1. Reset database (clears all prayer, chat, favorites, reading plans, etc.)
      final dbService = DatabaseService();
      await dbService.resetDatabase();

      // 2. Clear SharedPreferences (all app settings)
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // 3. Clear all cache
      try {
        imageCache.clear();
        imageCache.clearLiveImages();
        final tempDir = await getTemporaryDirectory();
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
          await tempDir.create();
        }
        final cacheDir = await getApplicationCacheDirectory();
        if (await cacheDir.exists()) {
          await cacheDir.delete(recursive: true);
          await cacheDir.create();
        }
      } catch (e) {
        debugPrint('Cache clearing failed: $e');
      }

      // Close loading dialog
      if (mounted) {
        NavigationService.pop();
      }

      // Show success message
      _showSnackBar('✅ All data deleted. App will restart.');

      // Wait a moment then exit the app (user needs to restart)
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        // Reset the app state by navigating to home
        NavigationService.goToHome();
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) {
        NavigationService.pop();
      }
      _showSnackBar('❌ Failed to delete data: $e');
    }
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
            maxWidth: ResponsiveUtils.maxContentWidth(context),
          ),
          child: FrostedGlassCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryColor.withValues(alpha: 0.3),
                            AppTheme.primaryColor.withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.xs + 2),
                        border: Border.all(
                          color: AppTheme.primaryColor.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.help_outline,
                        color: AppColors.primaryText,
                        size: ResponsiveUtils.iconSize(context, 20),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      'Help & FAQ',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, 20, minSize: 18, maxSize: 24),
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Find answers to common questions',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, 13, minSize: 11, maxSize: 15),
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Scrollable FAQ List
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildFAQSection('Getting Started', [
                          _FAQItem(
                            question: 'How do I get started?',
                            answer: 'Welcome! Start by exploring the Home screen where you\'ll find daily devotionals, verse of the day, and quick access to prayer and Bible reading. Navigate using the menu in the top left corner.',
                          ),
                          _FAQItem(
                            question: 'Is the app free to use?',
                            answer: 'Yes! Everyday Christian offers a free trial with daily message limits for AI chat. Upgrade to Premium for unlimited AI conversations and full access to all features.',
                          ),
                          _FAQItem(
                            question: 'Which Bible version is used?',
                            answer: 'The app uses the World English Bible (WEB), a modern public domain translation that\'s faithful to the original texts and easy to read.',
                          ),
                        ]),
                        const SizedBox(height: AppSpacing.lg),

                        _buildFAQSection('Bible Reading', [
                          _FAQItem(
                            question: 'Can I read the Bible offline?',
                            answer: 'Yes! The entire Bible is downloaded when you first install the app. You can read all 66 books, chapters, and verses without an internet connection.',
                          ),
                          _FAQItem(
                            question: 'How do I search for verses?',
                            answer: 'Navigate to the Bible section from the home menu. Use the search bar to find verses by keywords, or browse by book, chapter, and verse.',
                          ),
                          _FAQItem(
                            question: 'Can I change the Bible version?',
                            answer: 'The World English Bible (WEB) is currently the only version available. This ensures consistent offline access and optimal performance.',
                          ),
                        ]),
                        const SizedBox(height: AppSpacing.lg),

                        _buildFAQSection('Prayer Journal', [
                          _FAQItem(
                            question: 'How do I add a prayer?',
                            answer: 'Open the Prayer Journal from the home menu and tap the floating + button. Enter your prayer title, description, and choose a category (Personal, Family, Health, etc.), then save.',
                          ),
                          _FAQItem(
                            question: 'Can I mark prayers as answered?',
                            answer: 'Yes! Open any prayer and tap "Mark as Answered". You can add a description of how God answered your prayer. View all answered prayers in the "Answered" tab.',
                          ),
                          _FAQItem(
                            question: 'How do I export my prayer journal?',
                            answer: 'Go to Settings > Data & Privacy > Export Data. This creates a formatted text file containing all your prayers (both active and answered) that you can save or share.',
                          ),
                          _FAQItem(
                            question: 'Can I organize prayers by category?',
                            answer: 'Yes! Each prayer can be assigned to a category. Use the category filter at the top of the Prayer Journal to view prayers by specific categories.',
                          ),
                        ]),
                        const SizedBox(height: AppSpacing.lg),

                        _buildFAQSection('Devotionals & Reading Plans', [
                          _FAQItem(
                            question: 'Where can I find daily devotionals?',
                            answer: 'Daily devotionals appear on your Home screen. You can mark devotionals as completed to track your progress and build your devotional streak.',
                          ),
                          _FAQItem(
                            question: 'How do reading plans work?',
                            answer: 'Choose a reading plan from the Reading Plans section. Tap "Start Plan" to begin. The app tracks your progress as you complete daily readings. Only one plan can be active at a time.',
                          ),
                          _FAQItem(
                            question: 'Can I track my devotional streak?',
                            answer: 'Yes! The app automatically tracks how many consecutive days you\'ve completed devotionals. View your current streak on your Profile screen.',
                          ),
                        ]),
                        const SizedBox(height: AppSpacing.lg),

                        _buildFAQSection('AI Chat & Support', [
                          _FAQItem(
                            question: 'What can I ask the AI?',
                            answer: 'You can ask about Scripture interpretation, prayer requests, life challenges, faith questions, and daily encouragement. The AI provides biblically-grounded guidance and support.',
                          ),
                          _FAQItem(
                            question: 'How many messages can I send?',
                            answer: 'Free users have a daily message limit. Premium subscribers get unlimited messages. Check Settings > Subscription to see your current plan and remaining messages.',
                          ),
                          _FAQItem(
                            question: 'Are my conversations saved?',
                            answer: 'Yes! All your AI conversations are saved to your device. Each chat creates a new session that you can access from the conversation history.',
                          ),
                        ]),
                        const SizedBox(height: AppSpacing.lg),

                        _buildFAQSection('Notifications', [
                          _FAQItem(
                            question: 'How do I change notification times?',
                            answer: 'Go to Settings > Notifications > Notification Time. Select your preferred time for daily reminders.',
                          ),
                          _FAQItem(
                            question: 'Can I turn off specific notifications?',
                            answer: 'Yes! In Settings > Notifications, you can toggle each notification type (Daily Devotional, Prayer Reminders, Verse of the Day) independently.',
                          ),
                          _FAQItem(
                            question: 'Why aren\'t I receiving notifications?',
                            answer: 'Check your device settings to ensure notifications are enabled for Everyday Christian. Also verify that each notification type is enabled in Settings > Notifications.',
                          ),
                        ]),
                        const SizedBox(height: AppSpacing.lg),

                        _buildFAQSection('Settings & Customization', [
                          _FAQItem(
                            question: 'How do I adjust text size?',
                            answer: 'Go to Settings > Appearance > Text Size. Use the slider to adjust text size throughout the app from 80% to 150% of normal size.',
                          ),
                          _FAQItem(
                            question: 'Can I add a profile picture?',
                            answer: 'Yes! Tap your profile avatar in Settings or on your Profile screen. Choose to take a photo or select one from your gallery.',
                          ),
                          _FAQItem(
                            question: 'What does offline mode do?',
                            answer: 'Offline mode allows you to use core features (Bible reading, viewing saved prayers and devotionals) without an internet connection. AI chat requires internet.',
                          ),
                        ]),
                        const SizedBox(height: AppSpacing.lg),

                        _buildFAQSection('Data & Privacy', [
                          _FAQItem(
                            question: 'Is my data private and secure?',
                            answer: 'Yes! Your prayers, notes, and personal data are stored securely on your device. We never sell your information to third parties.',
                          ),
                          _FAQItem(
                            question: 'What data is stored on my device?',
                            answer: 'The Bible content, your prayers, conversation history, reading plan progress, devotional completion records, and app preferences are all stored locally.',
                          ),
                          _FAQItem(
                            question: 'What\'s the difference between Clear Cache and Delete All Data?',
                            answer: 'Clear Cache removes temporary files (image cache, temp directories) to free up storage space. Your prayers, settings, and all personal data remain safe. Delete All Data permanently erases everything including prayers, conversations, settings, and resets the app to factory defaults.',
                          ),
                          _FAQItem(
                            question: 'How do I clear cached data?',
                            answer: 'Go to Settings > Data & Privacy > Clear Cache. This removes temporary files and image cache to free up storage space. Your prayers, conversations, and personal data are NOT deleted - only temporary cache files are removed.',
                          ),
                          _FAQItem(
                            question: 'How do I delete all my data?',
                            answer: 'Go to Settings > Data & Privacy > Delete All Data. You\'ll be asked to type "DELETE" to confirm. This permanently erases all prayers, conversations, reading plans, favorites, settings, and profile picture. Export your prayer journal first if you want to keep a backup. This action cannot be undone.',
                          ),
                        ]),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Close Button
                GlassButton(
                  text: 'Close',
                  height: 48,
                  onPressed: () => NavigationService.pop(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFAQSection(String title, List<_FAQItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
              fontWeight: FontWeight.w700,
              color: AppTheme.goldColor,
            ),
          ),
        ),
        ...items.map((item) => _buildFAQTile(item.question, item.answer)),
      ],
    );
  }

  Widget _buildFAQTile(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: AppRadius.mediumRadius,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: AppSpacing.cardPadding,
          childrenPadding: const EdgeInsets.only(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            bottom: AppSpacing.md,
          ),
          title: Text(
            question,
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
              fontWeight: FontWeight.w600,
              color: AppColors.primaryText,
            ),
          ),
          iconColor: AppColors.primaryText,
          collapsedIconColor: Colors.white.withValues(alpha: 0.5),
          children: [
            Text(
              answer,
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(context, 13, minSize: 11, maxSize: 15),
                color: Colors.white.withValues(alpha: 0.8),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _contactSupport() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'connect@everydaychristian.app',
      queryParameters: {
        'subject': 'Everyday Christian Support Request',
        'body': 'Please describe your issue or question:\n\n',
      },
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        if (mounted) {
          _showSnackBar('Could not open email client. Please email connect@everydaychristian.app');
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error opening email: Please email connect@everydaychristian.app');
      }
    }
  }

  void _rateApp() {
    _showSnackBar('Opening App Store...');
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
            maxWidth: ResponsiveUtils.maxContentWidth(context),
          ),
          child: FrostedGlassCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryColor.withValues(alpha: 0.3),
                            AppTheme.primaryColor.withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.xs + 2),
                        border: Border.all(
                          color: AppTheme.primaryColor.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.privacy_tip_outlined,
                        color: AppColors.primaryText,
                        size: ResponsiveUtils.iconSize(context, 20),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      'Privacy Policy',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, 20, minSize: 18, maxSize: 24),
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Last Updated: October 15, 2025',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, 12, minSize: 10, maxSize: 14),
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Scrollable Privacy Policy Content
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.2),
                      borderRadius: AppRadius.mediumRadius,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: AppSpacing.cardPadding,
                      child: _buildPrivacyPolicyContent(),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Close Button
                GlassButton(
                  text: 'Close',
                  height: 48,
                  onPressed: () => NavigationService.pop(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrivacyPolicyContent() {
    return SelectableText.rich(
      TextSpan(
        style: TextStyle(
          fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
          color: AppColors.primaryText,
          height: 1.6,
        ),
        children: [
              TextSpan(
                text: 'EVERYDAY CHRISTIAN - PRIVACY POLICY\n',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 18, minSize: 16, maxSize: 22),
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryColor,
                ),
              ),
              const TextSpan(text: '\n'),
              TextSpan(
                text: 'Last Updated: October 15, 2025\n',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
              TextSpan(
                text: 'Effective Date: October 15, 2025\n',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
              const TextSpan(text: '\n'),
              TextSpan(
                text: '\n1. Introduction\n',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryColor,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(text: 'Welcome to Everyday Christian ("we," "our," "us," or the "App"). We are deeply committed to your privacy and have built this application on a '),
                  TextSpan(
                    text: 'privacy-first foundation',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: '. This Privacy Policy explains our data practices for the Everyday Christian mobile application.'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(text: 'Everyday Christian is a faith-centered mobile app that provides:\n'),
              const TextSpan(text: '  - AI-powered pastoral guidance using Google Gemini 2.0 Flash (Premium feature)\n'),
              const TextSpan(text: '  - Daily Bible verses and devotionals\n'),
              const TextSpan(text: '  - Personal prayer journal\n'),
              const TextSpan(text: '  - Comprehensive verse library (31,103 verses from the World English Bible)\n'),
              const TextSpan(text: '  - Bible reading plans\n'),
              const TextSpan(text: '  - Crisis intervention resources\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Our Privacy-First Commitment:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '  - NO user accounts required - use the app completely anonymously\n'),
              const TextSpan(text: '  - NO personal information collection - we don\'t ask for names, emails, or phone numbers\n'),
              const TextSpan(text: '  - NO location tracking - we never access your GPS or location data\n'),
              const TextSpan(text: '  - NO third-party analytics or tracking - we don\'t use Google Analytics, Facebook Pixel, or similar tracking services\n'),
              const TextSpan(text: '  - NO advertising networks - we don\'t integrate ad networks or sell ad space\n'),
              const TextSpan(text: '  - NO data monetization - we never sell or rent your information\n'),
              const TextSpan(text: '  - Local-first storage - all your data stays on your device using secure SQLite database\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'By using Everyday Christian, you agree to the collection and use of information in accordance with this Privacy Policy. If you do not agree, please do not use the App.',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              TextSpan(
                text: '\n2. Information We Collect\n',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryColor,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n2.1 Information Stored Locally on Your Device\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(text: 'All of the following data is stored '),
                  TextSpan(
                    text: 'exclusively on your device',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ' using SQLite database technology protected by your device\'s security and '),
                  TextSpan(
                    text: 'never leaves your device',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ' except when using the Premium AI chat feature:'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Prayer Journal Entries',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': Your personal prayers, prayer requests, prayer categories, and reflections that you choose to save. Includes prayer status (answered, pending, ongoing), timestamps, and optional notes.'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Favorite Verses',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': Bible verses you mark as favorites for quick access, including verse text, biblical reference, personal notes, tags, and date added.'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Reading History',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': Which Bible chapters and verses you\'ve read to track your reading progress through the 31,103 verses in the World English Bible translation.'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Reading Plan Progress',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': Your progress through selected Bible reading plans, including completion dates and chapter tracking.'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Verse Bookmarks',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': Bookmarked verses with personal notes, tags, creation timestamps, and last updated timestamps.'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'AI Chat History',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ' (Premium users only): Conversations with the AI pastoral guidance system, stored locally on your device with session IDs, message timestamps, and conversation metadata.'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Daily Verses',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': Track which daily verses have been delivered to you, whether you\'ve opened them, and whether notifications were sent.'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'App Settings',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': Your preferences including theme selection, text size, notification preferences, font size for Bible reader, biometric authentication preferences, and other customization options stored in a local settings table.'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Devotional Progress',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': Which daily devotionals you\'ve completed and when.'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n2.2 Information We Do NOT Collect\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(text: 'We have intentionally designed Everyday Christian to respect your privacy by '),
                  TextSpan(
                    text: 'NOT',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ' collecting:'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(text: '  - ❌ Personal identification (name, email, phone number)\n'),
              const TextSpan(text: '  - ❌ User accounts or login credentials\n'),
              const TextSpan(text: '  - ❌ Location data or GPS coordinates\n'),
              const TextSpan(text: '  - ❌ Device tracking identifiers for advertising\n'),
              const TextSpan(text: '  - ❌ Behavioral analytics or usage tracking\n'),
              const TextSpan(text: '  - ❌ Contacts, photos, or other device data\n'),
              const TextSpan(text: '  - ❌ Payment information (handled by Apple/Google payment systems)\n'),
              const TextSpan(text: '  - ❌ Social media connections or profiles\n'),
              const TextSpan(text: '  - ❌ IP addresses or network information\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n2.3 Third-Party Service: Google Gemini API\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Premium AI Chat Feature Only',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': When you use the Premium AI pastoral guidance feature (150 messages/month, approximately \$35/year subscription, pricing varies by region), your chat messages are sent to Google\'s Gemini 2.0 Flash API to generate biblically-grounded responses.'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Important details:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '  - Anonymous requests: We do not include your name, email, device ID, or any personal identifiers when sending messages to Google\n'),
              const TextSpan(text: '  - Session-based context: Within a single conversation session, recent message history is included with each request to maintain conversational context (e.g., "you mentioned earlier..."). This allows the AI to provide coherent, contextual guidance.\n'),
              const TextSpan(text: '  - No cross-session tracking: Unlike chat services with user accounts (like ChatGPT), we cannot and do not track your conversations across different sessions. Each new conversation you start on a different day appears as a completely separate, anonymous interaction. Even if you have 100 conversations over a year, there is no technical way for Google or us to link them together or build a long-term profile of you.\n'),
              const TextSpan(text: '  - Trained AI model: Our system includes pastoral training examples based on authentic biblical counseling to guide appropriate Christian responses\n'),
              const TextSpan(text: '  - Google\'s data use: Google processes your message text according to their API terms and may use it to improve their services. See Google\'s Generative AI Prohibited Use Policy: https://policies.google.com/terms/generative-ai/use-policy\n'),
              const TextSpan(text: '  - Content filtering: AI-generated responses are automatically filtered for harmful theology patterns including prosperity gospel, spiritual bypassing, toxic positivity, legalism, hate speech, and inappropriate medical advice. Filtered responses are replaced with safe, scripture-based alternatives.\n'),
              const TextSpan(text: '  - Crisis detection: User messages containing crisis keywords (suicide, self-harm, abuse) trigger immediate intervention with professional resources including the 988 Suicide & Crisis Lifeline\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Free tier users',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': If you don\'t subscribe to Premium, you can use all other app features without any data leaving your device.'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              TextSpan(
                text: '\n3. How We Use Your Information\n',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryColor,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n3.1 Local Data Usage (On Your Device)\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: 'The data stored locally on your device is used to:\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Provide Core Features',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': Display your prayer journal, favorite verses, reading history, and AI chat conversations within the app'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Personalize Your Experience',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': Remember your settings, track reading progress, and suggest relevant reading plans based on your history'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Maintain Reading Streaks',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': Track daily devotional completion and reading plan adherence'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Secure Your Data',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': Enable biometric authentication (Face ID, Touch ID, fingerprint) to protect your personal spiritual content if you choose to enable this feature'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'No external transmission',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': This local data is never sent to our servers or any third party'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n3.2 Third-Party Data Processing (Google Gemini API - Premium Only)\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: 'When you use the Premium AI chat feature:\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Generate Pastoral Responses',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': Your message text is sent anonymously to Google Gemini API to generate biblically-grounded guidance with scripture references'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Crisis Intervention',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': Messages containing crisis indicators trigger safety protocols, though the detection happens locally on your device before any API call'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Content Moderation',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': Messages are filtered locally for policy violations (prosperity gospel, hate speech) before being processed'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Google\'s Use',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': Google may use your message text according to their Generative AI terms to improve their API services'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n3.3 Subscription Management\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Payment Processing',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': Handled entirely by Apple App Store or Google Play Store payment systems. We never see or store your payment information.'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Subscription Status',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': Your device communicates with Apple/Google servers to verify your Premium subscription status, but we do not receive personal identifying information from these transactions.'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n3.4 Security Lockout System\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Content Policy Enforcement',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': If you enter an incorrect pastoral guidance PIN or violate our content policies (hate speech, prosperity gospel, harassment), the app implements a privacy-first security system:'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '  - 3 incorrect attempts = 30-minute temporary lockout\n'),
              const TextSpan(text: '  - Device authentication bypass: You can immediately bypass the lockout using your device\'s built-in authentication (PIN, fingerprint, or Face ID)\n'),
              const TextSpan(text: '  - Privacy-preserving: We do not see, store, or have access to your device authentication credentials - this is handled entirely by your device\'s operating system\n'),
              const TextSpan(text: '  - Local-only data: Only two integers are stored locally (attempt counter and lockout timestamp) - no accounts, usernames, or personal identifiers\n'),
              const TextSpan(text: '  - Other app features (Bible reading, prayer journal, etc.) remain accessible during lockout\n'),
              const TextSpan(text: '  - Zero data transmission: No authentication data ever leaves your device\n'),
              const TextSpan(text: '\n'),
              TextSpan(
                text: '\n4. Data Storage and Security\n',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryColor,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n4.1 Local Storage Architecture\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'All personal data',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ' - including prayer journal entries, AI chat history, favorite verses, reading history, and app settings - is stored '),
                  TextSpan(
                    text: 'exclusively on your device',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ' using:'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'SQLite Database',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': Secure local database technology that stores your data in the app\'s protected storage area, safeguarded by your device\'s built-in security'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Biometric Security (Optional)',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': You can enable Face ID, Touch ID, or fingerprint authentication to add an additional security layer before accessing sensitive features'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'No Cloud Storage',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': We do not sync your data to any cloud service, external server, or backup system. Your spiritual journey remains private on your device.'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'App Sandbox',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': The data is isolated within the app\'s secure container and cannot be accessed by other apps on your device'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n4.2 Data Security Measures\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: 'We implement industry-standard security practices:\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Secure Coding Standards',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': Development follows OWASP Mobile Security Guidelines to prevent common vulnerabilities'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Device-Level Protection',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': All app data is protected by your device\'s built-in security features, including full-disk encryption available on modern iOS and Android devices'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Secure API Communication',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': When using Premium AI chat, messages are transmitted to Google Gemini API over TLS/SSL encrypted connections'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'No User Credentials',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': Since we don\'t use accounts, there are no passwords to be compromised'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Regular Security Reviews',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': We conduct periodic security audits of our codebase and data handling'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Crisis Content Handling',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': Crisis detection keywords are processed locally on your device and never logged or transmitted'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Important',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': No system is 100% secure. While we implement strong protections, you should be aware that any data stored on your device could potentially be accessed if your device is compromised, lost, or stolen. We recommend:'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '  - Using device-level passcode/biometric protection\n'),
              const TextSpan(text: '  - Enabling app-level biometric authentication in Settings\n'),
              const TextSpan(text: '  - Being cautious about device sharing\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n4.3 Device Backups\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'iCloud Backup (iOS)',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': If you enable iCloud backup on your iOS device, your locally stored app data (including prayer journal and chat history) may be included in your iCloud backups. This is controlled by Apple\'s backup settings and governed by Apple\'s Privacy Policy.'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Google Drive Backup (Android)',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': If you enable Android device backup, app data may be included in your Google Drive backups per Google\'s Privacy Policy.'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'To exclude Everyday Christian from backups',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ':'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '  - iOS: Settings > [Your Name] > iCloud > Manage Storage > Backups > [Device] > Toggle off Everyday Christian\n'),
              const TextSpan(text: '  - Android: Settings > Google > Backup > Toggle off app data for Everyday Christian\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'We recommend',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': If you have particularly sensitive spiritual content, consider disabling app backups for Everyday Christian and manually clearing data before device transfers.'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              TextSpan(
                text: '\n5. Data Sharing and Disclosure\n',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryColor,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n5.1 We Do Not Sell Your Data\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'We categorically do not and will never:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '  - Sell your personal information to third parties\n'),
              const TextSpan(text: '  - Rent or lease your data to advertisers or marketers\n'),
              const TextSpan(text: '  - Share your data with data brokers\n'),
              const TextSpan(text: '  - Use your spiritual content for advertising purposes\n'),
              const TextSpan(text: '  - Monetize your prayers, Bible reading, or chat conversations\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'We have no business model based on data monetization.',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ' Our only revenue comes from optional Premium subscriptions (~\$35/year).'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n5.2 Third-Party Data Sharing\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Google Gemini API (Premium AI Chat Only)',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ':'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '  - What is shared: Your message text only (when you send an AI chat message)\n'),
              const TextSpan(text: '  - What is NOT shared: Your name, email, device ID, location, or any identifiers\n'),
              const TextSpan(text: '  - Purpose: To generate AI-powered pastoral guidance responses\n'),
              const TextSpan(text: '  - Google\'s use: Google may use message text to improve their AI services per their terms\n'),
              const TextSpan(text: '  - User control: Don\'t subscribe to Premium if you prefer zero third-party data sharing\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Apple App Store / Google Play Store',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ':'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '  - What is shared: Subscription purchase information (handled by Apple/Google)\n'),
              const TextSpan(text: '  - Purpose: Process Premium subscription payments and verify subscription status\n'),
              const TextSpan(text: '  - Our access: We receive only anonymous subscription validation; we do not see your payment details or personal information\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'NO other third-party services',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ' access your data. We do not use:'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '  - Analytics platforms (e.g., Google Analytics, Mixpanel)\n'),
              const TextSpan(text: '  - Advertising networks\n'),
              const TextSpan(text: '  - Crash reporting services with personal data\n'),
              const TextSpan(text: '  - Cloud storage providers\n'),
              const TextSpan(text: '  - Social media integrations\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n5.3 Legal Requirements and Safety\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'We may disclose information when required by law or to prevent harm:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Legal Obligations',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': We will comply with valid subpoenas, court orders, or legal processes. Since nearly all data is stored locally on your device, we have very limited information to provide to authorities.'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Crisis Intervention',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': If we implement server-side crisis detection in the future, we may report imminent threats of self-harm or harm to others to appropriate authorities. Currently, crisis detection is local and provides resources only.'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Child Safety',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': We will report suspected child abuse or endangerment to the National Center for Missing & Exploited Children (NCMEC) or appropriate authorities as required by law.'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Since we don\'t collect user identification information, our ability to respond to legal requests is inherently limited to aggregated, anonymous data.',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n5.4 Business Transfers\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: 'If Everyday Christian is acquired, merged, or sells assets:\n'),
              const TextSpan(text: '  - You will be notified via app update or email (if we have it)\n'),
              const TextSpan(text: '  - This Privacy Policy will continue to apply to your data\n'),
              const TextSpan(text: '  - You will have the option to delete your data before any transfer\n'),
              const TextSpan(text: '  - The acquiring party must honor these privacy commitments or obtain your explicit consent for changes\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n5.5 Data We CANNOT Share (Because We Don\'t Have It)\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: 'Since all data is stored locally on your device, we cannot:\n'),
              const TextSpan(text: '  - Provide your prayer journal to third parties\n'),
              const TextSpan(text: '  - Access your AI chat history\n'),
              const TextSpan(text: '  - See your Bible reading patterns\n'),
              const TextSpan(text: '  - Recover your data if you lose your device\n'),
              const TextSpan(text: '  - Transfer your data to a new device (unless you use device-level backups)\n'),
              const TextSpan(text: '\n'),
              TextSpan(
                text: '\n6. Sensitive Personal Information & Religious Data\n',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryColor,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(text: 'We recognize that Everyday Christian inherently processes '),
                  TextSpan(
                    text: 'sensitive personal information',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ' under various privacy laws:'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n6.1 Types of Sensitive Data\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Religious Beliefs',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': Your use of Bible reading, prayers, and AI pastoral guidance reveals your Christian faith'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Emotional and Mental Health',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': Questions about anxiety, depression, grief, anger, or other struggles shared in AI chat'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Personal Circumstances',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': Information about relationships, family matters, financial struggles, or life challenges mentioned in prayers or chat'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Crisis Content',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': Messages containing references to suicide, self-harm, abuse, or trauma'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n6.2 Special Protections for Sensitive Data\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Local Storage',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': All sensitive data remains on your device, minimizing exposure risk'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Anonymous API Calls',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': When using Premium AI chat, your messages are sent to Google without your identity'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'No Profiling',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': We do not build profiles of your religious practices, mental health patterns, or personal struggles'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'No Cross-App Tracking',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': We do not share data with other apps or use it for targeted advertising'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Biometric Protection',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': You can enable additional security layers to protect access to sensitive content'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Crisis Intervention',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': Crisis content triggers local safety resources without logging or transmitting the specific content'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n6.3 Legal Basis for Processing (GDPR Compliance)\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: 'For users in the European Union or European Economic Area, our legal basis for processing religious and sensitive data is:\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Explicit Consent',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ' (GDPR Article 9(2)(a)): By installing the app and using its features, you provide explicit consent to process religious data locally on your device and (for Premium users) send chat messages to Google Gemini API'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Manifest Public Interest',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': Religious data processing for spiritual guidance purposes where you have made it publicly manifest through voluntary use'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'You can withdraw consent at any time',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ' by uninstalling the app or ceasing to use specific features (e.g., Premium AI chat)'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n6.4 Additional Safeguards\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'No Minors Under 13',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': We do not knowingly collect sensitive religious data from children under 13 without parental consent (see Section 7)'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Crisis Detection Protocols',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': Automated detection of crisis content triggers professional resource recommendations'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Content Policy Enforcement',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': Hate speech, abuse, and harmful content result in warnings and potential feature lockouts to protect the community'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'No Discrimination',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': We do not use sensitive data for discriminatory purposes or to deny services'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              TextSpan(
                text: '\n7. Children\'s Privacy (COPPA Compliance)\n',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryColor,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: 'Everyday Christian is designed for Christians of all ages seeking biblical guidance. However, we take special precautions regarding children\'s privacy under the Children\'s Online Privacy Protection Act (COPPA) and similar laws.\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n7.1 Age Requirements and Restrictions\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'General Use (Ages 13+)',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': Users 13 and older may use all app features. We recommend parental guidance for users 13-17, especially when using AI pastoral guidance.'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Children Under 13',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': We do not knowingly collect personal information from children under 13 without verifiable parental consent. Given our privacy-first, local-only architecture:'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '  - Free features (Bible reading, verses, devotionals): Can be used by children under 13 without data collection concerns since all data stays on the device\n'),
              const TextSpan(text: '  - Premium AI Chat: Should not be used by children under 13 without parental consent due to message transmission to Google Gemini API\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n7.2 Parental Controls and Rights\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Parents and guardians of children under 13',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ':'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Your Rights Under COPPA',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ':'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '  - Review data stored locally on your child\'s device by accessing the app\n'),
              const TextSpan(text: '  - Delete your child\'s data by clearing app data or uninstalling\n'),
              const TextSpan(text: '  - Refuse further data collection by not subscribing to Premium features\n'),
              const TextSpan(text: '  - Control your child\'s use of AI chat features\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'How to Exercise Rights',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ':'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '1. Since data is local, you can directly access your child\'s device to review prayer journals, chat history, and reading activity\n'),
              const TextSpan(text: '2. Delete all data: Settings > Clear All Data or uninstall the app\n'),
              const TextSpan(text: '3. Disable Premium features: Cancel subscription through Apple/Google subscription settings\n'),
              const TextSpan(text: '4. Block AI chat: Use device-level parental controls to restrict Premium purchases\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Contact for COPPA Concerns',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': connect@everydaychristian.app'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n7.3 What Data We Collect from Children (If Any)\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: 'If a child under 13 uses Everyday Christian:\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'With parental consent (Premium users)',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ':'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '  - AI chat message text sent anonymously to Google Gemini API\n'),
              const TextSpan(text: '  - Stored locally: prayer journal, favorite verses, reading history\n'),
              const TextSpan(text: '  - No personal identifiers (name, email, birthdate) are collected\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Without parental consent (Free users)',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ':'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '  - Only local device storage (prayer journal, Bible reading history)\n'),
              const TextSpan(text: '  - No data transmission to external services\n'),
              const TextSpan(text: '  - No collection of personal information\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n7.4 Parental Consent Mechanism\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'To use Premium AI chat, parents of children under 13 should',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ':'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '1. Review this Privacy Policy and our Terms of Service\n'),
              const TextSpan(text: '2. Discuss appropriate use of AI spiritual guidance with your child\n'),
              const TextSpan(text: '3. Monitor your child\'s subscriptions through Family Sharing (Apple) or Family Link (Google)\n'),
              const TextSpan(text: '4. Supervise your child\'s use of AI chat features\n'),
              const TextSpan(text: '5. Understand that AI guidance is not professional counseling\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'We do not independently verify parental consent',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ' beyond the parent controlling the device and subscription purchases. Parents are responsible for monitoring their children\'s app usage.'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n7.5 Teen Users (Ages 13-17)\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Parental Guidance Recommended',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': While teens may use the app without explicit parental consent, we encourage parents to:'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '  - Discuss the difference between AI guidance and professional counseling\n'),
              const TextSpan(text: '  - Review crisis resources with your teen (988 Suicide & Crisis Lifeline)\n'),
              const TextSpan(text: '  - Monitor for signs of emotional distress\n'),
              const TextSpan(text: '  - Encourage your teen to speak with trusted adults, clergy, or counselors about serious issues\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Content Restrictions',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': The app enforces content policies that prohibit hate speech, harmful content, and dangerous advice regardless of user age.'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              TextSpan(
                text: '\n8. Your Privacy Rights\n',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryColor,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n8.1 Universal Rights (All Users)\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Right to Access',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': View all data stored locally on your device through the app interface (Settings > Data Management > View Stored Data)'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Right to Delete',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ':'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '  - Delete specific items: Long-press on prayers, chat messages, or favorites to delete\n'),
              const TextSpan(text: '  - Delete all data: Settings > Privacy > Delete All Data\n'),
              const TextSpan(text: '  - Complete removal: Uninstall the app (permanently deletes all local data)\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Right to Correct',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': Edit your app settings, preferences, and saved content directly within the app'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Right to Export',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': Settings > Privacy > Export My Data (generates JSON file of your prayers, chats, and reading history)'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Right to Withdraw Consent',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ':'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '  - Cancel Premium subscription to stop API data sharing\n'),
              const TextSpan(text: '  - Disable specific features in Settings\n'),
              const TextSpan(text: '  - Uninstall app completely\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n8.2 California Privacy Rights (CCPA/CPRA)\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'California residents have these specific rights:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Right to Know',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ' (CCPA §1798.100):'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '  - We collect: AI chat messages (Premium only), locally stored prayers, reading history\n'),
              const TextSpan(text: '  - Categories: Religious information, emotional content, personal thoughts\n'),
              const TextSpan(text: '  - Purpose: Provide pastoral guidance and track reading progress\n'),
              const TextSpan(text: '  - Third parties: Google Gemini API (Premium chat only)\n'),
              const TextSpan(text: '  - We do NOT sell personal information\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Right to Delete',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ' (CCPA §1798.105): Delete your data as described in Section 8.1'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Right to Opt-Out',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': Not applicable - we don\'t sell data'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Right to Non-Discrimination',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': We will never discriminate against you for exercising privacy rights'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Right to Limit Sensitive Data Use',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ' (CPRA §1798.121): All sensitive religious data stays local except Premium chat messages sent anonymously to Google'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Contact',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': connect@everydaychristian.app | Response time: 30 days'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n8.3 European Privacy Rights (GDPR)\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'EU/EEA residents have these rights under GDPR:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Right of Access',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ' (Article 15): Access your locally stored data through app interface'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Right to Erasure',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ' (Article 17): Delete data as described in Section 8.1'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Right to Data Portability',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ' (Article 20): Export data in JSON format (Settings > Export My Data)'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Right to Restrict Processing',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ' (Article 18): Don\'t subscribe to Premium to prevent API processing'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Right to Object',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ' (Article 21): Object to data processing by uninstalling or disabling features'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Right to Lodge Complaint',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': Contact your local Data Protection Authority'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '  - UK: ICO (ico.org.uk)\n'),
              const TextSpan(text: '  - EU: Find your DPA at edpb.europa.eu\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Right to Withdraw Consent',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ' (Article 7(3)): Cancel Premium subscription or uninstall app'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Legal Basis for Processing',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ':'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '  - Consent (Article 6(1)(a) & Article 9(2)(a)): Your use of the app constitutes consent for local data storage and (Premium) API transmission\n'),
              const TextSpan(text: '  - Legitimate Interest (Article 6(1)(f)): App functionality and security improvements\n'),
              const TextSpan(text: '  - Manifest Public Interest (Article 9(2)(g)): Religious guidance provision\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Data Controller',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': [INSERT LEGAL ENTITY NAME], [INSERT BUSINESS ADDRESS]'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Data Processor',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': Google LLC (for Gemini API - Premium users only)'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Data Protection Officer',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': Not required for our scale, but contact connect@everydaychristian.app for privacy matters'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n8.4 Other Jurisdictions\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Brazil (LGPD)',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': Rights similar to GDPR, contact connect@everydaychristian.app'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Canada (PIPEDA)',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': Rights to access and correct data, contact connect@everydaychristian.app'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Australia (Privacy Act)',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': Rights to access and correction, contact connect@everydaychristian.app'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'All regions',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': Our privacy-first architecture means you have direct control over your data through device-level access and deletion'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              TextSpan(
                text: '\n9. Data Retention\n',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryColor,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n9.1 Local Device Storage (Indefinite)\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: 'All data stored on your device is retained indefinitely until you choose to delete it:\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Prayer Journal',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': Retained until you delete individual entries or clear all data'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'AI Chat History',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': Retained until you delete conversations or clear all data'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Favorite Verses',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': Retained until you unfavorite or clear data'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Reading History',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': Retained until you clear history or uninstall app'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'App Settings',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': Retained until you reset settings or uninstall app'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Strike/Lockout Data',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': Retained for 30 days after lockout ends, then automatically deleted'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Your control',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': You have complete control over retention through deletion options in Settings'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n9.2 Third-Party Retention (Google Gemini API)\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Premium AI Chat Messages',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': When you send a message via Premium AI chat:'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '  - Processed by Google Gemini API according to Google\'s data retention policies\n'),
              const TextSpan(text: '  - Google may retain message text to improve AI services per their terms\n'),
              const TextSpan(text: '  - We do not control Google\'s retention periods\n'),
              const TextSpan(text: '  - Messages are sent anonymously without your identity\n'),
              const TextSpan(text: '  - See Google\'s AI Data Use Policy: https://policies.google.com/terms/generative-ai\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n9.3 Subscription Data Retention\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Apple/Google Payment Records',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': Managed by Apple App Store/Google Play Store according to their retention policies (typically 7 years for financial records)'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n9.4 No Server-Side Retention\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: 'We do not operate servers that store user data, so there are no server-side retention periods to disclose.\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n9.5 Recommended Data Hygiene\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'We recommend',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ':'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '  - Periodically review and delete sensitive chat conversations\n'),
              const TextSpan(text: '  - Clear prayer journal entries containing deeply personal information after reflection\n'),
              const TextSpan(text: '  - Uninstall the app before selling or transferring your device\n'),
              const TextSpan(text: '  - Disable iCloud/Google backups for the app if you want to prevent cloud retention\n'),
              const TextSpan(text: '\n'),
              TextSpan(
                text: '\n10. International Data Transfers\n',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryColor,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n10.1 Current Data Transfers\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Local Storage',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': No international transfers - all data stays on your device in your physical location'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Google Gemini API',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ' (Premium only):'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '  - Messages sent to Google servers, which may be located in the United States or other countries\n'),
              const TextSpan(text: '  - Google complies with GDPR Standard Contractual Clauses for EU data transfers\n'),
              const TextSpan(text: '  - Transfers occur only when you actively send an AI chat message\n'),
              const TextSpan(text: '  - Messages are anonymous and not linked to your identity\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Apple/Google Payments',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': Subscription data handled per Apple/Google\'s international transfer safeguards'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n10.2 Future Transfers\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: 'If we implement cloud synchronization or server-based features in the future:\n'),
              const TextSpan(text: '  - We will update this Privacy Policy with specific transfer details\n'),
              const TextSpan(text: '  - EU users will be protected by Standard Contractual Clauses (GDPR Article 46)\n'),
              const TextSpan(text: '  - You will have the option to opt-out of cloud features\n'),
              const TextSpan(text: '  - We will notify users before implementing such changes\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n10.3 Safeguards for International Transfers\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Current safeguards',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ':'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '  - Minimal data transfer (only anonymous chat messages)\n'),
              const TextSpan(text: '  - Google\'s GDPR compliance mechanisms\n'),
              const TextSpan(text: '  - No personal identifiers transmitted\n'),
              const TextSpan(text: '\n'),
              TextSpan(
                text: '\n11. Changes to This Privacy Policy\n',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryColor,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: 'We may update this Privacy Policy to reflect changes in our practices, technology, legal requirements, or other factors.\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n11.1 Notification of Changes\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'How we notify you',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ':'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '  - Update the "Last Updated" date at the top of this policy\n'),
              const TextSpan(text: '  - Display an in-app notification on next app launch\n'),
              const TextSpan(text: '  - For material changes, require acknowledgment before continuing to use the app\n'),
              const TextSpan(text: '  - Post updated policy at [INSERT WEBSITE URL if applicable]\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n11.2 Material vs. Non-Material Changes\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Material changes',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ' (require acceptance):'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '  - New third-party data sharing\n'),
              const TextSpan(text: '  - Changes to data retention periods\n'),
              const TextSpan(text: '  - Removal of privacy protections\n'),
              const TextSpan(text: '  - Changes to children\'s data practices\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Non-material changes',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ' (notification only):'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '  - Clarifications or additional detail\n'),
              const TextSpan(text: '  - Contact information updates\n'),
              const TextSpan(text: '  - Formatting or organizational changes\n'),
              const TextSpan(text: '  - New data protection safeguards\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n11.3 Version History\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: 'We maintain an archive of previous Privacy Policy versions. To request a previous version, contact connect@everydaychristian.app\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n11.4 Your Options After Changes\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: 'If you disagree with updated terms:\n'),
              const TextSpan(text: '  - Contact us to discuss concerns\n'),
              const TextSpan(text: '  - Delete your data and cease using affected features\n'),
              const TextSpan(text: '  - Uninstall the app (permanently deletes local data)\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Your continued use',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ' of the app after the effective date of changes constitutes acceptance of the updated Privacy Policy.'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              TextSpan(
                text: '\n12. Contact Us\n',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryColor,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n12.1 Privacy Inquiries\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'For questions about this Privacy Policy or our data practices:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Email',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': connect@everydaychristian.app'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Response Time',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': Within 30 days of inquiry'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Mailing Address',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': [INSERT IF REQUIRED BY YOUR JURISDICTION]'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n12.2 Exercising Privacy Rights\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: 'To exercise your privacy rights (access, deletion, correction, etc.):\n'),
              const TextSpan(text: '1. Most rights can be exercised directly in app Settings\n'),
              const TextSpan(text: '2. For assistance: email connect@everydaychristian.app with "Privacy Rights Request" in subject line\n'),
              const TextSpan(text: '3. We may request verification of device ownership before assisting with requests\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n12.3 COPPA Parental Inquiries\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Parents with questions about children under 13',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ':'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: 'Email: connect@everydaychristian.app with "COPPA Inquiry" in subject line\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n12.4 Data Protection Authorities\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'EU/EEA residents',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ' may also contact your local Data Protection Authority:'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '  - Find your DPA: https://edpb.europa.eu/about-edpb/board/members_en\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'California residents',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ' may contact the California Attorney General:'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '  - California Department of Justice: https://oag.ca.gov/privacy\n'),
              const TextSpan(text: '\n'),
              const TextSpan(text: '---\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Last Updated',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': October 15, 2025'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Effective Date',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': October 15, 2025'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Version',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': 1.0'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'By using Everyday Christian, you acknowledge that you have read and understood this Privacy Policy and agree to its terms.',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(text: '---\n'),
              const TextSpan(text: '\n'),
              TextSpan(
                text: '\n🔒 IMPLEMENTATION NOTES FOR DEVELOPER\n',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryColor,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'CRITICAL: Before app store submission, you MUST:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(text: '1. '),
                  TextSpan(
                    text: 'Replace all placeholders:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '- `connect@everydaychristian.app` → Your actual support email\n'),
              const TextSpan(text: '- `[INSERT LEGAL ENTITY NAME]` → Your company/individual name\n'),
              const TextSpan(text: '- `[INSERT BUSINESS ADDRESS]` → Your business address (required in CA, EU)\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(text: '2. '),
                  TextSpan(
                    text: 'Verify Google Gemini API integration:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '- Confirm API implementation matches privacy policy description\n'),
              const TextSpan(text: '- Verify anonymous request handling (no device IDs sent)\n'),
              const TextSpan(text: '- Test content filtering and crisis detection systems\n'),
              const TextSpan(text: '- Confirm 150 messages/month rate limiting\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(text: '3. '),
                  TextSpan(
                    text: 'Verify Premium subscription implementation:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '- Confirm \$35/year pricing\n'),
              const TextSpan(text: '- Verify Apple/Google payment integration\n'),
              const TextSpan(text: '- Test subscription status verification\n'),
              const TextSpan(text: '- Implement 3-strike content policy enforcement\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(text: '4. '),
                  TextSpan(
                    text: 'Add Bible translation attribution:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '- Confirm "World English Bible" is actually being used\n'),
              const TextSpan(text: '- Add attribution in app footer and credits screen\n'),
              const TextSpan(text: '- Verify no copyrighted translations are used without license\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(text: '5. '),
                  TextSpan(
                    text: 'Implement required legal features:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '- Age verification screen (COPPA compliance)\n'),
              const TextSpan(text: '- Crisis resources prominently accessible\n'),
              const TextSpan(text: '- Terms of Service acceptance on first launch\n'),
              const TextSpan(text: '- Privacy Policy accessible in Settings > Legal\n'),
              const TextSpan(text: '- Data export/deletion tools in Settings > Privacy\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(text: '6. '),
                  TextSpan(
                    text: 'Verify database security:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '- Confirm SQLite database is stored in app\'s protected sandbox\n'),
              const TextSpan(text: '- Test biometric authentication if implemented\n'),
              const TextSpan(text: '- Verify foreign key constraints are enabled\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(text: '7. '),
                  TextSpan(
                    text: 'Test notification system:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '- Verify notification permission requests match policy\n'),
              const TextSpan(text: '- Test daily verse notifications\n'),
              const TextSpan(text: '- Ensure notifications can be disabled\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(text: '8. '),
                  TextSpan(
                    text: 'App Store compliance:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '- Complete Apple App Privacy questionnaire accurately\n'),
              const TextSpan(text: '- Complete Google Data Safety section matching this policy\n'),
              const TextSpan(text: '- Host this privacy policy at a public URL (required)\n'),
              const TextSpan(text: '- Screenshot app showing disclaimers and privacy controls\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'MISSING IMPLEMENTATION VERIFICATION:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: 'Based on codebase review (5 Dart files, database schema only), the following features mentioned in this privacy policy need verification:\n'),
              const TextSpan(text: '  - ❓ Google Gemini API integration code\n'),
              const TextSpan(text: '  - ❓ Premium subscription/payment system\n'),
              const TextSpan(text: '  - ❓ Crisis keyword detection system\n'),
              const TextSpan(text: '  - ❓ Content policy enforcement (3-strike system)\n'),
              const TextSpan(text: '  - ❓ Biometric authentication implementation\n'),
              const TextSpan(text: '  - ❓ Data export/deletion features\n'),
              const TextSpan(text: '  - ❓ Age verification system\n'),
              const TextSpan(text: '  - ❓ Notification system\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'LEGAL DISCLAIMER:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ' This privacy policy was generated based on stated feature requirements. You must verify all claims are accurate against your final implementation before launch. Consult with a licensed attorney specializing in privacy law before app store submission.'),
                ],
              ),
              const TextSpan(text: '\n'),
        ],
      ),
    );
  }

  void _showTermsOfService() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
            maxWidth: ResponsiveUtils.maxContentWidth(context),
          ),
          child: FrostedGlassCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryColor.withValues(alpha: 0.3),
                            AppTheme.primaryColor.withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.xs + 2),
                        border: Border.all(
                          color: AppTheme.primaryColor.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.description_outlined,
                        color: AppColors.primaryText,
                        size: ResponsiveUtils.iconSize(context, 20),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      'Terms of Service',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, 20, minSize: 18, maxSize: 24),
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Last Updated: October 17, 2025',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, 12, minSize: 10, maxSize: 14),
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Scrollable Terms of Service Content
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.2),
                      borderRadius: AppRadius.mediumRadius,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: AppSpacing.cardPadding,
                      child: _buildTermsOfServiceContent(),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Close Button
                GlassButton(
                  text: 'Close',
                  height: 48,
                  onPressed: () => NavigationService.pop(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTermsOfServiceContent() {
    return SelectableText.rich(
      TextSpan(
        style: TextStyle(
          fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
          color: AppColors.primaryText,
          height: 1.6,
        ),
        children: [
              TextSpan(
                text: 'EVERYDAY CHRISTIAN - TERMS OF SERVICE\n',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 18, minSize: 16, maxSize: 22),
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryColor,
                ),
              ),
              const TextSpan(text: '\n'),
              TextSpan(
                text: 'Last Updated: October 17, 2025\n',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
              TextSpan(
                text: 'Effective Date: October 17, 2025\n',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
              const TextSpan(text: '\n'),
              TextSpan(
                text: '\n1. Agreement to Terms\n',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryColor,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: 'Welcome to Everyday Christian ("we," "our," "us," or the "App"). These Terms of Service ("Terms") govern your access to and use of the Everyday Christian mobile application, including all features, content, and services offered through the App.\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'BY DOWNLOADING, INSTALLING, OR USING EVERYDAY CHRISTIAN, YOU AGREE TO BE BOUND BY THESE TERMS AND OUR PRIVACY POLICY. IF YOU DO NOT AGREE TO THESE TERMS, DO NOT USE THE APP.',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(text: 'These Terms constitute a legally binding agreement between you ("you," "your," or "User") and Everyday Christian. If you are using the App on behalf of an organization, you represent that you have the authority to bind that organization to these Terms.\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n1.1 Additional Terms\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: 'Certain features or services may be subject to additional terms and conditions, which will be presented to you at the time you access those features. Those additional terms are incorporated into these Terms by reference.\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n1.2 Age Requirements\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '  - Users 13 and older may use all App features\n'),
              const TextSpan(text: '  - Users under 13 may use free features with parental consent, but Premium AI chat requires verifiable parental consent (see Section 3.2)\n'),
              const TextSpan(text: '  - Parents and guardians are responsible for monitoring their children\'s use of the App\n'),
              const TextSpan(text: '\n'),
              TextSpan(
                text: '\n2. Description of Service\n',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryColor,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: 'Everyday Christian is a faith-centered mobile application that provides:\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Core Features (Free):',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '  - Access to 31,103 Bible verses from the World English Bible translation\n'),
              const TextSpan(text: '  - Daily Bible verses and devotional content\n'),
              const TextSpan(text: '  - Personal prayer journal with categories and progress tracking\n'),
              const TextSpan(text: '  - Bible reading plans and progress tracking\n'),
              const TextSpan(text: '  - Verse bookmarking and favorites with personal notes\n'),
              const TextSpan(text: '  - Crisis intervention resources including 988 Suicide & Crisis Lifeline\n'),
              const TextSpan(text: '  - Biometric authentication for privacy protection\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Premium Features (approximately \$35/year, pricing varies by region):',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '  - AI-powered pastoral guidance using Google Gemini 2.0 Flash API\n'),
              const TextSpan(text: '  - 150 AI chat messages per month with biblically-grounded responses\n'),
              const TextSpan(text: '  - Scripture-based guidance on faith questions, spiritual struggles, and life challenges\n'),
              const TextSpan(text: '  - Conversation history stored locally on your device\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Content Safety Features:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '  - Automated filtering of AI responses for harmful theology (prosperity gospel, spiritual bypassing, toxic positivity, legalism, hate speech, medical overreach)\n'),
              const TextSpan(text: '  - Crisis keyword detection triggering professional resource recommendations\n'),
              const TextSpan(text: '  - Repeated crisis keyword use triggers safety intervention protocols\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n2.1 Service Availability\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: 'We strive to provide continuous access to the App, but we do not guarantee uninterrupted availability. The App may be unavailable due to:\n'),
              const TextSpan(text: '  - Scheduled maintenance or updates\n'),
              const TextSpan(text: '  - Technical difficulties or system failures\n'),
              const TextSpan(text: '  - Third-party service interruptions (Google Gemini API)\n'),
              const TextSpan(text: '  - Force majeure events beyond our reasonable control\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n2.2 Changes to Service\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: 'We reserve the right to modify, suspend, or discontinue any feature or the entire App at any time, with or without notice. We are not liable to you or any third party for any modification, suspension, or discontinuance of the service.\n'),
              const TextSpan(text: '\n'),
              TextSpan(
                text: '\n3. User Accounts and Registration\n',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryColor,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n3.1 No Account Required\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(text: 'Everyday Christian is designed with privacy-first principles. '),
                  TextSpan(
                    text: 'We do not require you to create an account, provide an email address, or share personal identifying information',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ' to use the App.'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n3.2 Age Verification for Premium Features\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Users under 13:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ' To subscribe to Premium features, parental consent is required under the Children\'s Online Privacy Protection Act (COPPA). Parents must:'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '1. Review these Terms and our Privacy Policy\n'),
              const TextSpan(text: '2. Authorize the subscription purchase through Apple Family Sharing or Google Family Link\n'),
              const TextSpan(text: '3. Supervise their child\'s use of AI chat features\n'),
              const TextSpan(text: '4. Understand that AI guidance is not professional counseling\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'We do not independently verify ages',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ' beyond the age gates provided by Apple App Store and Google Play Store.'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n3.3 Device Authentication\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: 'If you enable biometric authentication (Face ID, Touch ID, fingerprint), you are responsible for:\n'),
              const TextSpan(text: '  - Maintaining the security of your device authentication credentials\n'),
              const TextSpan(text: '  - Understanding that we do not have access to these credentials (they are managed by your device\'s operating system)\n'),
              const TextSpan(text: '  - Any unauthorized access to the App using your device authentication\n'),
              const TextSpan(text: '\n'),
              TextSpan(
                text: '\n4. Premium Subscription Terms\n',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryColor,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n4.1 Subscription Plans\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Premium Annual Subscription:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '  - Price: \$35.00 USD per year (pricing may vary by region and currency)\n'),
              const TextSpan(text: '  - Features: 150 AI chat messages per month, unlimited access to all Premium features\n'),
              const TextSpan(text: '  - Billing: Charged annually to your Apple App Store or Google Play Store account\n'),
              const TextSpan(text: '  - Auto-Renewal: Automatically renews each year unless canceled at least 24 hours before the end of the current period\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n4.2 Payment and Billing\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Payment Processing:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ' All payments are processed through Apple App Store or Google Play Store. We do not directly process, store, or have access to your payment information.'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Refunds:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ' Refund requests are subject to Apple\'s and Google\'s refund policies. Generally:'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '  - Within 48 hours of purchase: Contact Apple/Google support for a refund\n'),
              const TextSpan(text: '  - After 48 hours: Refunds are at Apple\'s/Google\'s discretion\n'),
              const TextSpan(text: '  - Unused message credits do not roll over and are non-refundable\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Pricing Changes:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ' We reserve the right to change subscription pricing with 30 days\' notice. Price changes will not affect your current subscription period but will apply upon renewal.'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n4.3 Subscription Management\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'To manage your subscription:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '  - iOS: Settings > [Your Name] > Subscriptions > Everyday Christian\n'),
              const TextSpan(text: '  - Android: Google Play Store > Menu > Subscriptions > Everyday Christian\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'To cancel auto-renewal:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ' Follow the steps above and select "Cancel Subscription" at least 24 hours before your renewal date.'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n4.4 Message Usage Limits\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(text: 'Premium subscribers receive '),
                  TextSpan(
                    text: '150 AI chat messages per month',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ':'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '  - Message count resets on your subscription renewal date\n'),
              const TextSpan(text: '  - Unused messages do not roll over to the next month\n'),
              const TextSpan(text: '  - If you exceed 150 messages, you must wait until renewal or upgrade (if available)\n'),
              const TextSpan(text: '  - We track message counts locally on your device; counts may reset if you reinstall the App\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n4.5 Free Trial (If Offered)\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: 'If we offer a free trial:\n'),
              const TextSpan(text: '  - Trial duration will be clearly disclosed before subscription\n'),
              const TextSpan(text: '  - You must cancel before the trial ends to avoid being charged\n'),
              const TextSpan(text: '  - You may not be eligible for a free trial if you previously subscribed\n'),
              const TextSpan(text: '  - We reserve the right to modify or discontinue free trials at any time\n'),
              const TextSpan(text: '\n'),
              TextSpan(
                text: '\n5. User Conduct and Content Policy\n',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryColor,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n5.1 Acceptable Use\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: 'You agree to use Everyday Christian only for lawful purposes and in accordance with these Terms. You agree NOT to:\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Prohibited Content:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '  - ❌ Post, transmit, or promote hate speech, harassment, threats, or violence\n'),
              const TextSpan(text: '  - ❌ Share content that is obscene, pornographic, or sexually explicit\n'),
              const TextSpan(text: '  - ❌ Promote or glorify self-harm, suicide, or eating disorders\n'),
              const TextSpan(text: '  - ❌ Engage in harassment, bullying, or intimidation\n'),
              const TextSpan(text: '  - ❌ Promote prosperity gospel theology, spiritual manipulation, or abusive religious practices\n'),
              const TextSpan(text: '  - ❌ Impersonate others or misrepresent your identity or affiliation\n'),
              const TextSpan(text: '  - ❌ Share spam, advertising, or unsolicited promotional content\n'),
              const TextSpan(text: '  - ❌ Violate intellectual property rights, privacy rights, or other legal rights\n'),
              const TextSpan(text: '  - ❌ Attempt to exploit, harm, or solicit information from minors\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Prohibited Activities:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '  - ❌ Reverse engineer, decompile, or disassemble the App\n'),
              const TextSpan(text: '  - ❌ Attempt to gain unauthorized access to the App, servers, or databases\n'),
              const TextSpan(text: '  - ❌ Use automated systems (bots, scripts, scrapers) to access the App\n'),
              const TextSpan(text: '  - ❌ Interfere with or disrupt the App\'s operation or servers\n'),
              const TextSpan(text: '  - ❌ Remove, alter, or obscure copyright notices, trademarks, or disclaimers\n'),
              const TextSpan(text: '  - ❌ Use the App for any illegal purpose or in violation of any laws\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n5.2 AI Chat Content Policy\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: 'When using Premium AI chat features, you agree to:\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Respectful Engagement:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '  - Use the AI for genuine faith questions, spiritual guidance, and biblical learning\n'),
              const TextSpan(text: '  - Engage respectfully and avoid testing boundaries with inappropriate content\n'),
              const TextSpan(text: '  - Understand that the AI is a spiritual resource tool, not a replacement for professional counseling, therapy, or medical advice\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Content That Triggers Warnings:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '  - Prosperity gospel language or health-and-wealth theology\n'),
              const TextSpan(text: '  - Spiritual bypassing or toxic positivity\n'),
              const TextSpan(text: '  - Legalistic or works-based salvation teachings\n'),
              const TextSpan(text: '  - Hate speech targeting any group\n'),
              const TextSpan(text: '  - Medical advice or discouragement from seeking professional help\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n5.3 Content Policy Enforcement\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'We reserve the right to suspend or terminate access to Premium AI chat features for:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '  - Repeated violations of prohibited content policies (Section 5.1)\n'),
              const TextSpan(text: '  - Attempts to bypass content filtering or safety mechanisms\n'),
              const TextSpan(text: '  - Abusive or harassing behavior\n'),
              const TextSpan(text: '  - Attempts to manipulate the AI into generating harmful content\n'),
              const TextSpan(text: '  - Any use that violates these Terms or applicable law\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Enforcement actions may include:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '  - Warnings and reminders of content policy\n'),
              const TextSpan(text: '  - Temporary suspension of AI chat access\n'),
              const TextSpan(text: '  - Permanent suspension from Premium features\n'),
              const TextSpan(text: '  - Account termination in severe cases\n'),
              const TextSpan(text: '\n'),
              const TextSpan(text: 'We reserve discretion in determining appropriate responses to policy violations based on severity and context.\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n5.4 Crisis Content and Intervention\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'If you express thoughts of suicide, self-harm, or harming others:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '  - Crisis detection keywords trigger immediate display of professional resources\n'),
              const TextSpan(text: '  - Resources include 988 Suicide & Crisis Lifeline (call or text 988)\n'),
              const TextSpan(text: '  - We strongly encourage you to reach out to professional crisis services immediately\n'),
              const TextSpan(text: '  - The App is NOT a crisis intervention service and cannot provide emergency assistance\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'If you are in immediate danger:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ' Call 911 (US), 999 (UK), or your local emergency number immediately.'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n5.5 User-Generated Content\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Prayer Journal Entries, Notes, and Bookmarks:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '  - All content you create (prayers, notes, highlights) is stored locally on your device\n'),
              const TextSpan(text: '  - You retain all rights to your user-generated content\n'),
              const TextSpan(text: '  - We do not have access to, monitor, or claim ownership of your locally stored content\n'),
              const TextSpan(text: '  - You are solely responsible for backing up your content (via device backups)\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'AI Chat Messages:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '  - Messages sent to AI chat are processed by Google Gemini API (see Privacy Policy)\n'),
              const TextSpan(text: '  - You grant us a limited license to transmit your messages to Google for processing\n'),
              const TextSpan(text: '  - Chat history is stored locally on your device and is not accessible to us\n'),
              const TextSpan(text: '  - We do not claim ownership of your chat conversations\n'),
              const TextSpan(text: '\n'),
              TextSpan(
                text: '\n6. Intellectual Property Rights\n',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryColor,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n6.1 App Ownership\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: 'Everyday Christian, including all software, design, graphics, text, functionality, and content (excluding user-generated content and third-party content), is owned by us or our licensors and is protected by:\n'),
              const TextSpan(text: '  - United States copyright law\n'),
              const TextSpan(text: '  - International copyright treaties\n'),
              const TextSpan(text: '  - Trademark law\n'),
              const TextSpan(text: '  - Other intellectual property laws\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n6.2 Limited License to Use\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: 'We grant you a limited, non-exclusive, non-transferable, revocable license to:\n'),
              const TextSpan(text: '  - Download and install the App on devices you own or control\n'),
              const TextSpan(text: '  - Use the App for personal, non-commercial purposes in accordance with these Terms\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'This license does NOT permit you to:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '  - Modify, copy, distribute, transmit, display, perform, reproduce, publish, license, create derivative works from, transfer, or sell any content, software, or services obtained from the App\n'),
              const TextSpan(text: '  - Use the App for commercial purposes without our prior written consent\n'),
              const TextSpan(text: '  - Remove or alter any copyright, trademark, or other proprietary notices\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n6.3 Bible Translation License\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: 'The World English Bible (WEB) translation used in Everyday Christian is in the public domain. We include the following attribution:\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'World English Bible (WEB)',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '  - Public Domain\n'),
              const TextSpan(text: '  - Updated: 2024\n'),
              const TextSpan(text: '  - Translation: Modern English from Hebrew, Aramaic, and Greek source texts\n'),
              const TextSpan(text: '  - Free for all use, modification, and distribution\n'),
              const TextSpan(text: '  - See ebible.org/web for more information\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n6.4 Third-Party Content\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Google Gemini AI responses',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ' are generated by Google\'s AI technology and may be subject to Google\'s intellectual property rights. By using Premium AI chat, you acknowledge that:'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '  - AI-generated content is provided "as is" for spiritual guidance purposes\n'),
              const TextSpan(text: '  - We make no warranties regarding accuracy, completeness, or theological soundness of AI responses\n'),
              const TextSpan(text: '  - You should verify important spiritual or theological matters with qualified clergy or theologians\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n6.5 Trademarks\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '"Everyday Christian" and our logo (if applicable) are trademarks or registered trademarks of [INSERT LEGAL ENTITY NAME]. You may not use these marks without our prior written permission.\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n6.6 Digital Millennium Copyright Act (DMCA)\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: 'If you believe content in the App infringes your copyright, please contact us with:\n'),
              const TextSpan(text: '1. Description of the copyrighted work\n'),
              const TextSpan(text: '2. Location of the infringing material in the App\n'),
              const TextSpan(text: '3. Your contact information\n'),
              const TextSpan(text: '4. Statement of good faith belief that use is unauthorized\n'),
              const TextSpan(text: '5. Statement that information is accurate and you are authorized to act\n'),
              const TextSpan(text: '6. Your physical or electronic signature\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'DMCA Contact:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ' connect@everydaychristian.app'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              TextSpan(
                text: '\n7. Disclaimers and Limitations of Liability\n',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryColor,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n7.1 "AS IS" and "AS AVAILABLE" Disclaimer\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'THE APP IS PROVIDED "AS IS" AND "AS AVAILABLE" WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(text: '  - Accuracy of Content: We do not warrant that Bible verses, devotionals, or AI-generated responses are free from errors or theologically sound for all denominations\n'),
              const TextSpan(text: '  - Availability: We do not guarantee uninterrupted, timely, secure, or error-free operation\n'),
              const TextSpan(text: '  - Fitness for Purpose: We do not warrant that the App will meet your specific spiritual needs or expectations\n'),
              const TextSpan(text: '  - Third-Party Services: We do not control Google Gemini API and are not responsible for its performance, availability, or content\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n7.2 AI Guidance Disclaimer\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'EVERYDAY CHRISTIAN\'S AI PASTORAL GUIDANCE IS NOT A SUBSTITUTE FOR:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '  - Professional mental health counseling or therapy\n'),
              const TextSpan(text: '  - Medical advice, diagnosis, or treatment\n'),
              const TextSpan(text: '  - Legal advice\n'),
              const TextSpan(text: '  - Financial advice\n'),
              const TextSpan(text: '  - Professional pastoral counseling from ordained clergy\n'),
              const TextSpan(text: '  - Crisis intervention services\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'AI-generated responses:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '  - Are based on patterns learned from training data and may contain inaccuracies\n'),
              const TextSpan(text: '  - Should be verified against Scripture and validated by trusted Christian leaders\n'),
              const TextSpan(text: '  - May not represent all theological perspectives or denominational views\n'),
              const TextSpan(text: '  - Are filtered for harmful theology, but filtering is not perfect\n'),
              const TextSpan(text: '  - Should never replace professional help for serious mental health, medical, or legal issues\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'If you are experiencing a mental health crisis, substance abuse emergency, domestic violence, or other serious situation:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ' Contact professional services immediately (988 Suicide & Crisis Lifeline, 911, or your local emergency services).'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n7.3 Limitation of Liability\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'TO THE MAXIMUM EXTENT PERMITTED BY LAW, WE SHALL NOT BE LIABLE FOR:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Direct Damages:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '  - Loss of data stored locally on your device\n'),
              const TextSpan(text: '  - Inability to access the App or Premium features\n'),
              const TextSpan(text: '  - Inaccurate or harmful AI-generated content\n'),
              const TextSpan(text: '  - Theological disputes or disagreements arising from App content\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Indirect Damages:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '  - Loss of profits, revenue, or business opportunities\n'),
              const TextSpan(text: '  - Emotional distress or spiritual harm\n'),
              const TextSpan(text: '  - Consequential, incidental, special, exemplary, or punitive damages\n'),
              const TextSpan(text: '  - Damages arising from reliance on AI guidance or devotional content\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Aggregate Liability Cap:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ' Our total liability to you for all claims arising from your use of the App shall not exceed the amount you paid for Premium subscription in the 12 months preceding the claim, or \$100 USD, whichever is greater.'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n7.4 Exceptions to Limitations\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: 'Some jurisdictions do not allow limitations on implied warranties or exclusion of certain damages. In such jurisdictions, our liability shall be limited to the greatest extent permitted by law.\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Nothing in these Terms excludes or limits our liability for:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '  - Death or personal injury caused by our negligence\n'),
              const TextSpan(text: '  - Fraud or fraudulent misrepresentation\n'),
              const TextSpan(text: '  - Any liability that cannot be excluded or limited under applicable law\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n7.5 Force Majeure\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: 'We are not liable for any failure or delay in performance due to causes beyond our reasonable control, including:\n'),
              const TextSpan(text: '  - Acts of God (natural disasters, pandemics, etc.)\n'),
              const TextSpan(text: '  - War, terrorism, civil unrest\n'),
              const TextSpan(text: '  - Government actions or regulations\n'),
              const TextSpan(text: '  - Internet service provider failures\n'),
              const TextSpan(text: '  - Third-party service outages (Google API)\n'),
              const TextSpan(text: '  - Cyber attacks, hacking, or security breaches\n'),
              const TextSpan(text: '\n'),
              TextSpan(
                text: '\n8. Indemnification\n',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryColor,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: 'You agree to defend, indemnify, and hold harmless Everyday Christian, its affiliates, licensors, and service providers, and their respective officers, directors, employees, contractors, agents, and representatives from and against any claims, liabilities, damages, judgments, awards, losses, costs, expenses, or fees (including reasonable attorneys\' fees) arising out of or relating to:\n'),
              const TextSpan(text: '\n'),
              const TextSpan(text: '1. Your violation of these Terms\n'),
              const TextSpan(text: '2. Your use or misuse of the App\n'),
              const TextSpan(text: '3. Your violation of any third-party rights, including intellectual property or privacy rights\n'),
              const TextSpan(text: '4. Your user-generated content (prayers, notes, chat messages)\n'),
              const TextSpan(text: '5. Your violation of any laws or regulations\n'),
              const TextSpan(text: '6. Any false or misleading information you provide\n'),
              const TextSpan(text: '7. Your reliance on AI-generated content leading to harm or loss\n'),
              const TextSpan(text: '\n'),
              const TextSpan(text: 'This indemnification obligation will survive termination of these Terms and your use of the App.\n'),
              const TextSpan(text: '\n'),
              TextSpan(
                text: '\n9. Privacy and Data Protection\n',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryColor,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: 'Your use of Everyday Christian is also governed by our Privacy Policy, which is incorporated into these Terms by reference. Please review our Privacy Policy to understand:\n'),
              const TextSpan(text: '  - How we collect, use, and protect your information\n'),
              const TextSpan(text: '  - Your privacy rights under GDPR, CCPA, and other laws\n'),
              const TextSpan(text: '  - How we handle sensitive religious data\n'),
              const TextSpan(text: '  - Third-party data sharing (Google Gemini API for Premium users)\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Key Privacy Highlights:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '  - NO user accounts or email addresses required\n'),
              const TextSpan(text: '  - All personal data stored locally on your device\n'),
              const TextSpan(text: '  - Premium AI chat messages sent anonymously to Google Gemini API\n'),
              const TextSpan(text: '  - NO analytics, tracking, or advertising networks\n'),
              const TextSpan(text: '  - Complete data deletion available in Settings\n'),
              const TextSpan(text: '\n'),
              TextSpan(
                text: '\n10. International Use and Export Controls\n',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryColor,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n10.1 Global Availability\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: 'Everyday Christian may be accessed from countries around the world. However, we make no representation that the App is appropriate or available for use in all locations. You are responsible for compliance with local laws if you access the App from outside the United States.\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n10.2 Export Controls\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: 'The App may be subject to U.S. export control laws and regulations. You agree not to export, re-export, or transfer the App or any technical data derived from it, in violation of:\n'),
              const TextSpan(text: '  - U.S. Export Administration Regulations\n'),
              const TextSpan(text: '  - International Traffic in Arms Regulations\n'),
              const TextSpan(text: '  - Economic sanctions enforced by the Office of Foreign Assets Control (OFAC)\n'),
              const TextSpan(text: '\n'),
              const TextSpan(text: 'You represent that you are not:\n'),
              const TextSpan(text: '  - Located in, under the control of, or a national or resident of any embargoed country\n'),
              const TextSpan(text: '  - On any U.S. government list of prohibited or restricted parties\n'),
              const TextSpan(text: '\n'),
              TextSpan(
                text: '\n11. Dispute Resolution and Governing Law\n',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryColor,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n11.1 Governing Law\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: 'These Terms shall be governed by and construed in accordance with the laws of the State of [INSERT STATE], United States, without regard to its conflict of law provisions.\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n11.2 Informal Dispute Resolution\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Before filing a claim',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ', you agree to contact us at connect@everydaychristian.app and attempt to resolve the dispute informally. We will attempt to resolve the dispute through good-faith negotiation within 60 days.'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n11.3 Arbitration Agreement\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'YOU AND EVERYDAY CHRISTIAN AGREE TO RESOLVE ANY DISPUTES THROUGH BINDING INDIVIDUAL ARBITRATION, EXCEPT AS SPECIFIED BELOW.',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Arbitration Procedures:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '  - Arbitration shall be conducted by the American Arbitration Association (AAA) under its Consumer Arbitration Rules\n'),
              const TextSpan(text: '  - Arbitration shall take place in [INSERT LOCATION] or via telephone/video conference\n'),
              const TextSpan(text: '  - The arbitrator\'s decision is final and binding\n'),
              const TextSpan(text: '  - Each party shall bear its own costs and attorneys\' fees unless the arbitrator awards otherwise\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Exceptions to Arbitration:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '  - Small claims court actions (if the claim qualifies)\n'),
              const TextSpan(text: '  - Intellectual property disputes\n'),
              const TextSpan(text: '  - Violations of our intellectual property rights\n'),
              const TextSpan(text: '  - Claims for injunctive or equitable relief\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'NO CLASS ACTIONS:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ' You agree to bring claims only in your individual capacity and not as a plaintiff or class member in any class, consolidated, or representative action.'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n11.4 Opt-Out of Arbitration\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: 'You may opt out of the arbitration agreement by sending written notice to connect@everydaychristian.app within 30 days of first accepting these Terms. Your opt-out notice must include your name, address, and a clear statement that you wish to opt out of arbitration.\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n11.5 Jurisdiction and Venue\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: 'If arbitration is not applicable or you have opted out, you agree that any legal action shall be brought exclusively in the state or federal courts located in [INSERT COUNTY, STATE], and you consent to personal jurisdiction in those courts.\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n11.6 Limitation on Time to File Claims\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'You agree that any claim arising out of your use of the App must be filed within ONE YEAR after the claim arose. Claims filed after one year are permanently barred.',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              TextSpan(
                text: '\n12. Termination\n',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryColor,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n12.1 Termination by You\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: 'You may stop using the App at any time by:\n'),
              const TextSpan(text: '  - Uninstalling the App from your device (permanently deletes all locally stored data)\n'),
              const TextSpan(text: '  - Canceling your Premium subscription (access continues until end of current billing period)\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n12.2 Termination by Us\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: 'We reserve the right to suspend or terminate your access to the App, with or without notice, for:\n'),
              const TextSpan(text: '  - Violation of these Terms or our content policy\n'),
              const TextSpan(text: '  - Repeated content policy strikes (3+ violations)\n'),
              const TextSpan(text: '  - Fraudulent, abusive, or illegal activity\n'),
              const TextSpan(text: '  - Harm to other users, the App, or our reputation\n'),
              const TextSpan(text: '  - Requests from law enforcement or legal process\n'),
              const TextSpan(text: '  - Technical or security reasons\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n12.3 Effect of Termination\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: 'Upon termination:\n'),
              const TextSpan(text: '  - Your Premium subscription will be canceled (subject to Apple/Google refund policies)\n'),
              const TextSpan(text: '  - You must immediately cease using the App and uninstall it\n'),
              const TextSpan(text: '  - All locally stored data remains on your device until you delete it\n'),
              const TextSpan(text: '  - Sections 6 (Intellectual Property), 7 (Disclaimers), 8 (Indemnification), 9 (Privacy), and 11 (Dispute Resolution) survive termination\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'NO REFUNDS',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ' are provided for terminations due to Terms violations.'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              TextSpan(
                text: '\n13. Modifications to Terms\n',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryColor,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n13.1 Right to Modify\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: 'We reserve the right to modify these Terms at any time. When we make changes:\n'),
              const TextSpan(text: '  - We will update the "Last Updated" date at the top of this document\n'),
              const TextSpan(text: '  - We will provide notice through the App (e.g., pop-up notification on next launch)\n'),
              const TextSpan(text: '  - For material changes, we will require you to accept the updated Terms before continuing to use the App\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n13.2 Material Changes\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: 'Material changes include:\n'),
              const TextSpan(text: '  - Changes to Premium subscription pricing or features\n'),
              const TextSpan(text: '  - New limitations on your rights to use the App\n'),
              const TextSpan(text: '  - Changes to dispute resolution or arbitration terms\n'),
              const TextSpan(text: '  - Changes to liability limitations\n'),
              const TextSpan(text: '  - Introduction of new fees\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n13.3 Acceptance of Changes\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Your continued use of the App after the effective date of updated Terms constitutes acceptance of those changes.',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ' If you do not agree to the modified Terms, you must stop using the App and uninstall it.'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n13.4 Version Archive\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: 'We maintain an archive of previous Terms versions. To request a previous version, contact connect@everydaychristian.app.\n'),
              const TextSpan(text: '\n'),
              TextSpan(
                text: '\n14. Miscellaneous Provisions\n',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryColor,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n14.1 Entire Agreement\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: 'These Terms, together with our Privacy Policy, constitute the entire agreement between you and Everyday Christian regarding your use of the App and supersede all prior agreements, understandings, or representations.\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n14.2 Severability\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: 'If any provision of these Terms is held to be invalid, illegal, or unenforceable, the remaining provisions shall continue in full force and effect. The invalid provision shall be modified to the minimum extent necessary to make it valid and enforceable.\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n14.3 Waiver\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: 'Our failure to enforce any provision of these Terms does not constitute a waiver of that provision or our right to enforce it in the future. Any waiver must be in writing and signed by an authorized representative.\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n14.4 Assignment\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: 'You may not assign or transfer these Terms or any rights hereunder without our prior written consent. We may assign these Terms to any affiliate or successor without your consent.\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n14.5 No Third-Party Beneficiaries\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: 'These Terms do not create any third-party beneficiary rights except as expressly stated herein.\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n14.6 Notices\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'To You:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ' We may provide notices to you through:'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '  - In-app notifications\n'),
              const TextSpan(text: '  - Email (if you provided one for support inquiries)\n'),
              const TextSpan(text: '  - Updates to this Terms document\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'To Us:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ' You may contact us at:'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '  - Email: connect@everydaychristian.app\n'),
              const TextSpan(text: '  - Mailing Address: [INSERT IF REQUIRED BY JURISDICTION]\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n14.7 Headings\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: 'Section headings in these Terms are for convenience only and do not affect interpretation.\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '\n14.8 Language\n',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: 'These Terms are drafted in English. In the event of any conflict between an English version and a translated version, the English version shall prevail.\n'),
              const TextSpan(text: '\n'),
              TextSpan(
                text: '\n15. Contact Information\n',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryColor,
                ),
              ),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'For questions about these Terms, the App, or to report violations:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Email:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ' connect@everydaychristian.app'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Response Time:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ' Within 7 business days for general inquiries, 30 days for legal matters'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'For Premium subscription support:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '  - iOS: Apple App Store support\n'),
              const TextSpan(text: '  - Android: Google Play Store support\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'For technical support or bug reports:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: 'Email: connect@everydaychristian.app with "Technical Support" in subject line\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'For content policy violations:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: 'Email: connect@everydaychristian.app with "Content Violation Report" in subject line\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'For privacy inquiries:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: 'See our Privacy Policy for detailed contact information regarding data protection rights.\n'),
              const TextSpan(text: '\n'),
              const TextSpan(text: '---\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Last Updated:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ' October 17, 2025'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Effective Date:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ' October 17, 2025'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Version:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ' 1.0'),
                ],
              ),
              const TextSpan(text: '\n'),
              const TextSpan(text: '\n'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'BY USING EVERYDAY CHRISTIAN, YOU ACKNOWLEDGE THAT YOU HAVE READ, UNDERSTOOD, AND AGREE TO BE BOUND BY THESE TERMS OF SERVICE.',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const TextSpan(text: '\n'),
        ],
      ),
    );
  }



  void _showSnackBar(String message) {
    // Determine icon and border color based on message content
    IconData icon;
    Color borderColor;
    Color iconColor;

    if (message.startsWith('✅') || message.startsWith('✓')) {
      icon = Icons.check_circle;
      borderColor = AppTheme.goldColor.withValues(alpha: 0.3);
      iconColor = AppTheme.goldColor;
    } else if (message.startsWith('❌') || message.startsWith('✗')) {
      icon = Icons.error_outline;
      borderColor = Colors.red.withValues(alpha: 0.5);
      iconColor = Colors.red.shade300;
    } else if (message.startsWith('⚠️')) {
      icon = Icons.warning_amber_outlined;
      borderColor = Colors.orange.withValues(alpha: 0.5);
      iconColor = Colors.orange.shade300;
    } else if (message.startsWith('📤') || message.startsWith('📥')) {
      icon = Icons.upload_outlined;
      borderColor = AppTheme.goldColor.withValues(alpha: 0.3);
      iconColor = AppTheme.goldColor;
    } else {
      icon = Icons.info_outline;
      borderColor = AppTheme.goldColor.withValues(alpha: 0.3);
      iconColor = Colors.white70;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
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
              color: borderColor,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
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

  /// Get subscription status text
  String _getSubscriptionStatus(WidgetRef ref) {
    final isPremium = ref.watch(isPremiumProvider);
    final isInTrial = ref.watch(isInTrialProvider);
    final remainingMessages = ref.watch(remainingMessagesProvider);

    if (isPremium) {
      return '$remainingMessages messages left this month';
    } else if (isInTrial) {
      return '$remainingMessages messages left today';
    } else {
      return 'Start your free trial';
    }
  }

  /// Build navigation tile
  Widget _buildNavigationTile(
    String title,
    String subtitle,
    IconData trailingIcon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.1),
              Colors.white.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              trailingIcon,
              size: 18,
              color: AppColors.secondaryText,
            ),
          ],
        ),
      ),
    );
  }
}

// FAQ Item Model
class _FAQItem {
  final String question;
  final String answer;

  _FAQItem({
    required this.question,
    required this.answer,
  });
}
