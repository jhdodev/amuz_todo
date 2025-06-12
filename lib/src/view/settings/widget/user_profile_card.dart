import 'package:amuz_todo/src/model/user.dart';
import 'package:amuz_todo/src/service/theme_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

class UserProfileCard extends ConsumerWidget {
  const UserProfileCard({
    super.key,
    required this.user,
    required this.isLoadingUser,
    required this.isUpdatingProfile,
    required this.onImageTap,
  });

  final User? user;
  final bool isLoadingUser;
  final bool isUpdatingProfile;
  final VoidCallback onImageTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(isDarkModeProvider);

    return SizedBox(
      width: double.infinity,
      child: Card(
        color: isDarkMode ? Color(0xFF181818) : Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: isDarkMode ? Color(0xFF272727) : Colors.grey.shade200,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children: [
                  // 프로필 이미지
                  GestureDetector(
                    onTap: onImageTap,
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage: user?.profileImageUrl != null
                          ? NetworkImage(user!.profileImageUrl!)
                          : const AssetImage(
                                  'assets/images/default_profile_black.png',
                                )
                                as ImageProvider,
                      child: isUpdatingProfile
                          ? Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.5),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : null,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: onImageTap,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: isDarkMode ? Color(0xFFE5E5E5) : Colors.black,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDarkMode
                                ? Color(0xFF181818)
                                : Colors.white,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          LucideIcons.camera,
                          color: isDarkMode ? Colors.black : Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              if (isLoadingUser)
                Container(
                  width: 80,
                  height: 20,
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? Color(0xFF272727)
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                )
              else
                Text(
                  user?.name ?? 'default',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Color(0xFFFAFAFA) : Colors.black,
                  ),
                ),

              const SizedBox(height: 4),

              if (isLoadingUser)
                Container(
                  width: 120,
                  height: 16,
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? Color(0xFF272727)
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                )
              else
                Text(
                  user?.email ?? 'default@example.com',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode ? Color(0xFFA0A0A0) : Colors.grey,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
