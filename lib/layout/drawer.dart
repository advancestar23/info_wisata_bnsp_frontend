import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/city_provider.dart';
import '../providers/connectivity_provider.dart';

class DrawerMenu extends ConsumerWidget {
  const DrawerMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnlineAsync = ref.watch(isOnlineProvider);

    return Drawer(
      child: Column(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text(
              "Menu utama",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          isOnlineAsync.when(
            data: (isOnline) => Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              color: isOnline ? Colors.green.shade100 : Colors.red.shade100,
              child: Row(
                children: [
                  Icon(
                    isOnline ? Icons.wifi : Icons.wifi_off,
                    size: 20,
                    color: isOnline ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isOnline ? 'Online' : 'Offline',
                    style: TextStyle(
                      color: isOnline ? Colors.green.shade700 : Colors.red.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            error: (_, __) => Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              color: Colors.orange.shade100,
              child: const Row(
                children: [
                  Icon(Icons.warning, size: 20, color: Colors.orange),
                  SizedBox(width: 8),
                  Text(
                    'Status koneksi tidak diketahui',
                    style: TextStyle(color: Colors.orange),
                  ),
                ],
              ),
            ),
            loading: () => Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: const Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text('Memeriksa koneksi...'),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              shrinkWrap: true,
              children: [
                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text("Home"),
                  onTap: () => Navigator.pushReplacementNamed(context, '/home'),
                ),
                ListTile(
                  leading: const Icon(Icons.location_city),
                  title: const Text("Pilih Kota"),
                  onTap: () => Navigator.pushReplacementNamed(context, '/pilih-kota'),
                ),
                ListTile(
                  leading: const Icon(Icons.place),
                  title: const Text("Daftar Wisata"),
                  onTap: () => Navigator.pushReplacementNamed(context, '/wisata'),
                ),
                ListTile(
                  leading: const Icon(Icons.favorite),
                  title: const Text("Wisata Favorit"),
                  onTap: () => Navigator.pushReplacementNamed(context, '/favorit'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
