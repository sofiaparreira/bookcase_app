import 'package:bookcase/features/shopping_list/shopping_item_form_modal.dart';
import 'package:bookcase/features/shopping_list/shopping_list_service.dart';
import 'package:bookcase/models/book.dart';
import 'package:bookcase/models/shopping_list_item.dart';
import 'package:bookcase/shared/widgets/alerts/app_alert.dart';
import 'package:flutter/material.dart';

class ShoppingListActions {
  ShoppingListActions._();

  static Future<bool> addBook(BuildContext context, Book book) async {
    final added = await showShoppingItemFormModal(
      context,
      showDetails: false,
      initial: ShoppingListItem(
        id: 0,
        title: book.title,
        author: book.author,
        price: 0,
        bought: false,
      ),
      onSubmit: ShoppingListService().create,
    );

    if (added && context.mounted) {
      AppAlert.success(context, '“${book.title}” adicionado à lista.');
    }
    return added;
  }

  static Future<bool> editItem(BuildContext context, ShoppingListItem item) {
    return showShoppingItemFormModal(
      context,
      isEditing: true,
      initial: item,
      onSubmit: ShoppingListService().update,
    );
  }
}
