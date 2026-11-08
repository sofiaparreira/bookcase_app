import 'package:bookcase/features/my_bookshelf/bookshelf_store.dart';
import 'package:bookcase/models/book.dart';
import 'package:bookcase/models/shelf_book.dart';
import 'package:bookcase/shared/widgets/modal/select_book_status_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('sem status mantém o ID e não aparece em Quero ler', () {
    final book = Book.fromApiJson({'id': 42, 'title': 'Livro', 'status': 3});
    expect(book.status, EnumBookStatus.none);
    expect(book.toApiJson()['status'], 3);
    expect(EnumBookStatus.fromApiValue('None'), EnumBookStatus.none);
    expect(EnumBookStatus.want.apiValue, 0);
    expect(EnumBookStatus.reading.apiValue, 1);
    expect(EnumBookStatus.finished.apiValue, 2);

    final store = BookshelfStore.instance;
    addTearDown(store.clear);
    store.save(
      ShelfBook(
        book: book,
        status: EnumBookStatus.none,
        progress: 0,
        totalPages: 100,
      ),
    );
    expect(store.booksWithStatus(EnumBookStatus.want), isEmpty);
    expect(store.contains(book), isFalse);
    expect(store.find(book)?.book.databaseId, 42);
  });

  test('remover da estante elimina a seleção e permite limpar o ID antigo', () {
    final book = Book.fromApiJson({'id': 42, 'title': 'Livro', 'status': 0});
    final store = BookshelfStore.instance;
    addTearDown(store.clear);
    store.save(
      ShelfBook(
        book: book,
        status: EnumBookStatus.want,
        progress: 0,
        totalPages: 100,
      ),
    );
    store.remove(book);
    expect(store.find(book), isNull);
    expect(store.booksWithStatus(EnumBookStatus.want), isEmpty);
    expect(book.copyWith().databaseId, 42);
    expect(book.copyWith(databaseId: null).databaseId, isNull);
  });

  for (final current in <EnumBookStatus?>[null, ...EnumBookStatus.values]) {
    for (final (selected, label) in [
      (EnumBookStatus.want, 'Quero ler'),
      (EnumBookStatus.reading, 'Lendo'),
      (EnumBookStatus.finished, 'Lido'),
    ]) {
      testWidgets('selecionar $selected com status atual $current', (
        tester,
      ) async {
        EnumBookStatus? result;
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () async {
                    result = await showModalBottomSheet<EnumBookStatus>(
                      context: context,
                      builder: (_) =>
                          SelectBookStatusModal(currentStatus: current),
                    );
                  },
                  child: const Text('Abrir'),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Abrir'));
        await tester.pumpAndSettle();
        await tester.tap(find.text(label));
        await tester.pumpAndSettle();
        expect(result, current == selected ? EnumBookStatus.none : selected);
      });
    }
  }

  testWidgets('fechar o modal não desmarca Quero ler', (tester) async {
    EnumBookStatus? result = EnumBookStatus.want;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                result = await showModalBottomSheet<EnumBookStatus>(
                  context: context,
                  builder: (_) => const SelectBookStatusModal(
                    currentStatus: EnumBookStatus.want,
                  ),
                );
              },
              child: const Text('Abrir'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();
    tester.state<NavigatorState>(find.byType(Navigator).first).pop();
    await tester.pumpAndSettle();
    expect(result, isNull);
  });
}
