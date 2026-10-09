import 'package:bookcase/core/theme/app_colors.dart';
import 'package:bookcase/core/theme/app_decorations.dart';
import 'package:bookcase/models/book.dart';
import 'package:bookcase/shared/widgets/button/button_default.dart';
import 'package:bookcase/shared/widgets/card/metric_card.dart';
import 'package:bookcase/shared/widgets/card/reading_card.dart';
import 'package:bookcase/shared/widgets/modal/update_reading_progress_modal.dart';
import 'package:bookcase/shared/widgets/text/title_h1.dart';
import 'package:bookcase/shared/widgets/text/title_h2.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

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
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
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
                        const Row(
                          spacing: 12,
                          children: [
                            MetricCard(
                              number: 10,
                              icon: Icon(Icons.menu_book),
                              text: 'Livros lidos',
                              variant: EnumMetricCardVariant.primary,
                            ),
                            MetricCard(
                              number: 3,
                              icon: Icon(Icons.emoji_events_outlined),
                              text: 'Conquistas',
                              variant: EnumMetricCardVariant.secondary,
                            ),
                            MetricCard(
                              number: 1552,
                              icon: Icon(Icons.description_outlined),
                              text: 'Páginas lidas',
                              variant: EnumMetricCardVariant.neutral,
                            ),
                          ],
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const TitleH2(text: 'Meta atual'),
                            ButtonDefault(
                              text: 'Ver metas',
                              variant: ButtonVariant.transparent,
                              suffixIcon: const Icon(Icons.chevron_right),
                              onPressed: () {},
                            ),
                          ],
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const TitleH2(text: 'Lista de compras'),
                            ButtonDefault(
                              text: 'Ver lista',
                              variant: ButtonVariant.transparent,
                              suffixIcon: const Icon(Icons.chevron_right),
                              onPressed: () {},
                            ),
                          ],
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
