import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:amuz_todo/src/model/user.dart' as app_user;

class AuthRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  User? get currentAuthUser => _supabase.auth.currentUser;

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  Future<User> signUpAuth({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('회원가입에 실패했습니다.');
      }

      return response.user!;
    } on AuthException catch (e) {
      throw Exception('회원가입 실패: ${e.message}');
    }
  }

  Future<User> signInAuth({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Auth 로그인에 실패했습니다.');
      }

      return response.user!;
    } on AuthException catch (e) {
      throw Exception('Auth 로그인 실패: ${e.message}');
    }
  }

  Future<void> signOutAuth() async {
    try {
      await _supabase.auth.signOut();
    } on AuthException catch (e) {
      throw Exception('로그아웃 실패: ${e.message}');
    }
  }

  Future<app_user.User> createUserProfile(app_user.User userProfile) async {
    try {
      await _supabase.from('user_profiles').insert(userProfile.toJson());

      return userProfile;
    } catch (e) {
      throw Exception('사용자 프로필 생성 실패: $e');
    }
  }

  Future<app_user.User> getUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('user_profiles')
          .select()
          .eq('id', userId)
          .single();

      return app_user.User.fromJson(response);
    } catch (e) {
      throw Exception('사용자 프로필 조회 실패: $e');
    }
  }

  Future<app_user.User> updateUserProfile(app_user.User userProfile) async {
    try {
      final updatedProfile = userProfile.copyWith(updatedAt: DateTime.now());

      await _supabase
          .from('user_profiles')
          .update(updatedProfile.toJson())
          .eq('id', updatedProfile.id);

      return updatedProfile;
    } catch (e) {
      throw Exception('사용자 프로필 업데이트 실패: $e');
    }
  }

  Future<void> reauthenticateUser(String currentPassword) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user?.email == null) {
        throw Exception('사용자 정보를 찾을 수 없습니다.');
      }

      // 현재 이메일과 비밀번호로 재로그인 시도
      await _supabase.auth.signInWithPassword(
        email: user!.email!,
        password: currentPassword,
      );
    } on AuthException catch (e) {
      throw Exception('현재 비밀번호가 올바르지 않습니다: ${e.message}');
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      await _supabase.auth.updateUser(UserAttributes(password: newPassword));
    } on AuthException catch (e) {
      throw Exception('비밀번호 변경에 실패했습니다: ${e.message}');
    }
  }

  Future<void> deleteUserProfile(String userId) async {
    try {
      print('🔥 AuthRepository: Edge Function으로 계정 삭제 시작 - userId: $userId');

      // Edge Function 호출
      final response = await _supabase.functions.invoke(
        'delete-user', // Edge Function 이름
        body: {'userId': userId},
      );

      print('🔥 AuthRepository: Edge Function 응답 상태: ${response.status}');
      print('🔥 AuthRepository: Edge Function 응답 데이터: ${response.data}');

      if (response.status != 200) {
        throw Exception('Edge Function 에러: ${response.data}');
      }

      // 응답 데이터 확인
      if (response.data['success'] != true) {
        throw Exception('계정 삭제 실패: ${response.data['error']}');
      }

      print('🔥 AuthRepository: Edge Function으로 계정 삭제 완료');
    } catch (e) {
      print('🔥 AuthRepository: Edge Function 호출 에러: $e');
      throw Exception('사용자 프로필 삭제 실패: $e');
    }
  }
}
