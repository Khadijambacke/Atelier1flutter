// screens/list_screen.dart
// Écran principal : affiche la liste des posts.
// Gère 3 états : chargement / erreur / données.
// Pull-to-refresh pour recharger depuis l'API.

import 'package:flutter/material.dart';
import '../models/post.dart';
import '../repositories/post_repository.dart';
import 'detail_screen.dart';
import 'form_screen.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  final PostRepository _repository = PostRepository();

  // ── Variables d'état ─────────────────────────────────────────────────────
  List<Post> _posts = [];          // La liste des posts à afficher
  bool _isLoading = true;          // true → on montre un spinner
  String? _errorMessage;           // non null → on montre une erreur
  bool _isFromCache = false;       // true → données venant du cache local

  @override
  void initState() {
    super.initState();
    _loadPosts(); // Chargement automatique au démarrage
  }

  // ── Chargement des posts ─────────────────────────────────────────────────
  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Vérifie si un cache est dispo avant l'appel API
      final hasCache = await _repository.hasCachedData();
      final posts = await _repository.getAll();

      if (mounted) {
        setState(() {
          _posts = posts;
          _isLoading = false;
          // Si l'appel API a échoué mais qu'on a du cache, hasCache sera true
          _isFromCache = hasCache && posts.isEmpty;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Impossible de charger les posts.\n${e.toString()}';
        });
      }
    }
  }

  // ── Suppression avec confirmation ────────────────────────────────────────
  Future<void> _deletePost(Post post) async {
    try {
      await _repository.delete(post.id);
      setState(() {
        _posts.removeWhere((p) => p.id == post.id);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Post supprimé avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur : ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ── AppBar ──────────────────────────────────────────────────────────
      appBar: AppBar(
        title: const Text('📝 Mes Posts'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          // Indicateur "données en cache"
          if (_isFromCache)
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(Icons.offline_bolt, color: Colors.orange),
            ),
        ],
      ),

      // ── Corps de l'écran ─────────────────────────────────────────────────
      body: _buildBody(),

      // ── Bouton flottant : créer un post ──────────────────────────────────
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        tooltip: 'Créer un post',
        onPressed: () async {
          // Navigue vers le formulaire de création
          final created = await Navigator.push<Post>(
            context,
            MaterialPageRoute(
              builder: (_) => const FormScreen(), // Pas de post → création
            ),
          );
          // Si un post a été créé, on l'ajoute en tête de liste
          if (created != null) {
            setState(() => _posts.insert(0, created));
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // ── Construction du corps selon l'état ───────────────────────────────────
  Widget _buildBody() {
    // État 1 : Chargement
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.indigo),
            SizedBox(height: 16),
            Text('Chargement des posts...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    // État 2 : Erreur
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadPosts, // Bouton "Réessayer"
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // État 3 : Liste vide
    if (_posts.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Aucun post', style: TextStyle(color: Colors.grey, fontSize: 18)),
            SizedBox(height: 8),
            Text('Appuyez sur + pour créer le premier', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    // État 4 : Liste avec données
    return Column(
      children: [
        // Bandeau "données en cache"
        if (_isFromCache)
          Container(
            width: double.infinity,
            color: Colors.orange.shade100,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: const Row(
              children: [
                Icon(Icons.offline_bolt, color: Colors.orange, size: 18),
                SizedBox(width: 8),
                Text('Données en cache · Pas de connexion',
                    style: TextStyle(color: Colors.orange)),
              ],
            ),
          ),

        // Liste avec pull-to-refresh
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadPosts, // Déclenché quand l'utilisateur tire vers le bas
            color: Colors.indigo,
            child: ListView.builder(
              itemCount: _posts.length,
              itemBuilder: (context, index) {
                final post = _posts[index];
                return _PostCard(
                  post: post,
                  onTap: () async {
                    // Navigation vers le détail
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailScreen(postId: post.id),
                      ),
                    );
                    // Si le post a été supprimé depuis l'écran détail
                    if (result == 'deleted') {
                      setState(() => _posts.removeWhere((p) => p.id == post.id));
                    }
                    // Si le post a été modifié depuis l'écran détail
                    if (result is Post) {
                      setState(() {
                        final idx = _posts.indexWhere((p) => p.id == result.id);
                        if (idx != -1) _posts[idx] = result;
                      });
                    }
                  },
                  onDelete: () => _deletePost(post),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

// ── Widget carte pour un post ─────────────────────────────────────────────────
class _PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _PostCard({
    required this.post,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      child: ListTile(
        // Numéro du post dans un cercle coloré
        leading: CircleAvatar(
          backgroundColor: Colors.indigo.shade100,
          child: Text(
            '${post.id}',
            style: const TextStyle(
              color: Colors.indigo,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        title: Text(
          post.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          post.body,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.grey),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
