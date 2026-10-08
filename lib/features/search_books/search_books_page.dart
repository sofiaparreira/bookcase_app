import 'package:bookcase/core/theme/app_colors.dart';
import 'package:bookcase/core/theme/app_decorations.dart';
import 'package:bookcase/features/book_details/book_details.dart';
import 'package:bookcase/models/book.dart';
import 'package:bookcase/shared/service/open_library_service.dart';
import 'package:bookcase/shared/widgets/card/book_card.dart';
import 'package:bookcase/shared/widgets/text/title_h1.dart';
import 'package:bookcase/shared/widgets/text_field/search_text_field.dart';
import 'package:flutter/material.dart';

class SearchBooksPage extends StatefulWidget {
  const SearchBooksPage({super.key});

  @override
  State<SearchBooksPage> createState() => _SearchBooksPageState();
}

class _SearchBooksPageState extends State<SearchBooksPage> {
  final TextEditingController searchController = TextEditingController();
  String selectedCategory = "all";
  final OpenLibraryService openLibraryService = OpenLibraryService();

  List<Book> searchedBooks = [];
  bool? hasSearched = false;

  static const List<({String value, String label})> categories = [
    (value: 'all', label: 'Todos'),
    (value: 'fiction', label: 'Ficção'),
    (value: 'thriller', label: 'Suspense'),
    (value: 'romance', label: 'Romance'),
    (value: 'fantasy', label: 'Fantasia'),
    (value: 'horror', label: 'Terror'),
    (value: 'biography', label: 'Biografia'),
  ];

  Future<void> searchBooks() async {
    final result = await openLibraryService.searchBooks(searchController.text);
    if (!mounted) return;

    setState(() {
      searchedBooks = result;
      hasSearched = true;
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TOPO (PARTE ROXA)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  spacing: 20,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TitleH1(text: "Buscar livros", color: Colors.white),
                    SearchTextField(
                      label: "Buscar por título, autor ou gênero",
                      controller: searchController,
                      onSubmitted: (value) {
                        if (value.trim().isEmpty) return;
                        searchBooks();
                      },
                    ),
                  ],
                ),
              ),

              // Parte branca - Conteúdo
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 82,
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                          scrollDirection: Axis.horizontal,
                          itemCount: categories.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final category = categories[index];

                            return _CategoryChip(
                              label: category.label,
                              selected: selectedCategory == category.value,
                              onSelected: (isSelected) {
                                setState(() {
                                  selectedCategory = isSelected
                                      ? category.value
                                      : "all";
                                });
                              },
                            );
                          },
                        ),
                      ),
                      Expanded(
                        child: searchedBooks.isEmpty
                            ? _SearchEmptyState(
                                hasSearched: hasSearched ?? false,
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.fromLTRB(
                                  20,
                                  0,
                                  20,
                                  20,
                                ),
                                itemCount: searchedBooks.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final book = searchedBooks[index];

                                  return BookCard(
                                    title: book.title,
                                    author: book.author,
                                    totalPages: book.totalPages,
                                    imageUrl: book.image,
                                    onPressedCard: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const BookDetailsPage(),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
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

class _SearchEmptyState extends StatelessWidget {
  final bool hasSearched;

  const _SearchEmptyState({required this.hasSearched});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 16, 32, 80),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary10,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.12),
                ),
              ),
              child: Icon(
                hasSearched
                    ? Icons.search_off_rounded
                    : Icons.manage_search_rounded,
                size: 38,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              hasSearched
                  ? 'Nenhum livro encontrado'
                  : 'Encontre sua próxima leitura',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasSearched
                  ? 'Tente pesquisar outro título, autor ou gênero.'
                  : 'Faça uma pesquisa para encontrar livros.',
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

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.cardSurface,
      disabledColor: AppColors.cardSurface,
      side: BorderSide.none,
      shape: const RoundedRectangleBorder(
        borderRadius: AppDecorations.buttonBorderRadius,
      ),
      showCheckmark: false,
      elevation: 0,
      pressElevation: 0,
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      labelStyle: TextStyle(
        color: selected ? Colors.white : AppColors.textPrimary,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
