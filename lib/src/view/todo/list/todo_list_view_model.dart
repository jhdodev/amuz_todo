import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amuz_todo/src/service/auth_service.dart';
import 'package:amuz_todo/src/repository/auth_repository.dart';
import 'package:amuz_todo/src/repository/todo_repository.dart';
import 'todo_list_view_state.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(AuthRepository());
});

final todoRepositoryProvider = Provider<TodoRepository>((ref) {
  return TodoRepository();
});

class TodoListViewModel extends StateNotifier<TodoListViewState> {
  final TodoRepository _todoRepository;

  TodoListViewModel(this._todoRepository) : super(const TodoListViewState()) {
    loadInitialData();
  }

  // 초기 데이터 로딩
  Future<void> loadInitialData() async {
    state = state.copyWith(status: TodoListViewStatus.loading);

    try {
      // 병렬로 데이터 가져오기
      final futures = await Future.wait([
        _todoRepository.getTodos(),
        _todoRepository.getUserTags(),
      ]);

      final todos = futures[0] as List<dynamic>;
      final userTags = futures[1] as List<dynamic>;

      state = state.copyWith(
        status: TodoListViewStatus.success,
        todos: todos.cast(),
        userTags: userTags.cast(),
      );
    } catch (e) {
      state = state.copyWith(
        status: TodoListViewStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // Todo 목록 새로고침
  Future<void> refreshTodos() async {
    try {
      final todos = await _todoRepository.getTodos();
      state = state.copyWith(todos: todos);
    } catch (e) {
      state = state.copyWith(
        status: TodoListViewStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // 새 Todo 생성
  Future<void> createTodo({
    required String title,
    String? description,
    String? imageUrl,
  }) async {
    try {
      await _todoRepository.createTodo(
        title: title,
        description: description,
        imageUrl: imageUrl,
      );

      // 목록 새로고침
      await refreshTodos();
    } catch (e) {
      state = state.copyWith(
        status: TodoListViewStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> toggleTodoCompletion(String todoId, bool isCompleted) async {
    try {
      await _todoRepository.toggleTodoCompletion(todoId, isCompleted);

      final updatedTodo = await _todoRepository.getTodoById(todoId);

      final updatedTodos = state.todos.map((todo) {
        return todo.id == todoId ? updatedTodo : todo;
      }).toList();

      state = state.copyWith(todos: updatedTodos);
    } catch (e) {
      state = state.copyWith(
        status: TodoListViewStatus.error,
        errorMessage: e.toString(),
      );
    }
  }
}

final todoListViewModelProvider =
    StateNotifierProvider<TodoListViewModel, TodoListViewState>((ref) {
      final todoRepository = ref.watch(todoRepositoryProvider);
      return TodoListViewModel(todoRepository);
    });
