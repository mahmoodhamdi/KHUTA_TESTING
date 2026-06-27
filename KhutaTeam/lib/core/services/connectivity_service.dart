import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import '../exceptions/app_exceptions.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  /// Check if device has internet connection
  Future<bool> hasConnection() async {
    final result = await _connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  /// Stream of connectivity changes
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged
        .map((result) => !result.contains(ConnectivityResult.none));
  }

  /// Throws NetworkException if no connection
  Future<void> ensureConnected() async {
    if (!await hasConnection()) {
      throw NetworkException(
        'no_internet_connection'.tr(),
        code: 'NO_CONNECTION',
      );
    }
  }

  /// Get current connection type
  Future<String> getConnectionType() async {
    final result = await _connectivity.checkConnectivity();
    if (result.contains(ConnectivityResult.wifi)) {
      return 'WiFi';
    } else if (result.contains(ConnectivityResult.mobile)) {
      return 'Mobile';
    } else if (result.contains(ConnectivityResult.ethernet)) {
      return 'Ethernet';
    } else {
      return 'None';
    }
  }
}
