import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class TodoSearchBar extends StatelessWidget {
  const TodoSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClearPressed,
  });

  final TextEditingController controller;
  final Function(String) onChanged;
  final VoidCallback onClearPressed;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      cursorColor: Colors.black,
      decoration: InputDecoration(
        hintText: "검색어를 입력하세요",
        prefixIcon: const Icon(LucideIcons.search),
        suffixIcon: IconButton(
          onPressed: onClearPressed,
          icon: const Icon(LucideIcons.x),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Color(0xFFE5E5E5), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Colors.black.withValues(alpha: 0.4),
            width: 3,
          ),
        ),
      ),
    );
  }
}
