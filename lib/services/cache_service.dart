// services/cache_service.dart
// Ce service gère le stockage local avec SharedPreferences.
// On stocke les posts en JSON dans la mémoire du téléphone.
// Avantage : l'app fonctionne même sans connexion Internet.

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/post.dart';

class CacheService {
  // Clé utilisée pour stocker la liste dans SharedPreferences
  static const String _postsKey = 'cached_posts';

  // ── Sauvegarde la liste en cache ─────────────────────────────────────────
  Future<void> savePosts(List<Post> posts) async {
    final prefs = await SharedPreferences.getInstance();

    // Convertit chaque Post en Map, puis en String JSON
    final jsonList = posts.map((p) => p.toJson()).toList();
    final jsonString = jsonEncode(jsonList);

    await prefs.setString(_postsKey, jsonString);
  }

  // ── Charge la liste depuis le cache ─────────────────────────────────────
  // Retourne null si aucun cache n'est disponible
  Future<List<Post>?> loadPosts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_postsKey);

    if (jsonString == null) return null; // Pas de cache

    // Convertit la String JSON en liste de Post
    final jsonList = jsonDecode(jsonString) as List<dynamic>;
    return jsonList.map((json) => Post.fromJson(json)).toList();
  }

  // ── Vérifie si un cache existe ───────────────────────────────────────────
  Future<bool> hasCachedPosts() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_postsKey);
  }

  // ── Vide le cache ────────────────────────────────────────────────────────
  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_postsKey);
  }
}
