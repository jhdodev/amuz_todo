import 'package:amuz_todo/src/model/user.dart';
import 'package:amuz_todo/src/model/todo.dart';
import 'package:amuz_todo/src/model/tag.dart';

enum TodoListViewStatus { initial, loading, success, error }

class TodoListViewState {
  final TodoListViewStatus status;
  final User? currentUser;
  final List<Todo> todos;
  final List<Tag> userTags;
  final String? errorMessage;

  const TodoListViewState({
    this.status = TodoListViewStatus.initial,
    this.currentUser,
    this.todos = const [],
    this.userTags = const [],
    this.errorMessage,
  });

  TodoListViewState copyWith({
    TodoListViewStatus? status,
    User? currentUser,
    List<Todo>? todos,
    List<Tag>? userTags,
    String? errorMessage,
  }) {
    return TodoListViewState(
      status: status ?? this.status,
      currentUser: currentUser ?? this.currentUser,
      todos: todos ?? this.todos,
      userTags: userTags ?? this.userTags,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
