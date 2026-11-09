// Tela feita por: Cauã de Moraes Furtado e Sofia Parreira Passos

import 'package:bookcase/shared/widgets/alerts/app_alert.dart';
import 'package:bookcase/core/theme/app_colors.dart';
import 'package:bookcase/core/theme/app_decorations.dart';
import 'package:bookcase/core/theme/app_shadow.dart';
import 'package:bookcase/features/shopping_list/add_to_shopping_list_page.dart';
import 'package:bookcase/features/shopping_list/price_utils.dart';
import 'package:bookcase/features/shopping_list/shopping_item_form_modal.dart';
import 'package:bookcase/features/shopping_list/shopping_list_actions.dart';
import 'package:bookcase/features/shopping_list/shopping_list_service.dart';
import 'package:bookcase/models/shopping_list_item.dart';
import 'package:bookcase/models/book.dart';
import 'package:bookcase/shared/widgets/badge_default.dart';
import 'package:bookcase/shared/widgets/button/button_default.dart';
import 'package:bookcase/shared/widgets/button/button_status_book.dart';
import 'package:bookcase/shared/widgets/modal/confirm_dialog.dart';
import 'package:bookcase/shared/widgets/text/title_h1.dart';
import 'package:bookcase/shared/widgets/text_field/search_text_field.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ShoppingListPage extends StatefulWidget {
  final Book? initialBook;
  final bool embeddedInNavigation;

  const ShoppingListPage({
    super.key,
    this.initialBook,
    this.embeddedInNavigation = false,
  });

  @override
  State<ShoppingListPage> createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends State<ShoppingListPage> {
  static const double _bottomNavigationSpace = 92;

  final ShoppingListService service = ShoppingListService();

  List<ShoppingListItem> items = [];
  bool isLoading = true;
  String? _error;
  int _selectedTab = 0;
  final Set<int> _checkingIds = {};

  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  int get _pendingItems => items.where((item) => !item.bought).length;

  double get _pendingTotal => items
      .where((item) => !item.bought)
      .fold(0, (total, item) => total + item.price);

  List<ShoppingListItem> get _toBuyItems =>
      _applySearch(items.where((item) => !item.bought));

  List<ShoppingListItem> get _acquiredItems =>
      _applySearch(items.where((item) => item.bought));

  List<ShoppingListItem> _applySearch(Iterable<ShoppingListItem> source) {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return source.toList();
    return source
        .where(
          (item) =>
              item.title.toLowerCase().contains(query) ||
              (item.author?.toLowerCase().contains(query) ?? false),
        )
        .toList();
  }

  @override
  void initState() {
    super.initState();
    loadItems();
    ShoppingListService.changes.addListener(_onListChanged);
    _searchCtrl.addListener(() {
      if (mounted) setState(() => _searchQuery = _searchCtrl.text);
    });
    if (widget.initialBook != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _openNewItemForm(widget.initialBook!);
      });
    }
  }

  @override
  void dispose() {
    ShoppingListService.changes.removeListener(_onListChanged);
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _openAddBookSearch() async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddToShoppingListPage()),
    );
  }

  Future<void> _openNewItemForm(Book book) {
    return showShoppingItemFormModal(
      context,
      initial: ShoppingListItem(
        id: 0,
        title: book.title,
        author: book.author,
        price: 0,
        bought: false,
      ),
      onSubmit: service.create,
    );
  }

  void _onListChanged() => loadItems(silent: true);

  Future<void> loadItems({bool silent = false}) async {
    if (!silent) {
      setState(() {
        isLoading = true;
        _error = null;
      });
    }
    try {
      final result = await service.getAll();
      if (!mounted) return;
      setState(() {
        items = result;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;
      if (silent && items.isNotEmpty) {
        AppAlert.error(context, 'Erro ao atualizar a lista: $error');
      } else {
        setState(() => _error = 'Não foi possível carregar a lista.');
      }
    } finally {
      if (mounted && !silent) setState(() => isLoading = false);
    }
  }

  Future<void> _toggleBought(ShoppingListItem item) async {
    if (_checkingIds.contains(item.id)) return;

    final updated = ShoppingListItem(
      id: item.id,
      title: item.title,
      author: item.author,
      price: item.price,
      bought: !item.bought,
    );

    setState(() => _checkingIds.add(item.id));
    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;

    setState(() {
      _checkingIds.remove(item.id);
      items = [for (final i in items) i.id == item.id ? updated : i];
    });

    try {
      await service.update(updated);
      if (mounted && updated.bought) {
        AppAlert.success(context, '“${item.title}” foi para adquiridos.');
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        items = [for (final i in items) i.id == item.id ? item : i];
      });
      AppAlert.error(context, 'Erro ao atualizar: $error');
    }
  }

  Future<void> _deleteItem(ShoppingListItem item) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Remover livro?',
      message: '“${item.title}” será removido da sua lista de compras.',
      confirmText: 'Remover',
      destructive: true,
    );
    if (!confirmed) return;

    try {
      await service.delete(item.id);
    } catch (error) {
      if (mounted) {
        AppAlert.error(context, 'Erro ao excluir: $error');
      }
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
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: TitleH1(
                            text: 'Lista de compras',
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(LucideIcons.plus),
                          tooltip: 'Adicionar livro',
                          onPressed: _openAddBookSearch,
                          style: IconButton.styleFrom(
                            fixedSize: const Size.square(40),
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.16,
                            ),
                            foregroundColor: Colors.white,
                            shape: const RoundedRectangleBorder(
                              borderRadius: AppDecorations.buttonBorderRadius,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isLoading || _error != null
                          ? ' '
                          : '$_pendingItems ${_pendingItems == 1 ? 'livro pendente' : 'livros pendentes'}  •  ${formatPrice(_pendingTotal)}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.72),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SearchTextField(
                      label: 'Buscar na lista...',
                      controller: _searchCtrl,
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
                  child: _buildContent(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              ButtonDefault(text: 'Tentar novamente', onPressed: loadItems),
            ],
          ),
        ),
      );
    }

    final tabItems = _selectedTab == 0 ? _toBuyItems : _acquiredItems;

    return Column(
      children: [
        _buildTabSelector(),
        Expanded(
          child: tabItems.isEmpty
              ? _buildTabEmptyState()
              : RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () => loadItems(silent: true),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      16,
                      16,
                      _bottomNavigationSpace,
                    ),
                    itemCount: tabItems.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) => _ShoppingItemCard(
                      item: tabItems[index],
                      formattedPrice: formatPrice(tabItems[index].price),
                      checked:
                          tabItems[index].bought !=
                          _checkingIds.contains(tabItems[index].id),
                      onTap: () => ShoppingListActions.editItem(
                        context,
                        tabItems[index],
                      ),
                      onToggle: () => _toggleBought(tabItems[index]),
                      onDelete: () => _deleteItem(tabItems[index]),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildTabSelector() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        spacing: 8,
        children: [
          Expanded(
            child: ButtonStatusBook(
              text: 'Para comprar',
              quantity: _toBuyItems.length,
              prefixIcon: const Icon(LucideIcons.shoppingBag),
              selected: _selectedTab == 0,
              onPressed: () => setState(() => _selectedTab = 0),
            ),
          ),
          Expanded(
            child: ButtonStatusBook(
              text: 'Adquiridos',
              quantity: _acquiredItems.length,
              prefixIcon: const Icon(LucideIcons.bookCheck),
              selected: _selectedTab == 1,
              onPressed: () => setState(() => _selectedTab = 1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabEmptyState() {
    final isSearching = _searchQuery.trim().isNotEmpty;
    final isToBuy = _selectedTab == 0;
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
              child: Icon(
                isSearching
                    ? LucideIcons.search
                    : (isToBuy
                          ? LucideIcons.shoppingBag
                          : LucideIcons.bookCheck),
                size: 36,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isSearching
                  ? 'Nenhum resultado'
                  : (isToBuy ? 'Nada para comprar' : 'Nenhum livro adquirido'),
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
                  : (isToBuy
                        ? 'Toque em + para adicionar livros que você quer comprar.'
                        : 'Marque itens como adquiridos para vê-los aqui.'),
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

class _ShoppingItemCard extends StatelessWidget {
  final ShoppingListItem item;
  final String formattedPrice;
  final bool checked;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _ShoppingItemCard({
    required this.item,
    required this.formattedPrice,
    required this.checked,
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: item.bought ? AppColors.primary10 : AppColors.cardSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: item.bought ? AppColors.primary10 : AppColors.surfaceBorder,
        ),
        boxShadow: item.bought ? null : AppShadows.card,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 16, 12, 16),
            child: Row(
              children: [
                Semantics(
                  button: true,
                  checked: checked,
                  label: item.bought
                      ? 'Marcar ${item.title} como pendente'
                      : 'Marcar ${item.title} como adquirido',
                  child: InkWell(
                    onTap: onToggle,
                    customBorder: const CircleBorder(),
                    child: SizedBox(
                      width: 42,
                      height: 42,
                      child: Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: checked
                                ? AppColors.primary
                                : Colors.transparent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: checked
                                  ? AppColors.primary
                                  : AppColors.textTertiary,
                              width: 2,
                            ),
                          ),
                          child: checked
                              ? const Icon(
                                  LucideIcons.check,
                                  size: 16,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: item.bought
                              ? AppColors.textSecondary
                              : AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                          decoration: item.bought
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.author?.trim().isNotEmpty == true
                            ? item.author!
                            : 'Autor não informado',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 10),
                      BadgeDefault(
                        text: formattedPrice,
                        variant: item.bought
                            ? BadgeVariant.secondary
                            : BadgeVariant.primary,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onDelete,
                  tooltip: 'Remover da lista',
                  icon: const Icon(LucideIcons.trash2, size: 18),
                  color: AppColors.danger,
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.background,
                    minimumSize: const Size(38, 38),
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
