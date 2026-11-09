import 'package:bookcase/core/theme/app_colors.dart';
import 'package:bookcase/core/theme/app_decorations.dart';
import 'package:bookcase/features/shopping_list/shopping_list_actions.dart';
import 'package:bookcase/models/book.dart';
import 'package:bookcase/shared/service/google_books_service.dart';
import 'package:bookcase/shared/widgets/alerts/app_alert.dart';
import 'package:bookcase/shared/widgets/card/book_card.dart';
import 'package:bookcase/shared/widgets/text/title_h1.dart';
import 'package:bookcase/shared/widgets/text_field/search_text_field.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AddToShoppingListPage extends StatefulWidget {
  const AddToShoppingListPage({super.key});

  @override
  State<AddToShoppingListPage> createState() => _AddToShoppingListPageState();
}

class _AddToShoppingListPageState extends State<AddToShoppingListPage> {
  final GoogleBooksService _bookService = GoogleBooksService();
  final TextEditingController _searchCtrl = TextEditingController();

  List<Book> _results = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final query = _searchCtrl.text.trim();
    if (query.isEmpty || _isLoading) return;

    setState(() {
      _isLoading = true;
      _results = [];
    });

    try {
      final result = await _bookService.searchBooks(query);
      if (!mounted) return;
      setState(() {
        _results = result;
        _hasSearched = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _hasSearched = true);
      AppAlert.error(
        context,
        'Não foi possível buscar os livros. Tente novamente.',
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _addBook(Book book) async {
    final added = await ShoppingListActions.addBook(context, book);
    if (added && mounted) {
      Navigator.pop(context, true); // sinaliza que adicionou
    }
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
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 10, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            LucideIcons.arrowLeft,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Flexible(
                          child: TitleH1(
                            text: 'Adicionar à lista',
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: SearchTextField(
                        label: 'Buscar livro...',
                        controller: _searchCtrl,
                        onSubmitted: (_) => _search(),
                      ),
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
                  child: _buildResults(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResults() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 24, 32, 80),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                LucideIcons.search,
                size: 40,
                color: AppColors.primary,
              ),
              const SizedBox(height: 16),
              Text(
                _hasSearched ? 'Nenhum livro encontrado' : 'Pesquise um livro',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _hasSearched
                    ? 'Tente outro título ou autor.'
                    : 'Para adicionar à sua lista de compras.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      itemCount: _results.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final book = _results[index];
        return BookCard(
          title: book.title,
          author: book.author,
          totalPages: book.totalPages,
          imageUrl: book.image,
          onPressedCard: () => _addBook(book),
        );
      },
    );
  }
}
