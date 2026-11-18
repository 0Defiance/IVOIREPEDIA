import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'api.dart' show apiBaseUrl;

/// Un compte de lecteur, tel que l'API le décrit.
@immutable
class AuthUser {
  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.emailVerified = false,
  });

  final String id;
  final String name;
  final String email;
  final String role;
  final bool emailVerified;

  /// Prénom seul : c'est ce que le bandeau affiche, sans tronquer.
  String get firstName {
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts.isEmpty ? name : parts.first;
  }

  bool get isEditor => role == 'ADMIN' || role == 'EDITOR';

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: (json['id'] ?? '') as String,
      name: (json['name'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      role: (json['role'] ?? 'READER') as String,
      emailVerified: json['email_verified'] == true,
    );
  }
}

/// Réponse d'une inscription ou d'une connexion : le compte et son jeton.
@immutable
class AuthSession {
  const AuthSession({required this.user, required this.token});

  final AuthUser user;
  final String token;
}

/// Erreur d'authentification, déjà lisible par un humain.
class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Contrat utilisé par l'application ; les tests fournissent un faux serveur.
abstract interface class AuthApi {
  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
  });

  Future<AuthSession> login({
    required String email,
    required String password,
  });

  Future<AuthUser> me(String token);

  Future<void> logout(String token);
}

/// Client HTTP des routes `/api/v1/auth`.
class HttpAuthApi implements AuthApi {
  HttpAuthApi({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? apiBaseUrl;

  final http.Client _client;
  final String _baseUrl;

  @override
  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final payload = await _post('/auth/register', {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': password,
    });

    return _session(payload);
  }

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final payload = await _post('/auth/login', {
      'email': email,
      'password': password,
    });

    return _session(payload);
  }

  @override
  Future<AuthUser> me(String token) async {
    final payload = await _get('/auth/me', token);
    final data = payload['data'] as Map<String, dynamic>?;

    if (data == null) {
      throw const AuthException('Réponse inattendue du serveur.');
    }

    return AuthUser.fromJson(data);
  }

  @override
  Future<void> logout(String token) async {
    await _post('/auth/logout', const {}, token: token);
  }

  AuthSession _session(Map<String, dynamic> payload) {
    final data = payload['data'] as Map<String, dynamic>?;
    final user = data?['user'] as Map<String, dynamic>?;
    final token = data?['token'] as String?;

    if (user == null || token == null) {
      throw const AuthException('Réponse inattendue du serveur.');
    }

    return AuthSession(user: AuthUser.fromJson(user), token: token);
  }

  Future<Map<String, dynamic>> _get(String path, String token) async {
    return _send(
      () => _client.get(
        Uri.parse('$_baseUrl$path'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );
  }

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    return _send(
      () => _client.post(
        Uri.parse('$_baseUrl$path'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      ),
    );
  }

  Future<Map<String, dynamic>> _send(
    Future<http.Response> Function() request,
  ) async {
    late final http.Response response;
    try {
      response = await request();
    } on Exception {
      throw const AuthException(
        'Impossible de joindre IVOIREPEDIA. Vérifiez votre connexion.',
      );
    }

    Map<String, dynamic>? payload;
    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is Map<String, dynamic>) {
        payload = decoded;
      }
    } on FormatException {
      payload = null;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return payload ?? const {};
    }

    throw AuthException(_message(payload, response.statusCode));
  }

  /// Le serveur répond en français : on affiche son message tel quel.
  String _message(Map<String, dynamic>? payload, int status) {
    final error = payload?['error'];
    if (error is Map && error['message'] is String) {
      return error['message'] as String;
    }

    final errors = payload?['errors'];
    if (errors is Map && errors.isNotEmpty) {
      final first = errors.values.first;
      if (first is List && first.isNotEmpty) {
        return '${first.first}';
      }
    }

    final message = payload?['message'];
    if (message is String && message.isNotEmpty) {
      return message;
    }

    return 'Le serveur a répondu $status.';
  }
}

/// Session du lecteur, conservée dans le stockage du navigateur.
///
/// Le jeton ne quitte jamais l'appareil ; au démarrage, [restore] le vérifie
/// auprès de l'API et efface la session s'il a expiré.
class AuthStore extends ChangeNotifier {
  AuthStore({AuthApi? api}) : _api = api ?? HttpAuthApi();

  static const tokenKey = 'auth.token.v1';

  final AuthApi _api;

  AuthUser? _user;
  String? _token;
  bool _restoring = true;
  bool _disposed = false;

  AuthUser? get user => _user;

  bool get signedIn => _user != null;

  bool get restoring => _restoring;

  Future<void> restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(tokenKey);

      if (token != null && token.isNotEmpty) {
        final user = await _api.me(token);
        _token = token;
        _user = user;
      }
    } catch (_) {
      // Jeton expiré, compte supprimé ou stockage indisponible : le site
      // reste utilisable en visiteur, c'est le comportement attendu.
    } finally {
      _restoring = false;
      _notify();
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    _adopt(await _api.login(email: email.trim(), password: password));
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    _adopt(
      await _api.register(
        name: name.trim(),
        email: email.trim(),
        password: password,
      ),
    );
  }

  Future<void> signOut() async {
    final token = _token;

    _token = null;
    _user = null;
    _notify();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(tokenKey);
    } catch (_) {
      // Sans stockage, la session vit le temps de l'onglet.
    }

    if (token != null) {
      try {
        await _api.logout(token);
      } catch (_) {
        // Le jeton expirera de lui-même : la déconnexion locale suffit.
      }
    }
  }

  void _adopt(AuthSession session) {
    _token = session.token;
    _user = session.user;
    _notify();
    _remember(session.token);
  }

  Future<void> _remember(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(tokenKey, token);
    } catch (_) {
      // Session valable jusqu'à la fermeture de l'onglet.
    }
  }

  void _notify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

/// Rend la session accessible à tout l'arbre (et remplaçable en test).
class AuthScope extends InheritedNotifier<AuthStore> {
  const AuthScope({required AuthStore store, required super.child, super.key})
      : super(notifier: store);

  static AuthStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AuthScope>();
    assert(scope?.notifier != null, 'AuthScope manquant au-dessus de ce widget.');
    return scope!.notifier!;
  }
}
