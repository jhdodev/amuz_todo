import 'package:amuz_todo/src/model/user.dart';

enum TodoListViewStatus { initial, loading, success, error }

class TodoListViewState {
  final TodoListViewStatus status;
  final User? currentUser;
  final String? errorMessage;
  // final List<Todo> todos;

  const TodoListViewState({
    this.status = TodoListViewStatus.initial,
    this.currentUser,
    this.errorMessage,
    // this.todos = const [],
  });

  TodoListViewState copyWith({
    TodoListViewStatus? status,
    User? currentUser,
    String? errorMessage,
    // List<Todo>? todos,
  }) {
    return TodoListViewState(
      status: status ?? this.status,
      currentUser: currentUser ?? this.currentUser,
      errorMessage: errorMessage ?? this.errorMessage,
      // todos: todos ?? this.todos,
    );
  }
}
