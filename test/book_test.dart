import 'package:bookcase/models/book.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Book', () {
    test('converte o status InProgress retornado pela API para Lendo', () {
      final book = Book.fromApiJson({
        'id': 42,
        'title': 'Livro salvo',
        'author': 'Autora',
        'status': 1,
      });

      expect(book.status, EnumBookStatus.reading);
      expect(book.databaseId, 42);
    });

    test('preserva o status da API ao adicionar metadados externos', () {
      const apiBook = Book(
        id: 42,
        databaseId: 42,
        title: 'Livro salvo',
        author: 'Autora',
        isbn: '',
        status: EnumBookStatus.reading,
        totalPages: 0,
        image: '',
      );
      const googleBook = Book(
        id: 99,
        title: 'Livro salvo',
        author: 'Autora',
        isbn: '9780000000000',
        status: EnumBookStatus.want,
        totalPages: 320,
        image: 'https://example.com/capa.jpg',
        googleBooksId: 'google-id',
      );

      final enrichedBook = apiBook.withExternalMetadata(googleBook);

      expect(enrichedBook.status, EnumBookStatus.reading);
      expect(enrichedBook.databaseId, 42);
      expect(enrichedBook.totalPages, 320);
      expect(enrichedBook.image, googleBook.image);
    });
  });
}
