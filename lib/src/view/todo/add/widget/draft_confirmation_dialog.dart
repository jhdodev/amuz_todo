import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DraftConfirmationDialog extends StatelessWidget {
  const DraftConfirmationDialog({
    super.key,
    required this.onLoadDraft,
    required this.onDiscardDraft,
  });

  final VoidCallback onLoadDraft;
  final VoidCallback onDiscardDraft;

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: const Text('작성 중인 내용이 있습니다'),
      content: const Text(
        "이전에 작성하던 내용을 불러올까요?\n '아니오'를 선택하시면 작성했던 내용이 삭제됩니다.",
        style: TextStyle(fontSize: 14),
      ),
      actions: [
        CupertinoDialogAction(
          onPressed: () {
            Navigator.pop(context);
            onDiscardDraft();
          },
          child: const Text('아니요', style: TextStyle(color: Colors.red)),
        ),
        CupertinoDialogAction(
          onPressed: () {
            Navigator.pop(context);
            onLoadDraft();
          },
          child: const Text(
            '네',
            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  static void show(
    BuildContext context, {
    required VoidCallback onLoadDraft,
    required VoidCallback onDiscardDraft,
  }) {
    showDialog(
      context: context,
      builder: (context) => DraftConfirmationDialog(
        onLoadDraft: onLoadDraft,
        onDiscardDraft: onDiscardDraft,
      ),
    );
  }
}
