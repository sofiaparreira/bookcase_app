import 'package:bookcase/core/theme/app_colors.dart';
import 'package:bookcase/core/theme/app_decorations.dart';
import 'package:bookcase/shared/widgets/badge_default.dart';
import 'package:bookcase/shared/widgets/button/button_default.dart';
import 'package:bookcase/shared/widgets/progress/reading_progress_bar.dart';
import 'package:bookcase/shared/widgets/title_card.dart';
import 'package:flutter/material.dart';

class ReadingCard extends StatelessWidget {
  final String title;
  final String author;
  final int currentPage;
  final int totalPages;
  final double progress;
  final int progressPercent;
  final VoidCallback onUpdateProgress;
  final String? imageUrl;

  const ReadingCard({
    super.key,
    required this.title,
    required this.author,
    required this.currentPage,
    required this.totalPages,
    required this.progress,
    required this.progressPercent,
    required this.onUpdateProgress,
    this.imageUrl,
  });

  static const double _coverWidth = 104;
  static const double _gap = 14;

  @override
  Widget build(BuildContext context) {
    final cardWidth = (MediaQuery.sizeOf(context).width - 40).clamp(
      300.0,
      360.0,
    );

    return Container(
      width: cardWidth,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppDecorations.card.borderRadius,
        boxShadow: [
          BoxShadow(
            color: AppColors.darkPurple.withValues(alpha: 0.10),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: _coverWidth,
              child: _buildCover(),
            ),
            Padding(
              padding: const EdgeInsets.only(left: _coverWidth + _gap),
              child: _buildInfo(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfo() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BadgeDefault(text: 'Lendo'),
        const SizedBox(height: 8),

        TitleCard(text: title),
        const SizedBox(height: 2),

        Text(
          author,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),

        const SizedBox(height: 10),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              totalPages > 0
                  ? 'Pág. $currentPage de $totalPages'
                  : '$progressPercent% concluído',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            Text(
              '$progressPercent%',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
        ),

        const SizedBox(height: 5),

        ReadingProgressBar(
          progress: progress,
          semanticLabel: 'Progresso de leitura de $title',
        ),

        const SizedBox(height: 10),

        ButtonDefault(
          text: 'Atualizar progresso',
          size: ButtonSize.sm,
          width: ButtonWidth.fit,
          onPressed: onUpdateProgress,
        ),
      ],
    );
  }

  Widget _buildCover() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: (imageUrl != null && imageUrl!.isNotEmpty)
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _coverPlaceholder(isLoading: true);
                },
                errorBuilder: (context, error, stackTrace) =>
                    _coverPlaceholder(),
              )
            : _coverPlaceholder(),
      ),
    );
  }

  Widget _coverPlaceholder({bool isLoading = false}) {
    return Container(
      color: Colors.grey.shade100,
      child: Center(
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(
                Icons.menu_book_rounded,
                size: 36,
                color: Colors.grey.shade400,
              ),
      ),
    );
  }
}