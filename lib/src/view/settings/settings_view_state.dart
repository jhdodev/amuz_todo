enum SettingsViewStatus { initial, loading, success, error }

class SettingsViewState {
  final SettingsViewStatus status;
  final String? errorMessage;
  final bool isSigningOut;
  final bool isDeletingAccount;

  const SettingsViewState({
    this.status = SettingsViewStatus.initial,
    this.errorMessage,
    this.isSigningOut = false,
    this.isDeletingAccount = false,
  });

  SettingsViewState copyWith({
    SettingsViewStatus? status,
    String? errorMessage,
    bool? isSigningOut,
    bool? isDeletingAccount,
  }) {
    return SettingsViewState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      isSigningOut: isSigningOut ?? this.isSigningOut,
      isDeletingAccount: isDeletingAccount ?? this.isDeletingAccount,
    );
  }

  @override
  String toString() {
    return 'SettingsViewState('
        'status: $status, '
        'errorMessage: $errorMessage, '
        'isSigningOut: $isSigningOut, '
        'isDeletingAccount: $isDeletingAccount'
        ')';
  }
}
