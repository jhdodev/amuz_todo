import 'package:amuz_todo/src/model/user.dart';
import 'package:amuz_todo/src/model/todo.dart';
import 'package:amuz_todo/src/model/tag.dart';

enum TodoListViewStatus { initial, loading, success, error }

enum SortOption {
  priorityHigh, // 우선순위 높은순
  priorityLow, // 우선순위 낮은순
  dueDateEarly, // 마감일 빠른순
  dueDateLate, // 마감일 느린순
  createdEarly, // 생성일 빠른순
  createdLate, // 생성일 느린순
}

class TodoListViewState {
  final TodoListViewStatus status;
  final User? currentUser;
  final List<Todo> todos;
  final List<Todo> filteredTodos;
  final List<Tag> userTags;
  final String completionFilter;
  final List<String> selectedTags;
  final String? errorMessage;
  final SortOption sortOption;
  final String searchQuery;

  const TodoListViewState({
    this.status = TodoListViewStatus.initial,
    this.currentUser,
    this.todos = const [],
    this.filteredTodos = const [],
    this.userTags = const [],
    this.completionFilter = '전체',
    this.selectedTags = const [],
    this.errorMessage,
    this.sortOption = SortOption.createdLate,
    this.searchQuery = '',
  });

  TodoListViewState copyWith({
    TodoListViewStatus? status,
    User? currentUser,
    List<Todo>? todos,
    List<Todo>? filteredTodos,
    List<Tag>? userTags,
    String? completionFilter,
    List<String>? selectedTags,
    String? errorMessage,
    SortOption? sortOption,
    String? searchQuery,
  }) {
    return TodoListViewState(
      status: status ?? this.status,
      currentUser: currentUser ?? this.currentUser,
      todos: todos ?? this.todos,
      filteredTodos: filteredTodos ?? this.filteredTodos,
      userTags: userTags ?? this.userTags,
      completionFilter: completionFilter ?? this.completionFilter,
      selectedTags: selectedTags ?? this.selectedTags,
      errorMessage: errorMessage ?? this.errorMessage,
      sortOption: sortOption ?? this.sortOption,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}
