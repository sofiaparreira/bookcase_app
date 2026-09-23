import 'package:bookcase/core/theme/app_colors.dart';
import 'package:bookcase/core/theme/app_decorations.dart';
import 'package:flutter/material.dart';

enum EnumMetricCardVariant {
  primary, secondary, neutral
}
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
    this.variant = EnumMetricCardVariant.neutral
  });

  @override
  Widget build(BuildContext context) {
    final Color color = switch (variant) {
      EnumMetricCardVariant.primary => AppColors.primary,
      EnumMetricCardVariant.secondary => AppColors.secondary,
      EnumMetricCardVariant.neutral => AppColors.textPrimary
    };

    return Expanded(
      child: Container(
        
        decoration: AppDecorations.card,
          
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              spacing: 4,
              children: [
              IconTheme(data: IconThemeData(color: color), child: icon), 
              Text(
                number.toString(), 
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w900,
                  fontSize: 20
                ),), 
                Text(text, style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                  fontSize: 12
                ),)
            ],),
          ),
      )
      );
  }
}