// Feito por: Sofia Parreira Passos

import 'package:bookcase/core/theme/app_colors.dart';
import 'package:bookcase/core/theme/app_decorations.dart';
import 'package:bookcase/features/my_bookshelf/bookshelf_store.dart';
import 'package:bookcase/features/shopping_list/shopping_list_page.dart';
import 'package:bookcase/models/book.dart';
import 'package:bookcase/shared/widgets/button/button_default.dart';
import 'package:bookcase/shared/widgets/card/metric_card.dart';
import 'package:bookcase/shared/widgets/card/reading_card.dart';
import 'package:bookcase/shared/widgets/modal/update_reading_progress_modal.dart';
import 'package:bookcase/shared/widgets/text/title_h1.dart';
import 'package:bookcase/shared/widgets/text/title_h2.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class DashboardPage extends StatelessWidget {
  final ValueChanged<int>? onNavigate;

  const DashboardPage({super.key, this.onNavigate});

  // Quantidade de dias seguidos lendo (ofensiva)
  static const int streakDays = 7;

  static const List<ReadingBook> readingBooksList = [
    ReadingBook(
      book: Book(
        id: 1,
        title: 'O Retrato de Dorian Gray',
        author: 'Oscar Wilde',
        isbn: '123123',
        status: EnumBookStatus.reading,
        totalPages: 300,
        image: 'https://darkside.vtexassets.com/arquivos/ids/176888/o-retrato-de-dorian-gray.png?v=637655004354600000',
      ),
      currentPage: 100,
    ),
    ReadingBook(
      book: Book(
        id: 1,
        title: 'O Retrato de Dorian Gray',
        author: 'Oscar Wilde',
        isbn: '123123',
        status: EnumBookStatus.reading,
        totalPages: 300,
        image: 'https://darkside.vtexassets.com/arquivos/ids/176888/o-retrato-de-dorian-gray.png?v=637655004354600000',
      ),
      currentPage: 100,
    ),
  ];

  void _openShoppingList(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ShoppingListPage(onNavigate: onNavigate),
      ),
    );
  }

  void _openGoals() {
    onNavigate?.call(3);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Container(
        decoration: AppDecorations.header,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // TOPO (PARTE ROXA)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Olá',
                          style: TextStyle(
                            color: Color.fromARGB(180, 255, 255, 255),
                            fontSize: 16,
                            fontWeight: FontWeight.w100,
                          ),
                        ),
                        TitleH1(text: 'Ana', color: Colors.white),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white15,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.local_fire_department_rounded,
                            color: AppColors.secondary,
                            size: 22,
                          ),
                          SizedBox(width: 5),
                          Text(
                            '$streakDays dias',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const TitleH2(text: 'Lendo agora', color: Colors.white),
                    TextButton.icon(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppDecorations.buttonBorderRadius,
                        ),
                      ),
                      label: const Text('Ver estante'),
                      iconAlignment: IconAlignment.end,
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
              ),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Row(
                  spacing: 12,
                  children: readingBooksList.map((readingBook) {
                    return ReadingCard(
                      title: readingBook.book.title,
                      author: readingBook.book.author,
                      currentPage: readingBook.currentPage,
                      totalPages: readingBook.book.totalPages,
                      progress: readingBook.progress,
                      progressPercent: readingBook.progressPercent,
                      imageUrl: readingBook.book.image,
                      onUpdateProgress: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) {
                            return UpdateReadingProgressModal(
                              currentPage: readingBook.currentPage,
                              totalPages: readingBook.book.totalPages,
                            );
                          },
                        );
                      },
                    );
                  }).toList(),
                ),
              ),

              // CONTEÚDO BRANCO
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 108),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      spacing: 20,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const TitleH2(text: 'Seu resumo'),
                        ListenableBuilder(
                          listenable: BookshelfStore.instance,
                          builder: (context, _) => Row(
                            spacing: 12,
                            children: [
                              MetricCard(
                                number: BookshelfStore.instance.countWithStatus(
                                  EnumBookStatus.finished,
                                ),
                                icon: const Icon(Icons.menu_book),
                                text: 'Livros lidos',
                                variant: EnumMetricCardVariant.primary,
                              ),
                              const MetricCard(
                                number: 3,
                                icon: Icon(Icons.emoji_events_outlined),
                                text: 'Conquistas',
                                variant: EnumMetricCardVariant.secondary,
                              ),
                              const MetricCard(
                                number: 1552,
                                icon: Icon(Icons.description_outlined),
                                text: 'Páginas lidas',
                                variant: EnumMetricCardVariant.neutral,
                              ),
                            ],
                          ),
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const TitleH2(text: 'Meta atual'),
                            ButtonDefault(
                              text: 'Ver metas',
                              variant: ButtonVariant.transparent,
                              suffixIcon: const Icon(Icons.chevron_right),
                              onPressed: _openGoals,
                            ),
                          ],
                        ),
                        _GoalPreview(onTap: _openGoals),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const TitleH2(text: 'Lista de compras'),
                            ButtonDefault(
                              text: 'Ver lista',
                              variant: ButtonVariant.transparent,
                              suffixIcon: const Icon(Icons.chevron_right),
                              onPressed: () => _openShoppingList(context),
                            ),
                          ],
                        ),
                        _ShoppingListPreview(
                          onTap: () => _openShoppingList(context),
                        ),
                      ],
                    ),
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

