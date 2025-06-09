import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amuz_todo/src/service/auth_service.dart';
import 'package:amuz_todo/src/repository/auth_repository.dart';
import 'todo_list_view_state.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(AuthRepository());
});

class TodoListViewModel extends StateNotifier<TodoListViewState> {
  final AuthService _authService;

  TodoListViewModel(this._authService) : super(const TodoListViewState());
}

final todoListViewModelProvider =
    StateNotifierProvider<TodoListViewModel, TodoListViewState>((ref) {
      final authService = ref.watch(authServiceProvider);
      return TodoListViewModel(authService);
    });
