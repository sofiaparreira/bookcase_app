import 'package:bookcase/core/theme/app_colors.dart';
import 'package:bookcase/core/theme/app_decorations.dart';
import 'package:flutter/material.dart';

enum EnumMetricCardVariant { primary, secondary, neutral }

class MetricCard extends StatelessWidget {
  final int number;
  final Widget icon;
  final String text;
  final EnumMetricCardVariant variant;

  const MetricCard({
    super.key,
    required this.number,
    required this.icon,
    required this.text,
    this.variant = EnumMetricCardVariant.neutral,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = switch (variant) {
      EnumMetricCardVariant.primary => AppColors.primary,
      EnumMetricCardVariant.secondary => AppColors.secondary,
      EnumMetricCardVariant.neutral => AppColors.darkPurple,
    };

    return Expanded(
      child: Container(
        height: 116,
        padding: const EdgeInsets.all(12),
        decoration: AppDecorations.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconTheme(
                data: IconThemeData(color: color, size: 18),
                child: icon,
              ),
            ),
            const Spacer(),
            Text(
              number.toString(),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 21,
                height: 1,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
                fontSize: 11,
                height: 1.15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
