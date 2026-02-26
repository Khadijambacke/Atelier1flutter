// screens/form_screen.dart
// Écran formulaire unique pour CRÉER et MODIFIER un post.
// Si `post` est null → mode création (POST)
// Si `post` est non-null → mode édition (PUT)

import 'package:flutter/material.dart';
import '../models/post.dart';
import '../repositories/post_repository.dart';

class FormScreen extends StatefulWidget {
  final Post? post; // null = création, non-null = édition

  const FormScreen({super.key, this.post});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  // ── Clé du formulaire pour la validation ────────────────────────────────
  // GlobalKey permet d'accéder aux méthodes validate() et save() du Form
  final _formKey = GlobalKey<FormState>();

  final PostRepository _repository = PostRepository();

  // Contrôleurs pour lire/écrire dans les champs texte
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;

  bool _isSubmitting = false; // true → affiche un spinner pendant l'envoi

  // Détermine le mode selon si un post est passé en paramètre
  bool get _isEditing => widget.post != null;

  @override
  void initState() {
    super.initState();
    // Pré-remplit les champs si on est en mode édition
    _titleController = TextEditingController(text: widget.post?.title ?? '');
    _bodyController = TextEditingController(text: widget.post?.body ?? '');
  }

  @override
  void dispose() {
    // IMPORTANT : toujours dispose() les contrôleurs pour éviter les fuites mémoire
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  // ── Soumission du formulaire ─────────────────────────────────────────────
  Future<void> _submit() async {
    // 1) Valide tous les champs du formulaire
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      Post result;

      if (_isEditing) {
        // Mode édition → PUT
        result = await _repository.update(
          widget.post!.id,
          _titleController.text.trim(),
          _bodyController.text.trim(),
        );
      } else {
        // Mode création → POST
        result = await _repository.create(
          _titleController.text.trim(),
          _bodyController.text.trim(),
        );
      }

      if (mounted) {
        // Affiche un message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing
                ? '✅ Post modifié avec succès !'
                : '✅ Post créé avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
        // Retourne le post créé/modifié à l'écran précédent
        Navigator.pop(context, result);
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
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifier le post' : 'Nouveau post'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey, // Associe la clé au formulaire
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Champ Titre ──────────────────────────────────────────────
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Titre *',
                  hintText: 'Entrez le titre du post',
                  prefixIcon: Icon(Icons.title),
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.sentences,
                maxLength: 100,
                // Règles de validation
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Le titre est obligatoire';
                  }
                  if (value.trim().length < 3) {
                    return 'Le titre doit avoir au moins 3 caractères';
                  }
                  return null; // null = valide
                },
              ),
              const SizedBox(height: 20),

              // ── Champ Corps ──────────────────────────────────────────────
              TextFormField(
                controller: _bodyController,
                decoration: const InputDecoration(
                  labelText: 'Contenu *',
                  hintText: 'Entrez le contenu du post',
                  prefixIcon: Icon(Icons.article),
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 6,      // Zone de texte multiligne
                maxLength: 500,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Le contenu est obligatoire';
                  }
                  if (value.trim().length < 10) {
                    return 'Le contenu doit avoir au moins 10 caractères';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // ── Bouton de soumission ─────────────────────────────────────
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                // Désactive le bouton pendant l'envoi
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(_isEditing ? 'Enregistrer les modifications' : 'Créer le post'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
