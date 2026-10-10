// Feito por: Maria Luiza Bertolino Matos
import 'package:bookcase/core/theme/app_colors.dart';
import 'package:bookcase/core/theme/app_decorations.dart';
import 'package:bookcase/models/book.dart';
import 'package:bookcase/models/shelf_book.dart';
import 'package:bookcase/shared/widgets/book_cover.dart';
import 'package:bookcase/shared/widgets/button/button_default.dart';
import 'package:bookcase/shared/widgets/progress/reading_progress_bar.dart';
import 'package:bookcase/shared/widgets/title_card.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ShelfBookCard extends StatelessWidget {
  final ShelfBook shelfBook;
  final VoidCallback onChangeStatus;
  final VoidCallback onEditProgress;
  final ValueChanged<double> onProgressChanged;
  final VoidCallback onFinish;
  final VoidCallback onStartReading;

  static const double progressStep = 0.05;

  const ShelfBookCard({
    super.key,
    required this.shelfBook,
    required this.onChangeStatus,
    required this.onEditProgress,
    required this.onProgressChanged,
    required this.onFinish,
    required this.onStartReading,
  });

  @override
  Widget build(BuildContext context) {
    final book = shelfBook.book;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: AppDecorations.card.borderRadius,
      ),
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BookCover(imageUrl: book.image),
          const SizedBox(width: 16),
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 124),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: TitleCard(text: book.title)),
                          SizedBox.square(
                            dimension: 32,
                            child: IconButton(
                              onPressed: onChangeStatus,
                              tooltip: 'Alterar status',
                              padding: EdgeInsets.zero,
                              iconSize: 18,
                              color: AppColors.textSecondary,
                              icon: const Icon(LucideIcons.ellipsisVertical),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        book.author,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  switch (shelfBook.status) {
                    EnumBookStatus.reading => _buildReading(),
                    EnumBookStatus.finished => _buildFinished(),
                    EnumBookStatus.want => _buildWant(),
                  },
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReading() {
    final progress = shelfBook.progress;
    final hasPages = shelfBook.totalPages > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                hasPages
                    ? 'Pág. ${shelfBook.currentPage} de ${shelfBook.totalPages}'
                    : 'Progresso',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ),
            Text(
              '${shelfBook.progressPercent}%',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        Row(
          spacing: 8,
          children: [
            _StepButton(
              icon: LucideIcons.minus,
              tooltip: 'Diminuir progresso',
              backgroundColor: AppColors.cream,
              iconColor: AppColors.primary,
              onPressed: progress > 0
                  ? () => onProgressChanged(_step(progress, -progressStep))
                  : null,
            ),
            Expanded(
              child: GestureDetector(
                onTap: onEditProgress,
                child: ReadingProgressBar(
                  progress: progress,
                  height: 10,
                  semanticLabel:
                      'Progresso de leitura de ${shelfBook.book.title}',
                ),
              ),
            ),
            _StepButton(
              icon: LucideIcons.plus,
              tooltip: 'Aumentar progresso',
              backgroundColor: AppColors.primary,
              iconColor: Colors.white,
              onPressed: progress < 1
                  ? () => onProgressChanged(_step(progress, progressStep))
                  : null,
            ),
          ],
        ),
        Row(
          spacing: 8,
          children: [
            TextButton(
              onPressed: onEditProgress,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(0, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: const Text('Editar progresso'),
            ),
            if (shelfBook.progressPercent >= 100)
              ButtonDefault(
                text: 'Concluir leitura',
                size: ButtonSize.sm,
                onPressed: onFinish,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildFinished() {
    final rating = shelfBook.rating ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6,
      children: [
        Row(
          spacing: 8,
          children: [
            const Expanded(
              child: ReadingProgressBar(
                progress: 1,
                height: 10,
                color: AppColors.secondary,
              ),
            ),
            const Text(
              '100%',
              style: TextStyle(
                color: AppColors.secondary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        Semantics(
          label: 'Avaliação: $rating de 5 estrelas',
          child: ExcludeSemantics(
            child: Row(
              children: [
                for (var star = 1; star <= 5; star++)
                  Icon(
                    star <= rating ? Icons.star_rounded : LucideIcons.star,
                    size: star <= rating ? 20 : 16,
                    color: star <= rating
                        ? AppColors.secondary
                        : AppColors.textTertiary,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWant() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Text(
          shelfBook.totalPages > 0
              ? '${shelfBook.totalPages} páginas · Não iniciado'
              : 'Não iniciado',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        ButtonDefault(
          text: 'Começar leitura',
          size: ButtonSize.sm,
          prefixIcon: const Icon(LucideIcons.bookOpen, size: 16),
          onPressed: onStartReading,
        ),
      ],
    );
  }

  static double _step(double progress, double delta) {
    const epsilon = 1e-9;
    final position = progress / progressStep;
    final steps = delta > 0
        ? (position + epsilon).floor() + 1
        : (position - epsilon).ceil() - 1;
    return (steps * progressStep).clamp(0.0, 1.0);
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback? onPressed;

  const _StepButton({
    required this.icon,
    required this.tooltip,
    required this.backgroundColor,
    required this.iconColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Opacity(
        opacity: onPressed == null ? 0.4 : 1,
        child: Material(
          color: backgroundColor,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: SizedBox.square(
              dimension: 28,
              child: Icon(icon, size: 14, color: iconColor),
            ),
          ),
        ),
      ),
    );
  }
}
