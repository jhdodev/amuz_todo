import 'package:amuz_todo/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:amuz_todo/src/service/theme_service.dart';
import 'sign_in_view_model.dart';

class SignInView extends ConsumerStatefulWidget {
  const SignInView({super.key});

  @override
  ConsumerState<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends ConsumerState<SignInView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(signInViewModelProvider);
    final isDarkMode = ref.watch(isDarkModeProvider);

    ref.listen(signInViewModelProvider, (previous, next) {
      if (previous?.isSignInSuccessful != true && next.isSignInSuccessful) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('로그인되었습니다!')));
        Navigator.pushReplacementNamed(context, '/home');
      }
    });

    return Stack(
      children: [
        Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
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
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      cursorColor: isDarkMode
                          ? AppColors.lightGrey
                          : Colors.black,
                      style: TextStyle(
                        color: isDarkMode
                            ? AppColors.almostWhite
                            : Colors.black,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        hintText: '이메일',
                        hintStyle: TextStyle(
                          color: isDarkMode
                              ? AppColors.mediumGrey
                              : Colors.grey,
                        ),
                        prefixIcon: Icon(
                          LucideIcons.mail,
                          size: 20,
                          color: isDarkMode
                              ? AppColors.mediumGrey
                              : Colors.black,
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
                      cursorColor: isDarkMode
                          ? AppColors.lightGrey
                          : Colors.black,
                      style: TextStyle(
                        color: isDarkMode
                            ? AppColors.almostWhite
                            : Colors.black,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        hintText: '비밀번호',
                        hintStyle: TextStyle(
                          color: isDarkMode
                              ? AppColors.mediumGrey
                              : Colors.grey,
                        ),
                        prefixIcon: Icon(
                          LucideIcons.lock,
                          size: 20,
                          color: isDarkMode
                              ? AppColors.mediumGrey
                              : Colors.black,
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
                                    .read(signInViewModelProvider.notifier)
                                    .signIn(
                                      email: _emailController.text,
                                      password: _passwordController.text,
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
                              '로그인',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.black : Colors.white,
                              ),
                            ),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "계정이 없으신가요?",
                          style: TextStyle(
                            color: isDarkMode
                                ? AppColors.mediumGrey
                                : Colors.black,
                          ),
                        ),
                        const SizedBox(width: 10),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/signUp');
                          },
                          child: Text(
                            '회원가입',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
