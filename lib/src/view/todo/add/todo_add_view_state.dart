import 'dart:io';
import 'package:amuz_todo/src/model/tag.dart';

enum TodoAddViewStatus { initial, loading, success, error }

class TodoAddViewState {
  final TodoAddViewStatus status;
  final List<Tag> availableTags; // 사용자의 기존 태그들
  final List<Tag> selectedTags; // 선택된 태그들
  final String? errorMessage;
  final File? selectedImage;
  final bool isUploadingImage;
  final String? imageUrl;

  const TodoAddViewState({
    this.status = TodoAddViewStatus.initial,
    this.availableTags = const [],
    this.selectedTags = const [],
    this.errorMessage,
    this.selectedImage,
    this.isUploadingImage = false,
    this.imageUrl,
  });

  TodoAddViewState copyWith({
    TodoAddViewStatus? status,
    List<Tag>? availableTags,
    List<Tag>? selectedTags,
    String? errorMessage,
    File? selectedImage,
    bool? isUploadingImage,
    String? imageUrl,
  }) {
    return TodoAddViewState(
      status: status ?? this.status,
      availableTags: availableTags ?? this.availableTags,
      selectedTags: selectedTags ?? this.selectedTags,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedImage: selectedImage ?? this.selectedImage,
      isUploadingImage: isUploadingImage ?? this.isUploadingImage,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
