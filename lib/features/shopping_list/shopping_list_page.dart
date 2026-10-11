// Tela feita por: Cauã de Moraes Furtado e Sofia Parreira Passos

import 'package:bookcase/core/theme/app_colors.dart';
import 'package:bookcase/core/theme/app_decorations.dart';
import 'package:bookcase/core/theme/app_shadow.dart';
import 'package:bookcase/features/shopping_list/shopping_list_service.dart';
import 'package:bookcase/models/shopping_list_item.dart';
import 'package:bookcase/shared/widgets/bottom_navigation.dart';
import 'package:bookcase/shared/widgets/button/button_default.dart';
import 'package:bookcase/shared/widgets/modal/confirm_dialog.dart';
import 'package:bookcase/shared/widgets/text/title_h1.dart';
import 'package:bookcase/shared/widgets/text_field/text_field_default.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ShoppingListPage extends StatefulWidget {
  final ValueChanged<int>? onNavigate;

  const ShoppingListPage({super.key, this.onNavigate});

  @override
  State<ShoppingListPage> createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends State<ShoppingListPage> {
  final ShoppingListService service = ShoppingListService();

  List<ShoppingListItem> items = [];
  bool isLoading = true;

  int get _pendingItems => items.where((item) => !item.bought).length;

  double get _pendingTotal => items
      .where((item) => !item.bought)
      .fold(0, (total, item) => total + item.price);

  @override
  void initState() {
    super.initState();
    loadItems();
  }

  String _formatPrice(double price) {
    return 'R\$ ${price.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  void _navigateTo(int index) {
    widget.onNavigate?.call(index);
    if (Navigator.canPop(context)) Navigator.pop(context);
  }

  Future<void> _openForm({ShoppingListItem? existing}) async {
    final isEditing = existing != null;
    final formKey = GlobalKey<FormState>();
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final authorCtrl = TextEditingController(text: existing?.author ?? '');
    final priceCtrl = TextEditingController(
      text: existing != null ? existing.price.toStringAsFixed(2) : '',
    );

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        var isSaving = false;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                20,
                4,
                20,
                MediaQuery.viewInsetsOf(context).bottom + 24,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEditing ? 'Editar livro' : 'Adicionar à lista',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isEditing
                          ? 'Atualize as informações deste item.'
                          : 'Salve um livro que você quer comprar depois.',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFieldDefault(
                      label: 'Título',
                      hintText: 'Nome do livro',
                      controller: titleCtrl,
                      prefixIcon: const Icon(LucideIcons.bookOpen, size: 18),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Informe o título do livro'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFieldDefault(
                      label: 'Autor (opcional)',
                      hintText: 'Nome do autor',
                      controller: authorCtrl,
                      prefixIcon: const Icon(LucideIcons.userRound, size: 18),
                    ),
                    const SizedBox(height: 16),
                    TextFieldDefault(
                      label: 'Preço',
                      hintText: '0,00',
                      controller: priceCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      prefixIcon: const Icon(
                        LucideIcons.badgeDollarSign,
                        size: 18,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return null;
                        final price = double.tryParse(
                          value.trim().replaceAll(',', '.'),
                        );
                        return price == null || price < 0
                            ? 'Informe um preço válido'
                            : null;
                      },
                    ),
                    const SizedBox(height: 24),
                    ButtonDefault(
                      text: isEditing ? 'Salvar alterações' : 'Adicionar livro',
                      width: ButtonWidth.full,
                      size: ButtonSize.lg,
                      isLoading: isSaving,
                      prefixIcon: Icon(
                        isEditing ? LucideIcons.check : LucideIcons.plus,
                        size: 18,
                      ),
                      onPressed: () async {
                        if (!(formKey.currentState?.validate() ?? false)) {
                          return;
                        }

                        setModalState(() => isSaving = true);
                        final item = ShoppingListItem(
                          id: existing?.id ?? 0,
                          title: titleCtrl.text.trim(),
                          author: authorCtrl.text.trim().isEmpty
                              ? null
                              : authorCtrl.text.trim(),
                          price:
                              double.tryParse(
                                priceCtrl.text.trim().replaceAll(',', '.'),
                              ) ??
                              0,
                          bought: existing?.bought ?? false,
                        );

                        try {
                          if (isEditing) {
                            await service.update(item);
                          } else {
                            await service.create(item);
                          }
                          if (sheetContext.mounted) {
                            Navigator.pop(sheetContext);
                          }
                          await loadItems();
                        } catch (error) {
                          if (sheetContext.mounted) {
                            setModalState(() => isSaving = false);
                            ScaffoldMessenger.of(sheetContext).showSnackBar(
                              SnackBar(content: Text('Erro ao salvar: $error')),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    titleCtrl.dispose();
    authorCtrl.dispose();
    priceCtrl.dispose();
  }

  Future<void> loadItems() async {
    setState(() => isLoading = true);
    try {
      final result = await service.getAll();
      if (!mounted) return;
      setState(() => items = result);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar a lista: $error')),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _toggleBought(ShoppingListItem item) async {
    try {
      await service.update(
        ShoppingListItem(
          id: item.id,
          title: item.title,
          author: item.author,
          price: item.price,
          bought: !item.bought,
        ),
      );
      await loadItems();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erro ao atualizar: $error')));
      }
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
      await loadItems();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erro ao excluir: $error')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.primary,
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: 0,
        onTap: _navigateTo,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openForm,
        tooltip: 'Adicionar livro',
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 5,
        shape: const CircleBorder(),
        child: const Icon(LucideIcons.plus, size: 26),
      ),
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
                    const TitleH1(
                      text: 'Lista de compras',
                      color: Colors.white,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isLoading
                          ? 'Organize suas próximas leituras'
                          : '$_pendingItems ${_pendingItems == 1 ? 'livro pendente' : 'livros pendentes'}  •  ${_formatPrice(_pendingTotal)}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.72),
                        fontSize: 14,
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

    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 24, 32, 112),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.primary10,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.shoppingBag,
                  color: AppColors.primary,
                  size: 30,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Sua lista está vazia',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Adicione os livros que você quer comprar e acompanhe tudo por aqui.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              ButtonDefault(
                text: 'Adicionar primeiro livro',
                prefixIcon: const Icon(LucideIcons.plus, size: 18),
                onPressed: _openForm,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: loadItems,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 124),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) => _ShoppingItemCard(
          item: items[index],
          formattedPrice: _formatPrice(items[index].price),
          onTap: () => _openForm(existing: items[index]),
          onToggle: () => _toggleBought(items[index]),
          onDelete: () => _deleteItem(items[index]),
        ),
      ),
    );
  }
}

class _ShoppingItemCard extends StatelessWidget {
  final ShoppingListItem item;
  final String formattedPrice;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _ShoppingItemCard({
    required this.item,
    required this.formattedPrice,
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
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: item.bought ? AppColors.primary10 : AppColors.surfaceBorder,
        ),
        boxShadow: item.bought ? null : AppShadows.card,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
            child: Row(
              children: [
                Semantics(
                  button: true,
                  checked: item.bought,
                  label: item.bought
                      ? 'Marcar ${item.title} como pendente'
                      : 'Marcar ${item.title} como comprado',
                  child: InkWell(
                    onTap: onToggle,
                    customBorder: const CircleBorder(),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 42,
                      height: 42,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: item.bought
                            ? AppColors.primary
                            : AppColors.background,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: item.bought
                              ? AppColors.primary
                              : AppColors.border,
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        item.bought ? LucideIcons.check : LucideIcons.bookOpen,
                        size: 19,
                        color: item.bought
                            ? Colors.white
                            : AppColors.textTertiary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
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
                          decoration: item.bought
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.author?.trim().isNotEmpty == true
                            ? item.author!
                            : 'Autor não informado',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: item.bought
                              ? AppColors.background.withValues(alpha: 0.7)
                              : AppColors.cream,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          formattedPrice,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
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
