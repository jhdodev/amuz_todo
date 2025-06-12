import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfileImagePickerActionSheet extends StatelessWidget {
  const ProfileImagePickerActionSheet({
    super.key,
    required this.onGalleryTap,
    required this.onRemoveImageTap,
    required this.hasProfileImage,
  });

  final VoidCallback onGalleryTap;
  final VoidCallback onRemoveImageTap;
  final bool hasProfileImage;

  @override
  Widget build(BuildContext context) {
    return CupertinoActionSheet(
      title: const Text(
        '프로필 사진 변경',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      actions: [
        // 갤러리에서 사진 선택
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
            onGalleryTap();
          },
          child: const Text('갤러리에서 사진 선택', style: TextStyle(fontSize: 16)),
        ),

        // 기본 이미지로 변경
        if (hasProfileImage)
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              onRemoveImageTap();
            },
            child: const Text(
              '기본 이미지로 변경',
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
    required VoidCallback onGalleryTap,
    required VoidCallback onRemoveImageTap,
    required bool hasProfileImage,
  }) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => ProfileImagePickerActionSheet(
        onGalleryTap: onGalleryTap,
        onRemoveImageTap: onRemoveImageTap,
        hasProfileImage: hasProfileImage,
      ),
    );
  }
}
