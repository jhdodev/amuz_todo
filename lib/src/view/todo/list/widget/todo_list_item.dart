import 'package:amuz_todo/src/model/priority.dart';
import 'package:amuz_todo/src/model/todo.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class TodoListItem extends StatelessWidget {
  const TodoListItem({
    super.key,
    required this.todo,
    required this.onTap,
    required this.onToggleCompletion,
    required this.onDelete,
  });

  final Todo todo;
  final VoidCallback onTap;
  final Function(bool) onToggleCompletion;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isCompleted = todo.isCompleted;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Card(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.grey.shade200, width: 1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: ListTile(
          onTap: onTap,
          leading: Transform.scale(
            scale: 1.2,
            child: Checkbox(
              value: isCompleted,
              activeColor: Colors.black,
              checkColor: Colors.white,
              side: BorderSide(color: Colors.grey.shade400, width: 1.0),
              onChanged: (bool? value) {
                if (value != null) {
                  onToggleCompletion(value);
                }
              },
            ),
          ),
          title: Text(
            todo.title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isCompleted ? Colors.grey[600] : Colors.black,
              decoration: isCompleted
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (todo.description != null && todo.description!.isNotEmpty)
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
                      color: _getPriorityColor(todo.priority),
                      borderRadius: BorderRadius.circular(10),
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
                        borderRadius: BorderRadius.circular(10),
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
                        borderRadius: BorderRadius.circular(10),
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
            onPressed: onDelete,
            icon: Icon(LucideIcons.trash2, color: Colors.grey[700], size: 20),
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
}
