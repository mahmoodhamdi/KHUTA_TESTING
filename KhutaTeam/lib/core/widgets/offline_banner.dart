import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:khuta/core/services/connectivity_service.dart';
import 'package:khuta/core/theme/home_screen_theme.dart';

/// A banner that displays when the device is offline.
///
/// Shows at the top of the screen with a warning icon and message.
/// Automatically hides when connectivity is restored.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: HomeScreenTheme.accentOrange(isDark),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              'offline_mode'.tr(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A widget that wraps content and shows an offline banner when disconnected.
///
/// Usage:
/// ```dart
/// OfflineAwareScaffold(
///   appBar: AppBar(title: Text('My Screen')),
///   body: MyContent(),
/// )
/// ```
class OfflineAwareScaffold extends StatefulWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;

  const OfflineAwareScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomNavigationBar,
    this.backgroundColor,
  });

  @override
  State<OfflineAwareScaffold> createState() => _OfflineAwareScaffoldState();
}

class _OfflineAwareScaffoldState extends State<OfflineAwareScaffold> {
  final ConnectivityService _connectivityService = ConnectivityService();
  bool _isOnline = true;

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

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: _connectivityService.onConnectivityChanged,
      initialData: _isOnline,
      builder: (context, snapshot) {
        final isOnline = snapshot.data ?? true;

        return Scaffold(
          appBar: widget.appBar,
          backgroundColor: widget.backgroundColor,
          floatingActionButton: widget.floatingActionButton,
          floatingActionButtonLocation: widget.floatingActionButtonLocation,
          bottomNavigationBar: widget.bottomNavigationBar,
          body: Column(
            children: [
              // Offline banner
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: isOnline ? 0 : null,
                child: isOnline ? const SizedBox.shrink() : const OfflineBanner(),
              ),
              // Main content
              Expanded(child: widget.body),
            ],
          ),
        );
      },
    );
  }
}

/// A simple wrapper that shows an offline indicator inline.
///
/// Use this when you don't want to replace the entire Scaffold.
class OfflineIndicator extends StatefulWidget {
  final Widget child;

  const OfflineIndicator({
    super.key,
    required this.child,
  });

  @override
  State<OfflineIndicator> createState() => _OfflineIndicatorState();
}

class _OfflineIndicatorState extends State<OfflineIndicator> {
  final ConnectivityService _connectivityService = ConnectivityService();
  bool _isOnline = true;

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

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: _connectivityService.onConnectivityChanged,
      initialData: _isOnline,
      builder: (context, snapshot) {
        final isOnline = snapshot.data ?? true;

        return Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: isOnline ? 0 : null,
              child: isOnline ? const SizedBox.shrink() : const OfflineBanner(),
            ),
            Expanded(child: widget.child),
          ],
        );
      },
    );
  }
}
