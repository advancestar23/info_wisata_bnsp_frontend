import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'login.dart';
import 'home.dart';
import 'pages/wisata_list_page.dart';
import 'pages/favorite_list_page.dart';
import 'pages/city_selection_page.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Info Wisata',
        theme: ThemeData(primarySwatch: Colors.blue),
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => LoginPage(),
          '/login': (context) => LoginPage(),
          '/home': (context) => const HomePage(),
          '/wisata': (context) => const WisataListPage(),
          '/favorit': (context) => const FavoriteListPage(),
          '/pilih-kota': (context) => const CitySelectionPage(),
        },
      ),
    );
  }
}
