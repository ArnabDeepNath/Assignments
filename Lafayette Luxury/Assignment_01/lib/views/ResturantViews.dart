import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:luxresapp/components/DetailsScreen.dart';
import 'package:luxresapp/models/NearbyResponse.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class NearByPlacesScreen extends StatefulWidget {
  const NearByPlacesScreen({Key? key}) : super(key: key);

  @override
  State<NearByPlacesScreen> createState() => _NearByPlacesScreenState();
}

class _NearByPlacesScreenState extends State<NearByPlacesScreen> {
  String apiKey =
      "AIzaSyAwQa2odTPLwOvCxOONH3qqoMZQoLv2HZ0"; // Replace with your actual API key
  String radius = "100";

  double latitude = 0.0; // Initialize with default or fallback values
  double longitude = 0.0; // Initialize with default or fallback values

  NearbyPlacesResponse nearbyPlacesResponse = NearbyPlacesResponse();
  GoogleMapController? _mapController;

  final TextEditingController addressController = TextEditingController();

  Set<Marker> _markers = Set<Marker>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextFormField(
              controller: addressController,
              decoration: InputDecoration(labelText: 'Enter an address'),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              getCoordinatesAndNearbyRestaurants();
            },
            child: const Text("Get Nearby Restaurants"),
          ),
          Expanded(
            child: GoogleMap(
              onMapCreated: (controller) {
                _mapController = controller;
              },
              initialCameraPosition: CameraPosition(
                target: LatLng(0.0, 0.0), // Initial position
                zoom: 12, // Zoom level
              ),
              markers: _markers,
            ),
          ),
        ],
      ),
    );
  }

  void getCoordinatesAndNearbyRestaurants() async {
    final address = addressController.text;

    var url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?address=' +
            Uri.encodeQueryComponent(address) +
            '&key=' +
            apiKey);

    var response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK' && data['results'].isNotEmpty) {
        final location = data['results'][0]['geometry']['location'];
        latitude = location['lat'];
        longitude = location['lng'];

        // Now that we have the coordinates, let's fetch nearby restaurants
        getNearbyRestaurants();
      }
    }
  }

  void _showRestaurantDetails(Results restaurant) {
    showDialog(
      context: context,
      builder: (context) {
        return DetailsScreen(
          name: restaurant.name as String,
          address: restaurant.vicinity as String,
          rating: restaurant.rating ?? 0,
          photos: restaurant.photos,
        );
      },
    );
  }

  void getNearbyRestaurants() async {
    var url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=' +
            latitude.toString() +
            ',' +
            longitude.toString() +
            '&radius=' +
            radius +
            '&type=restaurant' + // Specify restaurant type
            '&key=' +
            apiKey);

    var response = await http.get(url);

    nearbyPlacesResponse =
        NearbyPlacesResponse.fromJson(jsonDecode(response.body));

    // Clear existing markers
    _markers.clear();

    // Add markers for fetched restaurants
    if (nearbyPlacesResponse.results != null) {
      for (int i = 0; i < nearbyPlacesResponse.results!.length; i++) {
        final result = nearbyPlacesResponse.results![i];
        final marker = Marker(
          markerId: MarkerId(result.placeId!),
          position: LatLng(
            result.geometry!.location!.lat as double,
            result.geometry!.location!.lng as double,
          ),
          infoWindow: InfoWindow(
            title: result.name,
            onTap: () {
              _showRestaurantDetails(result);
            },
          ),
        );
        _markers.add(marker);
      }
    }

    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(
          _getLatLngBounds(_markers),
          50.0, // Padding
        ),
      );
    }

    setState(() {});
  }

  LatLngBounds _getLatLngBounds(Set<Marker> markers) {
    if (markers.isEmpty) {
      return LatLngBounds(southwest: LatLng(0, 0), northeast: LatLng(0, 0));
    }

    double minLat = double.infinity;
    double maxLat = double.negativeInfinity;
    double minLng = double.infinity;
    double maxLng = double.negativeInfinity;

    for (Marker marker in markers) {
      final position = marker.position;
      if (position.latitude < minLat) {
        minLat = position.latitude;
      }
      if (position.latitude > maxLat) {
        maxLat = position.latitude;
      }
      if (position.longitude < minLng) {
        minLng = position.longitude;
      }
      if (position.longitude > maxLng) {
        maxLng = position.longitude;
      }
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }
}
