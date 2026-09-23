import 'package:bookcase/core/theme/app_colors.dart';
import 'package:bookcase/models/book.dart';
import 'package:bookcase/shared/widgets/button/button_default.dart';
import 'package:bookcase/shared/widgets/card/metric_card.dart';
import 'package:bookcase/shared/widgets/card/reading_card.dart';
import 'package:bookcase/shared/widgets/text/title_h1.dart';
import 'package:bookcase/shared/widgets/text/title_h2.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  static const daysOfWeek = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
  static const List<ReadingBook> readingBooksList = [
    ReadingBook(
      book: Book(
        id: 1,
        title: 'O Retrato de Dorian Gray',
        author: 'Oscar Wilde',
        isbn: '123123',
        status: EnumBookStatus.reading,
        numPages: 300,
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
        numPages: 300,
        image: 'https://darkside.vtexassets.com/arquivos/ids/176888/o-retrato-de-dorian-gray.png?v=637655004354600000',
      ),
      currentPage: 100,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
     body: SafeArea(
  child: Column(
    children: [
      // TOPO
      Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Olá',
              style: TextStyle(
                color: Color.fromARGB(180, 255, 255, 255),
                fontSize: 16,
                fontWeight: FontWeight.w100,
              ),
            ),

            const TitleH1(
              text: 'Ana',
              color: Colors.white,
            ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color.fromARGB(26, 255, 255, 255),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                spacing: 6,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.local_fire_department,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        '7 dias de streak',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),

                  Row(
                    children: daysOfWeek.map((day) {
                      return Expanded(
                        child: Column(
                          children: [
                            SizedBox(
                              height: 44,
                              child: Card(
                                color: AppColors.secondary,
                                child: const Center(
                                  child: Icon(
                                    Icons.check_circle_outline,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              day,
                              style: const TextStyle(
                                color: Color.fromARGB(
                                  187,
                                  255,
                                  255,
                                  255,
                                ),
                                fontWeight: FontWeight.w200,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // CONTEÚDO BRANCO
      Expanded(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Color(0xFFFAFAFA),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              spacing: 12,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const TitleH2(text: 'Lendo agora'),
                    ButtonDefault(
                      text: 'Ver estante',
                      variant: ButtonVariant.transparent,
                      suffixIcon: const Icon(Icons.chevron_right),
                      onPressed: () {},
                    ),
                  ],
                ),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      spacing: 12,
                      children: readingBooksList.map((book) {
                        return ReadingCard(
                          title: book.book.title,
                          author: book.book.author,
                          currentPage: book.currentPage,
                          numPages: book.book.numPages,
                          progress: book.progress,
                          progressPercent: book.progressPercent,
                        );
                      }).toList(),
                    ),
                  ),
                ),

                Row(
                  spacing: 12,
                  children: const [
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
    );
  }
}
