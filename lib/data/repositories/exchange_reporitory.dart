import 'package:http/http.dart' as http;
import 'dart:convert';

class ExchangeRepository {
  static Future<Map<String, dynamic>?> fetchExchangeRates(String baseCode) async {
    final response = await http.get(
      Uri.parse('https://v6.exchangerate-api.com/v6/54ba8b90cf719f673b689cd6/latest/$baseCode'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load exchange rates: ${response.statusCode}');
    }
  }
}