import 'package:bookcase/core/theme/app_colors.dart';
import 'package:bookcase/features/shopping_list/shopping_list_service.dart';
import 'package:bookcase/models/book.dart';
import 'package:bookcase/models/shopping_list_item.dart';
import 'package:bookcase/shared/widgets/alerts/app_alert.dart';
import 'package:flutter/material.dart';

class ShoppingListActions {
  ShoppingListActions._();

  static Future<bool> addBook(BuildContext context, Book book) async {
    final price = await _askPrice(context, book);
    if (price == null || !context.mounted) return false;

    try {
      await ShoppingListService().create(
        ShoppingListItem(
          id: 0,
          title: book.title,
          author: book.author,
          price: price,
          bought: false,
        ),
      );
      if (!context.mounted) return false;

      AppAlert.success(context, '“${book.title}” adicionado à lista.');
      return true;
    } catch (error) {
      if (context.mounted) {
        AppAlert.error(context, 'Erro ao adicionar: $error');
      }
      return false;
    }
  }

  static Future<double?> _askPrice(BuildContext context, Book book) {
    final priceCtrl = TextEditingController();

    return showDialog<double>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            book.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: priceCtrl,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Preço',
              hintText: '0,00',
              prefixText: 'R\$ ',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final price =
                    double.tryParse(
                      priceCtrl.text.trim().replaceAll(',', '.'),
                    ) ??
                    0;
                Navigator.pop(dialogContext, price);
              },
              child: const Text('Adicionar'),
            ),
          ],
        );
      },
    ).whenComplete(priceCtrl.dispose);
  }
}
