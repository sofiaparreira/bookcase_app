import 'dart:convert';

import 'package:bookcase/core/config/api_config.dart';
import 'package:bookcase/features/auth/auth_service.dart';
import 'package:bookcase/models/book.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class BookStatusService {
  Future<Book> updateStatusBook({
    required Book book,
    required EnumBookStatus status,
  }) async {
    final token = AuthService().token;
    if (token == null || token.isEmpty) {
      throw Exception('Faça login antes de salvar o status do livro.');
    }

    final databaseId = book.databaseId;
    final method = databaseId == null ? 'POST' : 'PUT';
    final url = databaseId == null
        ? Uri.parse('${ApiConfig.baseUrl}/api/book')
        : Uri.parse('${ApiConfig.baseUrl}/api/book/$databaseId');
    final payload = book.toApiJson(status: status);
    if (databaseId != null) payload['id'] = databaseId;

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final body = jsonEncode(payload);

    debugPrint('[BookStatusService] $method $url');
    debugPrint('[BookStatusService] request body: $body');

    try {
      final response = databaseId == null
          ? await http.post(url, headers: headers, body: body)
          : await http.put(url, headers: headers, body: body);

      debugPrint(
        '[BookStatusService] response: ${response.statusCode} ${response.body}',
      );

      if (databaseId == null &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        final idValue = responseData['id'];
        final savedId = switch (idValue) {
          int value => value,
          String value => int.tryParse(value),
          _ => null,
        };

        if (savedId == null) {
          throw Exception('A API não retornou o ID do livro criado.');
        }

        return book.copyWith(databaseId: savedId);
      }

      if (databaseId != null && response.statusCode == 204) {
        return book;
      }

      throw Exception(
        'Falha ao salvar o status do livro (${response.statusCode}): '
        '${response.body}',
      );
    } catch (error, stackTrace) {
      debugPrint('[BookStatusService] request failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<List<Book>> getBooksForCurrentUser() async {
    final token = AuthService().token;
    if (token == null || token.isEmpty) {
      throw Exception('Faça login antes de carregar os livros.');
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/api/book');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    debugPrint('[BookStatusService] GET $url');

    try {
      final response = await http.get(url, headers: headers);
      debugPrint(
        '[BookStatusService] GET response: ${response.statusCode} ${response.body}',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        return data
            .map((item) => Book.fromApiJson(item as Map<String, dynamic>))
            .toList();
      }

      if (response.statusCode == 401) {
        throw Exception('Sessão expirada. Faça login novamente.');
      }

      throw Exception(
        'Falha ao carregar os livros (${response.statusCode}): '
        '${response.body}',
      );
    } catch (error, stackTrace) {
      debugPrint('[BookStatusService] GET failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }
}
