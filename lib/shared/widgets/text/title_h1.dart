import 'package:bookcase/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class TitleH1 extends StatelessWidget {
  final String text;
  final Color? color;

  const TitleH1({
    super.key,
    required this.text,
    this.color
  });

  @override
  Widget build(BuildContext context) {
    return Text(text, style: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: color ?? AppColors.textPrimary
    ));
  }
}