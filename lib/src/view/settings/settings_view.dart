import 'package:amuz_todo/src/view/settings/name/edit_name_view.dart';
import 'package:amuz_todo/src/view/settings/password/change_password_view.dart';
import 'package:amuz_todo/src/view/settings/widget/user_profile_card.dart';
import 'package:amuz_todo/src/view/settings/widget/settings_menu_button.dart';
import 'package:amuz_todo/src/view/settings/widget/profile_image_picker_action_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amuz_todo/src/service/auth_service.dart';
import 'package:amuz_todo/src/view/settings/settings_view_model.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsViewModelProvider);
    final currentUserAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '설정',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: true,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            currentUserAsync.when(
              data: (user) {
                final settingsState = ref.watch(settingsViewModelProvider);
                return UserProfileCard(
                  user: user,
                  isLoadingUser: settingsState.isLoadingUser,
                  isUpdatingProfile: settingsState.isUpdatingProfile,
                  onImageTap: () => _showImagePicker(context, ref),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
            const SizedBox(height: 20),

            /// 이름 변경 버튼
            SettingsMenuButton(
              title: '이름 변경',
              onTap: () async {
                currentUserAsync.when(
                  data: (user) async {
                    if (user != null) {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EditNameView(currentName: user.name ?? ''),
                        ),
                      );
                    }
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) {
                    // 에러 시 스낵바 표시
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('사용자 정보를 불러올 수 없습니다: $error'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  },
                );
              },
            ),

            /// 비밀번호 변경 버튼
            SettingsMenuButton(
              title: '비밀번호 변경',
              onTap: () async {
                currentUserAsync.when(
                  data: (user) async {
                    if (user != null) {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChangePasswordView(),
                        ),
                      );
                    }
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) {
                    // 에러 시 스낵바 표시
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('사용자 정보를 불러올 수 없습니다: $error'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 10),

            /// 다크모드 스위치
            SettingsMenuButton(
              title: false ? '다크 모드' : '라이트 모드',
              subtitle: '다크 모드와 라이트 모드 전환',
              trailingWidget: Switch(
                activeColor: Colors.black,
                activeTrackColor: Colors.white,
                inactiveThumbColor: Colors.grey.shade200,
                inactiveTrackColor: Colors.grey.shade200,
                onChanged: (bool? value) {},
                value: false,
                thumbIcon: WidgetStateProperty.resolveWith<Icon?>((
                  Set<WidgetState> states,
                ) {
                  return false
                      ? const Icon(Icons.wb_sunny, color: Colors.amber)
                      : const Icon(Icons.nightlight_round);
                }),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 60),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(14)),
                ),
              ),
              onPressed: state.isSigningOut
                  ? null
                  : () => ref
                        .read(settingsViewModelProvider.notifier)
                        .signOut(context),
              child: state.isSigningOut
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.redAccent,
                      ),
                    )
                  : const Text(
                      '로그아웃',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 60),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(14)),
                ),
              ),
              onPressed: state.isDeletingAccount
                  ? null
                  : () => ref
                        .read(settingsViewModelProvider.notifier)
                        .deleteAccount(context),
              child: state.isDeletingAccount
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.red,
                      ),
                    )
                  : const Text(
                      '계정 삭제',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImagePicker(BuildContext context, WidgetRef ref) {
    final currentUserAsync = ref.read(currentUserProvider);
    final user = currentUserAsync.when(
      data: (user) => user,
      loading: () => null,
      error: (error, stack) => null,
    );

    ProfileImagePickerActionSheet.show(
      context,
      onGalleryTap: () =>
          ref.read(settingsViewModelProvider.notifier).pickImageFromGallery(),
      onRemoveImageTap: () =>
          ref.read(settingsViewModelProvider.notifier).removeProfileImage(),
      hasProfileImage: user?.profileImageUrl != null,
    );
  }
}
