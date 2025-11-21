import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../theme/app_theme.dart';
import '../utils/responsive_utils.dart';
import 'glass_card.dart';

class GlassButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final double height;
  final Widget? loadingWidget;
  final Color? borderColor;

  const GlassButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.width,
    this.height = 56,
    this.loadingWidget,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final responsiveHeight = ResponsiveUtils.scaleSize(
      context,
      height,
      minScale: 0.8,
      maxScale: 1.5,
    );
    final responsiveBorderRadius = ResponsiveUtils.borderRadius(context, 28);

    return SizedBox(
      width: width ?? double.infinity,
      height: responsiveHeight,
      child: GlassContainer(
        borderRadius: responsiveBorderRadius,
        padding: const EdgeInsets.all(0),
        border: Border.all(
          color: borderColor ?? AppTheme.primaryColor,
          width: 2,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isLoading ? null : onPressed,
            borderRadius: BorderRadius.circular(responsiveBorderRadius),
            child: Center(
              child: isLoading
                ? (loadingWidget ?? SizedBox(
                    height: ResponsiveUtils.scaleSize(context, 20, minScale: 0.8, maxScale: 1.5),
                    width: ResponsiveUtils.scaleSize(context, 20, minScale: 0.8, maxScale: 1.5),
                    child: const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2,
                    ),
                  ))
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: AutoSizeText(
                      text,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, 18, minSize: 14, maxSize: 27),
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      minFontSize: 10,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
            ),
          ),
        ),
      ),
    );
  }
}