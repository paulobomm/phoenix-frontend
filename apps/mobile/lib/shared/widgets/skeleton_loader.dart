import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_colors.dart';

class SkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.card,
      highlightColor: AppColors.surface,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Shimmer.fromColors(
        baseColor: AppColors.surface,
        highlightColor: AppColors.border,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 16, width: 180, decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(4))),
            const SizedBox(height: 8),
            Container(height: 12, width: 120, decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(4))),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(height: 24, width: 60, decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(6))),
                const SizedBox(width: 8),
                Container(height: 24, width: 80, decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(6))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
