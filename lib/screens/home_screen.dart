import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onTabTapped(int index) {
    setState(() => _selectedIndex = index);
    if (index == 1) Navigator.pushNamed(context, '/map');
    if (index == 2) Navigator.pushNamed(context, '/mypage');
  }

  Stream<QuerySnapshot> _getSpots() {
    return FirebaseFirestore.instance
        .collection('spots')
        .orderBy('likes', descending: true)
        .limit(10)
        .snapshots();
  }



  Widget _buildSpotCard(dynamic spot) {
    String name = spot['name'] ?? '이름 없음';
    int likes = spot['likes'] ?? 0;
    String? thumbnail = spot['thumbnailUrl'];
    String description = spot['description'] ?? '장소 소개';
    List<dynamic> hashtags = spot['hashtags'];
    List<dynamic> images = spot['images'];
    double latitude = spot['latitude'] ?? 0.0;
    double longitude = spot['longitude'] ?? 0.0;

    bool isExample = false;

    if (spot is DocumentSnapshot) {
      name = spot['name'] ?? '이름 없음';
      likes = spot['likes'] ?? 0;
      thumbnail = spot['thumbnailUrl'];
      description = spot['description'] ?? '장소 소개';
      hashtags = spot['hashtags'];
      images = spot['images'];
      longitude = spot['longitude'] ?? 0.0;
      latitude = spot['latitude'] ?? 0.0;
    } else if (spot is Map<String, dynamic>) {
      name = spot['name'] ?? '이름 없음';
      likes = spot['likes'] ?? 0;
      thumbnail = spot['thumbnailUrl'];
      description = spot['description'] ?? '장소 소개';
      hashtags = spot['hashtags'];
      images = spot['images'];
      longitude = spot['longitude'] ?? 0.0;
      latitude = spot['latitude'] ?? 0.0;
      isExample = spot['isExample'] ?? false;
    } else {
      // 타입이 맞지 않으면 빈 카드 반환
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: thumbnail != null
            ? ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(thumbnail, width: 60, height: 60, fit: BoxFit.cover),
        )
            : Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.image_not_supported),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("좋아요 $likes개"),
        onTap: () {
          final data = spot.data() as Map<String, dynamic>;
          Navigator.pushNamed(context, '/detail', arguments: data);
        },
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("ShotSpot"),
        actions: [
          if (user != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: CircleAvatar(
                radius: 16,
                child: Text(user.email?[0].toUpperCase() ?? "U"),
              ),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "🔥 오늘의 인기 포토 스팟",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _getSpots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final spots = snapshot.data!.docs;

                  final combinedSpots = [...spots];

                  if (combinedSpots.isEmpty) {
                    return const Center(child: Text("추천 포토스팟이 없습니다"));
                  }
                  return ListView.builder(
                    itemCount: combinedSpots.length,
                    itemBuilder: (context, index) => _buildSpotCard(combinedSpots[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}