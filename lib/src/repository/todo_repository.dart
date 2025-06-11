import 'package:amuz_todo/src/model/priority.dart';
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
    required Priority priority,
    DateTime? dueDate, // 마감일 매개변수 추가
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
            'priority': priority.value,
            'due_date': dueDate?.toIso8601String(), // 마감일 추가
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

  // 특정 Todo 가져오기
  Future<Todo> getTodoById(String todoId) async {
    try {
      final todoResponse = await _supabase
          .from('todos')
          .select()
          .eq('id', todoId)
          .eq('user_id', _supabase.auth.currentUser!.id)
          .single();

      final todo = Todo.fromJson(todoResponse);
      final tags = await _getTagsForTodo(todo.id);
      return todo.copyWith(tags: tags);
    } catch (e) {
      throw Exception('Todo를 가져오는데 실패했습니다: $e');
    }
  }

  // Todo 업데이트
  Future<void> updateTodo({
    required String todoId,
    required String title,
    String? description,
    String? imageUrl,
    Priority? priority,
    DateTime? dueDate,
    bool clearDueDate = false,
  }) async {
    try {
      final updateData = {
        'title': title,
        'description': description,
        'image_url': imageUrl,
        'priority': priority?.value,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // 마감일 처리
      if (clearDueDate) {
        updateData['due_date'] = null;
      } else if (dueDate != null) {
        updateData['due_date'] = dueDate.toIso8601String();
      }

      await _supabase
          .from('todos')
          .update(updateData)
          .eq('id', todoId)
          .eq('user_id', _supabase.auth.currentUser!.id);
    } catch (e) {
      throw Exception('Todo 업데이트에 실패했습니다: $e');
    }
  }

  // Todo의 모든 태그 연결 해제
  Future<void> unlinkTodoFromAllTags(String todoId) async {
    try {
      await _supabase.from('todo_tags').delete().eq('todo_id', todoId);
    } catch (e) {
      throw Exception('Todo 태그 연결 해제에 실패했습니다: $e');
    }
  }

  // Todo 삭제
  Future<void> deleteTodo(String todoId) async {
    try {
      // 먼저 태그 연결 해제
      await unlinkTodoFromAllTags(todoId);

      // Todo 삭제
      await _supabase
          .from('todos')
          .delete()
          .eq('id', todoId)
          .eq('user_id', _supabase.auth.currentUser!.id);
    } catch (e) {
      throw Exception('Todo 삭제에 실패했습니다: $e');
    }
  }

  // Todo 완료 상태 토글
  Future<void> toggleTodoCompletion(String todoId, bool isCompleted) async {
    try {
      await _supabase
          .from('todos')
          .update({
            'is_completed': isCompleted,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', todoId)
          .eq('user_id', _supabase.auth.currentUser!.id);
    } catch (e) {
      throw Exception('Todo 완료 상태 변경에 실패했습니다: $e');
    }
  }
}
