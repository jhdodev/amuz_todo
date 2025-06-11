import 'dart:io';
import 'package:amuz_todo/src/model/priority.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amuz_todo/src/repository/todo_repository.dart';
import 'package:amuz_todo/src/model/tag.dart';
import 'package:amuz_todo/src/model/todo.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'todo_detail_view_state.dart';

final todoDetailRepositoryProvider = Provider<TodoRepository>((ref) {
  return TodoRepository();
});

class TodoDetailViewModel extends StateNotifier<TodoDetailViewState> {
  final TodoRepository _todoRepository;
  final ImagePicker _imagePicker = ImagePicker();
  final SupabaseClient _supabase = Supabase.instance.client;

  TodoDetailViewModel(this._todoRepository)
    : super(const TodoDetailViewState());

  void selectPriority(Priority priority) {
    state = state.copyWith(selectedPriority: priority);
  }

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
        selectedPriority: todo.priority,
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

  /// 갤러리에서 이미지 선택
  Future<void> pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        state = state.copyWith(selectedImage: File(image.path));
        await _uploadImage(image.path);
      }
    } catch (e) {
      state = state.copyWith(
        status: TodoDetailViewStatus.error,
        errorMessage: '이미지를 선택하는 중 오류가 발생했습니다.',
      );
    }
  }

  /// 이미지 업로드
  Future<void> _uploadImage(String imagePath) async {
    state = state.copyWith(isUploadingImage: true);

    try {
      final imageUrl = await _uploadToSupabaseStorage(imagePath);
      state = state.copyWith(isUploadingImage: false, imageUrl: imageUrl);
    } catch (e) {
      state = state.copyWith(
        isUploadingImage: false,
        status: TodoDetailViewStatus.error,
        errorMessage: '이미지 업로드에 실패했습니다.',
      );
    }
  }

  /// Supabase Storage에 업로드
  Future<String> _uploadToSupabaseStorage(String imagePath) async {
    try {
      final file = File(imagePath);
      final userId = _supabase.auth.currentUser?.id;

      if (userId == null) {
        throw Exception('로그인이 필요합니다');
      }

      final fileName =
          'todo_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = 'todos/$fileName';

      await _supabase.storage
          .from('todo-images')
          .upload(
            filePath,
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      final publicUrl = _supabase.storage
          .from('todo-images')
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      throw Exception('이미지 업로드에 실패했습니다: $e');
    }
  }

  /// 선택된 이미지 제거
  void removeSelectedImage() {
    if (state.todo == null) return;

    final newTodo = state.todo!.copyWith(clearImageUrl: true);

    state = TodoDetailViewState(
      status: state.status,
      todo: newTodo,
      availableTags: state.availableTags,
      selectedTags: state.selectedTags,
      errorMessage: state.errorMessage,
      selectedImage: null,
      isUploadingImage: false,
      imageUrl: null,
    );
  }

  // Todo 업데이트
  Future<bool> updateTodo({required String title, String? description}) async {
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
      // 새 이미지가 있으면 새 URL 사용, 없으면 현재 todo의 imageUrl 사용
      final imageUrlToSave = state.imageUrl ?? state.todo!.imageUrl;

      // Todo 업데이트
      await _todoRepository.updateTodo(
        todoId: state.todo!.id,
        title: title.trim(),
        description: description?.trim(),
        imageUrl: imageUrlToSave,
        priority: state.selectedPriority,
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
