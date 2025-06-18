import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

final connectivityProvider = StreamProvider<bool>((ref) {
  return Connectivity().onConnectivityChanged.map((status) {
    return status != ConnectivityResult.none;
  });
});

final isOnlineProvider = StreamProvider<bool>((ref) async* {
  // Initial connectivity check
  final initialStatus = await Connectivity().checkConnectivity();
  yield initialStatus != ConnectivityResult.none;

  // Listen to connectivity changes
  await for (final status in Connectivity().onConnectivityChanged) {
    yield status != ConnectivityResult.none;
  }
});
