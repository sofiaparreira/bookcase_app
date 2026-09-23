import 'package:bookcase/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

enum ButtonVariant { primary, secondary, transparent }

enum ButtonWidth { fit, full }

enum ButtonSize { sm, md }

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
    this.size = ButtonSize.md,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width == ButtonWidth.full ? double.infinity : null,
      height: switch (size) {
        ButtonSize.sm => 36,
        ButtonSize.md => 44,
      },
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (variant == ButtonVariant.transparent &&
                states.contains(WidgetState.hovered)) {
              return Colors.white;
            }

            return switch (variant) {
              ButtonVariant.primary => AppColors.primary,
              ButtonVariant.transparent => Colors.transparent,
              ButtonVariant.secondary => null,
            };
          }),

          overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (variant == ButtonVariant.transparent &&
                states.contains(WidgetState.hovered)) {
              return Colors.transparent;
            }

            return null;
          }),

          foregroundColor: WidgetStateProperty.all(
            variant == ButtonVariant.primary
                ? Colors.white
                : variant == ButtonVariant.transparent
                ? AppColors.primary
                : null,
          ),

          elevation: WidgetStateProperty.all(
            variant == ButtonVariant.transparent ? 0 : null,
          ),

          shadowColor: WidgetStateProperty.all(
            variant == ButtonVariant.transparent ? Colors.transparent : null,
          ),

          textStyle: WidgetStateProperty.all(
            Theme.of(context).textTheme.labelLarge,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [?prefixIcon, Text(text), ?suffixIcon],
        ),
      ),
    );
  }
}
