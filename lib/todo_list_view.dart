import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

// 필터 상태를 관리하는 provider
final filterProvider = StateProvider<String>((ref) => 'All');

class TodoListView extends ConsumerWidget {
  const TodoListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFilter = ref.watch(filterProvider);

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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(LucideIcons.listFilter),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            TextField(
              cursorColor: Colors.black,
              decoration: InputDecoration(
                hintText: "검색어를 입력하세요",
                prefixIcon: const Icon(LucideIcons.search),
                suffixIcon: const Icon(LucideIcons.x),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
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
                    _buildFilterButton('전체', selectedFilter, ref),
                    const SizedBox(width: 10),
                    _buildFilterButton('미완료', selectedFilter, ref),
                    const SizedBox(width: 10),
                    _buildFilterButton('완료', selectedFilter, ref),
                    const SizedBox(width: 10),
                    _buildFilterButton('#개발', selectedFilter, ref),
                    const SizedBox(width: 10),
                    _buildFilterButton('#집안일', selectedFilter, ref),
                    const SizedBox(width: 10),
                    _buildFilterButton('#쇼핑', selectedFilter, ref),
                    const SizedBox(width: 10),
                    _buildFilterButton('#기타', selectedFilter, ref),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: 10,
                itemBuilder: (context, index) {
                  final isCompleted = false;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Card(
                      color: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.grey.shade200, width: 1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ListTile(
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
                            onChanged: (bool? value) {},
                          ),
                        ),
                        title: Text(
                          "할 일 $index",
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
                        subtitle: Text(
                          "할 일 $index에 대한 상세 설명입니다",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        trailing: IconButton(
                          onPressed: () {},
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
        onPressed: () {},
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
        ref.read(filterProvider.notifier).state = filter;
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
}
