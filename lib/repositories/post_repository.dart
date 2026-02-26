import '../models/post.dart';
import '../services/api_client.dart';
import '../services/cache_service.dart';

class PostRepository {
  final ApiClient _api;
  final CacheService _cache;

  PostRepository({ApiClient? api, CacheService? cache})
      : _api = api ?? ApiClient(),
        _cache = cache ?? CacheService();

  Future<List<Post>> getAll() async {
    try {
      final data = await _api.get('/posts') as List<dynamic>;
      final posts = data.map((json) => Post.fromJson(json)).toList();

      await _cache.savePosts(posts);

      return posts;
    } catch (e) {
      final cached = await _cache.loadPosts();
      if (cached != null && cached.isNotEmpty) {
        return cached;
      }

      rethrow;
    }
  }

  Future<Post> getById(int id) async {
    try {
      final data = await _api.get('/posts/$id') as Map<String, dynamic>;
      return Post.fromJson(data);
    } catch (e) {
      final cached = await _cache.loadPosts();
      if (cached != null) {
        final post = cached.firstWhere(
          (p) => p.id == id,
          orElse: () => throw Exception('Post introuvable (hors ligne)'),
        );
        return post;
      }
      rethrow;
    }
  }

  Future<Post> create(String title, String body) async {
    final data = await _api.post('/posts', {
      'title': title,
      'body': body,
      'userId': 1, //
    }) as Map<String, dynamic>;

    final newPost = Post.fromJson(data);

    final cached = await _cache.loadPosts() ?? [];
    await _cache.savePosts([newPost, ...cached]);

    return newPost;
  }

  Future<Post> update(int id, String title, String body) async {
    final data = await _api.put('/posts/$id', {
      'id': id,
      'title': title,
      'body': body,
      'userId': 1,
    }) as Map<String, dynamic>;

    final updatedPost = Post.fromJson(data);
    final cached = await _cache.loadPosts() ?? [];
    final newList = cached.map((p) => p.id == id ? updatedPost : p).toList();
    await _cache.savePosts(newList);

    return updatedPost;
  }

  Future<void> delete(int id) async {
    await _api.delete('/posts/$id');

    // Retire du cache
    final cached = await _cache.loadPosts() ?? [];
    final newList = cached.where((p) => p.id != id).toList();
    await _cache.savePosts(newList);
  }

  Future<bool> hasCachedData() => _cache.hasCachedPosts();
}
