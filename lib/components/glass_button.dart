import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'glass_card.dart';

class GlassButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final double height;
  final Widget? loadingWidget;

  const GlassButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.width,
    this.height = 56,
    this.loadingWidget,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: GlassContainer(
        borderRadius: 28,
        padding: const EdgeInsets.all(0),
        border: Border.all(
          color: AppTheme.primaryColor,
          width: 2,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isLoading ? null : onPressed,
            borderRadius: AppRadius.buttonRadius,
            child: Center(
              child: isLoading
                ? (loadingWidget ?? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2,
                    ),
                  ))
                : Text(
                    text,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
            ),
          ),
        ),
      ),
    );
  }
}