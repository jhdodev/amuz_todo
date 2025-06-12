import 'package:amuz_todo/src/model/tag.dart';
import 'package:flutter/material.dart';

class FilterButtonsRow extends StatelessWidget {
  const FilterButtonsRow({
    super.key,
    required this.completionFilter,
    required this.selectedTags,
    required this.userTags,
    required this.onCompletionFilterChanged,
    required this.onTagFilterToggled,
  });

  final String completionFilter;
  final List<String> selectedTags;
  final List<Tag> userTags;
  final Function(String) onCompletionFilterChanged;
  final Function(String) onTagFilterToggled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterButton('전체', completionFilter),
            const SizedBox(width: 10),
            _buildFilterButton('미완료', completionFilter),
            const SizedBox(width: 10),
            _buildFilterButton('완료', completionFilter),
            const SizedBox(width: 10),
            VerticalDivider(color: Colors.grey.shade300, thickness: 1),
            const SizedBox(width: 10),
            // 동적으로 태그 필터 버튼들 생성
            ...userTags
                .map(
                  (tag) => [
                    _buildTagFilterButton('#${tag.name}', selectedTags),
                    const SizedBox(width: 10),
                  ],
                )
                .expand((element) => element),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton(String filter, String selectedFilter) {
    final isSelected = filter == selectedFilter;

    return GestureDetector(
      onTap: () => onCompletionFilterChanged(filter),
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

  Widget _buildTagFilterButton(String tagName, List<String> selectedTags) {
    final isSelected = selectedTags.contains(tagName);

    return GestureDetector(
      onTap: () => onTagFilterToggled(tagName),
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
}
