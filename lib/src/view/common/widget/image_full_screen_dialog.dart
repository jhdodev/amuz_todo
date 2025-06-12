import 'dart:io';
import 'package:flutter/material.dart';

class ImageFullScreenDialog extends StatelessWidget {
  const ImageFullScreenDialog({super.key, this.imageFile, this.imageUrl})
    : assert(
        imageFile != null || imageUrl != null,
        'Either imageFile or imageUrl must be provided',
      );

  final File? imageFile;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: InteractiveViewer(
            child: Center(
              child: imageFile != null
                  ? Image.file(imageFile!, fit: BoxFit.contain)
                  : Image.network(imageUrl!, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }

  static void show(BuildContext context, {File? imageFile, String? imageUrl}) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.9),
      builder: (BuildContext context) =>
          ImageFullScreenDialog(imageFile: imageFile, imageUrl: imageUrl),
    );
  }
}
