class SignInViewState {
  final bool isBusy;
  final String? errorMessage;
  final bool isSignInSuccessful;

  const SignInViewState({
    this.isBusy = false,
    this.errorMessage,
    this.isSignInSuccessful = false,
  });

  SignInViewState copyWith({
    bool? isBusy,
    String? errorMessage,
    bool? isSignInSuccessful,
  }) {
    return SignInViewState(
      isBusy: isBusy ?? this.isBusy,
      errorMessage: errorMessage,
      isSignInSuccessful: isSignInSuccessful ?? this.isSignInSuccessful,
    );
  }
}
