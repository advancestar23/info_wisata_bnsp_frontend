class WisataFavorit {
  final int id;
  final int idWisata;
  final int idUser;

  WisataFavorit({
    required this.id,
    required this.idWisata,
    required this.idUser,
  });

  factory WisataFavorit.fromJson(Map<String, dynamic> json) {
    // Fungsi helper untuk mengkonversi berbagai tipe data ke int
    int parseToInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) {
        // Menghapus karakter non-digit jika ada
        final cleanString = value.replaceAll(RegExp(r'[^0-9]'), '');
        if (cleanString.isEmpty) return 0;
        return int.parse(cleanString);
      }
      return 0;
    }

    return WisataFavorit(
      id: parseToInt(json['id']),
      idWisata: parseToInt(json['id_wisata']),
      idUser: parseToInt(json['id_user']),
    );
  }
}
