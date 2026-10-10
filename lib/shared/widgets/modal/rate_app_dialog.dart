// Feito por: Maria Luiza Bertolino Matos
import 'package:bookcase/core/theme/app_colors.dart';
import 'package:bookcase/shared/widgets/button/button_default.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

Future<int?> showRateAppDialog(BuildContext context) {
  return showDialog<int>(
    context: context,
    builder: (_) => const _RateAppDialog(),
  );
}

class _RateAppDialog extends StatefulWidget {
  const _RateAppDialog();

  @override
  State<_RateAppDialog> createState() => _RateAppDialogState();
}

class _RateAppDialogState extends State<_RateAppDialog> {
  static const _labels = ['Ruim', 'Regular', 'Bom', 'Muito bom', 'Excelente'];

  int _rating = 0;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Avaliar o app',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'O que você está achando do Página?',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var star = 1; star <= 5; star++)
                  IconButton(
                    onPressed: () => setState(() => _rating = star),
                    tooltip: '$star de 5',
                    icon: Icon(
                      star <= _rating ? Icons.star_rounded : LucideIcons.star,
                      size: star <= _rating ? 36 : 30,
                      color: star <= _rating
                          ? AppColors.secondary
                          : AppColors.textTertiary,
                    ),
                  ),
              ],
            ),
            SizedBox(
              height: 20,
              child: Text(
                _rating == 0 ? '' : _labels[_rating - 1],
                style: const TextStyle(
                  color: AppColors.secondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              spacing: 8,
              children: [
                Expanded(
                  child: ButtonDefault(
                    text: 'Cancelar',
                    variant: ButtonVariant.secondary,
                    width: ButtonWidth.full,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Expanded(
                  child: ButtonDefault(
                    text: 'Enviar',
                    width: ButtonWidth.full,
                    onPressed: _rating == 0
                        ? null
                        : () => Navigator.pop(context, _rating),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
