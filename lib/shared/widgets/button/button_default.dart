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
  final bool isLoading;

  const ButtonDefault({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
    this.width = ButtonWidth.fit,
    this.prefixIcon,
    this.suffixIcon,
    this.size = ButtonSize.md,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width == ButtonWidth.full ? double.infinity : null,
      height: switch (size) {
        ButtonSize.sm => 36,
        ButtonSize.md => 48,
      },
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (variant == ButtonVariant.transparent &&
                states.contains(WidgetState.hovered)) {
              return Colors.white;
            }

            return switch (variant) {
              ButtonVariant.primary => AppColors.primary,
              ButtonVariant.transparent => Colors.transparent,
              ButtonVariant.secondary => Colors.white,
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
                : AppColors.textPrimary,
          ),

          elevation: WidgetStateProperty.all(
            variant == ButtonVariant.transparent ||
                    variant == ButtonVariant.secondary
                ? 0
                : null,
          ),

          shadowColor: WidgetStateProperty.all(
            variant == ButtonVariant.transparent ? Colors.transparent : null,
          ),

          side: WidgetStateProperty.all(
            variant == ButtonVariant.secondary
                ? const BorderSide(color: AppColors.border, width: 1)
                : BorderSide.none,
          ),

          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
          ),

          padding: WidgetStateProperty.all(
            EdgeInsets.symmetric(
              horizontal: size == ButtonSize.sm ? 12 : 20,
            ),
          ),

          textStyle: WidgetStateProperty.all(
            Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: size == ButtonSize.sm ? 13 : 15,
                ),
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: variant == ButtonVariant.primary
                      ? Colors.white
                      : AppColors.primary,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: [
                  ?prefixIcon,
                  Flexible(
                    child: Text(
                      text,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  ?suffixIcon,
                ],
              ),
      ),
    );
  }
}
