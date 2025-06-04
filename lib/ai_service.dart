import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'dart:convert';

class AIService {
  final String apiKey = ''; // 발급받은 키로 교체

  Future<List<String>> classifyImage(File imageFile) async {
    final mimeType = lookupMimeType(imageFile.path) ?? 'image/jpeg';

    final response = await http.post(
      Uri.parse('https://api-inference.huggingface.co/models/google/vit-base-patch16-224'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': mimeType,
      },
      body: await imageFile.readAsBytes(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> result = response.body.contains('error')
          ? []
          : List<dynamic>.from(jsonDecode(response.body));

      return result.map((e) => e['label'].toString()).toList();
    } else {
      throw Exception('AI 분석 실패: ${response.body}');
    }
  }

  String generateGuideText(List<String> labels) {
    if (labels.contains('landscape')) {
      return '이 사진은 풍경 사진으로 보여요. 수평 구도와 넓은 배경을 강조해보세요.';
    } else if (labels.contains('person') || labels.contains('portrait')) {
      return '이 사진은 인물 중심 구도입니다. 인물 주변 여백과 배경 흐림 효과를 활용해보세요.';
    } else if (labels.contains('architecture')) {
      return '건축물이 주 피사체입니다. 수직선과 대칭을 고려해보세요.';
    } else {
      return '이 사진은 다양한 요소를 포함하고 있어요. 중심 피사체를 강조하는 구도를 고민해보세요.';
    }
  }
}