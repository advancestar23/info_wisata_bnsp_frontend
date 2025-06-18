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
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      print('Error checking connectivity: $e');
      return true; // Default to true to allow requests to try
    }
  }

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"email": email, "password": password}),
      );
      
      print('Login Response Status: ${response.statusCode}');
      print('Login Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        token = data['token'];
        username = data['user']['name'];
        return data;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to login');
      }
    } catch (e) {
      print('Login error: $e');
      throw Exception('Gagal login: ${e.toString()}');
    }
  }

  static Future<List<Wisata>> fetchWisata() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/wisata'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      print('Wisata Response Status: ${response.statusCode}');
      print('Wisata Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          final List<dynamic> data = jsonResponse['data'];
          return data.map((json) => Wisata.fromJson(json)).toList();
        } else {
          throw Exception(jsonResponse['message'] ?? 'Failed to load wisata');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Sesi telah berakhir. Silakan login kembali.');
      } else {
        throw Exception('Gagal memuat daftar wisata');
      }
    } catch (e) {
      print('Error fetching wisata: $e');
      throw Exception('Gagal memuat daftar wisata: ${e.toString()}');
    }
  }

  static Future<List<WisataFavorit>> getFavorites() async {
    try {
      if (token == null) {
        throw Exception('Silakan login terlebih dahulu');
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
          return data.map((item) => WisataFavorit.fromJson(item)).toList();
        }
      } else if (response.statusCode == 401) {
        throw Exception('Sesi telah berakhir. Silakan login kembali.');
      }
      return [];
    } catch (e) {
      print('Error in getFavorites: $e');
      throw Exception('Gagal memuat daftar favorit: ${e.toString()}');
    }
  }

  static Future<List<String>> getAvailableCities() async {
    try {
      final wisataList = await fetchWisata();
      final Set<String> cities = wisataList
          .map((wisata) => wisata.kota)
          .where((kota) => kota.isNotEmpty)
          .toSet();
      final sortedCities = cities.toList()..sort();
      return sortedCities;
    } catch (e) {
      print('Error getting cities: $e');
      throw Exception('Gagal memuat daftar kota: ${e.toString()}');
    }
  }

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "name": name,
          "email": email,
          "password": password,
        }),
      );
      
      print('Register Response Status: ${response.statusCode}');
      print('Register Response Body: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Gagal mendaftar');
      }
    } catch (e) {
      print('Register error: $e');
      throw Exception('Gagal mendaftar: ${e.toString()}');
    }
  }

  static Future<bool> addToFavorite(int wisataId) async {
    try {
      if (token == null) {
        throw Exception('Silakan login terlebih dahulu');
      }

      print('Adding to favorites: $wisataId');
      final response = await http.post(
        Uri.parse('$baseUrl/wisatafavorit'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'id_wisata': wisataId,
        }),
      );

      print('Add favorite Response Status: ${response.statusCode}');
      print('Add favorite Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          return true;
        } else {
          throw Exception(jsonResponse['message'] ?? 'Gagal menambahkan ke favorit');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Sesi telah berakhir. Silakan login kembali.');
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Gagal menambahkan ke favorit');
      }
    } catch (e) {
      print('Error adding to favorites: $e');
      throw Exception('Gagal menambahkan ke favorit: ${e.toString()}');
    }
  }

  static Future<bool> removeFromFavorite(int wisataId) async {
    try {
      if (token == null) {
        throw Exception('Silakan login terlebih dahulu');
      }

      print('Removing from favorites: $wisataId');
      final response = await http.delete(
        Uri.parse('$baseUrl/favorite/$wisataId'),
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

  static Future<bool> deleteFavorite(int favoriteId) async {
    try {
      if (token == null) {
        throw Exception('Silakan login terlebih dahulu');
      }

      print('Deleting favorite: $favoriteId');
      final response = await http.delete(
        Uri.parse('$baseUrl/wisatafavorit/$favoriteId'),
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

  static Future<bool> checkIsFavorite(int wisataId) async {
    try {
      if (token == null) {
        return false;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/wisatafavorit/check/$wisataId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Check favorite Response Status: ${response.statusCode}');
      print('Check favorite Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse['is_favorite'] == true;
      } else if (response.statusCode == 401) {
        throw Exception('Sesi telah berakhir. Silakan login kembali.');
      }
      return false;
    } catch (e) {
      print('Error checking favorite status: $e');
      return false;
    }
  }
}
