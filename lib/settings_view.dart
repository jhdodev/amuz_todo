import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "설정",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: true,
        scrolledUnderElevation: 0,
      ),
      body: const Center(
        child: Text(
          "Settings",
          style: TextStyle(fontSize: 24, color: Colors.grey),
        ),
      ),
    );
  }
}
