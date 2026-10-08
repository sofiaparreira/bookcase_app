import 'package:bookcase/core/theme/app_colors.dart';
import 'package:bookcase/core/theme/app_decorations.dart';
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

  const BookCard({
    super.key,
    required this.title,
    required this.author,
    required this.totalPages,
    this.imageUrl,
    this.onPressedCard
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
                _buildCover(),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TitleCard(text: title),
                      Text(author),
                      Text(totalPages.toString()),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                IconButtonDefault(
                  icon: Icon(LucideIcons.plus),
                  onPressed: () {},
                  variant: ButtonVariant.primary,
                  size: ButtonSize.sm,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCover() {
    return Container(
      width: 82,
      height: 124,
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
