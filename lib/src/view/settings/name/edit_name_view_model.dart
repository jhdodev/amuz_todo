// lib/viewmodels/edit_name_view_model.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amuz_todo/src/service/auth_service.dart';
import 'package:amuz_todo/src/view/settings/name/edit_name_view_state.dart';

class EditNameViewModel extends StateNotifier<EditNameViewState> {
  final AuthService _authService;
  final Ref _ref;

  EditNameViewModel(this._authService, this._ref)
    : super(const EditNameViewState());

  /// 초기 이름 로드
  void loadCurrentName(String name) {
    print('🔥 EditNameViewModel: 현재 이름 로드 - $name');
    state = state.copyWith(currentName: name);
  }

  /// 이름 업데이트
  Future<void> updateName(String newName, BuildContext context) async {
    try {
      print('🔥 EditNameViewModel: 이름 업데이트 시작 - $newName');

      // 입력값 검증
      if (newName.isEmpty) {
        throw Exception('이름을 입력해주세요.');
      }

      if (newName.trim().length < 2) {
        throw Exception('이름은 2자 이상이어야 합니다.');
      }

      if (newName.trim().length > 20) {
        throw Exception('이름은 20자 이하여야 합니다.');
      }

      state = state.copyWith(
        status: EditNameViewStatus.loading,
        isLoading: true,
        errorMessage: null,
      );

      // 현재 사용자 정보 가져오기
      final currentUserAsync = _ref.read(currentUserProvider);
      final currentUser = currentUserAsync.when(
        data: (user) => user,
        loading: () => throw Exception('사용자 정보를 불러오는 중입니다.'),
        error: (error, stack) => throw Exception('사용자 정보를 불러올 수 없습니다.'),
      );

      if (currentUser == null) {
        throw Exception('로그인이 필요합니다.');
      }

      // 기존 updateProfile 메서드 사용 (name만 업데이트)
      await _authService.updateProfile(
        userId: currentUser.id,
        name: newName.trim(),
      );

      print('🔥 EditNameViewModel: 이름 업데이트 성공');

      // 사용자 정보 새로고침
      _ref.invalidate(currentUserProvider);

      state = state.copyWith(
        status: EditNameViewStatus.success,
        isLoading: false,
        isNameUpdateSuccessful: true,
        currentName: newName.trim(),
      );

      // 성공 시 뒤로가기
      if (context.mounted) {
        Navigator.pop(context, true); // true 값으로 성공을 알림
      }
    } catch (e) {
      print('🔥 EditNameViewModel: 이름 업데이트 에러: $e');
      state = state.copyWith(
        status: EditNameViewStatus.error,
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  /// 에러 메시지 초기화
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// 상태 초기화
  void reset() {
    state = const EditNameViewState();
  }
}

final editNameViewModelProvider =
    StateNotifierProvider<EditNameViewModel, EditNameViewState>((ref) {
      final authService = ref.watch(authServiceProvider);
      return EditNameViewModel(authService, ref);
    });
