// SignUpViewState
class SignUpViewState {
  final bool isBusy;
  final String? errorMessage;
  final bool isSignUpSuccessful;

  const SignUpViewState({
    this.isBusy = false,
    this.errorMessage,
    this.isSignUpSuccessful = false,
  });

  SignUpViewState copyWith({
    bool? isBusy,
    String? errorMessage,
    bool? isSignUpSuccessful,
  }) {
    return SignUpViewState(
      isBusy: isBusy ?? this.isBusy,
      errorMessage: errorMessage,
      isSignUpSuccessful: isSignUpSuccessful ?? this.isSignUpSuccessful,
    );
  }
}
