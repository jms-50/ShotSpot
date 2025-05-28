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

  Widget _buildSpotCard(DocumentSnapshot spot) {
    final String name = spot['name'] ?? '이름 없음';
    final int likes = spot['likes'] ?? 0;
    final String? thumbnail = spot['thumbnailUrl'];

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
                  if (spots.isEmpty) {
                    return const Center(child: Text("추천 포토스팟이 없습니다"));
                  }
                  return ListView.builder(
                    itemCount: spots.length,
                    itemBuilder: (context, index) => _buildSpotCard(spots[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      /*
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: '지도'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '마이페이지'),
        ],
      ),
      */
    );
  }
}