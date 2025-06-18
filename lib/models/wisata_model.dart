class Wisata {
  final int id;
  final String namaWisata;
  final String alamat;
  final String deskripsi;
  final String hargaTiket;
  final String jamBuka;
  final String jamTutup;
  final String kota;
  final int rating;
  final String kategori;

  Wisata({
    required this.id,
    required this.namaWisata,
    required this.alamat,
    required this.deskripsi,
    required this.hargaTiket,
    required this.jamBuka,
    required this.jamTutup,
    required this.kota,
    required this.rating,
    required this.kategori,
  });

  factory Wisata.fromJson(Map<String, dynamic> json) {
    return Wisata(
      id: json['id'] as int,
      namaWisata: json['nama_wisata'] as String,
      alamat: json['alamat'] as String,
      deskripsi: json['deskripsi'] as String,
      hargaTiket: json['harga_tiket'] as String,
      jamBuka: json['jam_buka'] as String,
      jamTutup: json['jam_tutup'] as String,
      kota: json['kota'] as String,
      rating: json['rating'] as int,
      kategori: json['kategori'] as String,
    );
  }
}
