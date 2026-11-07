import 'package:bookcase/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

/// Avisos transitórios com uma aparência consistente em todo o aplicativo.
class AppAlert {
  AppAlert._();

  static void success(BuildContext context, String message) =>
      _show(context, message, ToastificationType.success);

  static void error(BuildContext context, String message) =>
      _show(context, message, ToastificationType.error);

  static void info(BuildContext context, String message) =>
      _show(context, message, ToastificationType.info);

  static void _show(
    BuildContext context,
    String message,
    ToastificationType type,
  ) {
    if (!context.mounted) return;

    final (title, color, icon) = switch (type) {
      ToastificationType.success => (
        'Tudo certo!',
        const Color(0xFF358568),
        Icons.check_circle_rounded,
      ),
      ToastificationType.error => (
        'Não foi possível concluir',
        AppColors.danger,
        Icons.error_outline_rounded,
      ),
      _ => ('Fique por dentro', AppColors.primary, Icons.info_outline_rounded),
    };

    toastification.dismissAll();
    toastification.show(
      overlayState: Navigator.of(context, rootNavigator: true).overlay,
      type: type,
      style: ToastificationStyle.flatColored,
      alignment: Alignment.topCenter,
      autoCloseDuration: Duration(
        seconds: type == ToastificationType.error ? 7 : 5,
      ),
      animationDuration: const Duration(milliseconds: 250),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
      description: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium
            ?.copyWith(color: AppColors.textSecondary),
      ),
      icon: Icon(icon, color: color),
      primaryColor: color,
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textPrimary,
      borderRadius: BorderRadius.circular(18),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      showProgressBar: false,
      closeOnClick: false,
      dragToClose: true,
      pauseOnHover: true,
    );
  }
}
