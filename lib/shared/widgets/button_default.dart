import 'package:bookcase/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

enum ButtonVariant {
  primary, 
  secondary,
  transparent
}

enum ButtonWidth {
  fit, 
  full
}

enum ButtonSize {
  sm, md
}

class ButtonDefault extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonWidth width;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ButtonSize size;

  const ButtonDefault({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
    this.width = ButtonWidth.fit,
    this.prefixIcon,
    this.suffixIcon,
    this.size = ButtonSize.md
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width == ButtonWidth.full ? double.infinity : null,
      height: switch (size) { ButtonSize.sm => 36, ButtonSize.md => 44 },
      child: ElevatedButton(
        onPressed: onPressed, 
        style: ElevatedButton.styleFrom(
          backgroundColor: variant == ButtonVariant.primary
              ? AppColors.primary
              : variant == ButtonVariant.transparent
                  ? Colors.white
                  : null,

          foregroundColor: variant == ButtonVariant.primary
              ? Colors.white
              : variant == ButtonVariant.transparent
                  ? AppColors.primary
                  : null,

          elevation: variant == ButtonVariant.transparent ? 0 : null,
          shadowColor: variant == ButtonVariant.transparent
              ? Colors.transparent
              : null,

          textStyle: Theme.of(context).textTheme.labelLarge
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ?prefixIcon,
            Text(text),
            ?suffixIcon         
          ],
      ))
    );
  }

}