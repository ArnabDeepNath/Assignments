import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:luxresapp/views/ResturantViews.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final Color customBeigeColor = const Color.fromARGB(160, 240, 235, 222);
  final _places =
      GoogleMapsPlaces(apiKey: 'AIzaSyAwQa2odTPLwOvCxOONH3qqoMZQoLv2HZ0');
  // This widget is the root of your application.
  Future<List<PlacesSearchResult>> searchPlaces(
      String query, LatLng location) async {
    final result = await _places.searchNearbyWithRadius(
      Location(lat: location.latitude, lng: location.longitude),
      5000,
      type: "restaurant",
      keyword: query,
    );
    if (result.status == "OK") {
      return result.results;
    } else {
      throw Exception(result.errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lafayette Luxury Concierge',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: customBeigeColor),
        useMaterial3: true,
      ),
      home: MyHomePage(title: 'Lafayette Luxury Concierge'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          widget.title,
          style: TextStyle(
            fontSize: 24,
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: NearByPlacesScreen(),
    );
  }
}
