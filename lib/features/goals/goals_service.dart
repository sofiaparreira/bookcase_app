import 'dart:convert';

import 'package:bookcase/core/config/api_config.dart';
import 'package:bookcase/features/auth/auth_service.dart';
import 'package:bookcase/models/reading_goal.dart';
import 'package:http/http.dart' as http;

class GoalsService {
  static const _timeout = Duration(seconds: 60); // a API grátis demora a acordar

  Map<String, String> get _headers {
    final token = AuthService().token;
    if (token == null) throw Exception('Usuário não autenticado.');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Uri _uri([int? id, String suffix = '']) => Uri.parse(
    '${ApiConfig.baseUrl}/api/ReadingGoal${id != null ? '/$id' : ''}$suffix',
  );

  void _check(http.Response r, String action) {
    if (r.statusCode >= 200 && r.statusCode < 300) return;
    if (r.statusCode == 401) {
      throw Exception('Sessão expirada. Faça login novamente.');
    }
    if (r.statusCode == 400 && r.body.isNotEmpty) {
      // A API responde 400 com uma mensagem simples (ex.: "Livro não encontrado.")
      try {
        final decoded = jsonDecode(r.body);
        if (decoded is String) throw Exception(decoded);
      } on FormatException {
        if (r.body.length < 120) throw Exception(r.body);
      }
    }
    throw Exception('Erro ao $action (código ${r.statusCode}).');
  }

  Future<List<ReadingGoal>> getGoals() async {
    final r = await http.get(_uri(), headers: _headers).timeout(_timeout);
    _check(r, 'buscar metas');
    final data = jsonDecode(r.body) as List<dynamic>;
    return data
        .map((e) => ReadingGoal.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ReadingGoal> createGoal(ReadingGoal goal) async {
    final r = await http
        .post(_uri(), headers: _headers, body: jsonEncode(goal.toJson()))
        .timeout(_timeout);
    _check(r, 'criar meta');
    return ReadingGoal.fromJson(jsonDecode(r.body) as Map<String, dynamic>);
  }

  Future<void> updateGoal(ReadingGoal goal) async {
    final r = await http
        .put(_uri(goal.id), headers: _headers, body: jsonEncode(goal.toJson()))
        .timeout(_timeout);
    _check(r, 'atualizar meta');
  }

  /// Salva só a página em que o usuário parou (PATCH /api/ReadingGoal/{id}/progress).
  Future<void> updateProgress(int id, int currentPage) async {
    final r = await http
        .patch(
          _uri(id, '/progress'),
          headers: _headers,
          body: jsonEncode({'currentPage': currentPage}),
        )
        .timeout(_timeout);
    _check(r, 'atualizar progresso');
  }

  Future<void> deleteGoal(int id) async {
    final r = await http.delete(_uri(id), headers: _headers).timeout(_timeout);
    _check(r, 'excluir meta');
  }
}