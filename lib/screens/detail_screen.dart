import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'guide_screen.dart';
import 'camera_screen.dart';

class DetailPage extends StatelessWidget {
  final String spotId;
  const DetailPage({super.key, required this.spotId});

  Future<DocumentSnapshot> _fetchSpotData() {
    return FirebaseFirestore.instance.collection('spots').doc(spotId).get();
  }

  void _launchMap(String spotName) async {
    final url = 'nmap://search?query=$spotName';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      print("Could not launch map for $spotName");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('포토 스팟 상세'),
        backgroundColor: Colors.white,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _fetchSpotData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('데이터를 찾을 수 없습니다.', style: TextStyle(color: Colors.black)));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final name = data['name'] ?? '제목 없음';
          final description = data['description'] ?? '설명 없음';
          final hashtags = List<String>.from(data['hashtags'] ?? []);
          final imageUrls = List<String>.from(data['images'] ?? []); // 스와이프 이미지
          final nearbySpots = List<String>.from(data['nearby'] ?? []); // 근처 스팟 이름 리스트

          return SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => GuidePage(spotId: spotId,)),
                  ),
                  child: SizedBox(
                    height: 200,
                    child: PageView(
                      children: imageUrls.isNotEmpty
                          ? imageUrls
                          .map((url) => Image.network(url, fit: BoxFit.cover))
                          .toList()
                          : [
                        Image.asset('assets/sample.jpg', fit: BoxFit.cover),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Wrap(
                    spacing: 8,
                    children: hashtags
                        .map((tag) => Chip(
                      label: Text('#$tag'),
                      backgroundColor: Colors.grey[200],
                    ))
                        .toList(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: GestureDetector(
                    onTap: () => _launchMap(name),
                    child: Row(
                      children: const [
                        Icon(Icons.map, color: Colors.blue),
                        SizedBox(width: 4),
                        Text('네이버지도에서 보기', style: TextStyle(color: Colors.black)),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(description, style: const TextStyle(color: Colors.black)),
                ),
                const Divider(color: Colors.black12),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('근처 포토 스팟', style: TextStyle(fontSize: 18, color: Colors.black)),
                ),
                SizedBox(
                  height: 150,
                  child: PageView.builder(
                    itemCount: nearbySpots.length,
                    controller: PageController(viewportFraction: 0.8),
                    itemBuilder: (context, index) {
                      return Card(
                        color: Colors.grey[100],
                        child: Center(
                          child: Text(nearbySpots[index], style: const TextStyle(color: Colors.black)),
                        ),
                      );
                    },
                  ),
                ),
                const Spacer(),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => CameraScreen(spotId: spotId,)),
                    ),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('사진 촬영'),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          );
        },
      ),
    );
  }
}
