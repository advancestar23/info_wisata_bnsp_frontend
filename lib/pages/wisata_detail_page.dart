import 'package:flutter/material.dart';
import '../models/wisata_model.dart';
import '../layout/main_layout.dart';
import '../data/api_service.dart';

class WisataDetailPage extends StatefulWidget {
  final Wisata wisata;

  const WisataDetailPage({super.key, required this.wisata});

  @override
  State<WisataDetailPage> createState() => _WisataDetailPageState();
}

class _WisataDetailPageState extends State<WisataDetailPage> {
  bool _isFavorite = false;
  bool _isLoading = false;

  String _formatHarga(String harga) {
    // Menghilangkan semua karakter non-angka
    String numericString = harga.replaceAll(RegExp(r'[^0-9]'), '');
    int hargaNum = int.tryParse(numericString) ?? 0;
    
    return hargaNum == 0 ? 'Gratis' : harga;
  }

  Future<void> _toggleFavorite() async {
    setState(() {
      _isLoading = true;
    });

    try {
      bool success;
      if (_isFavorite) {
        success = await ApiServices.removeFromFavorite(widget.wisata.id);
      } else {
        success = await ApiServices.addToFavorite(widget.wisata.id);
      }

      if (success) {
        setState(() {
          _isFavorite = !_isFavorite;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildRatingStars(int rating) {
    return Row(
      children: [
        ...List.generate(5, (index) {
          return Icon(
            Icons.star,
            color: index < rating ? Colors.amber : Colors.grey,
            size: 24,
          );
        }),
        Text(
          ' ($rating)',
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Detail Wisata',
      showDrawer: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        IconButton(
          icon: Icon(
            _isFavorite ? Icons.favorite : Icons.favorite_border,
            color: _isFavorite ? Colors.red : null,
          ),
          onPressed: _isLoading ? null : _toggleFavorite,
        ),
      ],
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.wisata.namaWisata,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(Icons.location_on, 'Lokasi', '${widget.wisata.alamat}, ${widget.wisata.kota}'),
                      const Divider(),
                      _buildInfoRow(Icons.category, 'Kategori', widget.wisata.kategori),
                      const Divider(),
                      _buildInfoRow(Icons.monetization_on, 'Harga Tiket', _formatHarga(widget.wisata.hargaTiket)),
                      const Divider(),
                      _buildInfoRow(Icons.access_time, 'Jam Operasional', 
                          '${widget.wisata.jamBuka} - ${widget.wisata.jamTutup}'),
                      const Divider(),
                      const Text(
                        'Rating',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildRatingStars(widget.wisata.rating),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Deskripsi',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.wisata.deskripsi,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
                textAlign: TextAlign.justify,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
