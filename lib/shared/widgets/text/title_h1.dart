import 'package:bookcase/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class TitleH1 extends StatelessWidget {
  final String text;
  final Color? color;
  final int? maxLines;
  final TextOverflow? overflow;

  const TitleH1({
    super.key,
    required this.text,
    this.color,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: maxLines,
      overflow: overflow,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: color ?? AppColors.textPrimary,
      ),
    );
  }
}
