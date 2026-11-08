import 'dart:convert';

import 'package:bookcase/models/book.dart';
import 'package:http/http.dart' as http;

class GoogleBooksService {
  static const String _apiKey = 'AIzaSyB7kTP3Q-uC9U5I__I159_dJgJDtp9Ppno';

  Future<Book?> findByTitleAndAuthor(String title, String author) async {
    final results = await searchBooks('intitle:"$title" inauthor:"$author"');
    if (results.isEmpty) return null;

    final normalizedTitle = _normalize(title);
    final normalizedAuthor = _normalize(author);

    for (final result in results) {
      if (_normalize(result.title) == normalizedTitle &&
          _normalize(result.author) == normalizedAuthor) {
        return result;
      }
    }

    for (final result in results) {
      if (_normalize(result.title) == normalizedTitle) return result;
    }

    return results.first;
  }

  // GET ALL
  Future<List<Book>> searchBooks(String search) async {
    final url = Uri.https('www.googleapis.com', '/books/v1/volumes', {
      'q': search,
      'maxResults': '20',
      'projection': 'full',
      'key': _apiKey,
    });

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final List<dynamic> items = data['items'] ?? const [];

      return items
          .map((item) => Book.fromGoogleBooks(item as Map<String, dynamic>))
          .toList();
    }

    throw Exception(
      'Falha ao buscar livros no Google Books (${response.statusCode}).',
    );
  }

  // GET BY ID
  Future<Book> getBookById(String id) async {
    final url = Uri.https('www.googleapis.com', '/books/v1/volumes/$id', {
      'projection': 'full',
      'key': _apiKey,
    });

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Book.fromGoogleBooks(data);
    }

    throw Exception('Falha ao carregar o livro (${response.statusCode})');
  }

  static String _normalize(String value) =>
      value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}
