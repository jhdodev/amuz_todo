import 'package:amuz_todo/common/bottom_bar.dart';
import 'package:amuz_todo/settings_view.dart';
import 'package:amuz_todo/todo_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// 현재 선택된 index
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: Scaffold(
        body: IndexedStack(
          index: currentIndex,
          children: const [
            /// Todo
            TodoListView(),

            /// Settings
            SettingsView(),
          ],
        ),
        bottomNavigationBar: Consumer(
          builder: (context, ref, child) => BottomBar(
            currentIndex: currentIndex,
            onTap: (index) => setState(() {
              currentIndex = index;
            }),
          ),
        ),
      ),
    );
  }
}
