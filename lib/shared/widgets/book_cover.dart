// Feito por: Maria Luiza Bertolino Matos
import 'package:flutter/material.dart';

class BookCover extends StatelessWidget {
  final String? imageUrl;
  final double width;
  final double height;

  const BookCover({
    super.key,
    this.imageUrl,
    this.width = 82,
    this.height = 124,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(width < 72 ? 8 : 12);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: (imageUrl != null && imageUrl!.isNotEmpty)
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _placeholder(isLoading: true);
                },
                errorBuilder: (context, error, stackTrace) => _placeholder(),
              )
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder({bool isLoading = false}) {
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
                size: width * 0.44,
                color: Colors.grey.shade400,
              ),
      ),
    );
  }
}
