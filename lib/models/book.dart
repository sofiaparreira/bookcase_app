// Modelo da classe de Livros
class Book {
  final int id;
  final String title;
  final String author;
  final String isbn;
  final EnumBookStatus status;
  final int totalPages;
  final String image;
  final String genre;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.isbn,
    required this.status,
    required this.totalPages,
    required this.image,
    required this.genre,
  });

  factory Book.fromOpenLibrary(Map<String, dynamic> json) {
    final coverId = json['cover_i'];
    final subjects = json['subject'] as List<dynamic>?;

    return Book(
      id: json['key']?.hashCode ?? 0,
      title: json['title'] ?? 'Sem título',
      author: json['author_name'] != null
          ? json['author_name'][0]
          : 'Autor desconhecido',
      isbn: json['isbn'] != null
          ? json['isbn'][0]
          : '',
      status: EnumBookStatus.want,
      totalPages: json['number_of_pages_median'] ?? 0,
      image: coverId != null
          ? 'https://covers.openlibrary.org/b/id/$coverId-M.jpg'
          : '',
      genre: subjects != null && subjects.isNotEmpty
          ? subjects[0].toString()
          : 'Gênero desconhecido',
    );
  }
}

// Status de leitura
enum EnumBookStatus {
  want,
  reading,
  finished,
}

// Livros - Lendo
class ReadingBook {
  final Book book;
  final int currentPage;

  const ReadingBook({
    required this.book,
    required this.currentPage,
  });

  double get progress =>
      book.totalPages == 0 ? 0 : currentPage / book.totalPages;

  int get progressPercent => (progress * 100).toInt();
}