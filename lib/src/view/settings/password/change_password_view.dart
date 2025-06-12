import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amuz_todo/src/service/theme_service.dart';
import 'package:amuz_todo/src/view/settings/password/change_password_view_model.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:amuz_todo/theme/app_colors.dart';

class ChangePasswordView extends ConsumerStatefulWidget {
  const ChangePasswordView({super.key});

  @override
  ConsumerState<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends ConsumerState<ChangePasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(changePasswordViewModelProvider);
    final isDarkMode = ref.watch(isDarkModeProvider);

    ref.listen(changePasswordViewModelProvider, (previous, next) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '비밀번호 변경',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        centerTitle: true,
        scrolledUnderElevation: 0,
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        iconTheme: IconThemeData(
          color: isDarkMode ? Colors.white : Colors.black,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: _currentPasswordController,
                  obscureText: true,
                  cursorColor: isDarkMode ? AppColors.lightGrey : Colors.black,
                  style: TextStyle(
                    color: isDarkMode ? AppColors.almostWhite : Colors.black,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    hintText: '현재 비밀번호',
                    hintStyle: TextStyle(
                      color: isDarkMode ? AppColors.mediumGrey : Colors.grey,
                    ),
                    prefixIcon: Icon(
                      LucideIcons.lock,
                      size: 20,
                      color: isDarkMode ? AppColors.mediumGrey : Colors.black,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: isDarkMode
                            ? AppColors.almostBlack
                            : AppColors.lightGrey,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: isDarkMode
                            ? AppColors.almostBlack
                            : Colors.black.withOpacity(0.4),
                        width: 3,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '현재 비밀번호를 입력해주세요';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _newPasswordController,
                  obscureText: true,
                  cursorColor: isDarkMode ? AppColors.lightGrey : Colors.black,
                  style: TextStyle(
                    color: isDarkMode ? AppColors.almostWhite : Colors.black,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    hintText: '새 비밀번호',
                    hintStyle: TextStyle(
                      color: isDarkMode ? AppColors.mediumGrey : Colors.grey,
                    ),
                    prefixIcon: Icon(
                      LucideIcons.lock,
                      size: 20,
                      color: isDarkMode ? AppColors.mediumGrey : Colors.black,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: isDarkMode
                            ? AppColors.almostBlack
                            : AppColors.lightGrey,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: isDarkMode
                            ? AppColors.almostBlack
                            : Colors.black.withOpacity(0.4),
                        width: 3,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '새 비밀번호를 입력해주세요';
                    }
                    if (value.length < 6) {
                      return '비밀번호는 6자 이상이어야 합니다';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  cursorColor: isDarkMode ? AppColors.lightGrey : Colors.black,
                  style: TextStyle(
                    color: isDarkMode ? AppColors.almostWhite : Colors.black,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    hintText: '새 비밀번호 확인',
                    hintStyle: TextStyle(
                      color: isDarkMode ? AppColors.mediumGrey : Colors.grey,
                    ),
                    prefixIcon: Icon(
                      LucideIcons.lock,
                      size: 20,
                      color: isDarkMode ? AppColors.mediumGrey : Colors.black,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: isDarkMode
                            ? AppColors.almostBlack
                            : AppColors.lightGrey,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: isDarkMode
                            ? AppColors.almostBlack
                            : Colors.black.withOpacity(0.4),
                        width: 3,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '새 비밀번호 확인을 입력해주세요';
                    }
                    if (value != _newPasswordController.text) {
                      return '비밀번호가 일치하지 않습니다';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                if (viewModel.errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.red.shade900.withOpacity(0.3)
                          : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDarkMode
                            ? Colors.red.shade700
                            : Colors.red.shade200,
                      ),
                    ),
                    child: Text(
                      viewModel.errorMessage!,
                      style: TextStyle(
                        color: isDarkMode
                            ? Colors.red.shade300
                            : Colors.red.shade700,
                        fontSize: 14,
                      ),
                    ),
                  ),

                ElevatedButton(
                  onPressed: viewModel.isLoading
                      ? null
                      : () {
                          if (_formKey.currentState!.validate()) {
                            ref
                                .read(changePasswordViewModelProvider.notifier)
                                .changePassword(
                                  currentPassword:
                                      _currentPasswordController.text,
                                  newPassword: _newPasswordController.text,
                                  confirmPassword:
                                      _confirmPasswordController.text,
                                  context: context,
                                );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDarkMode
                        ? AppColors.lightGrey
                        : Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: viewModel.isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: isDarkMode ? Colors.black : Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          '비밀번호 변경',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.black : Colors.white,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
