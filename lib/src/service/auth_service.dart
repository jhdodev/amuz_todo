import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:amuz_todo/src/repository/auth_repository.dart';
import 'package:amuz_todo/src/model/user.dart' as app_user;

class AuthService {
  final AuthRepository _authRepository;

  AuthService(this._authRepository);

  User? get currentAuthUser => _authRepository.currentAuthUser;

  Stream<AuthState> get authStateChanges => _authRepository.authStateChanges;

  Future<app_user.User> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      print('🔥 AuthService: 회원가입 시작 - email: $email, name: $name');

      // 1. Auth 회원가입
      print('🔥 AuthService: signUpAuth 호출 중...');
      final authUser = await _authRepository.signUpAuth(
        email: email,
        password: password,
      );
      print('🔥 AuthService: signUpAuth 성공 - userId: ${authUser.id}');

      // 2. 사용자 프로필 객체 생성
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

      // 3. 프로필 저장
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
