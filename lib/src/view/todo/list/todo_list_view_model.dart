import 'package:amuz_todo/src/model/priority.dart';
import 'package:amuz_todo/src/model/todo.dart';
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

      // 초기 필터링 적용
      _applyFiltersAndSort();
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
      _applyFiltersAndSort(); // 새로고침 후 필터링 다시 적용
    } catch (e) {
      state = state.copyWith(
        status: TodoListViewStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // 완료 상태 필터 변경
  void setCompletionFilter(String filter) {
    state = state.copyWith(completionFilter: filter);
    _applyFiltersAndSort();
  }

  // 태그 필터 변경
  void toggleTagFilter(String tagName) {
    List<String> newSelectedTags = List.from(state.selectedTags);
    if (newSelectedTags.contains(tagName)) {
      newSelectedTags.remove(tagName);
    } else {
      newSelectedTags.add(tagName);
    }
    state = state.copyWith(selectedTags: newSelectedTags);
    _applyFiltersAndSort();
  }

  // 필터링과 정렬 로직
  void _applyFiltersAndSort() {
    final filteredTodos = state.todos.where((todo) {
      // 완료 상태 필터링
      bool passesCompletionFilter = true;
      if (state.completionFilter == '완료') {
        passesCompletionFilter = todo.isCompleted;
      } else if (state.completionFilter == '미완료') {
        passesCompletionFilter = !todo.isCompleted;
      }

      // 태그 필터링
      bool passesTagFilter = true;
      if (state.selectedTags.isNotEmpty) {
        passesTagFilter = state.selectedTags.every((selectedTag) {
          final tagName = selectedTag.startsWith('#')
              ? selectedTag.substring(1)
              : selectedTag;
          return todo.tags.any((tag) => tag.name == tagName);
        });
      }

      return passesCompletionFilter && passesTagFilter;
    }).toList();

    // 정렬 적용
    filteredTodos.sort((a, b) => _compareTodos(a, b, state.sortOption));

    state = state.copyWith(filteredTodos: filteredTodos);
  }

  // Todo 비교 함수 (정렬용)
  int _compareTodos(Todo a, Todo b, SortOption sortOption) {
    switch (sortOption) {
      case SortOption.priorityHigh:
        return _comparePriority(b.priority, a.priority);
      case SortOption.priorityLow:
        return _comparePriority(a.priority, b.priority);
      case SortOption.dueDateEarly:
        return _compareDueDate(a.dueDate, b.dueDate);
      case SortOption.dueDateLate:
        return _compareDueDate(b.dueDate, a.dueDate);
      case SortOption.createdEarly:
        return a.createdAt.compareTo(b.createdAt);
      case SortOption.createdLate:
        return b.createdAt.compareTo(a.createdAt);
    }
  }

  // 우선순위 비교 (low=1, medium=2, high=3)
  int _comparePriority(Priority a, Priority b) {
    return a.value.compareTo(b.value);
  }

  // 마감일 비교
  int _compareDueDate(DateTime? a, DateTime? b) {
    if (a == null && b == null) return 0;
    if (a == null) return 1; // null은 뒤로
    if (b == null) return -1; // null은 뒤로
    return a.compareTo(b);
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
        priority: Priority.medium,
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
      _applyFiltersAndSort(); // 상태 변경 후 필터링 다시 적용
    } catch (e) {
      state = state.copyWith(
        status: TodoListViewStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // Todo 삭제
  Future<void> deleteTodo(String todoId) async {
    try {
      await _todoRepository.deleteTodo(todoId);

      final updatedTodos = state.todos
          .where((todo) => todo.id != todoId)
          .toList();

      state = state.copyWith(todos: updatedTodos);
      _applyFiltersAndSort(); // 삭제 후 필터링 다시 적용
    } catch (e) {
      state = state.copyWith(
        status: TodoListViewStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // 정렬 옵션 변경
  void setSortOption(SortOption sortOption) {
    state = state.copyWith(sortOption: sortOption);
    _applyFiltersAndSort();
  }
}

final todoListViewModelProvider =
    StateNotifierProvider<TodoListViewModel, TodoListViewState>((ref) {
      final todoRepository = ref.watch(todoRepositoryProvider);
      return TodoListViewModel(todoRepository);
    });
