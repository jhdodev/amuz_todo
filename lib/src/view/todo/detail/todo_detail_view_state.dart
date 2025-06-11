import 'dart:io';
import 'package:amuz_todo/src/model/priority.dart';
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
  final Priority selectedPriority;
  final DateTime? selectedDueDate;
  final String? errorMessage;
  final File? selectedImage;
  final bool isUploadingImage;
  final String? imageUrl;
  final bool clearDueDate;

  const TodoDetailViewState({
    this.status = TodoDetailViewStatus.initial,
    this.todo,
    this.availableTags = const [],
    this.selectedTags = const [],
    this.selectedPriority = Priority.medium,
    this.selectedDueDate,
    this.errorMessage,
    this.selectedImage,
    this.isUploadingImage = false,
    this.imageUrl,
    this.clearDueDate = false,
  });

  TodoDetailViewState copyWith({
    TodoDetailViewStatus? status,
    Todo? todo,
    List<Tag>? availableTags,
    List<Tag>? selectedTags,
    Priority? selectedPriority,
    DateTime? selectedDueDate,
    String? errorMessage,
    File? selectedImage,
    bool? isUploadingImage,
    String? imageUrl,
    bool? clearDueDate,
  }) {
    return TodoDetailViewState(
      status: status ?? this.status,
      todo: todo ?? this.todo,
      availableTags: availableTags ?? this.availableTags,
      selectedTags: selectedTags ?? this.selectedTags,
      selectedPriority: selectedPriority ?? this.selectedPriority,
      selectedDueDate: (clearDueDate == true)
          ? null
          : (selectedDueDate ?? this.selectedDueDate),
      clearDueDate: clearDueDate ?? this.clearDueDate,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedImage: selectedImage ?? this.selectedImage,
      isUploadingImage: isUploadingImage ?? this.isUploadingImage,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
