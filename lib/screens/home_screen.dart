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

  /// 예시 포토스팟 데이터 (Firestore 아님)
  final Map<String, dynamic> sampleSpot = {
    'name': '예시 포토존',
    'likes': 999,
    'thumbnailUrl': 'https://cdn.pixabay.com/photo/2022/10/08/11/13/banghwa-bridge-7506744_1280.jpg',
    'isExample': true, // 예시 카드임을 표시
  };

  //예시용 카드 처리를 위한 코드가 적용됨. 예시용 카드 없을시 수정 필요.
  Widget _buildSpotCard(dynamic spot) {
    String name = spot['name'] ?? '이름 없음';
    int likes = spot['likes'] ?? 0;
    String? thumbnail = spot['thumbnailUrl'];

    bool isExample = false;

    if (spot is DocumentSnapshot) {
      name = spot['name'] ?? '이름 없음';
      likes = spot['likes'] ?? 0;
      thumbnail = spot['thumbnailUrl'];
    } else if (spot is Map<String, dynamic>) {
      name = spot['name'] ?? '이름 없음';
      likes = spot['likes'] ?? 0;
      thumbnail = spot['thumbnailUrl'];
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
        onTap: () => Navigator.pushNamed(context, '/detail', arguments: spot),
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

                  final combinedSpots = [sampleSpot, ...spots];

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