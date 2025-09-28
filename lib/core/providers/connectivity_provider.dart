import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityProvider with ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _subscription;

  bool _isOnline = true;
  bool get isOnline => _isOnline;

  ConnectivityProvider() {
    _checkInitialConnection();
    _subscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
  }

  Future<void> _checkInitialConnection() async {
    final result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result);
  }

  void _updateConnectionStatus(List<ConnectivityResult> result) {
    final hasConnection =
        result.contains(ConnectivityResult.mobile) ||
        result.contains(ConnectivityResult.wifi);

    if (hasConnection != _isOnline) {
      _isOnline = hasConnection;
      print('Status koneksi: ${_isOnline ? 'Online' : 'Offline'}');
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
