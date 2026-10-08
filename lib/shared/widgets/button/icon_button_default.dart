import 'package:bookcase/core/theme/app_colors.dart';
import 'package:bookcase/core/theme/app_decorations.dart';
import 'package:bookcase/shared/widgets/button/button_default.dart';
import 'package:flutter/material.dart';

class IconButtonDefault extends StatelessWidget {
  final Widget icon;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool isLoading;
  final String? tooltip;

  const IconButtonDefault({
    super.key,
    required this.icon,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.md,
    this.isLoading = false,
    this.tooltip,
  });

  double get _dimension => switch (size) {
    ButtonSize.sm => 36,
    ButtonSize.md => 44,
    ButtonSize.lg => 48,
  };

  @override
  Widget build(BuildContext context) {
    final button = SizedBox.square(
      dimension: _dimension,
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
              ButtonVariant.transparent => AppColors.cardSurface,
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
            const RoundedRectangleBorder(
              borderRadius: AppDecorations.buttonBorderRadius,
            ),
          ),
          padding: WidgetStateProperty.all(EdgeInsets.zero),
          minimumSize: WidgetStateProperty.all(Size.zero),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: isLoading
            ? SizedBox.square(
                dimension: size == ButtonSize.sm ? 16 : 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: variant == ButtonVariant.primary
                      ? Colors.white
                      : AppColors.primary,
                ),
              )
            : IconTheme.merge(
                data: IconThemeData(size: size == ButtonSize.sm ? 18 : 22),
                child: icon,
              ),
      ),
    );

    if (tooltip == null || tooltip!.isEmpty) return button;

    return Tooltip(message: tooltip!, child: button);
  }
}
