import 'package:flutter/material.dart';

class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? spot =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final String spotName = spot?['name'] ?? '포토스팟';
    final String tip =
        "✔️ ${spotName}에서 인생샷을 찍는 팁!\n\n"
        "1. 인물은 배경보다 1~2미터 앞에 배치해보세요.\n"
        "2. 빛을 등지지 않도록 주의하고, 순광보단 측광으로!\n"
        "3. 가로 프레임보다는 세로 프레임으로 인물 강조!\n"
        "4. 밝은 날엔 노출을 -1로 살짝 낮춰주면 좋아요.";

    return Scaffold(
      appBar: AppBar(title: const Text("촬영 가이드")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "📸 $spotName",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(tip, style: const TextStyle(fontSize: 16, height: 1.6)),
            const Spacer(),

            // 버튼 영역
            SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                      label: const Text("이전으로"),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.camera_alt),
                      onPressed:
                          () => Navigator.pushNamed(
                            context,
                            '/camera',
                            arguments: spot,
                          ),
                      label: const Text("사진 촬영"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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
