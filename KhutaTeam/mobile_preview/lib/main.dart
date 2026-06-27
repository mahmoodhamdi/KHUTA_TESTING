import 'package:flutter/material.dart';
import 'package:device_frame/device_frame.dart';
import 'package:flutter/foundation.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

import 'package:khuta/core/config/app_config.dart';
import 'package:khuta/cubit/auth/auth_cubit.dart';
import 'package:khuta/cubit/onboarding/onboarding_cubit.dart';
import 'package:khuta/cubit/theme/theme_cubit.dart';
import 'package:khuta/firebase_options.dart';
import 'package:khuta/core/di/service_locator.dart';
import 'package:khuta/main.dart';
import 'mock_auth_cubit.dart';
import 'mock_child_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await EasyLocalization.ensureInitialized();

  // Initialize Firebase once with proper options
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }

  // Enable Firestore offline persistence
  try {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  } catch (e) {
    debugPrint('Firestore settings error: $e');
  }

  // Activate App Check after Firebase is initialized
  if (!kIsWeb) {
    try {
      await FirebaseAppCheck.instance.activate(
        providerAndroid: AppConfig.isDebug
            ? const AndroidDebugProvider()
            : const AndroidPlayIntegrityProvider(),
        providerApple: AppConfig.isDebug
            ? const AppleDebugProvider()
            : const AppleDeviceCheckProvider(),
      );
    } catch (e) {
      debugPrint('App Check activation error: $e');
    }
  }

  // Register in-memory mock repositories so no Firebase auth is required.
  // This must happen before runApp() so ChildCubit picks them up via ServiceLocator.
  ServiceLocator().registerChildRepository(MockChildRepository());

  // Initialize SharedPreferences for theme and onboarding
  final prefs = await SharedPreferences.getInstance();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(create: (context) => MockAuthCubit()),
          BlocProvider(create: (context) => ThemeCubit(prefs: prefs)),
          BlocProvider(create: (context) => OnboardingCubit(prefs: prefs)),
        ],
        child: KhutaApp(
          builder: (context, child) {
            return Scaffold(
              backgroundColor: const Color(0xFF0F172A),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: DeviceFrame(
                    device: Devices.ios.iPhone13,
                    isFrameVisible: true,
                    screen: child ?? const SizedBox.shrink(),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ),
  );
}