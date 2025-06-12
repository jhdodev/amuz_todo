import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amuz_todo/src/service/theme_service.dart';

class TagWidget extends ConsumerWidget {
  final String tag;
  final bool isSelected;
  final VoidCallback? onTap;

  const TagWidget({
    super.key,
    required this.tag,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? isDarkMode
                    ? Color(0xFFE5E5E5)
                    : Colors.black
              : isDarkMode
              ? Color(0xFF161616)
              : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isDarkMode ? Color(0xFF424242) : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Text(
          '#$tag',
          style: TextStyle(
            color: isSelected
                ? isDarkMode
                      ? Colors.black
                      : Colors.white
                : isDarkMode
                ? Color(0xFFFAFAFA)
                : Colors.black,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
