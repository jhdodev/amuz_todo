import 'package:amuz_todo/src/service/auth_service.dart';
import 'package:amuz_todo/src/service/theme_service.dart';
import 'package:amuz_todo/src/view/todo/add/todo_add_view.dart';
import 'package:amuz_todo/src/view/todo/detail/todo_detail_view.dart';
import 'package:amuz_todo/src/view/todo/list/todo_list_view_model.dart';
import 'package:amuz_todo/src/view/todo/list/todo_list_view_state.dart';
import 'package:amuz_todo/src/view/todo/list/widget/todo_search_bar.dart';
import 'package:amuz_todo/src/view/todo/list/widget/filter_buttons_row.dart';
import 'package:amuz_todo/src/view/todo/list/widget/todo_list_item.dart';
import 'package:amuz_todo/src/view/todo/list/widget/sort_action_sheet.dart';
import 'package:amuz_todo/src/view/todo/list/widget/user_profile_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

class TodoListView extends ConsumerStatefulWidget {
  const TodoListView({super.key});

  @override
  ConsumerState<TodoListView> createState() => _TodoListViewState();
}

class _TodoListViewState extends ConsumerState<TodoListView> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserAsync = ref.watch(currentUserProvider);
    final todoListState = ref.watch(todoListViewModelProvider);
    final isDarkMode = ref.watch(isDarkModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "amuz todo",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        centerTitle: true,
        scrolledUnderElevation: 0,
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        surfaceTintColor: Colors.white,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: IconButton(
            onPressed: () => _showSortDialog(context),
            icon: Icon(
              LucideIcons.listFilter,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ),
        actions: [UserProfileHeader(userAsync: currentUserAsync)],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 6),
              TodoSearchBar(
                controller: _searchController,
                onChanged: (value) => ref
                    .read(todoListViewModelProvider.notifier)
                    .setSearchQuery(value),
                onClearPressed: () {
                  _searchController.clear();
                  ref.read(todoListViewModelProvider.notifier).clearSearch();
                },
              ),
              const SizedBox(height: 20),

              // 필터 버튼들
              FilterButtonsRow(
                completionFilter: todoListState.completionFilter,
                selectedTags: todoListState.selectedTags,
                userTags: todoListState.userTags,
                onCompletionFilterChanged: (filter) => ref
                    .read(todoListViewModelProvider.notifier)
                    .setCompletionFilter(filter),
                onTagFilterToggled: (tagName) => ref
                    .read(todoListViewModelProvider.notifier)
                    .toggleTagFilter(tagName),
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
                          return TodoListItem(
                            todo: todo,
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
                            onToggleCompletion: (value) => ref
                                .read(todoListViewModelProvider.notifier)
                                .toggleTodoCompletion(todo.id, value),
                            onDelete: () => ref
                                .read(todoListViewModelProvider.notifier)
                                .deleteTodo(todo.id),
                          );
                        },
                      ),
              ),
            ],
          ),
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
        backgroundColor: isDarkMode ? Colors.white : Colors.black,
        foregroundColor: isDarkMode ? Colors.black : Colors.white,
        shape: CircleBorder(),
        child: Icon(
          LucideIcons.plus,
          color: isDarkMode ? Colors.black : Colors.white,
        ),
      ),
    );
  }

  // 정렬 옵션 선택 다이얼로그
  void _showSortDialog(BuildContext context) {
    final currentSort = ref.read(todoListViewModelProvider).sortOption;

    SortActionSheet.show(
      context,
      currentSort: currentSort,
      onSortSelected: (option) =>
          ref.read(todoListViewModelProvider.notifier).setSortOption(option),
    );
  }
}
