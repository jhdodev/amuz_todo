enum ChangePasswordViewStatus { initial, loading, success, error }

class ChangePasswordViewState {
  final ChangePasswordViewStatus status;
  final bool isLoading;
  final String? errorMessage;
  final bool isPasswordUpdateSuccessful;

  const ChangePasswordViewState({
    this.status = ChangePasswordViewStatus.initial,
    this.isLoading = false,
    this.errorMessage,
    this.isPasswordUpdateSuccessful = false,
  });

  ChangePasswordViewState copyWith({
    ChangePasswordViewStatus? status,
    bool? isLoading,
    String? errorMessage,
    bool? isPasswordUpdateSuccessful,
  }) {
    return ChangePasswordViewState(
      status: status ?? this.status,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isPasswordUpdateSuccessful:
          isPasswordUpdateSuccessful ?? this.isPasswordUpdateSuccessful,
    );
  }

  @override
  String toString() {
    return 'ChangePasswordViewState('
        'status: $status, '
        'isLoading: $isLoading, '
        'errorMessage: $errorMessage, '
        'isPasswordUpdateSuccessful: $isPasswordUpdateSuccessful'
        ')';
  }
}
