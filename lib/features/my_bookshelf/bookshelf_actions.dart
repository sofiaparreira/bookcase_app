// Tela feita por: Maria Luiza Bertolino Matos

import 'package:bookcase/shared/widgets/alerts/app_alert.dart';
import 'package:bookcase/features/my_bookshelf/bookshelf_store.dart';
import 'package:bookcase/models/book.dart';
import 'package:bookcase/models/shelf_book.dart';
import 'package:bookcase/shared/widgets/modal/finished_book_modal.dart';
import 'package:bookcase/shared/widgets/modal/select_book_status_modal.dart';
import 'package:bookcase/shared/widgets/modal/update_reading_progress_modal.dart';
import 'package:bookcase/shared/service/book_service.dart';
import 'package:flutter/material.dart';

class BookshelfActions {
  BookshelfActions._();

  static BookshelfStore get _store => BookshelfStore.instance;
  static final BookStatusService _statusService = BookStatusService();

  static Future<void> selectStatus(BuildContext context, Book book) async {
    final status = await showModalBottomSheet<EnumBookStatus>(
      context: context,
      isScrollControlled: true,
      constraints: const BoxConstraints(maxWidth: double.infinity),
      builder: (context) =>
          SelectBookStatusModal(currentStatus: _store.find(book)?.status),
    );

    if (status == null || !context.mounted) return;

    try {
      final bool saved;
      if (status == EnumBookStatus.none) {
        saved = await _removeFromBookshelf(book);
      } else if (status == EnumBookStatus.reading) {
        saved = await startReading(context, book);
      } else if (status == EnumBookStatus.finished) {
        saved = await finishReading(context, book);
      } else {
        saved = await _saveAsWant(book);
      }

      if (saved && context.mounted) {
        _showMessage(
          context,
          status == EnumBookStatus.none
              ? '"${book.title}" foi removido da sua estante.'
              : '"${book.title}" está em ${status.label}',
        );
      }
    } catch (_) {
      if (context.mounted) {
        AppAlert.error(
          context,
          status == EnumBookStatus.none
              ? 'Não foi possível remover o livro. Tente novamente.'
              : 'Não foi possível salvar o livro na API.',
        );
      }
    }
  }

  static Future<bool> _removeFromBookshelf(Book book) async {
    final current = _store.find(book);
    if (current == null || current.status == EnumBookStatus.none) return false;

    await _statusService.deleteBook(current.book);
    _store.remove(current.book);
    await _store.persistProgress();
    return true;
  }

  static Future<bool> _saveAsWant(Book book) async {
    final current = _store.find(book);
    final bookToSave = current?.book ?? book.copyWith(databaseId: null);
    final apiBook = await _statusService.updateStatusBook(
      book: bookToSave,
      status: EnumBookStatus.want,
    );
    final displayBook = book.copyWith(databaseId: apiBook.databaseId);
    _store.save(
      ShelfBook(
        book: displayBook,
        status: EnumBookStatus.want,
        progress: 0,
        totalPages: current != null && current.totalPages > 0
            ? current.totalPages
            : book.totalPages,
      ),
    );
    await _store.persistProgress();
    return true;
  }

  static Future<bool> startReading(BuildContext context, Book book) async {
    final current = _store.find(book);
    final result = await _askProgress(context, book, current);
    if (result == null) return false;

    final apiBook = await _statusService.updateStatusBook(
      book: current?.book ?? book.copyWith(databaseId: null),
      status: EnumBookStatus.reading,
    );
    final displayBook = book.copyWith(databaseId: apiBook.databaseId);
    _store.save(
      ShelfBook(
        book: displayBook,
        status: EnumBookStatus.reading,
        progress: result.progress,
        totalPages: result.totalPages,
      ),
    );
    await _store.persistProgress();
    return true;
  }

  static Future<void> editProgress(
    BuildContext context,
    ShelfBook shelfBook,
  ) async {
    final result = await _askProgress(context, shelfBook.book, shelfBook);
    if (result == null) return;

    _store.save(
      shelfBook.copyWith(
        progress: result.progress,
        totalPages: result.totalPages,
      ),
    );
    await _store.persistProgress();
  }

  static Future<bool> finishReading(BuildContext context, Book book) async {
    final current = _store.find(book);
    final totalPages = current != null && current.totalPages > 0
        ? current.totalPages
        : book.totalPages;

    final result = await showModalBottomSheet<FinishedBookResult>(
      context: context,
      isScrollControlled: true,
      constraints: const BoxConstraints(maxWidth: double.infinity),
      builder: (context) => FinishedBookModal(
        title: book.title,
        author: book.author,
        imageUrl: book.image,
        totalPages: totalPages,
        initialRating: current?.rating,
      ),
    );

    if (result == null) return false;

    final apiBook = await _statusService.updateStatusBook(
      book: current?.book ?? book.copyWith(databaseId: null),
      status: EnumBookStatus.finished,
      rating: result.rating.toDouble(),
    );
    final displayBook = book.copyWith(
      databaseId: apiBook.databaseId,
      status: EnumBookStatus.finished,
      rating: result.rating.toDouble(),
    );
    _store.save(
      ShelfBook(
        book: displayBook,
        status: EnumBookStatus.finished,
        progress: 1,
        totalPages: totalPages,
        rating: result.rating,
        finishedAt: result.finishedAt,
      ),
    );
    await _store.persistProgress();
    return true;
  }

  static Future<ReadingProgressResult?> _askProgress(
    BuildContext context,
    Book book,
    ShelfBook? current,
  ) {
    final totalPages = current != null && current.totalPages > 0
        ? current.totalPages
        : book.totalPages;

    final progress = current?.status == EnumBookStatus.reading
        ? current!.progress
        : 0.0;

    return showModalBottomSheet<ReadingProgressResult>(
      context: context,
      isScrollControlled: true,
      constraints: const BoxConstraints(maxWidth: double.infinity),
      builder: (context) => UpdateReadingProgressModal(
        title: book.title,
        totalPages: totalPages,
        currentPage: totalPages > 0 ? (progress * totalPages).round() : null,
        currentPercentage: progress,
      ),
    );
  }

  static void _showMessage(BuildContext context, String message) {
    AppAlert.success(context, message);
  }
}
