import 'package:bookcase/core/theme/app_colors.dart';
import 'package:bookcase/features/shopping_list/shopping_list_actions.dart';
import 'package:bookcase/models/book.dart';
import 'package:bookcase/shared/service/google_books_service.dart';
import 'package:bookcase/shared/widgets/alerts/app_alert.dart';
import 'package:bookcase/shared/widgets/card/book_card.dart';
import 'package:bookcase/shared/widgets/sub_page_layout.dart';
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
    return SubPageLayout(
      title: 'Adicionar à lista',
      headerBottom: SearchTextField(
        label: 'Buscar livro...',
        controller: _searchCtrl,
        onSubmitted: (_) => _search(),
      ),
      child: _buildResults(),
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
                  LucideIcons.search,
                  size: 36,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _hasSearched ? 'Nenhum livro encontrado' : 'Pesquise um livro',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _hasSearched
                    ? 'Tente pesquisar outro título ou autor.'
                    : 'Para adicionar à sua lista de compras.',
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

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
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
