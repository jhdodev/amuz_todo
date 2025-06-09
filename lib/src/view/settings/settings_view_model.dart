import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amuz_todo/src/service/auth_service.dart';
import 'package:amuz_todo/src/view/settings/settings_view_state.dart';
import 'package:amuz_todo/util/route_path.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsViewModel extends StateNotifier<SettingsViewState> {
  final AuthService _authService;
  final ImagePicker _imagePicker = ImagePicker();
  final SupabaseClient _supabase = Supabase.instance.client;

  SettingsViewModel(this._authService) : super(const SettingsViewState()) {
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    state = state.copyWith(isLoadingUser: true);

    try {
      final user = await _authService.getCurrentUserProfile();
      state = state.copyWith(currentUser: user, isLoadingUser: false);
    } catch (e) {
      print('🔥 SettingsViewModel: 사용자 정보 로딩 에러: $e');
      state = state.copyWith(
        isLoadingUser: false,
        errorMessage: '사용자 정보를 불러올 수 없습니다: $e',
      );
    }
  }

  /// 갤러리에서 이미지 선택
  Future<void> pickImageFromGallery() async {
    try {
      print('🔥 SettingsViewModel: 갤러리 이미지 선택 시작');

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        print('🔥 SettingsViewModel: 갤러리 이미지 선택 완료 - ${image.path}');
        await _uploadProfileImage(image.path);
      } else {
        print('🔥 SettingsViewModel: 갤러리 이미지 선택 취소');
      }
    } catch (e) {
      print('🔥 SettingsViewModel: 갤러리 이미지 선택 에러: $e');
      state = state.copyWith(errorMessage: '갤러리에서 이미지를 가져올 수 없습니다.');
    }
  }

  /// 프로필 이미지 업로드
  Future<void> _uploadProfileImage(String imagePath) async {
    if (state.currentUser == null) {
      print('🔥 SettingsViewModel: 현재 사용자 정보 없음');
      return;
    }

    state = state.copyWith(isUpdatingProfile: true);

    try {
      print('🔥 SettingsViewModel: 프로필 이미지 업로드 시작');

      // 🔄 변경: 기존 이미지 삭제 로직 제거, 바로 업로드
      final imageUrl = await _uploadToSupabaseStorage(imagePath);
      print('🔥 SettingsViewModel: Supabase Storage 업로드 완료 - $imageUrl');

      // AuthService를 통해 user_profiles 테이블 업데이트
      final updatedUser = await _authService.updateProfile(
        userId: state.currentUser!.id,
        profileImageUrl: imageUrl,
      );

      state = state.copyWith(
        currentUser: updatedUser,
        isUpdatingProfile: false,
      );

      print('🔥 SettingsViewModel: 프로필 이미지 업데이트 완료');
    } catch (e) {
      print('🔥 SettingsViewModel: 프로필 이미지 업로드 에러: $e');
      state = state.copyWith(
        isUpdatingProfile: false,
        errorMessage: '프로필 이미지 업데이트에 실패했습니다: $e',
      );
    }
  }

  Future<String> _uploadToSupabaseStorage(String imagePath) async {
    try {
      final file = File(imagePath);
      final userId = state.currentUser!.id;
      final fileName =
          'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = 'profiles/$fileName';

      print('🔥 SettingsViewModel: Storage 업로드 시작 - $filePath');

      // Storage에 파일 업로드
      await _supabase.storage
          .from('profile-images')
          .upload(
            filePath,
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      // Public URL 받아오기
      final publicUrl = _supabase.storage
          .from('profile-images')
          .getPublicUrl(filePath);

      print('🔥 SettingsViewModel: Storage 업로드 성공 - $publicUrl');
      return publicUrl;
    } catch (e) {
      print('🔥 SettingsViewModel: Storage 업로드 실패: $e');
      throw Exception('이미지 업로드에 실패했습니다: $e');
    }
  }

  /// 기본 이미지로 변경
  Future<void> removeProfileImage() async {
    if (state.currentUser == null) {
      print('🔥 SettingsViewModel: 현재 사용자 정보 없음');
      return;
    }

    state = state.copyWith(isUpdatingProfile: true);

    try {
      print('🔥 SettingsViewModel: 기본 이미지로 변경 시작');

      final updatedUser = await _authService.updateProfileImageToNull(
        userId: state.currentUser!.id,
      );

      state = state.copyWith(
        currentUser: updatedUser,
        isUpdatingProfile: false,
      );

      print('🔥 SettingsViewModel: 기본 이미지로 변경 완료');
      print('🔥 SettingsViewModel: 최종 URL: ${updatedUser.profileImageUrl}');
    } catch (e) {
      print('🔥 SettingsViewModel: 기본 이미지로 변경 에러: $e');
      state = state.copyWith(
        isUpdatingProfile: false,
        errorMessage: '기본 이미지로 변경에 실패했습니다: $e',
      );
    }
  }

  /// 사용자 정보 새로고침
  Future<void> refreshUser() async {
    await _loadCurrentUser();
  }

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

      state = state.copyWith(
        isDeletingAccount: true,
        status: SettingsViewStatus.loading,
      );

      await _authService.deleteAccount();

      print('🔥 SettingsViewModel: 계정 삭제 성공');

      state = state.copyWith(
        isDeletingAccount: false,
        status: SettingsViewStatus.success,
      );

      if (context.mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(RoutePath.signIn, (route) => false);
      }
    } catch (e) {
      print('🔥 SettingsViewModel: 계정 삭제 에러: $e');

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
