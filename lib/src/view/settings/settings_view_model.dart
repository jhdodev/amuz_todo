import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amuz_todo/src/service/auth_service.dart';
import 'package:amuz_todo/src/view/settings/settings_view_state.dart';
import 'package:amuz_todo/util/route_path.dart';

class SettingsViewModel extends StateNotifier<SettingsViewState> {
  final AuthService _authService;

  SettingsViewModel(this._authService) : super(const SettingsViewState());

  /// 로그아웃
  Future<void> signOut(BuildContext context) async {
    try {
      print('🔥 SettingsViewModel: 로그아웃 시작');

      // 로그아웃 로딩 상태 설정
      state = state.copyWith(
        isSigningOut: true,
        status: SettingsViewStatus.loading,
      );

      await _authService.signOut();

      print('🔥 SettingsViewModel: 로그아웃 성공');

      // 성공 상태 설정
      state = state.copyWith(
        isSigningOut: false,
        status: SettingsViewStatus.success,
      );

      // 로그인 페이지로 이동
      if (context.mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(RoutePath.signIn, (route) => false);
      }
    } catch (e) {
      print('🔥 SettingsViewModel - 로그아웃 에러: $e');

      // 에러 상태 설정
      state = state.copyWith(
        isSigningOut: false,
        status: SettingsViewStatus.error,
        errorMessage: '로그아웃 중 에러가 발생했습니다: $e',
      );
    }
  }

  /// 계정 삭제
  Future<void> deleteAccount(BuildContext context) async {
    try {
      print('🔥 SettingsViewModel: 계정 삭제 시작');

      // 계정 삭제 로딩 상태 설정
      state = state.copyWith(
        isDeletingAccount: true,
        status: SettingsViewStatus.loading,
      );

      await _authService.deleteAccount();

      print('🔥 SettingsViewModel: 계정 삭제 성공');

      // 성공 상태 설정
      state = state.copyWith(
        isDeletingAccount: false,
        status: SettingsViewStatus.success,
      );

      // 로그인 페이지로 이동
      if (context.mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(RoutePath.signIn, (route) => false);
      }
    } catch (e) {
      print('🔥 SettingsViewModel: 계정 삭제 에러: $e');

      // 에러 상태 설정
      state = state.copyWith(
        isDeletingAccount: false,
        status: SettingsViewStatus.error,
        errorMessage: '계정 삭제 중 에러가 발생했습니다: $e',
      );
    }
  }

  /// 에러 메시지 초기화
  void clearError() {
    state = state.copyWith(
      status: SettingsViewStatus.initial,
      errorMessage: null,
    );
  }
}
