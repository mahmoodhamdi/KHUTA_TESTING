import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Theme States
abstract class ThemeState {}

class ThemeInitial extends ThemeState {}

class ThemeLight extends ThemeState {}

class ThemeDark extends ThemeState {}

// Theme Cubit
class ThemeCubit extends Cubit<ThemeState> {
  final SharedPreferences prefs;

  ThemeCubit({required this.prefs}) : super(ThemeInitial()) {
    _loadTheme();
  }

  void _loadTheme() {
    final isDark = prefs.getBool('isDark') ?? false;
    emit(isDark ? ThemeDark() : ThemeLight());
  }

  Future<void> toggleTheme() async {
    if (state is ThemeLight) {
      await prefs.setBool('isDark', true);
      emit(ThemeDark());
    } else {
      await prefs.setBool('isDark', false);
      emit(ThemeLight());
    }
  }
}
