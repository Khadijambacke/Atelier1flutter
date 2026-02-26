import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';

  // Headers envoyés avec chaque requête
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // ── GET ──────────────────────────────────────────────────────────────────
  // Récupère des données depuis l'API
  Future<dynamic> get(String path) async {
    final response = await http
        .get(Uri.parse('$baseUrl$path'), headers: _headers)
        .timeout(const Duration(seconds: 10)); // Timeout après 10 secondes

    return _handleResponse(response);
  }

  // ── POST ─────────────────────────────────────────────────────────────────
  // Envoie de nouvelles données à l'API (création)
  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl$path'),
          headers: _headers,
          body: jsonEncode(body), // Convertit Map en String JSON
        )
        .timeout(const Duration(seconds: 10));

    return _handleResponse(response);
  }

  // ── PUT ──────────────────────────────────────────────────────────────────
  // Met à jour des données existantes sur l'API
  Future<dynamic> put(String path, Map<String, dynamic> body) async {
    final response = await http
        .put(
          Uri.parse('$baseUrl$path'),
          headers: _headers,
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 10));

    return _handleResponse(response);
  }

  // ── DELETE ───────────────────────────────────────────────────────────────
  // Supprime une donnée sur l'API
  Future<void> delete(String path) async {
    final response = await http
        .delete(Uri.parse('$baseUrl$path'), headers: _headers)
        .timeout(const Duration(seconds: 10));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Erreur API ${response.statusCode}: ${response.body}');
    }
  }

  // ── Gestion des réponses ─────────────────────────────────────────────────
  // Vérifie le code HTTP et convertit le corps JSON en objet Dart
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Succès : décode le JSON
      return jsonDecode(response.body);
    } else {
      // Erreur : lance une exception avec le code HTTP
      throw Exception('Erreur API ${response.statusCode}: ${response.body}');
    }
  }
}
