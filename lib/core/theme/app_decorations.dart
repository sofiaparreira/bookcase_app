import 'package:bookcase/core/theme/app_shadow.dart';
import 'package:flutter/material.dart';
import 'package:bookcase/core/theme/app_colors.dart';

class AppDecorations {
  static BoxDecoration get card => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(14),
    border: Border.all(
      color: Colors.black.withValues(alpha: 0.05),
      width: 1,
    ),
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
    color: Colors.white,
    borderRadius: BorderRadius.circular(999),
    border: Border.all(
      color: Colors.black.withValues(alpha: 0.06),
      width: 1,
    ),
    boxShadow: AppShadows.card,
);
}