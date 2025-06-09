import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amuz_todo/src/service/auth_service.dart';
import 'package:amuz_todo/src/view/settings/settings_view_state.dart';
import 'package:amuz_todo/util/route_path.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsViewModel extends StateNotifier<SettingsViewState> {
  final ImagePicker _imagePicker = ImagePicker();
  final SupabaseClient _supabase = Supabase.instance.client;
  final Ref _ref;

  SettingsViewModel(this._ref) : super(const SettingsViewState());

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
    state = state.copyWith(isUpdatingProfile: true);

    try {
      print('🔥 SettingsViewModel: 프로필 이미지 업로드 시작');

      final imageUrl = await _uploadToSupabaseStorage(imagePath);
      print('🔥 SettingsViewModel: Supabase Storage 업로드 완료 - $imageUrl');

      final authService = _ref.read(authServiceProvider);
      await authService.updateProfileImage(imageUrl);

      _ref.invalidate(currentUserProvider);

      state = state.copyWith(isUpdatingProfile: false);
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

      // AuthService에서 현재 사용자 정보 가져오기
      final authService = _ref.read(authServiceProvider);
      final currentUser = authService.currentAuthUser;

      if (currentUser == null) {
        throw Exception('로그인이 필요합니다');
      }

      final userId = currentUser.id;
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
    state = state.copyWith(isUpdatingProfile: true);

    try {
      print('🔥 SettingsViewModel: 기본 이미지로 변경 시작');

      final authService = _ref.read(authServiceProvider);
      await authService.updateProfileImageToNull();

      // 사용자 정보 새로고침하여 UI에 반영
      _ref.invalidate(currentUserProvider);

      state = state.copyWith(isUpdatingProfile: false);
      print('🔥 SettingsViewModel: 기본 이미지로 변경 완료');
    } catch (e) {
      print('🔥 SettingsViewModel: 기본 이미지로 변경 에러: $e');
      state = state.copyWith(
        isUpdatingProfile: false,
        errorMessage: '기본 이미지로 변경에 실패했습니다: $e',
      );
    }
  }

  /// 로그아웃
  Future<void> signOut(BuildContext context) async {
    try {
      print('🔥 SettingsViewModel: 로그아웃 시작');

      state = state.copyWith(
        isSigningOut: true,
        status: SettingsViewStatus.loading,
      );

      final authService = _ref.read(authServiceProvider);
      await authService.signOut();

      print('🔥 SettingsViewModel: 로그아웃 성공');

      state = state.copyWith(
        isSigningOut: false,
        status: SettingsViewStatus.success,
      );

      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          RoutePath.signIn,
          (route) => false,
        );
      }
    } catch (e) {
      print('🔥 SettingsViewModel: 로그아웃 에러: $e');
      state = state.copyWith(
        isSigningOut: false,
        status: SettingsViewStatus.error,
        errorMessage: '로그아웃에 실패했습니다: $e',
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

      final authService = _ref.read(authServiceProvider);
      await authService.deleteAccount();

      print('🔥 SettingsViewModel: 계정 삭제 성공');

      state = state.copyWith(
        isDeletingAccount: false,
        status: SettingsViewStatus.success,
      );

      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          RoutePath.signIn,
          (route) => false,
        );
      }
    } catch (e) {
      print('🔥 SettingsViewModel: 계정 삭제 에러: $e');
      state = state.copyWith(
        isDeletingAccount: false,
        status: SettingsViewStatus.error,
        errorMessage: '계정 삭제에 실패했습니다: $e',
      );
    }
  }
}

final settingsViewModelProvider =
    StateNotifierProvider<SettingsViewModel, SettingsViewState>((ref) {
      return SettingsViewModel(ref);
    });
