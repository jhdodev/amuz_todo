import 'package:amuz_todo/src/model/priority.dart';
import 'package:flutter/cupertino.dart';

class PrioritySelectorActionSheet extends StatelessWidget {
  const PrioritySelectorActionSheet({
    super.key,
    required this.onPrioritySelected,
  });

  final Function(Priority) onPrioritySelected;

  @override
  Widget build(BuildContext context) {
    return CupertinoActionSheet(
      title: const Text(
        '우선 순위',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      actions: [
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
            onPrioritySelected(Priority.high);
          },
          child: const Text('높음'),
        ),
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
            onPrioritySelected(Priority.medium);
          },
          child: const Text('보통'),
        ),
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
            onPrioritySelected(Priority.low);
          },
          child: const Text('낮음'),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        onPressed: () => Navigator.pop(context),
        child: const Text('취소'),
      ),
    );
  }

  static void show(
    BuildContext context, {
    required Function(Priority) onPrioritySelected,
  }) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) =>
          PrioritySelectorActionSheet(onPrioritySelected: onPrioritySelected),
    );
  }
}