class _GoalPreview extends StatelessWidget {
  final VoidCallback onTap;

  const _GoalPreview({required this.onTap});

  @override
  Widget build(BuildContext context) {
    const progress = 8 / 12;

    return Container(
      decoration: AppDecorations.card,
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
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.primary10,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        LucideIcons.target,
                        size: 21,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ler 12 livros em 2026',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              height: 1.25,
                            ),
                          ),
                          SizedBox(height: 5),
                          Row(
                            children: [
                              Icon(
                                LucideIcons.calendarDays,
                                size: 13,
                                color: AppColors.textTertiary,
                              ),
                              SizedBox(width: 5),
                              Text(
                                'Até 31/12/2026',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      LucideIcons.chevronRight,
                      size: 20,
                      color: AppColors.textTertiary,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const Row(
                  children: [
                    Expanded(
                      child: Text(
                        '8 de 12 livros',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      '67%',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: const LinearProgressIndicator(
                    value: progress,
                    minHeight: 9,
                    color: AppColors.primary,
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

class _ShoppingListPreview extends StatelessWidget {
  final VoidCallback onTap;

  const _ShoppingListPreview({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.card,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                _PreviewHeader(),
                SizedBox(height: 16),
                _PreviewShoppingItem(
                  title: 'A Biblioteca da Meia-Noite',
                  author: 'Matt Haig',
                  price: 'R\$ 44,90',
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, color: AppColors.surfaceBorder),
                ),
                _PreviewShoppingItem(
                  title: 'Torto Arado',
                  author: 'Itamar Vieira Junior',
                  price: 'R\$ 52,90',
                  bought: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PreviewHeader extends StatelessWidget {
  const _PreviewHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primary10,
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(
            LucideIcons.shoppingBag,
            size: 18,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Próximas compras',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 2),
              Text(
                '1 livro pendente',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
        ),
        Text(
          'R\$ 44,90',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _PreviewShoppingItem extends StatelessWidget {
  final String title;
  final String author;
  final String price;
  final bool bought;

  const _PreviewShoppingItem({
    required this.title,
    required this.author,
    required this.price,
    this.bought = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bought ? AppColors.primary : AppColors.background,
            shape: BoxShape.circle,
            border: Border.all(
              color: bought ? AppColors.primary : AppColors.border,
              width: 1.5,
            ),
          ),
          child: Icon(
            bought ? LucideIcons.check : LucideIcons.bookOpen,
            size: 16,
            color: bought ? Colors.white : AppColors.textTertiary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: bought
                      ? AppColors.textSecondary
                      : AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  decoration: bought ? TextDecoration.lineThrough : null,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                author,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          price,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
