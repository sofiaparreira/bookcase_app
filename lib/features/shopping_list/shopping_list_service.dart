import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:bookcase/models/shopping_list_item.dart';
import 'package:bookcase/features/auth/auth_service.dart';

class ShoppingListService {
  static const String baseUrl = 'https://bookcase-api-g9pa.onrender.com';

  // Monta os headers com o token de autenticação (usuário logado)
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${AuthService().token}',
  };

  // GET /api/shoppinglist - Lista os itens do usuário
  Future<List<ShoppingListItem>> getAll() async {
    final url = Uri.parse('$baseUrl/api/shoppinglist');
    final response = await http.get(url, headers: _headers);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => ShoppingListItem.fromJson(item)).toList();
    } else {
      throw Exception(
        'Falha ao carregar a lista de compras: ${response.statusCode}',
      );
    }
  }

  // POST /api/shoppinglist - Cria um item
  Future<ShoppingListItem> create(ShoppingListItem item) async {
    final url = Uri.parse('$baseUrl/api/shoppinglist');
    final response = await http.post(
      url,
      headers: _headers,
      body: jsonEncode(item.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return ShoppingListItem.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Falha ao criar o item: ${response.statusCode}');
    }
  }

  // PUT /api/shoppinglist/:id - Atualiza um item
  Future<void> update(ShoppingListItem item) async {
    final url = Uri.parse('$baseUrl/api/shoppinglist/${item.id}');
    final response = await http.put(
      url,
      headers: _headers,
      body: jsonEncode({...item.toJson(), 'id': item.id}),
    );

    if (response.statusCode != 204) {
      throw Exception('Falha ao atualizar o item: ${response.statusCode}');
    }
  }

  // DELETE /api/shoppinglist/:id - Remove um item
  Future<void> delete(int id) async {
    final url = Uri.parse('$baseUrl/api/shoppinglist/$id');
    final response = await http.delete(url, headers: _headers);

    if (response.statusCode != 204) {
      throw Exception('Falha ao remover o item: ${response.statusCode}');
    }
  }
}
