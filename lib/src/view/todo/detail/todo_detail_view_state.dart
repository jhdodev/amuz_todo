import 'package:amuz_todo/src/model/todo.dart';
import 'package:amuz_todo/src/model/tag.dart';

enum TodoDetailViewStatus {
  initial,
  loading,
  success,
  error,
  deleting,
  updating,
}

class TodoDetailViewState {
  final TodoDetailViewStatus status;
  final Todo? todo;
  final List<Tag> availableTags; // 기존 태그
  final List<Tag> selectedTags; // 선택된 태그
  final String? errorMessage;

  const TodoDetailViewState({
    this.status = TodoDetailViewStatus.initial,
    this.todo,
    this.availableTags = const [],
    this.selectedTags = const [],
    this.errorMessage,
  });

  TodoDetailViewState copyWith({
    TodoDetailViewStatus? status,
    Todo? todo,
    List<Tag>? availableTags,
    List<Tag>? selectedTags,
    String? errorMessage,
  }) {
    return TodoDetailViewState(
      status: status ?? this.status,
      todo: todo ?? this.todo,
      availableTags: availableTags ?? this.availableTags,
      selectedTags: selectedTags ?? this.selectedTags,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
