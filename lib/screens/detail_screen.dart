import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  int _currentPage = 0;
  List<Map<String, dynamic>> nearbySpots = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(loadNearbySpots);
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371;
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _deg2rad(double deg) => deg * (pi / 180);

  Future<void> loadNearbySpots() async {
    final Map<String, dynamic>? spot =
    ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (spot == null) return;
    final double lat1 = spot['latitude'];
    final double lon1 = spot['longitude'];

    final snapshot = await FirebaseFirestore.instance.collection('spots').get();

    final List<Map<String, dynamic>> allSpots = snapshot.docs
        .map((doc) => doc.data())
        .whereType<Map<String, dynamic>>()
        .toList();

    final filtered = allSpots.where((s) {
      if (s['latitude'] == lat1 && s['longitude'] == lon1) return false;
      final dist = _calculateDistance(lat1, lon1, s['latitude'], s['longitude']);
      return dist < 50.0;
    }).toList();

    setState(() {
      nearbySpots = filtered;
    });
  }

  Widget _buildNearbySpotCard(Map<String, dynamic> spot, String currentSpotName) {
    final String name = spot['name'] ?? '포토스팟';
    final String? url = spot['thumbnailUrl'];

    return GestureDetector(
      onTap: () {
        if (name != currentSpotName) {
          Navigator.pushNamed(context, '/detail', arguments: spot);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[200],
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              url ?? '',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey[300],
                alignment: Alignment.center,
                child: const Icon(Icons.broken_image, color: Colors.grey, size: 40),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
            Positioned(
              bottom: 12,
              left: 12,
              child: Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final Map<String, dynamic>? spot;
    if (args is DocumentSnapshot) {
      spot = args.data() as Map<String, dynamic>;
    } else {
      spot = args is Map<String, dynamic> ? args : null;
    }

    final String name = spot?['name'] ?? '포토스팟 이름';
    final String description = spot?['description'] ?? '이곳은 사진이 잘 나오는 장소입니다.';
    final List<String> hashtags = List<String>.from(
      spot?['hashtags'] ?? ['#강추천', '#인생샷'],
    );
    final List<String> imageUrls = List<String>.from(
      spot?['images'] ??
          [
            'https://cdn.pixabay.com/photo/2022/10/08/11/13/banghwa-bridge-7506744_1280.jpg',
            'https://cdn.pixabay.com/photo/2017/09/29/04/25/korea-2797865_1280.jpg',
          ],
    );

    final List<Map<String, dynamic>> spotsToShow = nearbySpots;

    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 이미지 스와이프
                    SizedBox(
                      height: 220,
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          PageView.builder(
                            itemCount: imageUrls.length,
                            onPageChanged: (index) {
                              setState(() => _currentPage = index);
                            },
                            itemBuilder: (context, index) => ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                imageUrls[index],
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 8,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                imageUrls.length,
                                    (index) => Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _currentPage == index
                                        ? Colors.white
                                        : Colors.white54,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 해시태그
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: hashtags
                          .map(
                            (tag) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            tag,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.blueAccent,
                            ),
                          ),
                        ),
                      )
                          .toList(),
                    ),
                    const SizedBox(height: 20),

                    // 설명
                    Text(
                      "장소 소개",
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: const TextStyle(fontSize: 15, height: 1.5),
                    ),

                    // 근처 포토스팟
                    const SizedBox(height: 28),
                    Text(
                      "📍 근처 포토스팟",
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 160,
                      child: PageView.builder(
                        controller: PageController(viewportFraction: 0.85),
                        itemCount: spotsToShow.length,
                        itemBuilder: (context, index) =>
                            _buildNearbySpotCard(spotsToShow[index], name),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // 하단 고정 버튼
            Container(
              color: Colors.white,
              padding: EdgeInsets.fromLTRB(
                16,
                12,
                16,
                16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/guide', arguments: spot);
                      },
                      icon: const Icon(Icons.camera_alt),
                      label: const Text("촬영 가이드 보기"),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(color: Colors.blueAccent),
                        foregroundColor: Colors.blueAccent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.camera_alt),
                      onPressed: () => Navigator.pushNamed(
                        context,
                        '/camera',
                        arguments: spot,
                      ),
                      label: const Text("사진 촬영"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
