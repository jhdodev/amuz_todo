import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amuz_todo/src/repository/todo_repository.dart';
import 'package:amuz_todo/src/model/tag.dart';
import 'todo_add_view_state.dart';

final todoAddRepositoryProvider = Provider<TodoRepository>((ref) {
  return TodoRepository();
});

class TodoAddViewModel extends StateNotifier<TodoAddViewState> {
  final TodoRepository _todoRepository;

  TodoAddViewModel(this._todoRepository) : super(const TodoAddViewState()) {
    loadAvailableTags();
  }

  // 기존 태그 목록 로드
  Future<void> loadAvailableTags() async {
    try {
      final tags = await _todoRepository.getUserTags();
      state = state.copyWith(
        availableTags: tags,
        status: TodoAddViewStatus.initial,
      );
    } catch (e) {
      state = state.copyWith(
        status: TodoAddViewStatus.error,
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

    // availableTags에 없는 경우에만 추가
    if (!availableTags.any((tag) => tag.name == trimmedTag)) {
      try {
        // DB에서 태그 생성
        final newTag = await _todoRepository.createTag(trimmedTag);

        availableTags.add(newTag);

        state = state.copyWith(availableTags: availableTags);
      } catch (e) {
        state = state.copyWith(
          status: TodoAddViewStatus.error,
          errorMessage: e.toString(),
        );
      }
    }
  }

  // Todo 저장
  Future<bool> saveTodo({
    required String title,
    String? description,
    String? imageUrl,
  }) async {
    if (title.trim().isEmpty) {
      state = state.copyWith(
        status: TodoAddViewStatus.error,
        errorMessage: '제목을 입력해주세요.',
      );
      return false;
    }

    state = state.copyWith(status: TodoAddViewStatus.loading);

    try {
      // 1. Todo 생성
      final todo = await _todoRepository.createTodo(
        title: title.trim(),
        description: description?.trim(),
        imageUrl: imageUrl,
      );

      // 2. 선택된 태그들 처리
      if (state.selectedTags.isNotEmpty) {
        List<String> tagIds = [];

        for (Tag tag in state.selectedTags) {
          tagIds.add(tag.id);
        }

        // 3. Todo와 태그 연결
        await _todoRepository.linkTodoWithTags(todo.id, tagIds);
      }

      state = state.copyWith(status: TodoAddViewStatus.success);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: TodoAddViewStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  // 상태 초기화
  void resetState() {
    state = const TodoAddViewState();
    loadAvailableTags();
  }
}

final todoAddViewModelProvider =
    StateNotifierProvider<TodoAddViewModel, TodoAddViewState>((ref) {
      final todoRepository = ref.watch(todoAddRepositoryProvider);
      return TodoAddViewModel(todoRepository);
    });
