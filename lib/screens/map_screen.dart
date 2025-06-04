import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _controller;
  LatLng? _currentLocation;
  final TextEditingController _searchController = TextEditingController();
  final Set<Marker> _markers = {};
  String? _selectedSpotName;
  String? _selectedSpotTitle;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  // 입력값 정규화 함수: 공백 제거 + 소문자 변환
  String normalize(String input) {
    return input.replaceAll(RegExp(r'\s+'), '').toLowerCase();
  }

  Future<void> _initLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      await Geolocator.requestPermission();
    }
    final position = await Geolocator.getCurrentPosition();
    _currentLocation = LatLng(position.latitude, position.longitude);

    _controller?.animateCamera(
      CameraUpdate.newLatLngZoom(_currentLocation!, 14),
    );

    setState(() {
      _markers.add(
        Marker(
          markerId: const MarkerId("current"),
          position: _currentLocation!,
          infoWindow: const InfoWindow(title: "현재 위치"),
        ),
      );
    });
  }

  Future<void> _searchPlace(String query) async {
    try {
      final locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        final latLng = LatLng(
          locations.first.latitude,
          locations.first.longitude,
        );
        final normalizedName = normalize(query);

        setState(() {
          _markers.add(
            Marker(
              markerId: MarkerId(normalizedName),
              position: latLng,
              infoWindow: InfoWindow(title: query),
              onTap: () {
                setState(() {
                  _selectedSpotName = normalizedName;
                  _selectedSpotTitle = query;
                });
              },
            ),
          );
          _selectedSpotName = normalizedName;
          _selectedSpotTitle = query;
        });

        _controller?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 15));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("장소를 찾을 수 없습니다: $query")),
      );
    }
  }

  Widget _buildSearchBar() {
    return Positioned(
      top: 40,
      left: 16,
      right: 16,
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(12),
        child: TextField(
          controller: _searchController,
          onSubmitted: _searchPlace,
          decoration: InputDecoration(
            hintText: "장소를 검색하세요",
            prefixIcon: const Icon(Icons.search),
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () => _searchController.clear(),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomInfoCard() {
    if (_selectedSpotName == null || _selectedSpotTitle == null) {
      return const SizedBox.shrink();
    }

    return Positioned(
      bottom: 30,
      left: 16,
      right: 16,
      child: GestureDetector(
        onTap: () async {
          final snapshot = await FirebaseFirestore.instance
              .collection('spots')
              .where('name', isEqualTo: _selectedSpotName)
              .limit(1)
              .get();

          if (snapshot.docs.isNotEmpty) {
            final spotData = snapshot.docs.first.data();
            Navigator.pushNamed(context, '/detail', arguments: spotData);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("해당 장소의 데이터가 존재하지 않습니다.")),
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _selectedSpotTitle!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _currentLocation == null
              ? const Center(child: CircularProgressIndicator())
              : GoogleMap(
            onMapCreated: (controller) => _controller = controller,
            initialCameraPosition: CameraPosition(
              target: _currentLocation!,
              zoom: 14,
            ),
            myLocationEnabled: true,
            markers: _markers,
            onTap: (_) => setState(() {
              _selectedSpotName = null;
              _selectedSpotTitle = null;
            }),
          ),
          _buildSearchBar(),
          _buildBottomInfoCard(),
        ],
      ),
    );
  }
}
