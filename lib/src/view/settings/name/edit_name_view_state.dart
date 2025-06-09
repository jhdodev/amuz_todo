enum EditNameViewStatus { initial, loading, success, error }

class EditNameViewState {
  final EditNameViewStatus status;
  final String currentName;
  final bool isLoading;
  final String? errorMessage;
  final bool isNameUpdateSuccessful;

  const EditNameViewState({
    this.status = EditNameViewStatus.initial,
    this.currentName = '',
    this.isLoading = false,
    this.errorMessage,
    this.isNameUpdateSuccessful = false,
  });

  EditNameViewState copyWith({
    EditNameViewStatus? status,
    String? currentName,
    bool? isLoading,
    String? errorMessage,
    bool? isNameUpdateSuccessful,
  }) {
    return EditNameViewState(
      status: status ?? this.status,
      currentName: currentName ?? this.currentName,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isNameUpdateSuccessful:
          isNameUpdateSuccessful ?? this.isNameUpdateSuccessful,
    );
  }

  @override
  String toString() {
    return 'EditNameViewState('
        'status: $status, '
        'currentName: $currentName, '
        'isLoading: $isLoading, '
        'errorMessage: $errorMessage, '
        'isNameUpdateSuccessful: $isNameUpdateSuccessful'
        ')';
  }
}
