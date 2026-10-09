import 'package:bookcase/core/theme/app_shadow.dart';
import 'package:flutter/material.dart';
import 'package:bookcase/core/theme/app_colors.dart';

class AppDecorations {
  static const BorderRadius buttonBorderRadius = BorderRadius.all(
    Radius.circular(18),
  );

  static BoxDecoration get card => BoxDecoration(
    color: AppColors.cardSurface,
    borderRadius: BorderRadius.circular(24),
    boxShadow: AppShadows.card,
  );

  static BoxDecoration get header => BoxDecoration(
    gradient: LinearGradient(
      colors: [AppColors.primary, AppColors.darkPurple],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  static BoxDecoration get button => BoxDecoration(
    color: AppColors.cardSurface,
    borderRadius: buttonBorderRadius,
    boxShadow: AppShadows.card,
  );
}
