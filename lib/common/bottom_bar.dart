import 'package:flutter/material.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({super.key, required this.currentIndex, this.onTap});

  final int currentIndex;

  final void Function(int index)? onTap;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey,
      items: [
        /// Todo
        const BottomNavigationBarItem(icon: Icon(Icons.list), label: '할 일'),

        /// Settings
        const BottomNavigationBarItem(icon: Icon(Icons.settings), label: '설정'),
      ],
    );
  }
}
