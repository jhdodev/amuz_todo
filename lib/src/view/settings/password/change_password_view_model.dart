import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amuz_todo/src/service/auth_service.dart';
import 'package:amuz_todo/src/view/settings/password/change_password_view_state.dart';

class ChangePasswordViewModel extends StateNotifier<ChangePasswordViewState> {
  final AuthService _authService;

  ChangePasswordViewModel(this._authService)
    : super(const ChangePasswordViewState());

  /// 비밀번호 변경 로직
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
    required BuildContext context,
  }) async {
    try {
      print('🔥 ChangePasswordViewModel: 비밀번호 변경 시작');

      _validatePasswords(currentPassword, newPassword, confirmPassword);

      state = state.copyWith(
        status: ChangePasswordViewStatus.loading,
        isLoading: true,
        errorMessage: null,
      );

      // AuthService를 통해 비밀번호 변경
      await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      print('🔥 ChangePasswordViewModel: 비밀번호 변경 성공');

      state = state.copyWith(
        status: ChangePasswordViewStatus.success,
        isLoading: false,
        isPasswordUpdateSuccessful: true,
      );

      if (context.mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      print('🔥 ChangePasswordViewModel: 비밀번호 변경 에러: $e');
      state = state.copyWith(
        status: ChangePasswordViewStatus.error,
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  /// 입력값 검증 로직
  void _validatePasswords(
    String currentPassword,
    String newPassword,
    String confirmPassword,
  ) {
    if (currentPassword.isEmpty) {
      throw Exception('현재 비밀번호를 입력해주세요.');
    }

    if (newPassword.isEmpty) {
      throw Exception('새 비밀번호를 입력해주세요.');
    }

    if (confirmPassword.isEmpty) {
      throw Exception('새 비밀번호 확인을 입력해주세요.');
    }

    if (newPassword.length < 6) {
      throw Exception('새 비밀번호는 6자 이상이어야 합니다.');
    }

    if (newPassword != confirmPassword) {
      throw Exception('새 비밀번호가 일치하지 않습니다.');
    }

    if (currentPassword == newPassword) {
      throw Exception('현재 비밀번호와 새 비밀번호가 같습니다.');
    }
  }

  /// 에러 메시지 초기화
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// 상태 초기화
  void reset() {
    state = const ChangePasswordViewState();
  }
}

// Provider 정의
final changePasswordViewModelProvider =
    StateNotifierProvider<ChangePasswordViewModel, ChangePasswordViewState>((
      ref,
    ) {
      final authService = ref.watch(authServiceProvider);
      return ChangePasswordViewModel(authService);
    });
