import 'package:amuz_todo/src/service/theme_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

class BottomBar extends ConsumerWidget {
  const BottomBar({super.key, required this.currentIndex, this.onTap});

  final int currentIndex;

  final void Function(int index)? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      selectedItemColor: isDarkMode ? Colors.white : Colors.black,
      unselectedItemColor: isDarkMode ? Colors.grey[800] : Colors.grey,
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      items: [
        /// Todo
        const BottomNavigationBarItem(
          icon: Icon(LucideIcons.listChecks),
          label: '할 일',
        ),

        /// Settings
        const BottomNavigationBarItem(
          icon: Icon(LucideIcons.settings),
          label: '설정',
        ),
      ],
    );
  }
}
