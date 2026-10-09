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
  final OpenLibraryService openLibraryService = OpenLibraryService();

  List<Book> searchedBooks = [];
  bool hasSearched = false;
  bool isLoading = false;

  Future<void> searchBooks() async {
    final search = searchController.text.trim();
    if (search.isEmpty || isLoading) return;

    setState(() {
      isLoading = true;
      searchedBooks = [];
    });

    try {
      final result = await openLibraryService.searchBooks(search);
      if (!mounted) return;

      setState(() {
        searchedBooks = result;
        hasSearched = true;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        hasSearched = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível buscar os livros. Tente novamente.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
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
                      label: "Buscar por título ou autor",
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
                      Expanded(
                        child: isLoading
                            ? const _SearchSkeletonList()
                            : searchedBooks.isEmpty
                            ? _SearchEmptyState(hasSearched: hasSearched)
                            : ListView.separated(
                                padding: const EdgeInsets.fromLTRB(
                                  20,
                                  20,
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

class _SearchSkeletonList extends StatefulWidget {
  const _SearchSkeletonList();

  @override
  State<_SearchSkeletonList> createState() => _SearchSkeletonListState();
}

class _SearchSkeletonListState extends State<_SearchSkeletonList>
    with SingleTickerProviderStateMixin {
  late final AnimationController animationController;
  late final Animation<double> opacity;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..repeat(reverse: true);
    opacity = Tween<double>(begin: 0.45, end: 0.9).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: FadeTransition(
        opacity: opacity,
        child: ListView.separated(
          padding: const EdgeInsets.all(20),
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 4,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) => const _BookCardSkeleton(),
        ),
      ),
    );
  }
}

class _BookCardSkeleton extends StatelessWidget {
  const _BookCardSkeleton();

  static const skeletonColor = Color(0xFFE8E4DF);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 144,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: AppDecorations.card.borderRadius,
      ),
      child: Row(
        children: [
          const _SkeletonBox(width: 82, height: 124, borderRadius: 12),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8),
                _SkeletonBox(width: double.infinity, height: 16),
                SizedBox(height: 10),
                _SkeletonBox(width: 140, height: 12),
                SizedBox(height: 10),
                _SkeletonBox(width: 52, height: 12),
              ],
            ),
          ),
          const SizedBox(width: 16),
          const _SkeletonBox(width: 36, height: 36, borderRadius: 10),
        ],
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const _SkeletonBox({
    required this.width,
    required this.height,
    this.borderRadius = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: _BookCardSkeleton.skeletonColor,
        borderRadius: BorderRadius.circular(borderRadius),
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
                  ? 'Tente pesquisar outro título ou autor.'
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
