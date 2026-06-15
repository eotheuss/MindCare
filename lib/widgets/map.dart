import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

Future<LatLng> getLatLngFromGoogle(String address) async {
  const apiKey = "AIzaSyCV9NqNeQZovuIOov4u_1Qh5R4omyaQ6kg";

  final url =
      "https://maps.googleapis.com/maps/api/geocode/json"
      "?address=${Uri.encodeComponent(address)}"
      "&key=$apiKey";

  final response = await http.get(Uri.parse(url));

  final data = json.decode(response.body);

  final location = data['results'][0]['geometry']['location'];

  return LatLng(location['lat'], location['lng']);
}

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {

  LatLng _initialPosition = const LatLng(-23.5505, -46.6333);
  LatLng? _position;
  Set<Marker> _markers = {};
  GoogleMapController? _mapController;

  Future<void> getLatLng() async {
    final newPosition = await getLatLngFromGoogle(
      "Rua Catão 124, Vila Romana, São Paulo, SP",
    );

    setState(() {
      _position = newPosition;

      _markers = {
        Marker(
          markerId: const MarkerId("clinica"),
          position: newPosition,
          infoWindow: const InfoWindow(title: "Clínica MindCare"),
        ),
      };
    });

    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(newPosition, 17));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mapa")),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _initialPosition,
          zoom: 15,
        ),
        onMapCreated: (controller) {
          _mapController = controller;
          getLatLng();
        },
        markers: _markers,
      ),
    );
  }
}
