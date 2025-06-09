import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amuz_todo/src/service/auth_service.dart';
import 'package:amuz_todo/src/repository/auth_repository.dart';
import 'package:amuz_todo/src/view/settings/settings_view_model.dart';
import 'package:amuz_todo/src/view/settings/settings_view_state.dart';
import 'package:lucide_icons/lucide_icons.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(AuthRepository());
});

final settingsViewModelProvider =
    StateNotifierProvider<SettingsViewModel, SettingsViewState>((ref) {
      final authService = ref.watch(authServiceProvider);
      return SettingsViewModel(authService);
    });

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsViewModelProvider);
    final viewModel = ref.read(settingsViewModelProvider.notifier);

    // 에러 처리
    ref.listen<SettingsViewState>(settingsViewModelProvider, (previous, next) {
      if (next.status == SettingsViewStatus.error &&
          next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
        // 에러 메시지 표시 후 초기화
        Future.delayed(const Duration(seconds: 1), () {
          viewModel.clearError();
        });
      }
    });

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
            Consumer(
              builder: (context, ref, child) {
                final settingsState = ref.watch(settingsViewModelProvider);
                final user = settingsState.currentUser;
                final isLoadingUser = settingsState.isLoadingUser;
                return SizedBox(
                  width: double.infinity,
                  child: Card(
                    color: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: Colors.grey.shade200, width: 1),
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
                                onTap: () => _showImagePicker(context, ref),
                                child: CircleAvatar(
                                  radius: 40,
                                  backgroundColor: Colors.grey.shade300,
                                  backgroundImage: user?.profileImageUrl != null
                                      ? NetworkImage(user!.profileImageUrl!)
                                      : const AssetImage(
                                              'assets/images/default_profile_black.png',
                                            )
                                            as ImageProvider,
                                  child: state.isUpdatingProfile
                                      ? Container(
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(
                                              alpha: 0.5,
                                            ),
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
                                  onTap: () => _showImagePicker(context, ref),
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                    child: const Icon(
                                      LucideIcons.camera,
                                      color: Colors.white,
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
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            )
                          else
                            Text(
                              user?.name ?? 'default',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                          const SizedBox(height: 4),

                          if (isLoadingUser)
                            Container(
                              width: 120,
                              height: 16,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            )
                          else
                            Text(
                              user?.email ?? 'default@example.com',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {},
              child: Card(
                color: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey.shade200, width: 1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    children: [
                      Text(
                        '이름 변경',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: Card(
                color: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey.shade200, width: 1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    children: [
                      Text(
                        '비밀번호 변경',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Card(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.grey.shade200, width: 1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            false ? '다크 모드' : '라이트 모드',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '다크 모드와 라이트 모드 전환',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Switch(
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
                  ],
                ),
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
                  : () => viewModel.signOut(context),
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
                  : () => viewModel.deleteAccount(context),
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
    final user = ref.read(settingsViewModelProvider).currentUser;

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text(
          '프로필 사진 변경',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          // 갤러리에서 사진 선택
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              ref
                  .read(settingsViewModelProvider.notifier)
                  .pickImageFromGallery();
            },
            child: Text('갤러리에서 사진 선택', style: TextStyle(fontSize: 16)),
          ),

          // 기본 이미지로 변경
          if (user?.profileImageUrl != null)
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                ref
                    .read(settingsViewModelProvider.notifier)
                    .removeProfileImage();
              },
              child: const Text(
                '기본 이미지로 변경',
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            '취소',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
