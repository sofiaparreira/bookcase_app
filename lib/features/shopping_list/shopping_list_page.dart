// Tela feita por: Cauã de Moraes Furtado

import 'package:bookcase/core/theme/app_colors.dart';
import 'package:bookcase/core/theme/app_decorations.dart';
import 'package:bookcase/features/shopping_list/shopping_list_service.dart';
import 'package:bookcase/models/shopping_list_item.dart';
import 'package:bookcase/shared/widgets/button/button_default.dart';
import 'package:bookcase/shared/widgets/text/title_h1.dart';
import 'package:bookcase/shared/widgets/text_field/text_field_default.dart';
import 'package:flutter/material.dart';

class ShoppingListPage extends StatefulWidget {
  const ShoppingListPage({super.key});

  @override
  State<ShoppingListPage> createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends State<ShoppingListPage> {
  final ShoppingListService service = ShoppingListService();

  List<ShoppingListItem> items = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadItems();
  }

  void _openForm({ShoppingListItem? existing}) {
    final isEditing = existing != null;
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final authorCtrl = TextEditingController(text: existing?.author ?? '');
    final priceCtrl = TextEditingController(
      text: existing != null ? existing.price.toString() : '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditing ? 'Editar item' : 'Novo item',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFieldDefault(label: 'Título', controller: titleCtrl),
              const SizedBox(height: 12),
              TextFieldDefault(
                label: 'Autor (opcional)',
                controller: authorCtrl,
              ),
              const SizedBox(height: 12),
              TextFieldDefault(
                label: 'Preço',
                controller: priceCtrl,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              ButtonDefault(
                text: isEditing ? 'Salvar' : 'Adicionar',
                width: ButtonWidth.full,
                onPressed: () async {
                  final item = ShoppingListItem(
                    id: existing?.id ?? 0,
                    title: titleCtrl.text.trim(),
                    author: authorCtrl.text.trim().isEmpty
                        ? null
                        : authorCtrl.text.trim(),
                    price:
                        double.tryParse(priceCtrl.text.replaceAll(',', '.')) ??
                        0,
                    bought: existing?.bought ?? false,
                  );

                  try {
                    if (isEditing) {
                      await service.update(item);
                    } else {
                      await service.create(item);
                    }
                    if (ctx.mounted) Navigator.pop(ctx);
                    loadItems();
                  } catch (e) {
                    if (ctx.mounted) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(content: Text('Erro ao salvar: $e')),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> loadItems() async {
    setState(() => isLoading = true);
    try {
      final result = await service.getAll();
      if (!mounted) return;
      setState(() => items = result);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao carregar a lista: $e')));
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
      loadItems();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erro ao atualizar: $e')));
      }
    }
  }

  Future<void> _deleteItem(ShoppingListItem item) async {
    try {
      await service.delete(item.id);
      loadItems();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erro ao excluir: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: FloatingActionButton(
          backgroundColor: AppColors.primary,
          onPressed: () => _openForm(),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
      body: Container(
        decoration: AppDecorations.header,
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(20),
                child: TitleH1(text: "Lista de compras", color: Colors.white),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : items.isEmpty
                      ? const Center(child: Text('Sua lista está vazia.'))
                      : ListView.separated(
                          padding: const EdgeInsets.all(20),
                          itemCount: items.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return Card(
                              child: ListTile(
                                onTap: () => _openForm(existing: item),
                                leading: Checkbox(
                                  value: item.bought,
                                  onChanged: (_) => _toggleBought(item),
                                ),
                                title: Text(
                                  item.title,
                                  style: TextStyle(
                                    decoration: item.bought
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                                subtitle: Text(
                                  item.author ?? 'Autor desconhecido',
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'R\$ ${item.price.toStringAsFixed(2)}',
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.redAccent,
                                      ),
                                      onPressed: () => _deleteItem(item),
                                    ),
                                  ],
                                ),
                              ),
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
