import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/log_item_model.dart';

class ApiService {
  static const String baseUrl = 'http://10.227.38.157:5000';

  Future<List<LogItemModel>> fetchHistory() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/history'));

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((dynamic item) => LogItemModel.fromJson(item)).toList();
      } else {
        throw Exception('Lỗi server: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Không thể kết nối đến server: $e');
    }
  }
}
