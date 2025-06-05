import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: "검색어를 입력하세요",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: const Icon(Icons.close),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
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
                itemBuilder: (context, index) =>
                    ListTile(title: Text("할 일 $index")),
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
        child: const Icon(Icons.add),
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
