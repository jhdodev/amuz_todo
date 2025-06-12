import 'package:amuz_todo/src/service/theme_service.dart';
import 'package:amuz_todo/src/view/todo/detail/todo_detail_view_model.dart';
import 'package:amuz_todo/src/view/todo/detail/todo_detail_view_state.dart';
import 'package:amuz_todo/src/view/common/widget/image_picker_action_sheet.dart';
import 'package:amuz_todo/src/view/common/widget/image_options_action_sheet.dart';
import 'package:amuz_todo/src/view/common/widget/image_full_screen_dialog.dart';
import 'package:amuz_todo/src/view/todo/widget/priority_selector_action_sheet.dart';
import 'package:amuz_todo/src/view/todo/widget/todo_date_picker_dialog.dart';
import 'package:amuz_todo/src/view/todo/widget/tag_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

class TodoDetailView extends ConsumerStatefulWidget {
  const TodoDetailView({super.key, required this.todoId});

  final String todoId;

  @override
  ConsumerState<TodoDetailView> createState() => _TodoDetailViewState();
}

class _TodoDetailViewState extends ConsumerState<TodoDetailView> {
  DateTime selectedDate = DateTime.now();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // ViewModel에서 todo 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(todoDetailViewModelProvider(widget.todoId).notifier)
          .loadTodo(widget.todoId);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _showImagePicker(BuildContext context) {
    ImagePickerActionSheet.show(
      context,
      onGalleryTap: () => ref
          .read(todoDetailViewModelProvider(widget.todoId).notifier)
          .pickImageFromGallery(),
    );
  }

  void _showImageOptions(BuildContext context) {
    ImageOptionsActionSheet.show(
      context,
      onViewTap: () => _showImageFullScreen(context),
      onDeleteTap: () => ref
          .read(todoDetailViewModelProvider(widget.todoId).notifier)
          .removeSelectedImage(),
    );
  }

  void _showImageFullScreen(BuildContext context) {
    final detailState = ref.read(todoDetailViewModelProvider(widget.todoId));

    // 새로 선택된 이미지가 있으면 그것을, 없으면 기존 이미지를 표시
    final selectedImage = detailState.selectedImage;
    final existingImageUrl = detailState.todo?.imageUrl;

    if (selectedImage == null && existingImageUrl == null) return;

    ImageFullScreenDialog.show(
      context,
      imageFile: selectedImage,
      imageUrl: existingImageUrl,
    );
  }

  void _showPrioritySelector(BuildContext context) {
    PrioritySelectorActionSheet.show(
      context,
      onPrioritySelected: (priority) => ref
          .read(todoDetailViewModelProvider(widget.todoId).notifier)
          .selectPriority(priority),
    );
  }

