import 'dart:io';
import 'package:amuz_todo/src/model/priority.dart';
import 'package:amuz_todo/src/model/tag.dart';

enum TodoAddViewStatus { initial, loading, success, error }

class TodoAddViewState {
  final TodoAddViewStatus status;
  final List<Tag> availableTags; // 사용자의 기존 태그들
  final List<Tag> selectedTags; // 선택된 태그들
  final Priority selectedPriority;
  final DateTime? selectedDueDate;
  final String? errorMessage;
  final File? selectedImage;
  final bool isUploadingImage;
  final String? imageUrl;

  const TodoAddViewState({
    this.status = TodoAddViewStatus.initial,
    this.availableTags = const [],
    this.selectedTags = const [],
    this.selectedPriority = Priority.medium,
    this.selectedDueDate,
    this.errorMessage,
    this.selectedImage,
    this.isUploadingImage = false,
    this.imageUrl,
  });

  TodoAddViewState copyWith({
    TodoAddViewStatus? status,
    List<Tag>? availableTags,
    List<Tag>? selectedTags,
    Priority? selectedPriority,
    DateTime? selectedDueDate,
    String? errorMessage,
    File? selectedImage,
    bool? isUploadingImage,
    String? imageUrl,
    bool clearDueDate = false,
  }) {
    return TodoAddViewState(
      status: status ?? this.status,
      availableTags: availableTags ?? this.availableTags,
      selectedTags: selectedTags ?? this.selectedTags,
      selectedPriority: selectedPriority ?? this.selectedPriority,
      selectedDueDate: clearDueDate
          ? null
          : (selectedDueDate ?? this.selectedDueDate),
      errorMessage: errorMessage ?? this.errorMessage,
      selectedImage: selectedImage ?? this.selectedImage,
      isUploadingImage: isUploadingImage ?? this.isUploadingImage,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
