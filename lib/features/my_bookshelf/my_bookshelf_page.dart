import 'package:bookcase/core/theme/app_decorations.dart';
import 'package:bookcase/features/my_bookshelf/bookshelf_actions.dart';
import 'package:bookcase/features/my_bookshelf/bookshelf_store.dart';
import 'package:bookcase/models/book.dart';
import 'package:bookcase/models/shelf_book.dart';
import 'package:bookcase/shared/widgets/button/button_status_book.dart';
import 'package:bookcase/shared/widgets/card/shelf_book_card.dart';
import 'package:bookcase/shared/widgets/text/title_h1.dart';
import 'package:bookcase/shared/widgets/text_field/search_text_field.dart';
import 'package:flutter/material.dart';
import 'package:bookcase/core/theme/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class MyBookshelfPage extends StatefulWidget {
  const MyBookshelfPage({super.key});

  @override
  State<MyBookshelfPage> createState() => _MyBookshelfPageState();
}

class _MyBookshelfPageState extends State<MyBookshelfPage> {
  final TextEditingController searchController = TextEditingController();
  final BookshelfStore store = BookshelfStore.instance;

  EnumBookStatus selectedStatus = EnumBookStatus.reading;

  static const tabs = [
    (status: EnumBookStatus.reading, icon: LucideIcons.bookOpen),
    (status: EnumBookStatus.want, icon: LucideIcons.bookBookmark),
    (status: EnumBookStatus.finished, icon: LucideIcons.circleCheck),
  ];

  @override
  void initState() {
    super.initState();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() => setState(() {});

  List<ShelfBook> get filteredBooks {
    final search = searchController.text.trim().toLowerCase();
    final books = store.booksWithStatus(selectedStatus);
    if (search.isEmpty) return books;

    return books
        .where(
          (shelfBook) =>
              shelfBook.book.title.toLowerCase().contains(search) ||
              shelfBook.book.author.toLowerCase().contains(search),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppDecorations.header,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 16,
                ),
                child: Column(
                  spacing: 12,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const TitleH1(
                          text: "Minha Estante",
                          color: Colors.white,
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(LucideIcons.plus),
                          color: Colors.white,
                          iconSize: 20,
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.white10,
                            shape: const RoundedRectangleBorder(
                              borderRadius: AppDecorations.buttonBorderRadius,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SearchTextField(
                      label: "Buscar livros...",
                      controller: searchController,
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
                  child: ListenableBuilder(
                    listenable: store,
                    builder: (context, _) {
                      final books = filteredBooks;

                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 16, 12, 0),
                            child: Row(
                              spacing: 8,
                              children: [
                                for (final tab in tabs)
                                  Expanded(
                                    child: ButtonStatusBook(
                                      text: tab.status.label,
                                      quantity: store.countWithStatus(
                                        tab.status,
                                      ),
                                      prefixIcon: Icon(tab.icon),
                                      selected: selectedStatus == tab.status,
                                      onPressed: () => setState(
                                        () => selectedStatus = tab.status,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: books.isEmpty
                                ? _BookshelfEmptyState(
                                    status: selectedStatus,
                                    isSearching: searchController.text
                                        .trim()
                                        .isNotEmpty,
                                  )
                                : ListView.separated(
                                    padding: const EdgeInsets.fromLTRB(
                                      12,
                                      16,
                                      12,
                                      100,
                                    ),
                                    itemCount: books.length,
                                    separatorBuilder: (context, index) =>
                                        const SizedBox(height: 12),
                                    itemBuilder: (context, index) {
                                      final shelfBook = books[index];
                                      final book = shelfBook.book;

                                      return ShelfBookCard(
                                        key: ValueKey(book.id),
                                        shelfBook: shelfBook,
                                        onChangeStatus: () =>
                                            BookshelfActions.selectStatus(
                                              context,
                                              book,
                                            ),
                                        onEditProgress: () =>
                                            BookshelfActions.editProgress(
                                              context,
                                              shelfBook,
                                            ),
                                        onProgressChanged: (progress) => store
                                            .updateProgress(book, progress),
                                        onFinish: () =>
                                            BookshelfActions.finishReading(
                                              context,
                                              book,
                                            ),
                                        onStartReading: () =>
                                            BookshelfActions.startReading(
                                              context,
                                              book,
                                            ),
                                      );
                                    },
                                  ),
                          ),
                        ],
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

class _BookshelfEmptyState extends StatelessWidget {
  final EnumBookStatus status;
  final bool isSearching;

  const _BookshelfEmptyState({required this.status, required this.isSearching});

  @override
  Widget build(BuildContext context) {
    final title = isSearching
        ? 'Nenhum livro encontrado'
        : switch (status) {
            EnumBookStatus.reading => 'Nenhuma leitura em andamento',
            EnumBookStatus.want => 'Sua lista de desejos está vazia',
            EnumBookStatus.finished => 'Nenhum livro lido ainda',
          };

    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 16, 32, 80),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.primary10,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.library,
                size: 36,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isSearching
                  ? 'Tente pesquisar outro título ou autor.'
                  : 'Use a aba Buscar e toque em + para adicionar livros.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
