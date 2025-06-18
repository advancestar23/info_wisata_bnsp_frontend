import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/city_provider.dart';
import '../layout/main_layout.dart';

class CitySelectionPage extends ConsumerWidget {
  const CitySelectionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final citiesAsync = ref.watch(availableCitiesProvider);
    final selectedCity = ref.watch(selectedCityProvider);

    return MainLayout(
      title: 'Pilih Kota',
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_city, color: Colors.blue),
                        const SizedBox(width: 8),
                        const Text(
                          'Pilih Kota Wisata',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Pilih kota untuk melihat wisata yang tersedia di kota tersebut.',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            citiesAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Error: $error',
                      textAlign: TextAlign.center,
                    ),
                    TextButton(
                      onPressed: () => ref.refresh(availableCitiesProvider),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
              data: (cities) {
                if (cities.isEmpty) {
                  return const Center(
                    child: Text('Tidak ada kota tersedia'),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: selectedCity,
                          hint: const Text('Pilih Kota'),
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('Semua Kota'),
                            ),
                            ...cities.map((city) => DropdownMenuItem(
                                  value: city,
                                  child: Text(city),
                                )),
                          ],
                          onChanged: (value) {
                            ref.read(selectedCityProvider.notifier).state = value;
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/wisata');
                      },
                      icon: const Icon(Icons.search),
                      label: Text(
                        selectedCity == null
                            ? 'Lihat Semua Wisata'
                            : 'Lihat Wisata di $selectedCity',
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
                    if (selectedCity != null) ...[
                      const SizedBox(height: 12),
                      TextButton.icon(
                        onPressed: () {
                          ref.read(selectedCityProvider.notifier).state = null;
                        },
                        icon: const Icon(Icons.clear),
                        label: const Text('Reset Pilihan Kota'),
                      ),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
