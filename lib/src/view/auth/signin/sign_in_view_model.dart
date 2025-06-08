import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amuz_todo/src/repository/auth_repository.dart';
import 'package:amuz_todo/src/service/auth_service.dart';
import 'sign_in_view_state.dart';

final signInViewModelProvider =
    AutoDisposeNotifierProvider<SignInViewModel, SignInViewState>(
      () => SignInViewModel(),
    );

class SignInViewModel extends AutoDisposeNotifier<SignInViewState> {
  late final AuthService _authService;

  @override
  SignInViewState build() {
    final authRepository = AuthRepository();
    _authService = AuthService(authRepository);

    return const SignInViewState();
  }

  Future<void> signIn({required String email, required String password}) async {
    state = state.copyWith(isBusy: true, errorMessage: null);

    try {
      if (email.isEmpty) {
        throw Exception('이메일을 입력해주세요.');
      }

      if (password.isEmpty) {
        throw Exception('비밀번호를 입력해주세요.');
      }

      if (!_isValidEmail(email)) {
        throw Exception('올바른 이메일 형식을 입력해주세요.');
      }

      await _authService.signIn(email: email, password: password);

      state = state.copyWith(isBusy: false, isSignInSuccessful: true);
    } catch (e) {
      state = state.copyWith(
        isBusy: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  void reset() {
    state = const SignInViewState();
  }
}
