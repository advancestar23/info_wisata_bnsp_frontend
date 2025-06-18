import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/wisata_model.dart';
import '../providers/wisata_provider.dart';
import '../providers/city_provider.dart';
import '../layout/main_layout.dart';
import './wisata_detail_page.dart';

class WisataListPage extends ConsumerWidget {
  const WisataListPage({super.key});

  String _formatHarga(String harga) {
    String numericString = harga.replaceAll(RegExp(r'[^0-9]'), '');
    int hargaNum = int.tryParse(numericString) ?? 0;

    return hargaNum == 0 ? 'Gratis' : harga;
  }

  Widget _buildRatingStars(int rating) {
    return Row(
      children: [
        const Text('Rating: '),
        ...List.generate(5, (index) {
          return Icon(
            Icons.star,
            color: index < rating ? Colors.amber : Colors.grey,
            size: 20,
          );
        }),
        Text(' ($rating)'),
      ],
    );
  }

  void _navigateToDetail(BuildContext context, Wisata wisata) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WisataDetailPage(wisata: wisata),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wisataAsync = ref.watch(wisataProvider);
    final selectedCity = ref.watch(selectedCityProvider);

    return MainLayout(
      title: selectedCity == null ? 'Daftar Wisata' : 'Wisata di $selectedCity',
      child: wisataAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error: $error',
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.refresh(wisataProvider),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
        data: (wisataList) {
          if (wisataList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    selectedCity == null 
                        ? 'Tidak ada wisata tersedia'
                        : 'Tidak ada wisata di $selectedCity',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: wisataList.length,
            itemBuilder: (context, index) {
              final wisata = wisataList[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(8),
                  title: Text(
                    wisata.namaWisata,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 16),
                          const SizedBox(width: 4),
                          Expanded(child: Text(wisata.kota)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('Harga: ${_formatHarga(wisata.hargaTiket)}'),
                      const SizedBox(height: 4),
                      _buildRatingStars(wisata.rating),
                    ],
                  ),
                  onTap: () => _navigateToDetail(context, wisata),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
