// Feito por: Sofia Parreira Passos

import 'dart:ui';

import 'package:bookcase/core/theme/app_colors.dart';
import 'package:bookcase/core/theme/app_decorations.dart';
import 'package:bookcase/features/my_bookshelf/bookshelf_actions.dart';
import 'package:bookcase/features/my_bookshelf/bookshelf_store.dart';
import 'package:bookcase/features/shopping_list/shopping_list_actions.dart';
import 'package:bookcase/models/book.dart';
import 'package:bookcase/shared/widgets/alerts/app_alert.dart';
import 'package:bookcase/shared/widgets/button/button_default.dart';
import 'package:bookcase/shared/widgets/progress/reading_progress_bar.dart';
import 'package:bookcase/shared/widgets/text/title_h1.dart';
import 'package:bookcase/shared/widgets/text/title_h3.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class BookDetailsPage extends StatelessWidget {
  final Book book;

  const BookDetailsPage({super.key, required this.book});

  Future<void> openBookStatusModal(BuildContext context) async {
    await BookshelfActions.selectStatus(context, book);
  }

  Future<void> _startReading(BuildContext context) async {
    try {
      final saved = await BookshelfActions.startReading(context, book);
      if (saved && context.mounted) {
        AppAlert.success(context, 'Leitura iniciada!');
      }
    } catch (_) {
      if (context.mounted) {
        AppAlert.error(
          context,
          'Não foi possível iniciar a leitura. Tente novamente.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: BookshelfStore.instance,
      builder: (context, _) {
        final shelfBook = BookshelfStore.instance.find(book);
        final isReading = shelfBook?.status == EnumBookStatus.reading;
        final isWant = shelfBook?.status == EnumBookStatus.want;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 300,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _BackgroundCover(imageUrl: book.image),
                      BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                        child: Container(
                          color: AppColors.darkPurple.withValues(alpha: 0.62),
                        ),
                      ),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0x22000000), Color(0x99000000)],
                          ),
                        ),
                      ),
                      SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    onPressed: () => Navigator.pop(context),
                                    style: IconButton.styleFrom(
                                      fixedSize: const Size.square(40),
                                      backgroundColor: Colors.white.withValues(
                                        alpha: 0.16,
                                      ),
                                      foregroundColor: Colors.white,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius:
                                            AppDecorations.buttonBorderRadius,
                                      ),
                                    ),
                                    icon: const Icon(
                                      LucideIcons.arrowLeft,
                                      size: 20,
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: 'Adicionar à lista de compras',
                                    onPressed: () =>
                                        ShoppingListActions.addBook(
                                          context,
                                          book,
                                        ),
                                    style: IconButton.styleFrom(
                                      fixedSize: const Size.square(40),
                                      backgroundColor: Colors.white.withValues(
                                        alpha: 0.16,
                                      ),
                                      foregroundColor: Colors.white,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius:
                                            AppDecorations.buttonBorderRadius,
                                      ),
                                    ),
                                    icon: const Icon(
                                      Icons.add_shopping_cart_rounded,
                                      size: 21,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  _BookCover(imageUrl: book.image),
                                  const SizedBox(width: 18),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          TitleH1(
                                            text: book.title,
                                            color: Colors.white,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),

                                          const SizedBox(height: 8),
                                          Text(
                                            book.author,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: Colors.white.withValues(
                                                alpha: 0.78,
                                              ),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 14),
                                          _MetadataBadge(
                                            icon: LucideIcons.bookOpen,
                                            label: book.totalPages > 0
                                                ? '${book.totalPages} páginas'
                                                : 'Páginas não informadas',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: isReading && shelfBook != null
                                    ? [
                                        Expanded(
                                          child: ButtonDefault(
                                            text: 'Atualizar progresso',
                                            width: ButtonWidth.full,
                                            size: ButtonSize.md,
                                            onPressed: () =>
                                                BookshelfActions.editProgress(
                                                  context,
                                                  shelfBook,
                                                ),
                                          ),
                                        ),
                                      ]
                                    : [
                                        Expanded(
                                          child: ButtonDefault(
                                            text: isWant
                                                ? 'Quero ler'
                                                : 'Adicionar à estante',
                                            suffixIcon: isWant
                                                ? const Icon(
                                                    LucideIcons.chevronDown,
                                                    size: 18,
                                                  )
                                                : null,
                                            width: ButtonWidth.full,
                                            size: ButtonSize.md,
                                            onPressed: () =>
                                                openBookStatusModal(context),
                                          ),
                                        ),
                                        if (isWant) ...[
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: ButtonDefault(
                                              text: 'Iniciar leitura',
                                              width: ButtonWidth.full,
                                              size: ButtonSize.md,
                                              variant: ButtonVariant.secondary,
                                              onPressed: () =>
                                                  _startReading(context),
                                            ),
                                          ),
                                        ],
                                      ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  color: AppColors.background,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 118,
                          child: Row(
                            children: [
                              Expanded(
                                child: _DetailRow(
                                  icon: LucideIcons.bookOpen,
                                  label: 'Páginas',
                                  value: book.totalPages > 0
                                      ? book.totalPages.toString()
                                      : 'Não informado',
                                ),
                              ),
                              if (book.isbn.isNotEmpty) ...[
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _DetailRow(
                                    icon: LucideIcons.scanBarcode,
                                    label: 'ISBN',
                                    value: book.isbn,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        if (isReading && shelfBook != null) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Progresso de leitura'),
                              Text('${shelfBook.progressPercent}%'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ReadingProgressBar(progress: shelfBook.progress),
                          const SizedBox(height: 8),
                          Text(
                            shelfBook.totalPages > 0
                                ? '${shelfBook.currentPage} de ${shelfBook.totalPages} páginas'
                                : '${shelfBook.progressPercent}% concluído',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                        TitleH3(text: "Avaliação geral"),
                        Row(
                          children: [
                            ...List.generate(5, (index) {
                              final rating = book.averageRating ?? 0;
                              final starValue = index + 1;
                              final IconData icon = rating >= starValue
                                  ? Icons.star
                                  : rating >= starValue - 0.5
                                  ? Icons.star_half
                                  : Icons.star_outline;

                              return Icon(
                                icon,
                                color: icon == Icons.star_outline
                                    ? AppColors.textTertiary
                                    : Colors.yellow,
                                size: 22,
                              );
                            }),
                            SizedBox(width: 6),
                            Text(
                              book.averageRating?.toStringAsFixed(1) ?? '—',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        TitleH3(text: "Sinopse"),
                        Text(book.description ?? ''),
                        if (!isReading) ...[
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: ButtonDefault(
                                  text: isWant
                                      ? 'Quero ler'
                                      : 'Adicionar à estante',
                                  width: ButtonWidth.full,
                                  size: ButtonSize.lg,
                                  prefixIcon: isWant
                                      ? null
                                      : const Icon(LucideIcons.plus, size: 19),
                                  suffixIcon: isWant
                                      ? const Icon(
                                          LucideIcons.chevronDown,
                                          size: 18,
                                        )
                                      : null,
                                  onPressed: () => openBookStatusModal(context),
                                ),
                              ),
                              if (isWant) ...[
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ButtonDefault(
                                    text: 'Iniciar leitura',
                                    width: ButtonWidth.full,
                                    size: ButtonSize.lg,
                                    variant: ButtonVariant.secondary,
                                    onPressed: () => _startReading(context),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BackgroundCover extends StatelessWidget {
  final String imageUrl;

  const _BackgroundCover({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return const ColoredBox(color: AppColors.primary);
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
      errorBuilder: (context, error, stackTrace) =>
          const ColoredBox(color: AppColors.primary),
    );
  }
}

class _BookCover extends StatelessWidget {
  final String imageUrl;

  const _BookCover({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 144,
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl.isEmpty
          ? const Icon(
              LucideIcons.bookOpen,
              color: AppColors.textTertiary,
              size: 34,
            )
          : Image.network(
              imageUrl,
              fit: BoxFit.cover,
              webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
              errorBuilder: (context, error, stackTrace) => const Icon(
                LucideIcons.bookOpen,
                color: AppColors.textTertiary,
                size: 34,
              ),
            ),
    );
  }
}

class _MetadataBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetadataBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: Colors.white),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
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
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary10,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 17, color: AppColors.primary),
          ),
          const Spacer(),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textTertiary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
