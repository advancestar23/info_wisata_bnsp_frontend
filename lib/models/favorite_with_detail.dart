class FavoriteWithDetail {
  final int id;
  final int idWisata;
  final int idUser;
  final String namaWisata;
  final String kategori;

  FavoriteWithDetail({
    required this.id,
    required this.idWisata,
    required this.idUser,
    required this.namaWisata,
    required this.kategori,
  });

  factory FavoriteWithDetail.combine(Map<String, dynamic> favorite, Map<String, dynamic> wisata) {
    return FavoriteWithDetail(
      id: int.parse(favorite['id'].toString()),
      idWisata: int.parse(favorite['id_wisata'].toString()),
      idUser: int.parse(favorite['id_user'].toString()),
      namaWisata: wisata['nama_wisata'] ?? 'Unknown',
      kategori: wisata['kategori'] ?? 'Unknown',
    );
  }
}
