import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'detail_screen.dart';

class Spot {
  final String spotId;
  final String name;
  final String description;
  final double latitude;
  final double longitude;

  Spot({
    required this.spotId,
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
  });

  factory Spot.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Spot(
      spotId: data['spotId'] ?? doc.id,
      name: data['name'],
      description: data['description'],
      latitude: data['latitude'],
      longitude: data['longitude'],
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();
  Set<Marker> _markers = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('지도 검색'), backgroundColor: Colors.white),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '장소나 지역 검색',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _searchLocation(_searchController.text),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onSubmitted: _searchLocation,
            ),
          ),
          Expanded(
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(37.5665, 126.9780), // 서울
                zoom: 12,
              ),
              onMapCreated: (controller) => _mapController = controller,
              markers: _markers,
              onTap: (LatLng position) {
                // 배경 지도 클릭 시 정보창 닫기 등 구현 가능
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) return;
    try {
      final locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        final location = locations.first;
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(location.latitude, location.longitude),
            14,
          ),
        );
        _loadSpotsNearby(location.latitude, location.longitude);
      }
    } catch (e) {
      print('주소 검색 실패: $e');
    }
  }

  Future<void> _loadSpotsNearby(double lat, double lng) async {
    final snapshot = await FirebaseFirestore.instance.collection('spots').get();
    final spots = snapshot.docs.map((doc) => Spot.fromFirestore(doc)).toList();

    final markers = spots.where((spot) {
      final distance = Geolocator.distanceBetween(lat, lng, spot.latitude, spot.longitude);
      return distance < 3000; // 3km 이내
    }).map((spot) => _createMarker(spot)).toSet();

    setState(() => _markers = markers);
  }

  Marker _createMarker(Spot spot) {
    return Marker(
      markerId: MarkerId(spot.spotId),
      position: LatLng(spot.latitude, spot.longitude),
      infoWindow: InfoWindow(
        title: spot.name,
        snippet: spot.description,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetailPage(spotId: spot.spotId,),
            ),
          );
        },
      ),
    );
  }
}