import 'dart:convert';
import 'dart:io';

import 'package:amuz_todo/src/model/priority.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amuz_todo/src/repository/todo_repository.dart';
import 'package:amuz_todo/src/model/tag.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'todo_add_view_state.dart';

final todoAddRepositoryProvider = Provider<TodoRepository>((ref) {
  return TodoRepository();
});

class TodoAddViewModel extends StateNotifier<TodoAddViewState> {
  final TodoRepository _todoRepository;
  final ImagePicker _imagePicker = ImagePicker();
  final SupabaseClient _supabase = Supabase.instance.client;

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

  void selectPriority(Priority priority) {
    state = state.copyWith(selectedPriority: priority);
  }

  // 마감일 선택
  void selectDueDate(DateTime? dueDate) {
    state = state.copyWith(selectedDueDate: dueDate);
  }

  // 마감일 제거
  void clearDueDate() {
    state = state.copyWith(clearDueDate: true);
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
      // Todo 생성
      final todo = await _todoRepository.createTodo(
        title: title.trim(),
        description: description?.trim(),
        imageUrl: state.imageUrl,
        priority: state.selectedPriority,
        dueDate: state.selectedDueDate,
      );

      // 선택된 태그들 처리
      if (state.selectedTags.isNotEmpty) {
        List<String> tagIds = [];

        for (Tag tag in state.selectedTags) {
          tagIds.add(tag.id);
        }

        // Todo와 태그 연결
        await _todoRepository.linkTodoWithTags(todo.id, tagIds);
      }

      state = state.copyWith(status: TodoAddViewStatus.success);
      // Todo 등록 성공 시 임시 저장 데이터 삭제
      await clearDraft();
      return true;
    } catch (e) {
      state = state.copyWith(
        status: TodoAddViewStatus.error,
        errorMessage: e.toString(),
      );
      return false;
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
        status: TodoAddViewStatus.error,
        errorMessage: '이미지를 선택하는 중 오류가 발생했습니다.',
      );
    }
  }

  /// 이미지 업로드
  Future<void> _uploadImage(String imagePath) async {
    print('🔥 이미지 업로드 시작: $imagePath');
    state = state.copyWith(isUploadingImage: true);

    try {
      final imageUrl = await _uploadToSupabaseStorage(imagePath);
      print('🔥 업로드 성공! imageUrl: $imageUrl');
      state = state.copyWith(isUploadingImage: false, imageUrl: imageUrl);
    } catch (e) {
      print('🔥 업로드 실패: $e');
      state = state.copyWith(
        isUploadingImage: false,
        status: TodoAddViewStatus.error,
        errorMessage: '이미지 업로드에 실패했습니다.',
      );
    }
  }

  /// Supabase Storage에 업로드
  Future<String> _uploadToSupabaseStorage(String imagePath) async {
    try {
      print('🔥 Storage 업로드 시작');
      final file = File(imagePath);
      final userId = _supabase.auth.currentUser?.id;

      print('🔥 userId: $userId');

      if (userId == null) {
        throw Exception('로그인이 필요합니다');
      }

      final fileName =
          'todo_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = 'todos/$fileName';

      print('🔥 업로드할 파일 경로: $filePath');

      await _supabase.storage
          .from('todo-images')
          .upload(
            filePath,
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      print('🔥 Storage 업로드 완료');

      final publicUrl = _supabase.storage
          .from('todo-images')
          .getPublicUrl(filePath);

      print('🔥 Public URL: $publicUrl');

      return publicUrl;
    } catch (e) {
      print('🔥 Storage 업로드 에러: $e');
      throw Exception('이미지 업로드에 실패했습니다: $e');
    }
  }

  /// 선택된 이미지 제거
  void removeSelectedImage() {
    state = TodoAddViewState(
      status: state.status,
      availableTags: state.availableTags,
      selectedTags: state.selectedTags,
      errorMessage: state.errorMessage,
      selectedImage: null,
      isUploadingImage: false,
      imageUrl: null,
    );
  }

  // 상태 초기화
  void resetState() {
    state = const TodoAddViewState();
    loadAvailableTags();
  }

  Future<void> saveDraft({required String title, String? description}) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('draft_title', title);
    await prefs.setString('draft_description', description ?? '');
    await prefs.setInt('draft_priority', state.selectedPriority.value);
    await prefs.setString(
      'draft_due_date',
      state.selectedDueDate?.toIso8601String() ?? '',
    );

    // 선택된 태그들을 JSON으로 저장
    final tagNames = state.selectedTags.map((tag) => tag.name).toList();
    await prefs.setString('draft_tags', jsonEncode(tagNames));

    print('🔥 임시 저장 완료!');
  }

  // 임시 저장된 데이터가 있는지 확인
  Future<bool> hasDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final title = prefs.getString('draft_title') ?? '';
    return title.isNotEmpty;
  }

  // 임시 저장된 데이터 불러오기
  Future<Map<String, dynamic>> loadDraft() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'title': prefs.getString('draft_title') ?? '',
      'description': prefs.getString('draft_description') ?? '',
      'priority': prefs.getInt('draft_priority') ?? 2,
      'due_date': prefs.getString('draft_due_date') ?? '',
      'tags': prefs.getString('draft_tags') ?? '[]',
    };
  }

  // 임시 저장 데이터 삭제
  Future<void> clearDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('draft_title');
    await prefs.remove('draft_description');
    await prefs.remove('draft_priority');
    await prefs.remove('draft_due_date');
    await prefs.remove('draft_tags');
    print('🔥 임시 저장 데이터 삭제 완료!');
  }
}

final todoAddViewModelProvider =
    StateNotifierProvider.autoDispose<TodoAddViewModel, TodoAddViewState>((
      ref,
    ) {
      final todoRepository = ref.watch(todoAddRepositoryProvider);
      return TodoAddViewModel(todoRepository);
    });
