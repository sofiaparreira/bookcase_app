import 'package:bookcase/features/my_bookshelf/bookshelf_actions.dart';
import 'package:bookcase/features/my_bookshelf/bookshelf_store.dart';
import 'package:bookcase/features/my_bookshelf/my_bookshelf_page.dart';
import 'package:bookcase/models/book.dart';
import 'package:bookcase/models/shelf_book.dart';
import 'package:bookcase/shared/widgets/modal/update_reading_progress_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReadingProgressResult.isComplete', () {
    test('returns true when progress reaches 100 percent', () {
      const result = ReadingProgressResult(
        progress: 1,
        totalPages: 0,
        currentPage: 0,
      );

      expect(result.isComplete, isTrue);
    });

    test('returns true when displayed percentage rounds to 100', () {
      const result = ReadingProgressResult(
        progress: 0.995,
        totalPages: 0,
        currentPage: 0,
      );

      expect(result.isComplete, isTrue);
    });

    test('returns true when current page reaches total pages', () {
      const result = ReadingProgressResult(
        progress: 0.99,
        totalPages: 200,
        currentPage: 200,
      );

      expect(result.isComplete, isTrue);
    });

    test('returns false while reading is still in progress', () {
      const result = ReadingProgressResult(
        progress: 0.99,
        totalPages: 200,
        currentPage: 198,
      );

      expect(result.isComplete, isFalse);
    });
  });

  testWidgets('opens finish modal when edited progress reaches 100 percent', (
    tester,
  ) async {
    const book = Book(
      id: 1,
      title: 'Livro em leitura',
      author: 'Autora',
      isbn: '',
      status: EnumBookStatus.reading,
      totalPages: 200,
      image: '',
    );
    const shelfBook = ShelfBook(
      book: book,
      status: EnumBookStatus.reading,
      progress: 0.5,
      totalPages: 200,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () =>
                  BookshelfActions.editProgress(context, shelfBook),
              child: const Text('Atualizar progresso'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Atualizar progresso'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Porcentagem'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), '100');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(find.text('Finalizar leitura'), findsOneWidget);
  });

  testWidgets('opens finish modal when progress button reaches 100 percent', (
    tester,
  ) async {
    const book = Book(
      id: 2,
      title: 'Outro livro em leitura',
      author: 'Autor',
      isbn: '',
      status: EnumBookStatus.reading,
      totalPages: 100,
      image: '',
    );
    const shelfBook = ShelfBook(
      book: book,
      status: EnumBookStatus.reading,
      progress: 0.95,
      totalPages: 100,
    );
    BookshelfStore.instance
      ..clear()
      ..save(shelfBook);

    await tester.pumpWidget(const MaterialApp(home: MyBookshelfPage()));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Aumentar progresso'));
    await tester.pumpAndSettle();

    expect(find.text('Finalizar leitura'), findsOneWidget);

    BookshelfStore.instance.clear();
  });
}
