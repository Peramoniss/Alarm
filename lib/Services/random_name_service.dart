import 'package:http/http.dart' as http;
import 'dart:convert';

class RandomNameService {
  static const _apiKey = '10ed0808215446bda1924ef2d935cdbc';
  static const _url = 'https://randommer.io/api/Name?nameType=firstname&quantity=1';

  static Future<String> fetchRandomName() async {
    String result = "Gertrudes"; // Fallback padrão

    try {
      final response = await http.get(
        Uri.parse(_url),
        headers: {
          'X-Api-Key': _apiKey,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        result = data.isNotEmpty ? data[0] : "Gertrudes";
      }
    } catch (_) {
      // Silencia o erro e mantém fallback
    }

    return result;
  }
}
