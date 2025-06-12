import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends StateNotifier<bool> {
  ThemeService() : super(false) {
    _loadTheme();
  }

  static const String _themeKey = 'isDarkMode';

  // 다크모드 상태 토글
  Future<void> toggleTheme() async {
    state = !state;
    await _saveTheme(state);
  }

  // 다크모드 상태 설정
  Future<void> setDarkMode(bool isDark) async {
    state = isDark;
    await _saveTheme(isDark);
  }

  // SharedPreferences에서 테마 상태 로드
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_themeKey) ?? false;
    state = isDark;
  }

  // SharedPreferences에 테마 상태 저장
  Future<void> _saveTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDark);
  }
}

// ThemeService Provider
final themeServiceProvider = StateNotifierProvider<ThemeService, bool>((ref) {
  return ThemeService();
});

// 다크모드 상태만 가져오는 Provider
final isDarkModeProvider = Provider<bool>((ref) {
  return ref.watch(themeServiceProvider);
});
