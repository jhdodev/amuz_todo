import 'package:amuz_todo/src/model/priority.dart';
import 'package:amuz_todo/src/service/auth_service.dart';
import 'package:amuz_todo/src/view/todo/add/todo_add_view.dart';
import 'package:amuz_todo/src/view/todo/detail/todo_detail_view.dart';
import 'package:amuz_todo/src/view/todo/list/todo_list_view_model.dart';
import 'package:amuz_todo/src/view/todo/list/todo_list_view_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

class TodoListView extends ConsumerWidget {
  const TodoListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserAsync = ref.watch(currentUserProvider);
    final todoListState = ref.watch(todoListViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "amuz todo",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: true,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: IconButton(
            onPressed: () => _showSortDialog(context, ref),
            icon: const Icon(LucideIcons.listFilter),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Row(
              children: [
                currentUserAsync.when(
                  data: (user) => CircleAvatar(
                    radius: 14,
                    backgroundImage: user?.profileImageUrl != null
                        ? NetworkImage(user!.profileImageUrl!)
                        : AssetImage('assets/images/default_profile_black.png'),
                  ),
                  error: (error, stack) => const SizedBox.shrink(),
                  loading: () => const SizedBox.shrink(),
                ),
                const SizedBox(width: 6),
                Text(
                  currentUserAsync.value?.name ?? 'default',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 6),
            TextField(
              onChanged: (value) => ref
                  .read(todoListViewModelProvider.notifier)
                  .setSearchQuery(value),
              cursorColor: Colors.black,
              decoration: InputDecoration(
                hintText: "검색어를 입력하세요",
                prefixIcon: const Icon(LucideIcons.search),
                suffixIcon: IconButton(
                  onPressed: () => ref
                      .read(todoListViewModelProvider.notifier)
                      .clearSearch(),
                  icon: const Icon(LucideIcons.x),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Color(0xFFE5E5E5), width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: Colors.black.withValues(alpha: 0.4),
                    width: 3,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 필터 버튼들
            SizedBox(
              height: 50,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterButton(
                      '전체',
                      todoListState.completionFilter,
                      ref,
                    ),
                    const SizedBox(width: 10),
                    _buildFilterButton(
                      '미완료',
                      todoListState.completionFilter,
                      ref,
                    ),
                    const SizedBox(width: 10),
                    _buildFilterButton(
                      '완료',
                      todoListState.completionFilter,
                      ref,
                    ),
                    const SizedBox(width: 10),
                    VerticalDivider(color: Colors.grey.shade300, thickness: 1),
                    const SizedBox(width: 10),
                    // 동적으로 태그 필터 버튼들 생성
                    ...todoListState.userTags
                        .map(
                          (tag) => [
                            _buildTagFilterButton(
                              '#${tag.name}',
                              todoListState.selectedTags,
                              ref,
                            ),
                            const SizedBox(width: 10),
                          ],
                        )
                        .expand((element) => element),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: todoListState.status == TodoListViewStatus.loading
                  ? const Center(child: CircularProgressIndicator())
                  : todoListState.status == TodoListViewStatus.error
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('오류가 발생했습니다: ${todoListState.errorMessage}'),
                          TextButton(
                            onPressed: () => ref
                                .read(todoListViewModelProvider.notifier)
                                .loadInitialData(),
                            child: const Text('다시 시도'),
                          ),
                        ],
                      ),
                    )
                  : todoListState.filteredTodos.isEmpty
                  ? const Center(
                      child: Text(
                        '조건에 맞는 할 일이 없습니다.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: todoListState.filteredTodos.length,
                      itemBuilder: (context, index) {
                        final todo = todoListState.filteredTodos[index];
                        final isCompleted = todo.isCompleted;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Card(
                            color: Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                color: Colors.grey.shade200,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: ListTile(
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        TodoDetailView(todoId: todo.id),
                                  ),
                                );

                                // 상세 페이지에서 돌아왔을 때 목록 새로고침
                                if (result == true) {
                                  ref
                                      .read(todoListViewModelProvider.notifier)
                                      .refreshTodos();
                                }
                              },
                              leading: Transform.scale(
                                scale: 1.2,
                                child: Checkbox(
                                  value: isCompleted,
                                  activeColor: Colors.black,
                                  checkColor: Colors.white,
                                  side: BorderSide(
                                    color: Colors.grey.shade400,
                                    width: 1.0,
                                  ),
                                  onChanged: (bool? value) {
                                    if (value != null) {
                                      ref
                                          .read(
                                            todoListViewModelProvider.notifier,
                                          )
                                          .toggleTodoCompletion(todo.id, value);
                                    }
                                  },
                                ),
                              ),
                              title: Text(
                                todo.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: isCompleted
                                      ? Colors.grey[600]
                                      : Colors.black,
                                  decoration: isCompleted
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (todo.description != null &&
                                      todo.description!.isNotEmpty)
                                    Text(
                                      todo.description!,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                        decoration: isCompleted
                                            ? TextDecoration.lineThrough
                                            : TextDecoration.none,
                                      ),
                                    ),
                                  // 우선순위, 마감일, 태그를 함께 표시
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: [
                                      // 우선순위
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getPriorityColor(
                                            todo.priority,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              LucideIcons.listOrdered,
                                              size: 12,
                                              color: Colors.white,
                                            ),
                                            const SizedBox(width: 3),
                                            Text(
                                              todo.priority.displayName,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // 마감일
                                      if (todo.dueDate != null)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.blue,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                LucideIcons.calendarX,
                                                size: 12,
                                                color: Colors.white,
                                              ),
                                              const SizedBox(width: 3),
                                              Text(
                                                _formatDueDate(todo.dueDate!),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      // 실제 태그들
                                      ...todo.tags.map(
                                        (tag) => Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            border: Border.all(
                                              color: Colors.grey[300]!,
                                              width: 0.5,
                                            ),
                                          ),
                                          child: Text(
                                            '#${tag.name}',
                                            style: TextStyle(
                                              color: Colors.grey[700],
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              trailing: IconButton(
                                onPressed: () {
                                  ref
                                      .read(todoListViewModelProvider.notifier)
                                      .deleteTodo(todo.id);
                                },
                                icon: Icon(
                                  LucideIcons.trash2,
                                  color: Colors.grey[700],
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TodoAddView()),
          );

          // Todo 목록 새로고침
          if (result == true) {
            ref.read(todoListViewModelProvider.notifier).refreshTodos();
          }
        },
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        shape: CircleBorder(),
        child: const Icon(LucideIcons.plus),
      ),
    );
  }

  Widget _buildFilterButton(
    String filter,
    String selectedFilter,
    WidgetRef ref,
  ) {
    final isSelected = filter == selectedFilter;

    return GestureDetector(
      onTap: () {
        ref
            .read(todoListViewModelProvider.notifier)
            .setCompletionFilter(filter);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: Text(
          filter,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildTagFilterButton(
    String tagName,
    List<String> selectedTags,
    WidgetRef ref,
  ) {
    final isSelected = selectedTags.contains(tagName);

    return GestureDetector(
      onTap: () {
        ref.read(todoListViewModelProvider.notifier).toggleTagFilter(tagName);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: Text(
          tagName,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  // 우선순위에 따른 색상 반환
  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.high:
        return Colors.red;
      case Priority.medium:
        return Colors.orange;
      case Priority.low:
        return Colors.green;
    }
  }

  // 마감일 포맷팅
  String _formatDueDate(DateTime dueDate) {
    return '${dueDate.month}/${dueDate.day}';
  }

  // 정렬 옵션 선택 다이얼로그
  void _showSortDialog(BuildContext context, WidgetRef ref) {
    final currentSort = ref.read(todoListViewModelProvider).sortOption;

    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(
          '정렬 기준 선택',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        actions: SortOption.values.map((option) {
          final isSelected = option == currentSort;
          return CupertinoActionSheetAction(
            onPressed: () {
              ref
                  .read(todoListViewModelProvider.notifier)
                  .setSortOption(option);
              Navigator.pop(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _getSortDisplayName(option),
                  style: TextStyle(
                    color: isSelected ? Colors.blue : Colors.black,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
                if (isSelected) ...[
                  SizedBox(width: 8),
                  Icon(LucideIcons.check, size: 16, color: Colors.blue),
                ],
              ],
            ),
          );
        }).toList(),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          isDefaultAction: true,
          child: Text('취소'),
        ),
      ),
    );
  }

  // 정렬 옵션 이름 반환
  String _getSortDisplayName(SortOption option) {
    switch (option) {
      case SortOption.priorityHigh:
        return '우선순위 높은순';
      case SortOption.priorityLow:
        return '우선순위 낮은순';
      case SortOption.dueDateEarly:
        return '마감일 빠른순';
      case SortOption.dueDateLate:
        return '마감일 느린순';
      case SortOption.createdEarly:
        return '생성일 빠른순';
      case SortOption.createdLate:
        return '생성일 느린순';
    }
  }
}
