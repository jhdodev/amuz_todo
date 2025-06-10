import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amuz_todo/src/repository/todo_repository.dart';
import 'package:amuz_todo/src/model/tag.dart';
import 'package:amuz_todo/src/model/todo.dart';
import 'todo_detail_view_state.dart';

final todoDetailRepositoryProvider = Provider<TodoRepository>((ref) {
  return TodoRepository();
});

class TodoDetailViewModel extends StateNotifier<TodoDetailViewState> {
  final TodoRepository _todoRepository;

  TodoDetailViewModel(this._todoRepository)
    : super(const TodoDetailViewState());

  // 특정 Todo 로드
  Future<void> loadTodo(String todoId) async {
    state = state.copyWith(status: TodoDetailViewStatus.loading);

    try {
      // 데이터 가져오기
      final futures = await Future.wait([
        _todoRepository.getTodoById(todoId),
        _todoRepository.getUserTags(),
      ]);

      final todo = futures[0] as Todo;
      final availableTags = futures[1] as List<Tag>;

      state = state.copyWith(
        status: TodoDetailViewStatus.success,
        todo: todo,
        availableTags: availableTags,
        selectedTags: todo.tags, // 기존에 선택된 태그들
      );
    } catch (e) {
      state = state.copyWith(
        status: TodoDetailViewStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // 태그 선택/해제 토글
  void toggleTag(Tag tag) {
    final selectedTags = List<Tag>.from(state.selectedTags);

    if (selectedTags.any((t) => t.name == tag.name)) {
      selectedTags.removeWhere((t) => t.name == tag.name);
    } else {
      selectedTags.add(tag);
    }

    state = state.copyWith(selectedTags: selectedTags);
  }

  // 새 태그 추가
  Future<void> addNewTag(String tagName) async {
    if (tagName.trim().isEmpty) return;

    final trimmedTag = tagName.trim();
    final availableTags = List<Tag>.from(state.availableTags);

    if (!availableTags.any((tag) => tag.name == trimmedTag)) {
      try {
        final newTag = await _todoRepository.createTag(trimmedTag);
        availableTags.add(newTag);
        state = state.copyWith(availableTags: availableTags);
      } catch (e) {
        state = state.copyWith(
          status: TodoDetailViewStatus.error,
          errorMessage: e.toString(),
        );
      }
    }
  }

  // Todo 업데이트
  Future<bool> updateTodo({
    required String title,
    String? description,
    String? imageUrl,
  }) async {
    if (state.todo == null) return false;

    if (title.trim().isEmpty) {
      state = state.copyWith(
        status: TodoDetailViewStatus.error,
        errorMessage: '제목을 입력해주세요.',
      );
      return false;
    }

    state = state.copyWith(status: TodoDetailViewStatus.updating);

    try {
      // Todo 업데이트
      await _todoRepository.updateTodo(
        todoId: state.todo!.id,
        title: title.trim(),
        description: description?.trim(),
        imageUrl: imageUrl,
      );

      // 기존 태그 해제 후 새로 연결
      await _todoRepository.unlinkTodoFromAllTags(state.todo!.id);

      if (state.selectedTags.isNotEmpty) {
        List<String> tagIds = state.selectedTags.map((tag) => tag.id).toList();
        await _todoRepository.linkTodoWithTags(state.todo!.id, tagIds);
      }

      // 업데이트된 Todo 다시 로드
      await loadTodo(state.todo!.id);

      return true;
    } catch (e) {
      state = state.copyWith(
        status: TodoDetailViewStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  // Todo 삭제
  Future<bool> deleteTodo() async {
    if (state.todo == null) return false;

    state = state.copyWith(status: TodoDetailViewStatus.deleting);

    try {
      // Todo 삭제
      await _todoRepository.deleteTodo(state.todo!.id);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: TodoDetailViewStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }
}

final todoDetailViewModelProvider =
    StateNotifierProvider.family<
      TodoDetailViewModel,
      TodoDetailViewState,
      String
    >((ref, todoId) {
      final todoRepository = ref.watch(todoDetailRepositoryProvider);
      final viewModel = TodoDetailViewModel(todoRepository);
      viewModel.loadTodo(todoId);
      return viewModel;
    });
