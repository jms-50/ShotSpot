import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key});

  void _launchMap() async {
    const url = 'https://map.naver.com/v5/search/한강공원';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? spot =
    ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final String name = spot?['name'] ?? '포토스팟 이름';
    final String description = spot?['description'] ?? '이곳은 사진이 잘 나오는 장소입니다.';
    final List<String> hashtags = List<String>.from(spot?['hashtags'] ?? ['#강추천', '#인생샷']);

    final List<String> imageUrls = List<String>.from(spot?['images'] ?? [
      'https://via.placeholder.com/300x200',
      'https://via.placeholder.com/300x200?text=Second',
    ]);

    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지 스와이프
            SizedBox(
              height: 200,
              child: PageView.builder(
                itemCount: imageUrls.length,
                itemBuilder: (context, index) => ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(imageUrls[index], fit: BoxFit.cover),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 해시태그
            Wrap(
              spacing: 8,
              children: hashtags
                  .map((tag) => Chip(label: Text(tag)))
                  .toList(),
            ),
            const SizedBox(height: 16),

            // 설명
            Text(
              description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),

            // 네이버 지도 버튼
            ElevatedButton.icon(
              onPressed: _launchMap,
              icon: const Icon(Icons.map),
              label: const Text("지도에서 보기"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),

            // 촬영 가이드 버튼
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/guide', arguments: spot);
              },
              icon: const Icon(Icons.camera_alt),
              label: const Text("촬영 가이드 보기"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
