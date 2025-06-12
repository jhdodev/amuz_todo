import 'dart:convert';
import 'package:amuz_todo/src/model/priority.dart';
import 'package:amuz_todo/src/view/todo/add/todo_add_view_model.dart';
import 'package:amuz_todo/src/view/todo/add/todo_add_view_state.dart';
import 'package:amuz_todo/src/view/common/widget/image_picker_action_sheet.dart';
import 'package:amuz_todo/src/view/common/widget/image_options_action_sheet.dart';
import 'package:amuz_todo/src/view/common/widget/image_full_screen_dialog.dart';
import 'package:amuz_todo/src/view/todo/widget/priority_selector_action_sheet.dart';
import 'package:amuz_todo/src/view/todo/widget/todo_date_picker_dialog.dart';
import 'package:amuz_todo/src/view/todo/widget/tag_widget.dart';
import 'package:amuz_todo/src/view/todo/add/widget/draft_confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

class TodoAddView extends ConsumerStatefulWidget {
  const TodoAddView({super.key});

  @override
  ConsumerState<TodoAddView> createState() => _TodoAddViewState();
}

class _TodoAddViewState extends ConsumerState<TodoAddView> {
  DateTime selectedDate = DateTime.now();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 페이지가 열릴 때 임시 저장 데이터 확인
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkDraft();
    });
  }

  // 임시 저장 데이터 확인 후 사용자에게 물어보기
  Future<void> _checkDraft() async {
    final hasDraft = await ref
        .read(todoAddViewModelProvider.notifier)
        .hasDraft();

    if (hasDraft && mounted) {
      DraftConfirmationDialog.show(
        context,
        onLoadDraft: _loadDraft,
        onDiscardDraft: () =>
            ref.read(todoAddViewModelProvider.notifier).clearDraft(),
      );
    }
  }

  // 임시 저장된 데이터 불러와서 UI에 적용
  Future<void> _loadDraft() async {
    try {
      final draftData = await ref
          .read(todoAddViewModelProvider.notifier)
          .loadDraft();

      // 텍스트 필드에 저장된 내용 설정
      _titleController.text = draftData['title'] ?? '';
      _descriptionController.text = draftData['description'] ?? '';

      // 우선순위 설정
      final priorityValue = draftData['priority'] ?? 2;
      final priority = Priority.fromValue(priorityValue);
      ref.read(todoAddViewModelProvider.notifier).selectPriority(priority);

      // 마감일 설정
      final dueDateString = draftData['due_date'] ?? '';
      if (dueDateString.isNotEmpty) {
        final dueDate = DateTime.parse(dueDateString);
        ref.read(todoAddViewModelProvider.notifier).selectDueDate(dueDate);
      }

      // 태그 설정
      final tagsJson = draftData['tags'] ?? '[]';
      final tagNames = List<String>.from(jsonDecode(tagsJson));

      // 저장된 태그들을 선택 상태로 만들기
      final viewModel = ref.read(todoAddViewModelProvider.notifier);
      for (String tagName in tagNames) {
        // 기존 태그 중에서 찾아서 선택
        final availableTags = ref.read(todoAddViewModelProvider).availableTags;
        final tag = availableTags.firstWhere(
          (t) => t.name == tagName,
          orElse: () => throw Exception('Tag not found'),
        );
        viewModel.toggleTag(tag);
      }

      print('🔥 임시 저장 데이터 불러오기 완료!');

      // 사용자에게 불러오기 완료 알림
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('이전 작성 내용을 불러왔습니다! 📋'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('🔥 임시 저장 데이터 불러오기 실패: $e');
    }
  }

  void _showImagePicker(BuildContext context) {
    ImagePickerActionSheet.show(
      context,
      onGalleryTap: () =>
          ref.read(todoAddViewModelProvider.notifier).pickImageFromGallery(),
    );
  }

  void _showImageOptions(BuildContext context) {
    ImageOptionsActionSheet.show(
      context,
      onViewTap: () => _showImageFullScreen(context),
      onDeleteTap: () =>
          ref.read(todoAddViewModelProvider.notifier).removeSelectedImage(),
    );
  }

  void _showImageFullScreen(BuildContext context) {
    final selectedImage = ref.read(todoAddViewModelProvider).selectedImage;
    if (selectedImage == null) return;

    ImageFullScreenDialog.show(context, imageFile: selectedImage);
  }

  void _showPrioritySelector(BuildContext context) {
    PrioritySelectorActionSheet.show(
      context,
      onPrioritySelected: (priority) =>
          ref.read(todoAddViewModelProvider.notifier).selectPriority(priority),
    );
  }

  void _showDatePicker(BuildContext context) {
    final currentDueDate =
        ref.read(todoAddViewModelProvider).selectedDueDate ?? DateTime.now();

    TodoDatePickerDialog.show(
      context,
      initialDate: currentDueDate,
      onDateSelected: (date) =>
          ref.read(todoAddViewModelProvider.notifier).selectDueDate(date),
      onDateCleared: () =>
          ref.read(todoAddViewModelProvider.notifier).clearDueDate(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '할 일 추가',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: true,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        actions: [
          Consumer(
            builder: (context, ref, child) {
              final addState = ref.watch(todoAddViewModelProvider);

              return TextButton(
                onPressed: addState.status == TodoAddViewStatus.loading
                    ? null
                    : () async {
                        final success = await ref
                            .read(todoAddViewModelProvider.notifier)
                            .saveTodo(
                              title: _titleController.text,
                              description: _descriptionController.text,
                            );

                        if (success && mounted) {
                          Navigator.pop(context, true); // true를 반환해서 새로고침 신호
                        }
                      },
                child: addState.status == TodoAddViewStatus.loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        '등록',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        bottom: true,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '제목',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _titleController,
                  cursorColor: Colors.black,
                  decoration: InputDecoration(
                    hintText: "할 일을 입력해주세요.",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: Colors.black.withValues(alpha: 0.4),
                        width: 3,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '설명',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _descriptionController,
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          hintText: "설명을 입력해주세요.",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                              width: 2,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: Colors.black.withValues(alpha: 0.4),
                              width: 3,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Consumer(
                      builder: (context, ref, child) {
                        final addState = ref.watch(todoAddViewModelProvider);
                        final hasImage = addState.selectedImage != null;
                        final isUploading = addState.isUploadingImage;

                        return GestureDetector(
                          onTap: isUploading
                              ? null
                              : hasImage
                              ? () => _showImageOptions(context)
                              : () => _showImagePicker(context),
                          child: Container(
                            width: 68,
                            height: 51,
                            decoration: BoxDecoration(
                              color: hasImage
                                  ? Colors.transparent
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 2,
                              ),
                            ),
                            child: isUploading
                                ? const Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  )
                                : hasImage
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(
                                      addState.selectedImage!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                  )
                                : const Icon(
                                    LucideIcons.imagePlus,
                                    color: Colors.grey,
                                    size: 30,
                                  ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '태그',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                Consumer(
                  builder: (context, ref, child) {
                    final addState = ref.watch(todoAddViewModelProvider);

                    return SizedBox(
                      height: 50,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            ...addState.availableTags.map(
                              (tag) => Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: TagWidget(
                                  tag: tag.name,
                                  isSelected: addState.selectedTags.any(
                                    (t) => t.name == tag.name,
                                  ),
                                  onTap: () => ref
                                      .read(todoAddViewModelProvider.notifier)
                                      .toggleTag(tag),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _tagController,
                  cursorColor: Colors.black,
                  decoration: InputDecoration(
                    prefixText: '#',
                    prefixStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    hintText: "태그를 입력해주세요.",
                    suffixIcon: IconButton(
                      onPressed: () {
                        if (_tagController.text.trim().isNotEmpty) {
                          ref
                              .read(todoAddViewModelProvider.notifier)
                              .addNewTag(_tagController.text);
                          _tagController.clear();
                        }
                      },
                      icon: const Icon(LucideIcons.plus),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: Colors.black.withValues(alpha: 0.4),
                        width: 3,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '우선 순위',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => _showPrioritySelector(context),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300, width: 2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          ref
                              .watch(todoAddViewModelProvider)
                              .selectedPriority
                              .displayName,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        const Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '마감일',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                Consumer(
                  builder: (context, ref, child) {
                    final addState = ref.watch(todoAddViewModelProvider);
                    final dueDate = addState.selectedDueDate;

                    return GestureDetector(
                      onTap: () => _showDatePicker(context),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              dueDate != null
                                  ? '${dueDate.year}년 ${dueDate.month}월 ${dueDate.day}일'
                                  : '마감일을 선택해주세요',
                              style: TextStyle(
                                fontSize: 16,
                                color: dueDate != null
                                    ? Colors.black
                                    : Colors.grey,
                              ),
                            ),
                            const Icon(
                              Icons.calendar_today,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () async {
                    // 임시 저장 실행
                    await ref
                        .read(todoAddViewModelProvider.notifier)
                        .saveDraft(
                          title: _titleController.text,
                          description: _descriptionController.text,
                        );

                    // 사용자에게 저장 완료 알림
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('임시 저장 완료!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    '임시 저장',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
