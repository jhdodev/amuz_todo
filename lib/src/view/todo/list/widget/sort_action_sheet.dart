import 'package:amuz_todo/src/view/todo/list/todo_list_view_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SortActionSheet extends StatelessWidget {
  const SortActionSheet({
    super.key,
    required this.currentSort,
    required this.onSortSelected,
  });

  final SortOption currentSort;
  final Function(SortOption) onSortSelected;

  @override
  Widget build(BuildContext context) {
    return CupertinoActionSheet(
      title: Text(
        '정렬 기준 선택',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      actions: SortOption.values.map((option) {
        final isSelected = option == currentSort;
        return CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
            onSortSelected(option);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _getSortDisplayName(option),
                style: TextStyle(
                  color: isSelected ? Color(0xFF057AFF) : Colors.black,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              if (isSelected) ...[
                SizedBox(width: 8),
                Icon(LucideIcons.check, size: 16, color: Color(0xFF057AFF)),
              ],
            ],
          ),
        );
      }).toList(),
      cancelButton: CupertinoActionSheetAction(
        onPressed: () => Navigator.pop(context),
        isDefaultAction: true,
        child: Text('취소', style: TextStyle(color: Colors.red)),
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

  static void show(
    BuildContext context, {
    required SortOption currentSort,
    required Function(SortOption) onSortSelected,
  }) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => SortActionSheet(
        currentSort: currentSort,
        onSortSelected: onSortSelected,
      ),
    );
  }
}