  void _showDatePicker(BuildContext context) {
    final currentDueDate =
        ref.read(todoDetailViewModelProvider(widget.todoId)).selectedDueDate ??
        DateTime.now();

    TodoDatePickerDialog.show(
      context,
      initialDate: currentDueDate,
      onDateSelected: (date) => ref
          .read(todoDetailViewModelProvider(widget.todoId).notifier)
          .selectDueDate(date),
      onDateCleared: () => ref
          .read(todoDetailViewModelProvider(widget.todoId).notifier)
          .clearDueDate(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(isDarkModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Consumer(
          builder: (context, ref, child) {
            final detailState = ref.watch(
              todoDetailViewModelProvider(widget.todoId),
            );

            return Text(
              detailState.todo?.title ?? '',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            );
          },
        ),
        centerTitle: true,
        scrolledUnderElevation: 0,
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        iconTheme: IconThemeData(
          color: isDarkMode ? Colors.white : Colors.black,
        ),
        actions: [
          Consumer(
            builder: (context, ref, child) {
              final detailState = ref.watch(
                todoDetailViewModelProvider(widget.todoId),
              );

              return TextButton(
                onPressed: detailState.status == TodoDetailViewStatus.updating
                    ? null
                    : () async {
                        final success = await ref
                            .read(
                              todoDetailViewModelProvider(
                                widget.todoId,
                              ).notifier,
                            )
                            .updateTodo(
                              title: _titleController.text,
                              description: _descriptionController.text,
                            );

                        if (success && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('수정이 완료되었습니다.')),
                          );
                          // 수정 완료 후 리스트 화면으로 돌아가기
                          Navigator.pop(context, true);
                        }
                      },
                child: detailState.status == TodoDetailViewStatus.updating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        '수정',
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
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
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Consumer(
                  builder: (context, ref, child) {
                    final detailState = ref.watch(
                      todoDetailViewModelProvider(widget.todoId),
                    );

                    if (detailState.todo != null &&
                        _titleController.text.isEmpty) {
                      _titleController.text = detailState.todo!.title;
                    }

                    return TextField(
                      controller: _titleController,
                      cursorColor: isDarkMode
                          ? Color(0xFFE5E5E5)
                          : Colors.black,
                      style: TextStyle(
                        color: isDarkMode ? Color(0xFFFAFAFA) : Colors.black,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        hintText: "할 일을 입력해주세요.",
                        hintStyle: TextStyle(
                          color: isDarkMode ? Color(0xFFA0A0A0) : Colors.grey,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: isDarkMode
                                ? Color(0xFF1A1A1A)
                                : Color(0xFFE5E5E5),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: isDarkMode
                                ? Color(0xFF1A1A1A)
                                : Colors.black.withValues(alpha: 0.4),
                            width: 3,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '설명',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Consumer(
                        builder: (context, ref, child) {
                          final detailState = ref.watch(
                            todoDetailViewModelProvider(widget.todoId),
                          );

                          if (detailState.todo != null &&
                              _descriptionController.text.isEmpty) {
                            _descriptionController.text =
                                detailState.todo!.description ?? '';
                          }

                          return TextField(
                            controller: _descriptionController,
                            cursorColor: isDarkMode
                                ? Color(0xFFE5E5E5)
                                : Colors.black,
                            style: TextStyle(
                              color: isDarkMode
                                  ? Color(0xFFFAFAFA)
                                  : Colors.black,
                              fontSize: 16,
                            ),
                            decoration: InputDecoration(
                              hintText: "설명을 입력해주세요.",
                              hintStyle: TextStyle(
                                color: isDarkMode
                                    ? Color(0xFFA0A0A0)
                                    : Colors.grey,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                  color: isDarkMode
                                      ? Color(0xFF1A1A1A)
                                      : Color(0xFFE5E5E5),
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                  color: isDarkMode
                                      ? Color(0xFF1A1A1A)
                                      : Colors.black.withValues(alpha: 0.4),
                                  width: 3,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Consumer(
                      builder: (context, ref, child) {
                        final detailState = ref.watch(
                          todoDetailViewModelProvider(widget.todoId),
                        );
                        final hasNewImage = detailState.selectedImage != null;
                        final hasExistingImage =
                            detailState.todo?.imageUrl != null;
                        final hasAnyImage = hasNewImage || hasExistingImage;
                        final isUploading = detailState.isUploadingImage;

                        return GestureDetector(
                          onTap: isUploading
                              ? null
                              : hasAnyImage
                              ? () => _showImageOptions(context)
                              : () => _showImagePicker(context),
                          child: Container(
                            width: 68,
                            height: 51,
                            decoration: BoxDecoration(
                              color: hasAnyImage
                                  ? Colors.transparent
                                  : (isDarkMode
                                        ? Color(0xFF272727)
                                        : Colors.grey.shade200),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isDarkMode
                                    ? Color(0xFF1A1A1A)
                                    : Color(0xFFE5E5E5),
                                width: 1,
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
                                : hasNewImage
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(
                                      detailState.selectedImage!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                  )
                                : hasExistingImage
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      detailState.todo!.imageUrl!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return const Icon(
                                              LucideIcons.imagePlus,
                                              color: Colors.grey,
                                              size: 30,
                                            );
                                          },
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
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Consumer(
                  builder: (context, ref, child) {
                    final detailState = ref.watch(
                      todoDetailViewModelProvider(widget.todoId),
                    );

                    return SizedBox(
                      height: 50,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            ...detailState.availableTags.map(
                              (tag) => Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: TagWidget(
                                  tag: tag.name,
                                  isSelected: detailState.selectedTags.any(
                                    (t) => t.name == tag.name,
                                  ),
                                  onTap: () => ref
                                      .read(
                                        todoDetailViewModelProvider(
                                          widget.todoId,
                                        ).notifier,
                                      )
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
                  cursorColor: isDarkMode ? Color(0xFFE5E5E5) : Colors.black,
                  style: TextStyle(
                    color: isDarkMode ? Color(0xFFFAFAFA) : Colors.black,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    prefixText: '#',
                    prefixStyle: TextStyle(
                      color: isDarkMode ? Color(0xFFFAFAFA) : Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    hintText: "태그를 입력해주세요.",
                    hintStyle: TextStyle(
                      color: isDarkMode ? Color(0xFFA0A0A0) : Colors.grey,
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        if (_tagController.text.trim().isNotEmpty) {
                          ref
                              .read(
                                todoDetailViewModelProvider(
                                  widget.todoId,
                                ).notifier,
                              )
                              .addNewTag(_tagController.text);
                          _tagController.clear();
                        }
                      },
                      icon: Icon(
                        LucideIcons.plus,
                        color: isDarkMode ? Color(0xFFA0A0A0) : Colors.black,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: isDarkMode
                            ? Color(0xFF1A1A1A)
                            : Color(0xFFE5E5E5),
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: isDarkMode
                            ? Color(0xFF1A1A1A)
                            : Colors.black.withValues(alpha: 0.4),
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
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
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
                      color: isDarkMode
                          ? Colors.transparent
                          : Colors.transparent,
                      border: Border.all(
                        color: isDarkMode
                            ? Color(0xFF1A1A1A)
                            : Color(0xFFE5E5E5),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          ref
                              .watch(todoDetailViewModelProvider(widget.todoId))
                              .selectedPriority
                              .displayName,
                          style: TextStyle(
                            fontSize: 16,
                            color: isDarkMode
                                ? Color(0xFFFAFAFA)
                                : Colors.black,
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_down,
                          color: isDarkMode ? Color(0xFFA0A0A0) : Colors.grey,
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
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Consumer(
                  builder: (context, ref, child) {
                    final detailState = ref.watch(
                      todoDetailViewModelProvider(widget.todoId),
                    );
                    final dueDate = detailState.selectedDueDate;

                    return GestureDetector(
                      onTap: () => _showDatePicker(context),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? Colors.transparent
                              : Colors.transparent,
                          border: Border.all(
                            color: isDarkMode
                                ? Color(0xFF1A1A1A)
                                : Color(0xFFE5E5E5),
                            width: 1,
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
                                    ? (isDarkMode
                                          ? Color(0xFFFAFAFA)
                                          : Colors.black)
                                    : (isDarkMode
                                          ? Color(0xFFA0A0A0)
                                          : Colors.grey),
                              ),
                            ),
                            Icon(
                              Icons.calendar_today,
                              color: isDarkMode
                                  ? Color(0xFFA0A0A0)
                                  : Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                Consumer(
                  builder: (context, ref, child) {
                    final detailState = ref.watch(
                      todoDetailViewModelProvider(widget.todoId),
                    );

                    return TextButton(
                      onPressed:
                          detailState.status == TodoDetailViewStatus.deleting
                          ? null
                          : () async {
                              // 삭제 확인 다이얼로그
                              final shouldDelete =
                                  await showCupertinoDialog<bool>(
                                    context: context,
                                    builder: (context) => CupertinoAlertDialog(
                                      title: const Text('할 일 삭제'),
                                      content: const Text(
                                        '이 할 일을 삭제하시겠습니까?\n삭제 후에는 복구가 불가능합니다.',
                                      ),
                                      actions: [
                                        CupertinoDialogAction(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('취소'),
                                        ),
                                        CupertinoDialogAction(
                                          isDestructiveAction: true,
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text('삭제'),
                                        ),
                                      ],
                                    ),
                                  );

                              if (shouldDelete == true) {
                                final success = await ref
                                    .read(
                                      todoDetailViewModelProvider(
                                        widget.todoId,
                                      ).notifier,
                                    )
                                    .deleteTodo();

                                if (success && mounted) {
                                  Navigator.pop(
                                    context,
                                    true,
                                  ); // 삭제 성공 시 이전 화면으로 돌아가기
                                }
                              }
                            },
                      child: detailState.status == TodoDetailViewStatus.deleting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.red,
                                ),
                              ),
                            )
                          : const Text(
                              '삭제',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
