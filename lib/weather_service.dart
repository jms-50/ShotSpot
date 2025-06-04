import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

class WeatherService {
  final String serviceKey = 'BFCuyT7S0/kzym5orKwIc5vE+f1n3VUEhhzBUTya0QJh/3AQr//i3oUTE244yNmVBQwRKQlJE0VJyyVoCbLxNQ==';

  Future<Map<String, String>> fetchUltraShortWeather({
    required String baseDate,
    required String baseTime,
    required int nx,
    required int ny,
  }) async {
    final uri = Uri.parse(
      'https://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getUltraSrtNcst'
          '?serviceKey=$serviceKey'
          '&pageNo=1&numOfRows=1000&dataType=XML'
          '&base_date=$baseDate&base_time=$baseTime'
          '&nx=$nx&ny=$ny',
    );

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('기상청 요청 실패');
    }

    final xmlDoc = XmlDocument.parse(response.body);
    final items = xmlDoc.findAllElements('item');

    final Map<String, String> result = {};
    for (var item in items) {
      final category = item.getElement('category')?.innerText;
      final obsrValue = item.getElement('obsrValue')?.innerText;
      if (category != null && obsrValue != null) {
        result[category] = obsrValue;
      }
    }

    return result;
  }
}