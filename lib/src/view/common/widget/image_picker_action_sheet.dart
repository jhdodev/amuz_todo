import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ImagePickerActionSheet extends StatelessWidget {
  const ImagePickerActionSheet({super.key, required this.onGalleryTap});

  final VoidCallback onGalleryTap;

  @override
  Widget build(BuildContext context) {
    return CupertinoActionSheet(
      title: const Text(
        '이미지 첨부',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      actions: [
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
            onGalleryTap();
          },
          child: const Text('갤러리에서 사진 선택', style: TextStyle(fontSize: 16)),
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

  static void show(BuildContext context, {required VoidCallback onGalleryTap}) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) =>
          ImagePickerActionSheet(onGalleryTap: onGalleryTap),
    );
  }
}
