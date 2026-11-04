// Modelo da classe de Livros
class Book {
  final int id;
  final String title;
  final String author;
  final String isbn;
  final EnumBookStatus status;
  final int totalPages;
  final String image;
  final String? googleBooksId;
  final String? description;
  final double? averageRating;
  final int? databaseId;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.isbn,
    required this.status,
    required this.totalPages,
    required this.image,
    this.googleBooksId,
    this.description,
    this.averageRating,
    this.databaseId,
  });

  Book copyWith({int? databaseId, EnumBookStatus? status}) => Book(
    id: id,
    title: title,
    author: author,
    isbn: isbn,
    status: status ?? this.status,
    totalPages: totalPages,
    image: image,
    googleBooksId: googleBooksId,
    description: description,
    averageRating: averageRating,
    databaseId: databaseId ?? this.databaseId,
  );

  /// Combina os dados persistidos pela API com metadados de uma fonte externa.
  ///
  /// O status e o ID do banco pertencem à estante do usuário e nunca devem ser
  /// substituídos pelo status padrão usado nos resultados do Google Books.
  Book withExternalMetadata(Book metadata) => Book(
    id: metadata.id,
    title: title,
    author: author,
    isbn: metadata.isbn,
    status: status,
    totalPages: metadata.totalPages,
    image: metadata.image,
    googleBooksId: metadata.googleBooksId,
    description: description ?? metadata.description,
    averageRating: metadata.averageRating,
    databaseId: databaseId,
  );

  Map<String, dynamic> toApiJson({EnumBookStatus? status}) => {
    'title': title,
    'author': author,
    'description': description,
    'status': (status ?? this.status).apiValue,
  };

  factory Book.fromGoogleBooks(Map<String, dynamic> json) {
    final volumeId = json['id'] as String? ?? '';
    final volumeInfo = json['volumeInfo'] as Map<String, dynamic>? ?? {};
    final imageLinks = volumeInfo['imageLinks'] as Map<String, dynamic>? ?? {};
    final industryIdentifiers =
        volumeInfo['industryIdentifiers'] as List<dynamic>? ?? const [];
    final description = volumeInfo['description'] as String? ?? '';
    final ratingValue = volumeInfo['averageRating'];

    Map<String, dynamic>? isbnIdentifier;
    for (final identifier in industryIdentifiers) {
      if (identifier is Map<String, dynamic> &&
          (identifier['type'] == 'ISBN_13' ||
              identifier['type'] == 'ISBN_10')) {
        isbnIdentifier = identifier;
        break;
      }
    }
    final authors = volumeInfo['authors'] as List<dynamic>? ?? const [];
    final image =
        imageLinks['extraLarge'] ??
        imageLinks['large'] ??
        imageLinks['medium'] ??
        imageLinks['thumbnail'] ??
        imageLinks['smallThumbnail'];
    final pages = volumeInfo['pageCount'];
    final totalPages = switch (pages) {
      int value => value,
      num value => value.toInt(),
      String value => int.tryParse(value) ?? 0,
      _ => 0,
    };

    return Book(
      id: volumeId.hashCode,
      title: volumeInfo['title'] as String? ?? 'Sem título',
      author: authors.isNotEmpty
          ? authors.first as String? ?? 'Autor desconhecido'
          : 'Autor desconhecido',
      isbn: isbnIdentifier?['identifier'] as String? ?? '',
      status: EnumBookStatus.want,
      totalPages: totalPages,
      image: _secureImageUrl(image as String?),
      description: description,
      averageRating: ratingValue is num ? ratingValue.toDouble() : null,
      googleBooksId: volumeId,
    );
  }

  factory Book.fromApiJson(Map<String, dynamic> json) {
    final idValue = json['id'] ?? json['Id'];
    final databaseId = switch (idValue) {
      int value => value,
      String value => int.tryParse(value),
      _ => null,
    };

    if (databaseId == null) {
      throw const FormatException('A resposta da API não contém um ID válido.');
    }

    return Book(
      id: databaseId,
      databaseId: databaseId,
      title:
          json['title'] as String? ?? json['Title'] as String? ?? 'Sem título',
      author: json['author'] as String? ?? json['Author'] as String? ?? '',
      isbn: '',
      status: EnumBookStatus.fromApiValue(json['status'] ?? json['Status']),
      totalPages: 0,
      image: '',
      description:
          json['description'] as String? ?? json['Description'] as String?,
    );
  }

  static String _secureImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return '';

    final uri = Uri.tryParse(imageUrl);
    if (uri == null || uri.host.isEmpty) return '';

    final query = Map<String, String>.from(uri.queryParameters);
    query['zoom'] = '2';
    return uri.replace(scheme: 'https', queryParameters: query).toString();
  }
}

// Status de leitura
enum EnumBookStatus {
  want(0),
  reading(1),
  finished(2);

  const EnumBookStatus(this.apiValue);

  final int apiValue;

  static EnumBookStatus fromApiValue(Object? value) {
    final numericValue = switch (value) {
      num number => number.toInt(),
      String text =>
        int.tryParse(text) ??
            switch (text.toLowerCase()) {
              'notstarted' || 'want' => 0,
              'inprogress' || 'reading' => 1,
              'completed' || 'finished' => 2,
              _ => null,
            },
      _ => null,
    };

    return switch (numericValue) {
      0 => EnumBookStatus.want,
      1 => EnumBookStatus.reading,
      2 => EnumBookStatus.finished,
      _ => throw FormatException('Status de livro inválido: $value'),
    };
  }
}

// Livros - Lendo
class ReadingBook {
  final Book book;
  final int currentPage;

  const ReadingBook({required this.book, required this.currentPage});

  double get progress =>
      book.totalPages == 0 ? 0 : currentPage / book.totalPages;

  int get progressPercent => (progress * 100).toInt();
}
