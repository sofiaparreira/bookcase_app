import 'package:bookcase/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class TitleH2 extends StatelessWidget {
  final String text;
  final Color? color;

  const TitleH2({
    super.key,
    required this.text,
    this.color
  });

  @override
  Widget build(BuildContext context) {
    return Text(text, style: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: color ?? AppColors.textPrimary
    ));
  }
}