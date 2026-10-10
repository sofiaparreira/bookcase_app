// Feito por: Maria Luiza Bertolino Matos

import 'package:bookcase/models/book.dart';
import 'package:bookcase/models/shelf_book.dart';
import 'package:flutter/foundation.dart';

class BookshelfStore extends ChangeNotifier {
  BookshelfStore._();

  static final BookshelfStore instance = BookshelfStore._();

  final Map<int, ShelfBook> _books = {};

  List<ShelfBook> booksWithStatus(EnumBookStatus status) => _books.values
      .where((shelfBook) => shelfBook.status == status)
      .toList()
      .reversed
      .toList();

  int countWithStatus(EnumBookStatus status) =>
      _books.values.where((shelfBook) => shelfBook.status == status).length;

  ShelfBook? find(Book book) => _books[book.id];

  bool contains(Book book) => _books.containsKey(book.id);

  void save(ShelfBook shelfBook) {
    _books.remove(shelfBook.book.id);
    _books[shelfBook.book.id] = shelfBook;
    notifyListeners();
  }

  void updateProgress(Book book, double progress) {
    final shelfBook = _books[book.id];
    if (shelfBook == null) return;

    _books[book.id] = shelfBook.copyWith(progress: progress.clamp(0.0, 1.0));
    notifyListeners();
  }

  void remove(Book book) {
    if (_books.remove(book.id) != null) notifyListeners();
  }
}
