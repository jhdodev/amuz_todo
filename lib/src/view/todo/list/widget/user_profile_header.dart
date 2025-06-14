import 'package:amuz_todo/src/model/user.dart';
import 'package:amuz_todo/src/service/theme_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserProfileHeader extends ConsumerWidget {
  const UserProfileHeader({super.key, required this.userAsync});

  final AsyncValue<User?> userAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: Row(
        children: [
          userAsync.when(
            data: (user) => CircleAvatar(
              radius: 14,
              backgroundImage: user?.profileImageUrl != null
                  ? NetworkImage(user!.profileImageUrl!)
                  : AssetImage('assets/images/default_profile_black.png'),
            ),
            error: (error, stack) => const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
          ),
          const SizedBox(width: 6),
          Text(
            userAsync.value?.name ?? 'default',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
