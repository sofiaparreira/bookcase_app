// Feito por: Maria Luiza Bertolino Matos

import 'dart:async';
import 'dart:convert';

import 'package:bookcase/models/book.dart';
import 'package:bookcase/models/shelf_book.dart';
import 'package:bookcase/features/auth/auth_service.dart';
import 'package:bookcase/shared/service/book_service.dart';
import 'package:bookcase/shared/service/google_books_service.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookshelfStore extends ChangeNotifier {
  BookshelfStore._();

  static final BookshelfStore instance = BookshelfStore._();

  final Map<int, ShelfBook> _books = {};
  final BookStatusService _statusService = BookStatusService();
  final GoogleBooksService _googleBooksService = GoogleBooksService();
  Timer? _progressSaveTimer;
  bool isLoadingFromApi = false;
  String? _loadedForToken;

  Future<void> loadFromApi({bool refresh = false}) async {
    final token = AuthService().token;
    if (isLoadingFromApi || token == null || token.isEmpty) return;
    if (!refresh && _loadedForToken == token) return;

    isLoadingFromApi = true;
    notifyListeners();

    try {
      final apiBooks = await _statusService.getBooksForCurrentUser();
      final enrichedApiBooks = await Future.wait(
        apiBooks.map(_restoreGoogleBookData),
      );
      final savedProgress = await _readSavedProgress();
      final previousBooks = _books.values.toList();
      _books.clear();

      for (final apiBook in enrichedApiBooks) {
        ShelfBook? previous;
        for (final item in previousBooks) {
          final sameDatabaseId =
              apiBook.databaseId != null &&
              item.book.databaseId == apiBook.databaseId;
          final sameTitle =
              _normalize(item.book.title) == _normalize(apiBook.title);
          final sameTitleAndAuthor =
              sameTitle &&
              (_normalize(item.book.author).isEmpty ||
                  _normalize(apiBook.author).isEmpty ||
                  _normalize(item.book.author) == _normalize(apiBook.author));
          if (sameDatabaseId || sameTitleAndAuthor) {
            previous = item;
            break;
          }
        }

        final displayBook =
            previous?.book.copyWith(
              databaseId: apiBook.databaseId,
              status: apiBook.status,
              rating: apiBook.rating,
            ) ??
            apiBook;
        final savedBookProgress = savedProgress[apiBook.databaseId.toString()];
        final savedProgressValue = savedBookProgress is Map
            ? _numberAsDouble(savedBookProgress['progress'])
            : null;
        final savedTotalPages = savedBookProgress is Map
            ? _numberAsInt(savedBookProgress['totalPages'])
            : null;
        final savedShelfBook = ShelfBook(
          book: displayBook,
          status: apiBook.status,
          progress: previous?.progress ?? savedProgressValue ?? 0,
          totalPages: previous != null && previous.totalPages > 0
              ? previous.totalPages
              : savedTotalPages ?? apiBook.totalPages,
          rating: apiBook.rating > 0 ? apiBook.rating.round() : null,
          finishedAt: previous?.finishedAt,
        );
        _books[displayBook.id] = savedShelfBook;
      }
      _loadedForToken = token;
    } finally {
      isLoadingFromApi = false;
      notifyListeners();
    }
  }

  List<ShelfBook> booksWithStatus(EnumBookStatus status) => _books.values
      .where((shelfBook) => shelfBook.status == status)
      .toList()
      .reversed
      .toList();

  int countWithStatus(EnumBookStatus status) =>
      _books.values.where((shelfBook) => shelfBook.status == status).length;

  ShelfBook? find(Book book) {
    final directMatch = _books[book.id];
    if (directMatch != null) return directMatch;

    for (final shelfBook in _books.values) {
      final sameDatabaseId =
          book.databaseId != null &&
          shelfBook.book.databaseId == book.databaseId;
      final sameGoogleBooksId =
          book.googleBooksId != null &&
          shelfBook.book.googleBooksId == book.googleBooksId;
      final sameTitle =
          _normalize(book.title) == _normalize(shelfBook.book.title);
      final sameTitleAndAuthor =
          sameTitle &&
          (_normalize(book.author).isEmpty ||
              _normalize(shelfBook.book.author).isEmpty ||
              _normalize(book.author) == _normalize(shelfBook.book.author));

      if (sameDatabaseId || sameGoogleBooksId || sameTitleAndAuthor) {
        return shelfBook;
      }
    }

    return null;
  }

  bool contains(Book book) {
    final shelfBook = find(book);
    return shelfBook != null && shelfBook.status != EnumBookStatus.none;
  }

  void save(ShelfBook shelfBook) {
    final existingIds = _books.entries
        .where((entry) {
          final existing = entry.value.book;
          final sameDatabaseId =
              shelfBook.book.databaseId != null &&
              existing.databaseId == shelfBook.book.databaseId;
          final sameGoogleBooksId =
              shelfBook.book.googleBooksId != null &&
              existing.googleBooksId == shelfBook.book.googleBooksId;
          final sameTitleAndAuthor =
              _normalize(existing.title) == _normalize(shelfBook.book.title) &&
              _normalize(existing.author) == _normalize(shelfBook.book.author);
          return entry.key == shelfBook.book.id ||
              sameDatabaseId ||
              sameGoogleBooksId ||
              sameTitleAndAuthor;
        })
        .map((entry) => entry.key)
        .toList();
    for (final id in existingIds) {
      _books.remove(id);
    }
    _books[shelfBook.book.id] = shelfBook;
    notifyListeners();
    _scheduleProgressPersistence();
  }

  void clear() {
    _progressSaveTimer?.cancel();
    _books.clear();
    _loadedForToken = null;
    notifyListeners();
  }

  void updateProgress(Book book, double progress) {
    final shelfBook = _books[book.id];
    if (shelfBook == null) return;

    _books[book.id] = shelfBook.copyWith(progress: progress.clamp(0.0, 1.0));
    notifyListeners();
    _scheduleProgressPersistence();
  }

  Future<void> persistProgress() async {
    _progressSaveTimer?.cancel();
    final preferencesKey = _progressPreferencesKey;
    if (preferencesKey == null) return;

    final values = <String, Map<String, dynamic>>{};
    for (final shelfBook in _books.values) {
      final databaseId = shelfBook.book.databaseId;
      if (databaseId == null) continue;
      values[databaseId.toString()] = {
        'progress': shelfBook.progress,
        'totalPages': shelfBook.totalPages,
      };
    }

    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(preferencesKey, jsonEncode(values));
    } catch (error) {
      debugPrint(
        '[BookshelfStore] Não foi possível salvar o progresso: $error',
      );
    }
  }

  void remove(Book book) {
    final shelfBook = find(book);
    if (shelfBook == null) return;

    _books.remove(shelfBook.book.id);
    notifyListeners();
  }

  static String _normalize(String value) =>
      value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  String? get _progressPreferencesKey {
    final user = AuthService().currentUser;
    final identity = user?.id?.toString() ?? user?.email.trim().toLowerCase();
    if (identity == null || identity.isEmpty) return null;
    return 'bookcase_progress_$identity';
  }

  Future<Map<String, dynamic>> _readSavedProgress() async {
    final preferencesKey = _progressPreferencesKey;
    if (preferencesKey == null) return {};

    try {
      final preferences = await SharedPreferences.getInstance();
      final json = preferences.getString(preferencesKey);
      if (json == null || json.isEmpty) return {};

      final decoded = jsonDecode(json);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (error) {
      debugPrint('[BookshelfStore] Não foi possível ler o progresso: $error');
    }
    return {};
  }

  void _scheduleProgressPersistence() {
    _progressSaveTimer?.cancel();
    _progressSaveTimer = Timer(
      const Duration(milliseconds: 350),
      persistProgress,
    );
  }

  static double? _numberAsDouble(Object? value) => switch (value) {
    num number => number.toDouble(),
    String text => double.tryParse(text),
    _ => null,
  };

  static int? _numberAsInt(Object? value) => switch (value) {
    int number => number,
    num number => number.toInt(),
    String text => int.tryParse(text),
    _ => null,
  };

  Future<Book> _restoreGoogleBookData(Book apiBook) async {
    if (apiBook.status != EnumBookStatus.reading || apiBook.image.isNotEmpty) {
      return apiBook;
    }

    try {
      final googleBook = await _googleBooksService.findByTitleAndAuthor(
        apiBook.title,
        apiBook.author,
      );
      return googleBook == null
          ? apiBook
          : apiBook.withExternalMetadata(googleBook);
    } catch (error) {
      debugPrint('[BookshelfStore] Não foi possível recuperar a capa: $error');
      return apiBook;
    }
  }
}
