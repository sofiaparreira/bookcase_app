// Feito por: João e Sofia Parreira Passos

import 'package:bookcase/core/theme/app_colors.dart';
import 'package:bookcase/core/theme/app_decorations.dart';
import 'package:bookcase/shared/widgets/button/button_default.dart';
import 'package:bookcase/shared/widgets/modal/confirm_dialog.dart';
import 'package:bookcase/shared/widgets/sub_page_layout.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'meta_form_screen.dart';

class MetaItem {
  final String titulo;
  final String tipo;
  final int atual;
  final int total;
  final String prazo;

  const MetaItem({
    required this.titulo,
    required this.tipo,
    required this.atual,
    required this.total,
    required this.prazo,
  });

  double get progresso => atual / total;
}

class MetaDetalheScreen extends StatelessWidget {
  final MetaItem meta;

  const MetaDetalheScreen({super.key, required this.meta});

  Future<void> _deleteGoal(BuildContext context) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Excluir meta?',
      message: 'Essa ação removerá “${meta.titulo}” das suas metas.',
      confirmText: 'Excluir',
      destructive: true,
    );

    if (!confirmed || !context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Exclusão na próxima etapa')));
  }

  @override
  Widget build(BuildContext context) {
    final progress = meta.progresso.clamp(0.0, 1.0);
    final percentage = (progress * 100).round();
    final isComplete = progress >= 1;

    return SubPageLayout(
      title: 'Detalhe da meta',
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: AppDecorations.card,
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isComplete
                                    ? AppColors.cream
                                    : AppColors.primary10,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Icon(
                                meta.tipo == 'livros'
                                    ? LucideIcons.bookOpen
                                    : LucideIcons.fileText,
                                size: 25,
                                color: isComplete
                                    ? AppColors.secondary
                                    : AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isComplete
                                          ? AppColors.cream
                                          : AppColors.primary10,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      isComplete ? 'Concluída' : 'Em andamento',
                                      style: TextStyle(
                                        color: isComplete
                                            ? AppColors.secondary
                                            : AppColors.primary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 9),
                                  Text(
                                    meta.titulo,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      height: 1.25,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Progresso',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${meta.atual} de ${meta.total} ${meta.tipo}',
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '$percentage%',
                              style: TextStyle(
                                color: isComplete
                                    ? AppColors.secondary
                                    : AppColors.primary,
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                height: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 11,
                            color: isComplete
                                ? AppColors.secondary
                                : AppColors.primary,
                            backgroundColor: AppColors.surfaceBorder,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: AppDecorations.card,
                    child: Column(
                      children: [
                        _DetailRow(
                          icon: LucideIcons.layers3,
                          label: 'Tipo da meta',
                          value: meta.tipo == 'livros' ? 'Livros' : 'Páginas',
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Divider(
                            height: 1,
                            color: AppColors.surfaceBorder,
                          ),
                        ),
                        _DetailRow(
                          icon: LucideIcons.calendarDays,
                          label: 'Prazo',
                          value: meta.prazo,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: const BoxDecoration(
                color: AppColors.background,
                border: Border(top: BorderSide(color: AppColors.surfaceBorder)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ButtonDefault(
                      text: 'Excluir',
                      variant: ButtonVariant.secondary,
                      size: ButtonSize.lg,
                      prefixIcon: const Icon(
                        LucideIcons.trash2,
                        size: 18,
                        color: AppColors.danger,
                      ),
                      onPressed: () => _deleteGoal(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ButtonDefault(
                      text: 'Editar',
                      size: ButtonSize.lg,
                      prefixIcon: const Icon(LucideIcons.pencil, size: 18),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MetaFormScreen(meta: meta),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primary10,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
