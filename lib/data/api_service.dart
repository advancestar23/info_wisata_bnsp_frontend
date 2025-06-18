import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/wisata_model.dart';
import '../models/wisata_favorit_model.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ApiServices {
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  static String? token;
  static String? username;

  static Future<bool> checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  static Future<T> _handleRequest<T>(Future<T> Function() request) async {
    if (!await checkConnectivity()) {
      throw Exception('Tidak ada koneksi internet. Silakan cek koneksi Anda dan coba lagi.');
    }

    try {
      return await request();
    } catch (e) {
      if (e is http.ClientException) {
        throw Exception('Gagal terhubung ke server. Silakan cek koneksi Anda dan coba lagi.');
      }
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    return _handleRequest(() async {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"email": email, "password": password}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        token = data['token'];
        username = data['user']['name'];
        return data;
      } else {
        throw Exception('failed to login');
      }
    });
  }

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "name": name,
        "email": email,
        "password": password,
      }),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception('failed to register');
    }
  }

  static Future<List<Wisata>> fetchWisata() async {
    return _handleRequest(() async {
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/wisata'),
          headers: {
            'Content-Type': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> jsonResponse = json.decode(response.body);
          if (jsonResponse['success'] == true) {
            final List<dynamic> data = jsonResponse['data'];
            return data.map((json) => Wisata.fromJson(json)).toList();
          } else {
            throw Exception(jsonResponse['message']);
          }
        } else {
          throw Exception('Failed to load wisata');
        }
      } catch (e) {
        throw Exception('Error: $e');
      }
    });
  }

  static Future<List<WisataFavorit>> getFavorites() async {
    return _handleRequest(() async {
      try {
        if (token == null) {
          throw Exception('User not logged in');
        }

        print('Getting favorites with token: $token');
        final response = await http.get(
          Uri.parse('$baseUrl/wisatafavorit'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        print('Favorites Response Status: ${response.statusCode}');
        print('Favorites Response Body: ${response.body}');

        if (response.statusCode == 200) {
          final Map<String, dynamic> jsonResponse = json.decode(response.body);
          if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
            final List<dynamic> data = jsonResponse['data'];
            return data.map((item) {
              try {
                return WisataFavorit.fromJson(item);
              } catch (e) {
                print('Error parsing favorite item: $e');
                print('Problematic item: $item');
                return null;
              }
            }).whereType<WisataFavorit>().toList();
          }
        } else if (response.statusCode == 401) {
          throw Exception('Unauthorized. Please login again.');
        }
        return [];
      } catch (e) {
        print('Error in getFavorites: $e');
        throw Exception('Error loading favorites: $e');
      }
    });
  }

  static Future<Wisata?> getWisataById(int id) async {
    try {
      print('Getting wisata detail for ID: $id');
      final response = await http.get(
        Uri.parse('$baseUrl/tourist/$id'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      print('Wisata Detail Response Status: ${response.statusCode}');
      print('Wisata Detail Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          if (jsonResponse['data'] is List && jsonResponse['data'].isNotEmpty) {
            return Wisata.fromJson(jsonResponse['data'][0]);
          } else if (jsonResponse['data'] is Map) {
            return Wisata.fromJson(jsonResponse['data']);
          }
        }
      }
      return null;
    } catch (e) {
      print('Error getting wisata detail: $e');
      return null;
    }
  }

  static Future<bool> addToFavorite(int idWisata) async {
    try {
      if (token == null) {
        throw Exception('User not logged in');
      }

      print('Adding to favorites: $idWisata');
      final response = await http.post(
        Uri.parse('$baseUrl/favorite'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'id_wisata': idWisata.toString(),
        }),
      );

      print('Add favorite Response Status: ${response.statusCode}');
      print('Add favorite Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error adding to favorites: $e');
      return false;
    }
  }

  static Future<bool> removeFromFavorite(int idWisata) async {
    try {
      if (token == null) {
        throw Exception('User not logged in');
      }

      print('Removing from favorites: $idWisata');
      final response = await http.delete(
        Uri.parse('$baseUrl/favorite/$idWisata'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Remove favorite Response Status: ${response.statusCode}');
      print('Remove favorite Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error removing from favorites: $e');
      return false;
    }
  }

  static Future<bool> deleteFavorite(int id) async {
    try {
      if (token == null) {
        throw Exception('User not logged in');
      }

      print('Deleting favorite with id: $id');
      final response = await http.delete(
        Uri.parse('$baseUrl/wisatafavorit/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Delete favorite Response Status: ${response.statusCode}');
      print('Delete favorite Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error deleting favorite: $e');
      return false;
    }
  }

  static Future<List<Wisata>> getFavoriteWisataList() async {
    try {
      final favorites = await getFavorites();
      print('Got ${favorites.length} favorites');

      List<Wisata> wisataList = [];
      for (var favorite in favorites) {
        print('Getting details for wisata ID: ${favorite.idWisata}');
        final wisata = await getWisataById(favorite.idWisata);
        if (wisata != null) {
          wisataList.add(wisata);
        }
      }

      print('Returning ${wisataList.length} wisata details');
      return wisataList;
    } catch (e) {
      print('Error in getFavoriteWisataList: $e');
      throw Exception('Failed to load favorite wisata list: $e');
    }
  }

  static Future<List<String>> getAvailableCities() async {
    return _handleRequest(() async {
      final wisataList = await fetchWisata();
      final Set<String> cities = wisataList
          .map((wisata) => wisata.kota)
          .where((kota) => kota.isNotEmpty)
          .toSet();
      final sortedCities = cities.toList()..sort();
      return sortedCities;
    });
  }
}
