// Feito por: Maria Luiza Bertolino Matos

import 'package:bookcase/features/streak/streak_store.dart';
import 'package:bookcase/models/book.dart';
import 'package:bookcase/models/shelf_book.dart';
import 'package:flutter/foundation.dart';

class BookshelfStore extends ChangeNotifier {
  BookshelfStore._(this._streak);

  static final BookshelfStore instance = BookshelfStore._(StreakStore.instance);

  final StreakStore _streak;

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
    final previous = _books.remove(shelfBook.book.id);
    _books[shelfBook.book.id] = shelfBook;
    _registerStreakIfActive(previous, shelfBook);
    notifyListeners();
  }

  void updateProgress(Book book, double progress) {
    final shelfBook = _books[book.id];
    if (shelfBook == null) return;

    final updated = shelfBook.copyWith(progress: progress.clamp(0.0, 1.0));
    _books[book.id] = updated;
    _registerStreakIfActive(shelfBook, updated);
    notifyListeners();
  }

  void _registerStreakIfActive(ShelfBook? previous, ShelfBook current) {
    final startedReading =
        current.status == EnumBookStatus.reading &&
        previous?.status != EnumBookStatus.reading;
    final advanced = current.progress > (previous?.progress ?? 0);

    if (startedReading || advanced) _streak.registerActivity();
  }

  void remove(Book book) {
    if (_books.remove(book.id) != null) notifyListeners();
  }
}
