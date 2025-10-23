import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Glassmorphic loading indicator for pagination
/// Shows when loading older messages from database
class LoadMore extends StatelessWidget {
  final double size;
  final EdgeInsetsGeometry padding;
  final Color? color;

  const LoadMore({
    super.key,
    this.size = 24,
    this.padding = const EdgeInsets.symmetric(vertical: 20),
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.15),
                Colors.white.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SizedBox(
            height: size,
            width: size,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? AppTheme.primaryColor,
              ),
              strokeCap: StrokeCap.round,
            ),
          ),
        ),
      ),
    );
  }
}
