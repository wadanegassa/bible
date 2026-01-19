import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_config.dart';
import 'models/bible_models.dart';

class ApiService {
  Future<List<Verse>> getChapterContent(String bookId, int chapter) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/$bookId+$chapter?translation=${ApiConfig.translation}');
    
    try {
      final response = await http.get(url, headers: ApiConfig.headers).timeout(const Duration(seconds: 15));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> versesData = data['verses'];
        return versesData.map((v) => Verse.fromJson(v)).toList();
      } else {
        throw Exception('API Error ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // bible-api.com search is done via the same endpoint if you input a query string 
  // but it's limited. We'll rely more on local or simple pass-through if available.
  // For now, let's keep getChapterContent as the primary.
}
