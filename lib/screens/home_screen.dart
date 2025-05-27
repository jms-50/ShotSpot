import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('홈', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('spots').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('포토 스팟이 없습니다.', style: TextStyle(color: Colors.black)));
          }

          final spots = snapshot.data!.docs;

          return ListView.builder(
            itemCount: spots.length,
            itemBuilder: (context, index) {
              final data = spots[index].data() as Map<String, dynamic>;
              final spotId = spots[index].id;
              final name = data['name'] ?? '이름 없음';
              final description = data['description'] ?? '설명 없음';

              return Card(
                color: Colors.grey[100],
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(name, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  subtitle: Text(description, style: const TextStyle(color: Colors.black54)),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => DetailPage(spotId: spotId)),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}