import 'dart:convert';

import 'package:http/http.dart' as http;

class AuthUser {
  final int? id;
  final String name;
  final String email;

  AuthUser({this.id, required this.name, required this.email});

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: switch (json['id']) {
        int value => value,
        String value => int.tryParse(value),
        _ => null,
      },
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }

  String get initials {
    final source = name.trim().isNotEmpty ? name : email;
    return source
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();
  }
}

class AuthService {
  static const String baseUrl = 'https://bookcase-api-g9pa.onrender.com';

  static String? _token;
  static AuthUser? _currentUser;

  String? get token => _token;
  AuthUser? get currentUser => _currentUser;
  bool get isAuthenticated => _token != null;

  Future<AuthUser> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/api/auth/register');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name.trim(),
        'email': email.trim(),
        'password': password,
      }),
    );

    final data = response.body.isNotEmpty ? jsonDecode(response.body) : null;

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (data is Map<String, dynamic>) {
        final user = AuthUser.fromJson(data);
        _currentUser = user;
        return user;
      }
      return AuthUser(name: name, email: email);
    } else if (response.statusCode == 400) {
      final message = data is Map ? data['message'] : null;
      throw Exception(message ?? 'Dados inválidos para cadastro.');
    } else {
      throw Exception(
        'Erro ao cadastrar usuário (código ${response.statusCode}).',
      );
    }
  }

  Future<String> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/api/auth/login');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email.trim(), 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final token = data['token'] as String;
      _token = token;
      _currentUser = AuthUser(name: '', email: email.trim());

      try {
        await fetchCurrentUser();
      } catch (_) {}

      return token;
    } else if (response.statusCode == 401) {
      throw Exception('Email ou senha inválidos.');
    } else {
      throw Exception(
        'Erro ao realizar login (código ${response.statusCode}).',
      );
    }
  }

  Future<AuthUser> fetchCurrentUser() async {
    if (_token == null) {
      throw Exception('Usuário não autenticado.');
    }

    final url = Uri.parse('$baseUrl/api/auth/me');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final user = AuthUser.fromJson(data);
      _currentUser = AuthUser(
        id: user.id ?? _currentUser?.id,
        name: user.name,
        email: user.email.isNotEmpty ? user.email : _currentUser?.email ?? '',
      );
      return _currentUser!;
    } else if (response.statusCode == 401) {
      throw Exception('Sessão expirada. Faça login novamente.');
    } else {
      throw Exception(
        'Erro ao buscar usuário (código ${response.statusCode}).',
      );
    }
  }

  void signOut() {
    _token = null;
    _currentUser = null;
  }

  /// Recuperação de senha
  Future<void> sendPasswordResetEmail(String email) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
