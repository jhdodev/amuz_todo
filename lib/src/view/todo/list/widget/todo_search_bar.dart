import 'package:amuz_todo/src/service/theme_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

class TodoSearchBar extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    return TextField(
      controller: controller,
      onChanged: onChanged,
      cursorColor: isDarkMode ? Color(0xFFE5E5E5) : Colors.black,
      style: TextStyle(
        color: isDarkMode ? Color(0xFFFAFAFA) : Colors.black,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        hintText: "검색어를 입력하세요",
        prefixIcon: Icon(
          LucideIcons.search,
          color: isDarkMode ? Color(0xFFA0A0A0) : Colors.black,
        ),
        suffixIcon: IconButton(
          onPressed: onClearPressed,
          icon: Icon(
            LucideIcons.x,
            color: isDarkMode ? Color(0xFFA0A0A0) : Colors.black,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDarkMode ? Color(0xFF1A1A1A) : Color(0xFFE5E5E5),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDarkMode
                ? Color(0xFF1A1A1A)
                : Colors.black.withValues(alpha: 0.4),
            width: 3,
          ),
        ),
      ),
    );
  }
}
