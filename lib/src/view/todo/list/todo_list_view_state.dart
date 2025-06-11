import 'package:amuz_todo/src/model/user.dart';
import 'package:amuz_todo/src/model/todo.dart';
import 'package:amuz_todo/src/model/tag.dart';

enum TodoListViewStatus { initial, loading, success, error }

class TodoListViewState {
  final TodoListViewStatus status;
  final User? currentUser;
  final List<Todo> todos;
  final List<Todo> filteredTodos;
  final List<Tag> userTags;
  final String completionFilter;
  final List<String> selectedTags;
  final String? errorMessage;

  const TodoListViewState({
    this.status = TodoListViewStatus.initial,
    this.currentUser,
    this.todos = const [],
    this.filteredTodos = const [],
    this.userTags = const [],
    this.completionFilter = '전체',
    this.selectedTags = const [],
    this.errorMessage,
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
    );
  }
}
