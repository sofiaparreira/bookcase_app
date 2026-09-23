import 'package:bookcase/core/theme/app_colors.dart';
import 'package:bookcase/shared/widgets/button/button_default.dart';
import 'package:flutter/material.dart';

enum BadgeVariant {
  primary,
  secondary,
  transparent
}
class BadgeDefault extends StatelessWidget {
  final String text;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final BadgeVariant variant;

  const BadgeDefault({
    super.key,
    required this.text,
    this.variant = BadgeVariant.primary,
    this.prefixIcon,
    this.suffixIcon
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: variant == BadgeVariant.primary ?  AppColors.primary10: null,
        
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ?prefixIcon,
          Text(text, style: TextStyle(color: variant == BadgeVariant.primary ? AppColors.primary : null, fontWeight: FontWeight.w600, fontSize: 12)),
          ?suffixIcon
        ],
      ),
    );
  }
}