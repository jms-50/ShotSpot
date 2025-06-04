import 'package:flutter/material.dart';

class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? spot =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final String spotName = spot?['name'] ?? '포토스팟';
    final String tip;
    if (spotName == '아라쿠라야마센겐공원') {
      tip =
          "✔️ ${spotName}에서 인생샷을 찍는 팁!\n\n"
          "1. 전망대의 왼쪽으로 이동해 탑을 오른쪽 프레임에 배치\n"
          "2. 전경: 벚꽃 / 중경: 파고다 / 배경: 후지산 구도로 구성  \n"
          "3. 35~50mm 화각 렌즈 사용 시 엽서 느낌 연출 가능\n\n\n"
          "☀추천 시간 & 날씨\n"
          "- 맑은 날: 오전 8~10시, 선명한 색 대비\n"
          "- 흐린 날: 안개 낀 후지산과 파고다로 몽환적인 분위기\n"
          "- 벚꽃 시즌: 벚꽃 프레임으로 계절감 강조\n"
          "- 해질 무렵: 황금빛 후지산 + 붉은 탑의 드라마틱한 조화\n";
    } else if (spotName == '시모요시다혼초거리') {
      tip =
      "✔️ ${spotName}에서 인생샷을 찍는 팁!\n\n"
          "1. 도로 중앙선에 맞춰 정면 촬영하면 좌우 대칭의 가로등과 후지산이 자연스럽게 이어지는 구도 완성\n"
          "2. 횡단보도 직전 중앙 지점이 베스트 포인트\n"
          "3. 광각 또는 35~50mm 화각 렌즈 사용 추천\n"
          "\n\n"
          "☀추천 시간 & 날씨\n"
          "- 맑은 날: 일출 직후 or 일몰 직전 하늘과 후지산의 조화\n"
          "- 흐린 날: 후지산이 안 보일 땐 상점가와 인물 중심으로\n"
          "- 비 오는 날: 젖은 도로에 반사된 빛으로 감성적인 분위기\n"
          "- 눈 오는 날: 지붕 위 눈 + 설산 후지산 조합으로 드라마틱\n"
          "- 해 질 무렵: 가로등 차량 불빛 후지산 실루엣이 어우러진 로맨틱 야경\n";
    }else if (spotName == '대전역') {
      tip =
          "✔️ ${spotName}에서 인생샷을 찍는 팁!\n\n"
          "1. 대전역 서광장 정면에서 '대전역' 간판이 잘 보이게 촬영\n"
          "2. 간판 기준 2~3m 앞에 서서 '대' 글자가 머리 위에 오도록 앵글 맞추기\n"
          "3. 스마트폰을 아래에서 위로 올려 찍으면 인물이 더 크게 나와요\n"
          "\n\n"
          "🎖보너스 팁\n"
          "- 전역티 or 군복 + 모자 착용 추천\n"
          "- 삼각대나 친구 도움으로 인물 중심 촬영\n"
          "- Live Photo 또는 연사 모드로 베스트컷 선택\n";
    } else {
      tip =
          "✔️ ${spotName}에서 인생샷을 찍는 팁!\n\n"
          "1. 인물은 배경보다 1~2미터 앞에 배치해보세요.\n"
          "2. 빛을 등지지 않도록 주의하고, 순광보단 측광으로!\n"
          "3. 가로 프레임보다는 세로 프레임으로 인물 강조!\n"
          "4. 밝은 날엔 노출을 -1로 살짝 낮춰주면 좋아요.";
    }
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
