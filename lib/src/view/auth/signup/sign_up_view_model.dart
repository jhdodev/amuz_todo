import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amuz_todo/src/repository/auth_repository.dart';
import 'package:amuz_todo/src/service/auth_service.dart';
import 'sign_up_view_state.dart';

final signUpViewModelProvider =
    AutoDisposeNotifierProvider<SignUpViewModel, SignUpViewState>(
      () => SignUpViewModel(),
    );

class SignUpViewModel extends AutoDisposeNotifier<SignUpViewState> {
  late final AuthService _authService;

  @override
  SignUpViewState build() {
    print('🚀 ViewModel: build() 메서드 호출됨');

    final authRepository = AuthRepository();
    _authService = AuthService(authRepository);
    print('🚀 ViewModel: AuthService 인스턴스 생성 완료');

    return const SignUpViewState();
  }

  /// 회원가입
  Future<void> signUp({
    required String email,
    required String password,
    required String confirmPassword,
    required String name,
  }) async {
    print('🚀 ViewModel: signUp 메서드 시작');
    print('🚀 ViewModel: 입력값 - email: $email, name: $name');

    print('🚀 ViewModel: 상태를 isBusy=true로 변경 시작');
    state = state.copyWith(isBusy: true, errorMessage: null);
    print('🚀 ViewModel: 상태 변경 완료 - isBusy: ${state.isBusy}');

    try {
      print('🚀 ViewModel: 입력값 검증 시작');

      // 입력값 검증
      if (email.isEmpty) {
        print('🚀 ViewModel: 이메일 빈값 에러');
        throw Exception('이메일을 입력해주세요.');
      }

      if (password.isEmpty) {
        print('🚀 ViewModel: 비밀번호 빈값 에러');
        throw Exception('비밀번호를 입력해주세요.');
      }

      if (name.isEmpty) {
        print('🚀 ViewModel: 이름 빈값 에러');
        throw Exception('이름을 입력해주세요.');
      }

      // 이메일 형식 검증
      if (!_isValidEmail(email)) {
        print('🚀 ViewModel: 이메일 형식 에러');
        throw Exception('올바른 이메일 형식을 입력해주세요.');
      }

      // 비밀번호 확인
      if (password != confirmPassword) {
        print('🚀 ViewModel: 비밀번호 불일치 에러');
        throw Exception('비밀번호가 일치하지 않습니다.');
      }

      // 비밀번호 강도 검증
      if (password.length < 6) {
        print('🚀 ViewModel: 비밀번호 길이 에러');
        throw Exception('비밀번호는 6자 이상이어야 합니다.');
      }

      print('🚀 ViewModel: 모든 검증 통과');

      // AuthService를 통해 회원가입
      print('🚀 ViewModel: AuthService.signUp 호출 시작');
      await _authService.signUp(email: email, password: password, name: name);
      print('🚀 ViewModel: AuthService.signUp 호출 완료');

      print('🚀 ViewModel: 성공 상태로 업데이트 시작');
      state = state.copyWith(isBusy: false, isSignUpSuccessful: true);
      print('🚀 ViewModel: 성공 상태 업데이트 완료');
      print(
        '🚀 ViewModel: 최종 상태 - isBusy: ${state.isBusy}, isSignUpSuccessful: ${state.isSignUpSuccessful}',
      );
    } catch (e) {
      print('🚀 ViewModel: catch 블록 진입');
      print('🚀 ViewModel: 에러 내용: $e');
      print('🚀 ViewModel: 에러 타입: ${e.runtimeType}');

      state = state.copyWith(
        isBusy: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );

      print('🚀 ViewModel: 에러 상태 업데이트 완료');
      print(
        '🚀 ViewModel: 최종 상태 - isBusy: ${state.isBusy}, errorMessage: ${state.errorMessage}',
      );
    }

    print('🚀 ViewModel: signUp 메서드 종료');
  }

  /// 이메일 형식 검증
  bool _isValidEmail(String email) {
    bool isValid = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
    print('🚀 ViewModel: 이메일 검증 결과 - $email: $isValid');
    return isValid;
  }

  /// 에러 메시지 초기화
  void clearError() {
    print('🚀 ViewModel: clearError 호출됨');
    state = state.copyWith(errorMessage: null);
  }

  /// 상태 초기화
  void reset() {
    print('🚀 ViewModel: reset 호출됨');
    state = const SignUpViewState();
  }
}
