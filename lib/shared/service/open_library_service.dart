import 'dart:convert';

import 'package:bookcase/models/book.dart';
import 'package:http/http.dart' as http;

class OpenLibraryService {
  Future<List<Book>> searchBooks(String search) async {
    final url = Uri.https('openlibrary.org', '/search.json', {
      'q': search,
      'limit': '20',
    });

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final List<dynamic> docs = data['docs'];

      return docs
          .map((item) => Book.fromOpenLibrary(item as Map<String, dynamic>))
          .toList();
    }

    throw Exception('Failed to load books');
  }
}
