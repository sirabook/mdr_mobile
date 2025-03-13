import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class NewsService {
  static final StreamController<List<dynamic>> _newsStreamController =
      StreamController.broadcast(); // ✅ ใช้ broadcast เพื่อให้หลาย widget ฟังได้
  static Timer? _timer;

  static Future<List<dynamic>> fetchNews() async {
    try {
      final response = await http.get(
        Uri.parse('http://csoc-center.com:8000/news'),
        headers: {'accept': '/'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load news');
      }
    } catch (e) {
      throw Exception('Error fetching news: $e');
    }
  }

  static void startNewsRefresh() {
    _fetchAndUpdateNews(); // ✅ โหลดข่าวครั้งแรก
    _timer?.cancel(); // ✅ ป้องกันการสร้าง Timer ซ้ำ
    _timer = Timer.periodic(Duration(minutes: 5), (timer) {
      _fetchAndUpdateNews(); // ✅ โหลดข่าวใหม่ทุก 5 นาที
    });
  }

  static void _fetchAndUpdateNews() async {
    try {
      final news = await fetchNews();
      _newsStreamController.add(news.reversed.take(10).toList()); // ✅ ส่งข่าวใหม่ไป Stream
    } catch (e) {
      _newsStreamController.addError("Error fetching news: $e");
    }
  }

  static Stream<List<dynamic>> get newsStream => _newsStreamController.stream;

  static void dispose() {
    _timer?.cancel();
    _newsStreamController.close();
  }
}
