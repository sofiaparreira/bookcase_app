// Modelo da classe de Livros
class Book {
  final int id;
  final String title;
  final String author;
  final String isbn;
  final EnumBookStatus status;
  final int totalPages;
  final String image;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.isbn,
    required this.status,
    required this.totalPages,
    required this.image
  });
}

// Status de leitura
enum EnumBookStatus {
  want,
  reading,
  finished
}

// Livros - Lendo
class ReadingBook {
  final Book book;
  final int currentPage;

  const ReadingBook({
    required this.book,
    required this.currentPage
  });

  double get progress => currentPage / book.totalPages;
  int get progressPercent => (progress * 100).toInt();
  
}