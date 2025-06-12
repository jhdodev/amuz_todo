import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TodoDatePickerDialog extends StatefulWidget {
  const TodoDatePickerDialog({
    super.key,
    required this.initialDate,
    required this.onDateSelected,
    required this.onDateCleared,
  });

  final DateTime initialDate;
  final Function(DateTime) onDateSelected;
  final VoidCallback onDateCleared;

  @override
  State<TodoDatePickerDialog> createState() => _TodoDatePickerDialogState();

  static void show(
    BuildContext context, {
    required DateTime initialDate,
    required Function(DateTime) onDateSelected,
    required VoidCallback onDateCleared,
  }) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => TodoDatePickerDialog(
        initialDate: initialDate,
        onDateSelected: onDateSelected,
        onDateCleared: onDateCleared,
      ),
    );
  }
}

class _TodoDatePickerDialogState extends State<TodoDatePickerDialog> {
  late DateTime tempDate;

  @override
  void initState() {
    super.initState();
    tempDate = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320,
      padding: const EdgeInsets.only(top: 6.0),
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      color: CupertinoColors.systemBackground.resolveFrom(context),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                      color: Colors.black,
                    ),
                  ),
                  CupertinoButton(
                    onPressed: () {
                      widget.onDateSelected(tempDate);
                      Navigator.pop(context);
                    },
                    child: const Text('완료'),
                  ),
                ],
              ),
            ),
            // 마감일 제거 버튼 추가
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CupertinoButton(
                onPressed: () {
                  widget.onDateCleared();
                  Navigator.pop(context);
                },
                child: const Text(
                  '마감일 제거',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: widget.initialDate,
                minimumDate: DateTime.now().subtract(const Duration(hours: 1)),
                maximumDate: DateTime.now().add(const Duration(days: 365)),
                onDateTimeChanged: (DateTime newDate) {
                  tempDate = newDate;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
