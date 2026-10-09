import 'package:bookcase/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class ReadingProgressBar extends StatelessWidget {
  final double progress;
  final double height;
  final Color color;
  final Color backgroundColor;
  final String? semanticLabel;

  const ReadingProgressBar({
    super.key,
    required this.progress,
    this.height = 12,
    this.color = AppColors.primary,
    this.backgroundColor = AppColors.surfaceBorder,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedProgress = progress.clamp(0.0, 1.0);
    final progressPercent = (normalizedProgress * 100).round();
    const borderRadius = BorderRadius.all(Radius.circular(999));

    return Semantics(
      label: semanticLabel,
      value: '$progressPercent%',
      child: SizedBox(
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: borderRadius,
              ),
            ),
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: normalizedProgress,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: borderRadius,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
