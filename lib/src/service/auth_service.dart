import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:amuz_todo/src/repository/auth_repository.dart';
import 'package:amuz_todo/src/model/user.dart' as app_user;

class AuthService {
  final AuthRepository _authRepository;

  AuthService(this._authRepository);

  User? get currentAuthUser => _authRepository.currentAuthUser;

  Stream<AuthState> get authStateChanges => _authRepository.authStateChanges;

  Stream<app_user.User?> get currentUserStream async* {
    await for (final authState in _authRepository.authStateChanges) {
      print('🔥 AuthService: 인증 상태 변화 감지 - ${authState.event}');

      if (authState.session?.user == null) {
        print('🔥 AuthService: 로그아웃됨, null 반환');
        yield null;
      } else {
        try {
          print('🔥 AuthService: 로그인됨, 사용자 정보 로딩 중...');
          final user = await getCurrentUserProfile();
          print('🔥 AuthService: 사용자 정보 로딩 완료 - ${user?.name}');
          yield user;
        } catch (e) {
          print('🔥 AuthService: 사용자 정보 로딩 에러 - $e');

          // refresh token 에러인 경우 자동 로그아웃
          if (e.toString().contains('refresh_token_not_found') ||
              e.toString().contains('Invalid Refresh Token')) {
            print('🔥 AuthService: Refresh Token 에러 감지, 자동 로그아웃 수행');
            try {
              await signOut();
            } catch (signOutError) {
              print('🔥 AuthService: 자동 로그아웃 실패: $signOutError');
            }
          }

          yield null;
        }
      }
    }
  }

  Future<app_user.User> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      print('🔥 AuthService: 회원가입 시작 - email: $email, name: $name');

      print('🔥 AuthService: signUpAuth 호출 중...');
      final authUser = await _authRepository.signUpAuth(
        email: email,
        password: password,
      );
      print('🔥 AuthService: signUpAuth 성공 - userId: ${authUser.id}');

