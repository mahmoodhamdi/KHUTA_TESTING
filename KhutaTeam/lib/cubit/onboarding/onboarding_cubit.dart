import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Onboarding States
abstract class OnboardingState {}

class OnboardingInitial extends OnboardingState {}

class OnboardingRequired extends OnboardingState {}

class OnboardingCompleted extends OnboardingState {}

// Onboarding Cubit
class OnboardingCubit extends Cubit<OnboardingState> {
  final SharedPreferences prefs;
  static const String _hasCompletedOnboardingKey = 'hasCompletedOnboarding';

  OnboardingCubit({required this.prefs}) : super(OnboardingInitial()) {
    _checkOnboardingStatus();
  }

  void _checkOnboardingStatus() {
    final hasCompletedOnboarding =
        prefs.getBool(_hasCompletedOnboardingKey) ?? false;
    emit(hasCompletedOnboarding ? OnboardingCompleted() : OnboardingRequired());
  }

  Future<void> completeOnboarding() async {
    await prefs.setBool(_hasCompletedOnboardingKey, true);
    emit(OnboardingCompleted());
  }

  // For testing purposes only
  Future<void> resetOnboarding() async {
    await prefs.setBool(_hasCompletedOnboardingKey, false);
    emit(OnboardingRequired());
  }
}
