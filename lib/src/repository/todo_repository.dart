import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:amuz_todo/src/model/todo.dart';
import 'package:amuz_todo/src/model/tag.dart';

class TodoRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Todo 목록 가져오기
  Future<List<Todo>> getTodos() async {
    try {
      final todosResponse = await _supabase
          .from('todos')
          .select()
          .eq('user_id', _supabase.auth.currentUser!.id)
          .order('created_at', ascending: false);

      List<Todo> todos = [];
      for (var todoJson in todosResponse) {
        final todo = Todo.fromJson(todoJson);
        final tags = await _getTagsForTodo(todo.id);
        todos.add(todo.copyWith(tags: tags));
      }

      return todos;
    } catch (e) {
      throw Exception('Todo 목록을 가져오는데 실패했습니다: $e');
    }
  }

  // 특정 todo의 태그 목록 가져오기
  Future<List<Tag>> _getTagsForTodo(String todoId) async {
    try {
      final response = await _supabase
          .from('todo_tags')
          .select('tags(*)')
          .eq('todo_id', todoId);

      return response
          .map((item) => Tag.fromJson(item['tags']))
          .cast<Tag>()
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Todo 생성
  Future<Todo> createTodo({
    required String title,
    String? description,
    String? imageUrl,
  }) async {
    try {
      final userId = _supabase.auth.currentUser!.id;

      final todoResponse = await _supabase
          .from('todos')
          .insert({
            'title': title,
            'description': description,
            'image_url': imageUrl,
            'user_id': userId,
          })
          .select()
          .single();

      return Todo.fromJson(todoResponse);
    } catch (e) {
      throw Exception('Todo 생성에 실패했습니다: $e');
    }
  }

  // Tag 생성
  Future<Tag> createTag(String tagName) async {
    try {
      final userId = _supabase.auth.currentUser!.id;

      // 기존 태그 확인
      final existingTagResponse = await _supabase
          .from('tags')
          .select()
          .eq('name', tagName)
          .eq('user_id', userId)
          .maybeSingle();

      if (existingTagResponse != null) {
        return Tag.fromJson(existingTagResponse);
      }

      // 새 태그 생성
      final newTagResponse = await _supabase
          .from('tags')
          .insert({'name': tagName, 'user_id': userId})
          .select()
          .single();

      return Tag.fromJson(newTagResponse);
    } catch (e) {
      throw Exception('태그 생성에 실패했습니다: $e');
    }
  }

  // Todo와 태그 연결
  Future<void> linkTodoWithTags(String todoId, List<String> tagIds) async {
    try {
      for (String tagId in tagIds) {
        await _supabase.from('todo_tags').insert({
          'todo_id': todoId,
          'tag_id': tagId,
        });
      }
    } catch (e) {
      throw Exception('Todo와 태그 연결에 실패했습니다: $e');
    }
  }

  // 사용자의 모든 태그 가져오기
  Future<List<Tag>> getUserTags() async {
    try {
      final response = await _supabase
          .from('tags')
          .select()
          .eq('user_id', _supabase.auth.currentUser!.id)
          .order('name');

      return response.map((json) => Tag.fromJson(json)).cast<Tag>().toList();
    } catch (e) {
      throw Exception('태그 목록을 가져오는데 실패했습니다: $e');
    }
  }
}
