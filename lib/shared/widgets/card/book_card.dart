import 'package:bookcase/core/theme/app_colors.dart';
import 'package:bookcase/core/theme/app_decorations.dart';
import 'package:bookcase/shared/widgets/book_cover.dart';
import 'package:bookcase/shared/widgets/button/button_default.dart';
import 'package:bookcase/shared/widgets/button/icon_button_default.dart';
import 'package:bookcase/shared/widgets/title_card.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class BookCard extends StatelessWidget {
  final String title;
  final String author;
  final int totalPages;
  final String? imageUrl;
  final VoidCallback? onPressedCard;
  final VoidCallback? onPressedAdd;

  final bool isAdded;

  const BookCard({
    super.key,
    required this.title,
    required this.author,
    required this.totalPages,
    this.imageUrl,
    this.onPressedCard,
    this.onPressedAdd,
    this.isAdded = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressedCard,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: AppDecorations.card.borderRadius,
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: SizedBox(
            width: double.infinity,
            height: 124,
            child: Row(
              children: [
                BookCover(imageUrl: imageUrl),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TitleCard(text: title),
                      Text(author),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            LucideIcons.bookOpen,
                            size: 14,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              totalPages > 0
                                  ? '$totalPages páginas'
                                  : 'Páginas não informadas',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                IconButtonDefault(
                  icon: Icon(isAdded ? LucideIcons.check : LucideIcons.plus),
                  tooltip: isAdded ? 'Alterar status' : 'Adicionar à estante',
                  onPressed: onPressedAdd,
                  variant: isAdded
                      ? ButtonVariant.transparent
                      : ButtonVariant.primary,
                  size: ButtonSize.sm,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
