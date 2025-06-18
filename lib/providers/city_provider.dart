import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/api_service.dart';

final availableCitiesProvider = FutureProvider<List<String>>((ref) async {
  return ApiServices.getAvailableCities();
});

final selectedCityProvider = StateProvider<String?>((ref) => null);
