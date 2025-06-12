import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ImageOptionsActionSheet extends StatelessWidget {
  const ImageOptionsActionSheet({
    super.key,
    required this.onViewTap,
    required this.onDeleteTap,
  });

  final VoidCallback onViewTap;
  final VoidCallback onDeleteTap;

  @override
  Widget build(BuildContext context) {
    return CupertinoActionSheet(
      title: const Text(
        '이미지 관리',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      actions: [
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
            onViewTap();
          },
          child: const Text('사진 크게 보기', style: TextStyle(fontSize: 16)),
        ),
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
            onDeleteTap();
          },
          child: const Text(
            '사진 삭제',
            style: TextStyle(fontSize: 16, color: Colors.red),
          ),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        onPressed: () => Navigator.pop(context),
        child: const Text(
          '취소',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  static void show(
    BuildContext context, {
    required VoidCallback onViewTap,
    required VoidCallback onDeleteTap,
  }) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => ImageOptionsActionSheet(
        onViewTap: onViewTap,
        onDeleteTap: onDeleteTap,
      ),
    );
  }
}
