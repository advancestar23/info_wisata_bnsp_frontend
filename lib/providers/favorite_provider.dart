import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/favorite_with_detail.dart';
import '../data/api_service.dart';
import 'dart:convert';

final favoriteProvider = StateNotifierProvider<FavoriteNotifier, AsyncValue<List<FavoriteWithDetail>>>((ref) {
  return FavoriteNotifier();
});

class FavoriteNotifier extends StateNotifier<AsyncValue<List<FavoriteWithDetail>>> {
  FavoriteNotifier() : super(const AsyncValue.loading()) {
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    try {
      state = const AsyncValue.loading();
      
      // Ambil data wisata terlebih dahulu
      final wisataResponse = await ApiServices.fetchWisata();
      final wisataMap = {for (var w in wisataResponse) w.id: w};
      
      // Ambil data favorit
      final favoritesResponse = await ApiServices.getFavorites();
      
      // Gabungkan data
      final List<FavoriteWithDetail> combinedData = [];
      
      for (var favorite in favoritesResponse) {
        final wisata = wisataMap[favorite.idWisata];
        if (wisata != null) {
          combinedData.add(FavoriteWithDetail(
            id: favorite.id,
            idWisata: favorite.idWisata,
            idUser: favorite.idUser,
            namaWisata: wisata.namaWisata,
            kategori: wisata.kategori,
          ));
        }
      }
      
      state = AsyncValue.data(combinedData);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  void refresh() {
    loadFavorites();
  }

  Future<void> removeFavorite(int id) async {
    try {
      await ApiServices.deleteFavorite(id);
      
      // Update state to remove the favorite
      state.whenData((favorites) {
        state = AsyncValue.data(
          favorites.where((favorite) => favorite.id != id).toList(),
        );
      });
    } catch (e) {
      throw Exception('Failed to remove favorite: $e');
    }
  }
}
