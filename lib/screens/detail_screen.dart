// screens/detail_screen.dart
// Écran détail : affiche un post complet.
// Actions disponibles : Modifier (→ formulaire) et Supprimer (avec dialog).

import 'package:flutter/material.dart';
import '../models/post.dart';
import '../repositories/post_repository.dart';
import 'form_screen.dart';

class DetailScreen extends StatefulWidget {
  final int postId; // On reçoit l'ID depuis la liste

  const DetailScreen({super.key, required this.postId});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final PostRepository _repository = PostRepository();

  Post? _post;           // Le post chargé
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPost();
  }

  // ── Charge le post par son ID ────────────────────────────────────────────
  Future<void> _loadPost() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final post = await _repository.getById(widget.postId);
      if (mounted) setState(() {
        _post = post;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() {
        _isLoading = false;
        _errorMessage = 'Impossible de charger le post.\n${e.toString()}';
      });
    }
  }

  // ── Dialog de confirmation avant suppression ─────────────────────────────
  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text(
          'Voulez-vous vraiment supprimer ce post ?\nCette action est irréversible.',
        ),
        actions: [
          // Bouton Annuler
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          // Bouton Supprimer (rouge)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deletePost();
    }
  }

  // ── Suppression du post ───────────────────────────────────────────────────
  Future<void> _deletePost() async {
    try {
      await _repository.delete(widget.postId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Post supprimé avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        // Retourne 'deleted' à la liste pour qu'elle retire le post
        Navigator.pop(context, 'deleted');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur suppression : ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détail du post'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          // Bouton Modifier (visible seulement si le post est chargé)
          if (_post != null)
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Modifier',
              onPressed: () async {
                final updated = await Navigator.push<Post>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FormScreen(post: _post), // Mode édition
                  ),
                );
                if (updated != null) {
                  setState(() => _post = updated);
                  // Retourne le post modifié à la liste
                  if (mounted) Navigator.pop(context, updated);
                }
              },
            ),
          // Bouton Supprimer
          if (_post != null)
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Supprimer',
              onPressed: _confirmDelete,
            ),
        ],
      ),

      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // Chargement
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.indigo));
    }

    // Erreur
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadPost,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
            ),
          ],
        ),
      );
    }

    // Données
    final post = _post!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge ID
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.indigo.shade200),
            ),
            child: Text(
              'Post #${post.id}',
              style: TextStyle(color: Colors.indigo.shade700, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 16),

          // Titre
          Text(
            post.title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Séparateur
          const Divider(),
          const SizedBox(height: 12),

          // Corps du post
          const Text('Contenu', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(post.body, style: const TextStyle(fontSize: 16, height: 1.6, color: Colors.black87)),
          const SizedBox(height: 32),

          // Boutons d'action en bas
          Row(
            children: [
              // Bouton Modifier
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.edit),
                  label: const Text('Modifier'),
                  onPressed: () async {
                    final updated = await Navigator.push<Post>(
                      context,
                      MaterialPageRoute(builder: (_) => FormScreen(post: post)),
                    );
                    if (updated != null) {
                      setState(() => _post = updated);
                      if (mounted) Navigator.pop(context, updated);
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              // Bouton Supprimer
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.delete),
                  label: const Text('Supprimer'),
                  onPressed: _confirmDelete,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
