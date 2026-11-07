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

  Uri _uri([int? id]) =>
      Uri.parse('${ApiConfig.baseUrl}/api/ReadingGoal${id != null ? '/$id' : ''}');

  void _check(http.Response r, String action) {
    if (r.statusCode >= 200 && r.statusCode < 300) return;
    if (r.statusCode == 401) {
      throw Exception('Sessão expirada. Faça login novamente.');
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

  Future<void> deleteGoal(int id) async {
    final r = await http.delete(_uri(id), headers: _headers).timeout(_timeout);
    _check(r, 'excluir meta');
  }
}