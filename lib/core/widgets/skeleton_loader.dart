import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../theme/app_theme.dart';

class SkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius borderRadius;

  const SkeletonLoader({
    super.key,
    this.width = double.infinity,
    this.height = 20,
    this.borderRadius = const BorderRadius.all(Radius.circular(AppRadius.xs)),
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius,
        ),
      ),
    );
  }
}

// Specialized skeleton variants
class SkeletonChip extends StatelessWidget {
  const SkeletonChip({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonLoader(
      width: 80,
      height: 36,
      borderRadius: BorderRadius.circular(AppRadius.md + 2), // 18
    );
  }
}

class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonLoader(height: 24, width: 200),
          SizedBox(height: 8),
          SkeletonLoader(height: 16),
          SkeletonLoader(height: 16, width: 150),
        ],
      ),
    );
  }
}
