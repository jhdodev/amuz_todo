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

  Future<void> deleteUserProfile(String userId) async {
    try {
      await _supabase.from('user_profiles').delete().eq('id', userId);
    } catch (e) {
      throw Exception('사용자 프로필 삭제 실패: $e');
    }
  }
}
