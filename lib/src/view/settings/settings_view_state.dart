import 'package:amuz_todo/src/model/user.dart';

enum SettingsViewStatus { initial, loading, success, error }

class SettingsViewState {
  final SettingsViewStatus status;
  final String? errorMessage;
  final bool isSigningOut;
  final bool isDeletingAccount;
  final User? currentUser;
  final bool isLoadingUser;
  final bool isUpdatingProfile;

  const SettingsViewState({
    this.status = SettingsViewStatus.initial,
    this.errorMessage,
    this.isSigningOut = false,
    this.isDeletingAccount = false,
    this.currentUser,
    this.isLoadingUser = false,
    this.isUpdatingProfile = false,
  });

  SettingsViewState copyWith({
    SettingsViewStatus? status,
    String? errorMessage,
    bool? isSigningOut,
    bool? isDeletingAccount,
    User? currentUser,
    bool? isLoadingUser,
    bool? isUpdatingProfile,
  }) {
    return SettingsViewState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      isSigningOut: isSigningOut ?? this.isSigningOut,
      isDeletingAccount: isDeletingAccount ?? this.isDeletingAccount,
      currentUser: currentUser ?? this.currentUser,
      isLoadingUser: isLoadingUser ?? this.isLoadingUser,
      isUpdatingProfile: isUpdatingProfile ?? this.isUpdatingProfile,
    );
  }

  @override
  String toString() {
    return 'SettingsViewState('
        'status: $status, '
        'errorMessage: $errorMessage, '
        'isSigningOut: $isSigningOut, '
        'isDeletingAccount: $isDeletingAccount, '
        'currentUser: $currentUser, '
        'isLoadingUser: $isLoadingUser, '
        'isUpdatingProfile: $isUpdatingProfile'
        ')';
  }
}
