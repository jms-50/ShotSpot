import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'guide_screen.dart';
import 'camera_screen.dart';

class DetailPage extends StatefulWidget {
  final String spotId;
  const DetailPage({super.key, required this.spotId});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late Future<DocumentSnapshot> _spotFuture;
  late Future<List<String>> _photoUrlsFuture;

  @override
  void initState() {
    super.initState();
    _spotFuture = FirebaseFirestore.instance.collection('spots').doc(widget.spotId).get();
    _photoUrlsFuture = _fetchSpotPhotos(widget.spotId);
  }

  Future<List<String>> _fetchSpotPhotos(String spotId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('spot_photos')
        .where('spotId', isEqualTo: spotId)
        .get();

    final allPhotos = snapshot.docs.map((doc) => doc['imageUrl'] as String).toList();
    allPhotos.shuffle(); // 랜덤 순서
    return allPhotos.take(5).toList(); // 최대 5장만 보여줌
  }

  void _launchMap(String spotName) async {
    final url = 'nmap://search?query=$spotName';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      print("지도 열기 실패");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('포토 스팟 상세'), backgroundColor: Colors.white),
      body: FutureBuilder<DocumentSnapshot>(
        future: _spotFuture,
        builder: (context, spotSnapshot) {
          if (spotSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!spotSnapshot.hasData || !spotSnapshot.data!.exists) {
            return const Center(child: Text('데이터를 찾을 수 없습니다.', style: TextStyle(color: Colors.black)));
          }

          final data = spotSnapshot.data!.data() as Map<String, dynamic>;
          final name = data['name'] ?? '제목 없음';
          final description = data['description'] ?? '설명 없음';
          final hashtags = List<String>.from(data['hashtags'] ?? []);
          final nearbySpots = List<String>.from(data['nearby'] ?? []);

          return SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 랜덤 공개 이미지 표시
                FutureBuilder<List<String>>(
                  future: _photoUrlsFuture,
                  builder: (context, photoSnapshot) {
                    if (photoSnapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(
                        height: 200,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final photos = photoSnapshot.data ?? [];

                    return SizedBox(
                      height: 200,
                      child: PageView(
                        children: photos.isNotEmpty
                            ? photos.map((url) => Image.network(url, fit: BoxFit.cover)).toList()
                            : [Image.asset('assets/sample.jpg', fit: BoxFit.cover)],
                      ),
                    );
                  },
                ),

                // 해시태그
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Wrap(
                    spacing: 8,
                    children: hashtags.map((tag) => Chip(label: Text('#$tag'))).toList(),
                  ),
                ),

                // 지도 링크
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: GestureDetector(
                    onTap: () => _launchMap(name),
                    child: Row(
                      children: const [
                        Icon(Icons.map, color: Colors.blue),
                        SizedBox(width: 4),
                        Text('Google지도에서 보기', style: TextStyle(color: Colors.black)),
                      ],
                    ),
                  ),
                ),

                // 설명
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(description, style: const TextStyle(color: Colors.black)),
                ),

                const Divider(color: Colors.black12),

                // 근처 포토 스팟
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

                // 사진 촬영 버튼
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => CameraScreen(spotId: widget.spotId)),
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