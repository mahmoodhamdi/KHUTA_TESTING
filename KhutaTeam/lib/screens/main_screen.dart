import 'package:flutter/material.dart';
import 'package:khuta/core/services/connectivity_service.dart';
import 'package:khuta/core/widgets/offline_banner.dart';
import 'package:khuta/screens/about/about_screen.dart';
import 'package:khuta/screens/home/home_screen.dart';
import 'package:khuta/screens/settings/settings_screen.dart';
import 'package:khuta/widgets/animated_bottom_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final ConnectivityService _connectivityService = ConnectivityService();
  bool _isOnline = true;

  final List<Widget> _screens = [
    const HomeScreen(),
    const SettingsScreen(),
    const AboutScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _checkInitialConnectivity();
  }

  Future<void> _checkInitialConnectivity() async {
    final isOnline = await _connectivityService.hasConnection();
    if (mounted) {
      setState(() => _isOnline = isOnline);
    }
  }

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: _connectivityService.onConnectivityChanged,
      initialData: _isOnline,
      builder: (context, snapshot) {
        final isOnline = snapshot.data ?? true;

        return Scaffold(
          body: Column(
            children: [
              // Offline banner at the top
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: isOnline ? 0 : null,
                child: isOnline ? const SizedBox.shrink() : const OfflineBanner(),
              ),
              // Main content
              Expanded(child: _screens[_currentIndex]),
            ],
          ),
          bottomNavigationBar: AnimatedBottomBar(
            activeIndex: _currentIndex,
            onTap: _onTabTapped,
          ),
        );
      },
    );
  }
}
