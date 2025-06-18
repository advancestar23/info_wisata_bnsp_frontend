import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/api_service.dart';
import '../models/wisata_model.dart';
import 'city_provider.dart';

final wisataProvider = FutureProvider<List<Wisata>>((ref) async {
  final selectedCity = ref.watch(selectedCityProvider);
  final allWisata = await ApiServices.fetchWisata();
  
  if (selectedCity == null) {
    return allWisata;
  }
  
  return allWisata.where((wisata) => wisata.kota == selectedCity).toList();
});