      print('🔥 AuthService: User 프로필 객체 생성 중...');
      final userProfile = app_user.User(
        id: authUser.id,
        email: email,
        name: name,
        profileImageUrl: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      print('🔥 AuthService: User 프로필 객체 생성 완료');

      print('🔥 AuthService: createUserProfile 호출 중...');
      final result = await _authRepository.createUserProfile(userProfile);
      print('🔥 AuthService: createUserProfile 성공');

      print('🔥 AuthService: 회원가입 완료');
      return result;
    } catch (e) {
      print('🔥 AuthService: 회원가입 에러 발생: $e');
      print('🔥 AuthService: 에러 타입: ${e.runtimeType}');
      throw Exception('회원가입 오류: $e');
    }
  }

  Future<app_user.User> signIn({
    required String email,
    required String password,
  }) async {
    try {
      print('🔥 AuthService: 로그인 시작 - email: $email');

      print('🔥 AuthService: signInAuth 호출 중...');
      final authUser = await _authRepository.signInAuth(
        email: email,
        password: password,
      );
      print('🔥 AuthService: signInAuth 성공 - userId: ${authUser.id}');

      print('🔥 AuthService: getUserProfile 호출 중...');
      final result = await _authRepository.getUserProfile(authUser.id);
      print('🔥 AuthService: getUserProfile 성공');

      print('🔥 AuthService: 로그인 완료');
      return result;
    } catch (e) {
      print('🔥 AuthService: 로그인 에러 발생: $e');
      throw Exception('로그인 오류: $e');
    }
  }

  Future<void> signOut() async {
    try {
      print('🔥 AuthService: 로그아웃 시작');
      await _authRepository.signOutAuth();
      print('🔥 AuthService: 로그아웃 완료');
    } catch (e) {
      print('🔥 AuthService: 로그아웃 에러: $e');
      rethrow;
    }
  }

  Future<app_user.User?> getCurrentUserProfile() async {
    final authUser = currentAuthUser;
    if (authUser == null) {
      print('🔥 AuthService: getCurrentUserProfile - 인증된 사용자 없음');
      return null;
    }

    try {
      print(
        '🔥 AuthService: getCurrentUserProfile 시작 - userId: ${authUser.id}',
      );
      final result = await _authRepository.getUserProfile(authUser.id);
      print('🔥 AuthService: getCurrentUserProfile 성공');
      return result;
    } catch (e) {
      print('🔥 AuthService: getCurrentUserProfile 에러: $e');
      return null;
    }
  }

  Future<app_user.User> updateProfile({
    required String userId,
    String? name,
    String? profileImageUrl,
  }) async {
    try {
      print('🔥 AuthService: updateProfile 시작 - userId: $userId');

      final currentProfile = await _authRepository.getUserProfile(userId);
      print('🔥 AuthService: 현재 프로필 조회 완료');

      final updatedProfile = currentProfile.copyWith(
        name: name,
        profileImageUrl: profileImageUrl,
        updatedAt: DateTime.now(),
      );
      print('🔥 AuthService: 업데이트할 프로필 생성 완료');

      final result = await _authRepository.updateUserProfile(updatedProfile);
      print('🔥 AuthService: updateProfile 완료');
      return result;
    } catch (e) {
      print('🔥 AuthService: updateProfile 에러: $e');
      throw Exception('프로필 업데이트 오류: $e');
    }
  }

  Future<app_user.User> updateProfileImage(String imageUrl) async {
    final currentUser = currentAuthUser;
    if (currentUser == null) {
      throw Exception('로그인이 필요합니다');
    }

    return await updateProfile(
      userId: currentUser.id,
      profileImageUrl: imageUrl,
    );
  }

  Future<app_user.User> updateProfileImageToNull() async {
    final currentUser = currentAuthUser;
    if (currentUser == null) {
      throw Exception('로그인이 필요합니다');
    }

    try {
      print(
        '🔥 AuthService: updateProfileImageToNull 시작 - userId: ${currentUser.id}',
      );

      final currentProfile = await _authRepository.getUserProfile(
        currentUser.id,
      );
      print('🔥 AuthService: 현재 프로필 조회 완료');

      final updatedProfile = app_user.User(
        id: currentProfile.id,
        email: currentProfile.email,
        name: currentProfile.name,
        profileImageUrl: null,
        createdAt: currentProfile.createdAt,
        updatedAt: DateTime.now(),
      );

      print('🔥 AuthService: null로 설정된 프로필 생성 완료');
      print(
        '🔥 AuthService: profileImageUrl: ${updatedProfile.profileImageUrl}',
      );

      final result = await _authRepository.updateUserProfile(updatedProfile);
      print('🔥 AuthService: updateProfileImageToNull 완료');
      return result;
    } catch (e) {
      print('🔥 AuthService: updateProfileImageToNull 에러: $e');
      throw Exception('프로필 이미지 제거 오류: $e');
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      print('🔥 AuthService: changePassword 시작');

      // 현재 비밀번호로 재인증
      await _authRepository.reauthenticateUser(currentPassword);
      print('🔥 AuthService: 재인증 완료');

      // 새 비밀번호로 업데이트
      await _authRepository.updatePassword(newPassword);
      print('🔥 AuthService: 비밀번호 업데이트 완료');

      print('🔥 AuthService: changePassword 완료');
    } catch (e) {
      print('🔥 AuthService: changePassword 에러: $e');
      throw Exception('비밀번호 변경 오류: $e');
    }
  }

  Future<void> deleteAccount() async {
    final authUser = currentAuthUser;
    if (authUser == null) {
      print('🔥 AuthService: deleteAccount - 인증된 사용자 없음');
      throw Exception('로그인이 필요합니다.');
    }

    try {
      print('🔥 AuthService: deleteAccount 시작 - userId: ${authUser.id}');

      await _authRepository.deleteUserProfile(authUser.id);
      print('🔥 AuthService: 프로필 삭제 완료');

      await _authRepository.signOutAuth();
      print('🔥 AuthService: 로그아웃 완료');

      print('🔥 AuthService: deleteAccount 완료');
    } catch (e) {
      print('🔥 AuthService: deleteAccount 에러: $e');
      throw Exception('회원탈퇴 오류: $e');
    }
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(AuthRepository());
});

final currentUserProvider = StreamProvider<app_user.User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.currentUserStream;
});
