import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../core/navigation/app_routes.dart';
import '../utils/responsive_utils.dart';

/// Glassmorphic Floating Action Button Menu
///
/// A modern, brand-focused navigation menu that replaces traditional drawers.
/// Features:
/// - App logo instead of generic icon
/// - Full-screen backdrop blur when open
/// - Glassmorphic styled menu items
/// - Smooth animations
/// - Responsive sizing
/// - Haptic feedback
class GlassmorphicFABMenu extends StatefulWidget {
  const GlassmorphicFABMenu({super.key});

  @override
  State<GlassmorphicFABMenu> createState() => _GlassmorphicFABMenuState();
}

class _GlassmorphicFABMenuState extends State<GlassmorphicFABMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isVisible = false;
  OverlayEntry? _overlayEntry;

  // Menu items matching your app routes
  final List<MenuOption> _menuOptions = [
    MenuOption(
      title: "Home",
      icon: Icons.home,
      color: AppTheme.goldColor,
      route: AppRoutes.home,
    ),
    MenuOption(
      title: "Bible Reading",
      icon: Icons.menu_book,
      color: AppTheme.goldColor,
      route: AppRoutes.bibleBrowser,
    ),
    MenuOption(
      title: "Biblical Chat",
      icon: Icons.chat_bubble_outline,
      color: Colors.blue,
      route: AppRoutes.chat,
    ),
    MenuOption(
      title: "Prayer Journal",
      icon: Icons.favorite_outline,
      color: Colors.red,
      route: AppRoutes.prayerJournal,
    ),
    MenuOption(
      title: "Daily Devotional",
      icon: Icons.auto_stories,
      color: Colors.green,
      route: AppRoutes.devotional,
    ),
    MenuOption(
      title: "Reading Plans",
      icon: Icons.library_books_outlined,
      color: Colors.purple,
      route: AppRoutes.readingPlan,
    ),
    MenuOption(
      title: "Verse Library",
      icon: Icons.search,
      color: Colors.orange,
      route: AppRoutes.verseLibrary,
    ),
    MenuOption(
      title: "Profile",
      icon: Icons.person_outline,
      color: Colors.teal,
      route: AppRoutes.profile,
    ),
    MenuOption(
      title: "Settings",
      icon: Icons.settings_outlined,
      color: Colors.grey,
      route: AppRoutes.settings,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
  }

  @override
  void dispose() {
    _removeOverlay();
    _controller.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    // Haptic feedback
    HapticFeedback.mediumImpact();

    setState(() {
      _isVisible = !_isVisible;
    });

    if (_isVisible) {
      _controller.forward();
      _showOverlay();
    } else {
      _controller.reverse();
      _removeOverlay();
    }
  }

  void _showOverlay() {
    _overlayEntry = OverlayEntry(
      builder: (context) => _buildOverlay(),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Widget _buildOverlay() {
    return GestureDetector(
      onTap: _toggleMenu,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            children: [
              // Full-screen backdrop blur (matches blur_dropdown.dart)
              Positioned.fill(
                child: AnimatedOpacity(
                  opacity: _controller.value,
                  duration: const Duration(milliseconds: 300),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: _controller.value * 8,
                      sigmaY: _controller.value * 8,
                    ),
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.3 * _controller.value),
                    ),
                  ),
                ),
              ),
              // Animated menu items
              ..._buildAnimatedMenuItems(),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildAnimatedMenuItems() {
    final options = _menuOptions; // Don't reverse, show in order

    // Position from top-left where FAB is located
    final double leftPadding = ResponsiveUtils.scaleSize(context, 20, minScale: 0.8, maxScale: 1.2);
    final double topPadding = ResponsiveUtils.scaleSize(context, 70, minScale: 0.9, maxScale: 1.1); // Below FAB

    // EXACT height calculation for 2px gaps:
    // padding(8+8) + icon(30) + border(3) + shadow(3) = 52px per item
    // Add exactly 2px gap = 54px total spacing between items
    const double itemHeight = 52.0; // Exact container height
    const double gap = 2.0; // Exactly 2px gap
    const double itemSpacing = itemHeight + gap; // 54px total

    return List.generate(options.length, (index) {
      final option = options[index];

      // Staggered animation for each item
      final animation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            0.0 * (1 - (index / options.length)),
            1.0 * (1 - (index / options.length)),
            curve: Curves.fastEaseInToSlowEaseOut,
          ),
        ),
      );

      return Positioned(
        top: topPadding + (itemSpacing * index * animation.value),
        left: leftPadding,
        child: Transform.scale(
          alignment: Alignment.topLeft,
          scale: animation.value,
          child: Opacity(
            opacity: animation.value,
            child: _buildMenuItem(option),
          ),
        ),
      );
    });
  }

  Widget _buildMenuItem(MenuOption option) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        final route = option.route;
        _toggleMenu();

        // Navigate after menu closes (capture context before async gap)
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            // If navigating to home, clear stack and make home the root (same as auth)
            if (route == AppRoutes.home) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.home,
                (route) => false,
              );
            } else {
              // For other main screens, replace current screen to avoid stacking
              Navigator.pushReplacementNamed(context, route);
            }
          }
        });
      },
      child: ClipRRect(
        borderRadius: AppRadius.cardRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
          child: Container(
            width: ResponsiveUtils.scaleSize(context, 200, minScale: 0.85, maxScale: 1.2),
            height: 52, // Fixed height for precise 2px gap calculation
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: AppRadius.cardRadius,
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.2),
                  Colors.white.withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    option.title,
                    style: TextStyle(
                      fontSize: ResponsiveUtils.fontSize(context, 15, minSize: 13, maxSize: 17),
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      shadows: AppTheme.textShadowSubtle,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: option.color.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(AppRadius.xs + 2),
                    border: Border.all(
                      color: option.color.withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    option.icon,
                    size: ResponsiveUtils.iconSize(context, 18),
                    color: option.color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isVisible ? 0.0 : 1.0,
      duration: const Duration(milliseconds: 700),
      curve: _isVisible ? Curves.fastEaseInToSlowEaseOut : Curves.easeIn,
      child: AnimatedOpacity(
        opacity: _isVisible ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 700),
        curve: _isVisible ? Curves.fastEaseInToSlowEaseOut : Curves.easeIn,
        child: GestureDetector(
          onTap: _toggleMenu,
          child: ClipRRect(
            borderRadius: AppRadius.mediumRadius,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: ResponsiveUtils.scaleSize(context, 80, minScale: 0.85, maxScale: 1.2),
                height: ResponsiveUtils.scaleSize(context, 80, minScale: 0.85, maxScale: 1.2),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.goldColor.withValues(alpha: 0.3),
                      AppTheme.primaryColor.withValues(alpha: 0.3),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: AppTheme.goldColor.withValues(alpha: 0.6),
                    width: 1.5,
                  ),
                  borderRadius: AppRadius.mediumRadius,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Image.asset(
                      'assets/images/logo_transparent.png',
                      width: 64,
                      height: 64,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback to icon if logo fails to load
                        return const Icon(
                          Icons.menu,
                          color: Colors.white,
                          size: 48,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Menu option data model
class MenuOption {
  final String title;
  final IconData icon;
  final Color color;
  final String route;

  MenuOption({
    required this.title,
    required this.icon,
    required this.color,
    required this.route,
  });
}
