import 'dart:async';

import 'package:bookcase/features/goals/goals_service.dart';
import 'package:bookcase/features/my_bookshelf/bookshelf_store.dart';
import 'package:bookcase/models/book.dart';
import 'package:bookcase/models/shelf_book.dart';
import 'package:flutter/foundation.dart';

/// Faz a página da meta acompanhar o progresso do livro na estante.
class GoalsSync {
  GoalsSync._();
  static final GoalsSync instance = GoalsSync._();

  Timer? _timer;
  bool _started = false;
  bool _running = false;

  void start() {
    if (_started) return;
    _started = true;
    BookshelfStore.instance.addListener(_schedule);
    _schedule();
  }

  // Espera um pouco, porque o progresso pode mudar várias vezes seguidas.
  void _schedule() {
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 1200), _sync);
  }

  Future<void> _sync() async {
    final store = BookshelfStore.instance;
    if (store.isLoadingFromApi) return;
    
    if (_running) {
      _schedule();
      return;
    }
    _running = true;
    try {
      final shelf = <ShelfBook>[
        ...store.booksWithStatus(EnumBookStatus.reading),
        ...store.booksWithStatus(EnumBookStatus.finished),
      ];
      if (shelf.isEmpty) return;

      final goals = await GoalsService().getGoals();
      
      for (final goal in goals) {
        final id = goal.id;
        if (id == null) continue;

        ShelfBook? item;
        for (final s in shelf) {
          if (s.book.databaseId == goal.bookId) {
            item = s;
            break;
          }
        }
        if (item == null) continue;

        int page;
        if (item.status == EnumBookStatus.finished) {
          page = goal.targetPages;
        } else if (item.totalPages > 0) {
          page = item.currentPage.clamp(0, goal.targetPages);
        } else {
          // Livro sem total de páginas: usa a porcentagem sobre o total da meta.
          page = (item.progress * goal.targetPages).round().clamp(
            0,
            goal.targetPages,
          );
        }

        // Só avança; nunca diminui a página da meta.
        if (page  > goal.currentPage) {
          await GoalsService().updateProgress(id, page);
        }
      }
    } catch (e) {
      debugPrint('[GoalsSync] $e');
    } finally {
      _running = false;
    }
  }
}