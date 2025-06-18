import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// Provider untuk status koneksi real-time
final connectivityStatusProvider = StateNotifierProvider<ConnectivityStatusNotifier, bool>((ref) {
  return ConnectivityStatusNotifier();
});

class ConnectivityStatusNotifier extends StateNotifier<bool> {
  ConnectivityStatusNotifier() : super(true) {
    // Inisialisasi dengan mengecek koneksi saat ini
    _initConnectivity();
    // Mulai monitoring perubahan koneksi
    _startMonitoring();
  }

  StreamSubscription? _subscription;
  final _connectivity = Connectivity();

  Future<void> _initConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e) {
      print('Error checking initial connectivity: $e');
    }
  }

  void _startMonitoring() {
    _subscription = _connectivity.onConnectivityChanged.listen(
      (ConnectivityResult result) {
        _updateConnectionStatus(result);
      },
      onError: (error) {
        print('Error monitoring connectivity: $error');
      },
    );
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    print('Connectivity status changed: $result'); // Debug log
    state = result != ConnectivityResult.none;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
