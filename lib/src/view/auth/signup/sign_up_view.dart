import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:amuz_todo/src/service/theme_service.dart';
import 'package:amuz_todo/theme/app_colors.dart';
import 'sign_up_view_model.dart';

class SignUpView extends ConsumerStatefulWidget {
  const SignUpView({super.key});

  @override
  ConsumerState<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends ConsumerState<SignUpView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(signUpViewModelProvider);
    final isDarkMode = ref.watch(isDarkModeProvider);

    ref.listen(signUpViewModelProvider, (previous, next) {
      if (next.isSignUpSuccessful) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('회원가입이 완료되었습니다!')));
        Navigator.pushReplacementNamed(context, '/');
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '회원가입',
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        ),
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        iconTheme: IconThemeData(
          color: isDarkMode ? Colors.white : Colors.black,
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
                Center(
                  child: Text(
                    'amuz todo',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _nameController,
                  cursorColor: isDarkMode ? AppColors.lightGrey : Colors.black,
                  style: TextStyle(
                    color: isDarkMode ? AppColors.almostWhite : Colors.black,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    hintText: '이름',
                    hintStyle: TextStyle(
                      color: isDarkMode ? AppColors.mediumGrey : Colors.grey,
                    ),
                    prefixIcon: Icon(
                      LucideIcons.user,
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
                      return '이름을 입력해주세요';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  cursorColor: isDarkMode ? AppColors.lightGrey : Colors.black,
                  style: TextStyle(
                    color: isDarkMode ? AppColors.almostWhite : Colors.black,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    hintText: '이메일',
                    hintStyle: TextStyle(
                      color: isDarkMode ? AppColors.mediumGrey : Colors.grey,
                    ),
                    prefixIcon: Icon(
                      LucideIcons.mail,
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
                      return '이메일을 입력해주세요';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  cursorColor: isDarkMode ? AppColors.lightGrey : Colors.black,
                  style: TextStyle(
                    color: isDarkMode ? AppColors.almostWhite : Colors.black,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    hintText: '비밀번호',
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
                      return '비밀번호를 입력해주세요';
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
                    hintText: '비밀번호 확인',
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
                      return '비밀번호 확인을 입력해주세요';
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
                  onPressed: viewModel.isBusy
                      ? null
                      : () {
                          if (_formKey.currentState!.validate()) {
                            ref
                                .read(signUpViewModelProvider.notifier)
                                .signUp(
                                  email: _emailController.text,
                                  password: _passwordController.text,
                                  confirmPassword:
                                      _confirmPasswordController.text,
                                  name: _nameController.text,
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
                  child: viewModel.isBusy
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: isDarkMode ? Colors.black : Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          '가입하기',
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
