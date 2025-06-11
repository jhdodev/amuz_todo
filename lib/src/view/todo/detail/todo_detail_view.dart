import 'package:amuz_todo/src/view/todo/detail/todo_detail_view_model.dart';
import 'package:amuz_todo/src/view/todo/detail/todo_detail_view_state.dart';
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
  String selectedPriority = '중요도 보통';
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

  void _showPrioritySelector(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text(
          '우선 순위',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              setState(() {
                selectedPriority = '중요도 높음';
              });
              Navigator.pop(context);
            },
            child: const Text('중요도 높음'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              setState(() {
                selectedPriority = '중요도 보통';
              });
              Navigator.pop(context);
            },
            child: const Text('중요도 보통'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              setState(() {
                selectedPriority = '중요도 낮음';
              });
              Navigator.pop(context);
            },
            child: const Text('중요도 낮음'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('취소'),
        ),
      ),
    );
  }

  void _showDatePicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => Container(
        height: 250,
        padding: const EdgeInsets.only(top: 6.0),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('취소'),
                    ),
                    const Text(
                      '마감일 선택',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none,
                        color: Colors.red,
                      ),
                    ),
                    CupertinoButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('완료'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: selectedDate,
                  minimumDate: DateTime.now().subtract(
                    const Duration(hours: 1),
                  ),
                  maximumDate: DateTime.now().add(const Duration(days: 365)),
                  onDateTimeChanged: (DateTime newDate) {
                    setState(() {
                      selectedDate = newDate;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer(
          builder: (context, ref, child) {
            final detailState = ref.watch(
              todoDetailViewModelProvider(widget.todoId),
            );

            return Text(
              detailState.todo?.title ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            );
          },
        ),
        centerTitle: true,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
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
                    : const Text(
                        '수정',
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
                Consumer(
                  builder: (context, ref, child) {
                    final detailState = ref.watch(
                      todoDetailViewModelProvider(widget.todoId),
                    );

                    // todo 데이터 로드되면 컨트롤러에 값 설정
                    if (detailState.todo != null &&
                        _titleController.text.isEmpty) {
                      _titleController.text = detailState.todo!.title;
                    }

                    return TextField(
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
                    );
                  },
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
                      child: Consumer(
                        builder: (context, ref, child) {
                          final detailState = ref.watch(
                            todoDetailViewModelProvider(widget.todoId),
                          );

                          // todo 데이터 로드되면 컨트롤러에 값 설정
                          if (detailState.todo != null &&
                              _descriptionController.text.isEmpty) {
                            _descriptionController.text =
                                detailState.todo!.description ?? '';
                          }

                          return TextField(
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
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: 68,
                        height: 51,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          LucideIcons.imagePlus,
                          color: Colors.grey,
                          size: 30,
                        ),
                      ),
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
                                child: _buildTag(
                                  tag.name,
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
                  cursorColor: Colors.black,
                  decoration: InputDecoration(
                    prefixText: '#',
                    prefixStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    hintText: "태그를 입력해주세요.",
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
                          selectedPriority,
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
                    '마감일 설정',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => _showDatePicker(context),
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
                          '${selectedDate.year}년 ${selectedDate.month}월 ${selectedDate.day}일',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        const Icon(Icons.calendar_today, color: Colors.grey),
                      ],
                    ),
                  ),
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

Widget _buildTag(String tag, {bool isSelected = false, VoidCallback? onTap}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? Colors.black : Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Text(
        '#$tag',
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
    ),
  );
}
