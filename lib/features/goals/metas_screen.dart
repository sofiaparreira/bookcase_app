// Feito por: João e Sofia Parreira Passos
import 'package:bookcase/core/theme/app_colors.dart';
import 'package:bookcase/core/theme/app_decorations.dart';
import 'package:bookcase/core/theme/app_shadow.dart';
import 'package:bookcase/shared/widgets/button/button_default.dart';
import 'package:bookcase/shared/widgets/button/icon_button_default.dart';
import 'package:bookcase/shared/widgets/text/title_h1.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'meta_detalhe_screen.dart';
import 'meta_form_screen.dart';

const List<MetaItem> _metas = [
  MetaItem(
    titulo: 'Ler 12 livros em 2026',
    tipo: 'livros',
    atual: 8,
    total: 12,
    prazo: '31/12/2026',
  ),
  MetaItem(
    titulo: '3.000 páginas no semestre',
    tipo: 'páginas',
    atual: 1450,
    total: 3000,
    prazo: '30/11/2026',
  ),
  MetaItem(
    titulo: 'Clássicos brasileiros',
    tipo: 'livros',
    atual: 1,
    total: 5,
    prazo: '31/01/2027',
  ),
  MetaItem(
    titulo: '500 páginas em outubro',
    tipo: 'páginas',
    atual: 500,
    total: 500,
    prazo: '31/10/2026',
  ),
];

class MetasScreen extends StatelessWidget {
  const MetasScreen({super.key});

  static const double _bottomNavigationSpace = 92;

  void _openForm(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MetaFormScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final completedGoals = _metas.where((meta) => meta.progresso >= 1).length;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Container(
        decoration: AppDecorations.header,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: TitleH1(
                            text: 'Minhas metas',
                            color: Colors.white,
                          ),
                        ),
                        IconButtonDefault(
                          icon: const Icon(LucideIcons.plus),
                          tooltip: 'Criar nova meta',
                          variant: ButtonVariant.secondary,
                          onPressed: () => _openForm(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${_metas.length} metas  •  $completedGoals concluída${completedGoals == 1 ? '' : 's'}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.72),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      20,
                      16,
                      _bottomNavigationSpace,
                    ),
                    itemCount: _metas.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final meta = _metas[index];
                      return _GoalCard(
                        meta: meta,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MetaDetalheScreen(meta: meta),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final MetaItem meta;
  final VoidCallback onTap;

  const _GoalCard({required this.meta, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isComplete = meta.progresso >= 1;
    final progress = meta.progresso.clamp(0.0, 1.0);
    final percentage = (progress * 100).round();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.surfaceBorder),
        boxShadow: AppShadows.card,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isComplete
                            ? AppColors.cream
                            : AppColors.primary10,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(
                        meta.tipo == 'livros'
                            ? LucideIcons.bookOpen
                            : LucideIcons.fileText,
                        size: 21,
                        color: isComplete
                            ? AppColors.secondary
                            : AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            meta.titulo,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              const Icon(
                                LucideIcons.calendarDays,
                                size: 13,
                                color: AppColors.textTertiary,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'Até ${meta.prazo}',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      LucideIcons.chevronRight,
                      size: 20,
                      color: AppColors.textTertiary,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${meta.atual} de ${meta.total} ${meta.tipo}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      '$percentage%',
                      style: TextStyle(
                        color: isComplete
                            ? AppColors.secondary
                            : AppColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 9,
                    color: isComplete ? AppColors.secondary : AppColors.primary,
                    backgroundColor: AppColors.surfaceBorder,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
