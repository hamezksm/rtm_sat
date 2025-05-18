import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../features/customers/data/models/customer_model.dart';
import '../../features/activities/data/models/activity_model.dart';

class ApiService {
  final http.Client client;
  final String baseUrl;
  final String apiKey;

  ApiService({
    required this.client,
    required this.baseUrl,
    required this.apiKey,
  });

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'apikey': apiKey,
    'Authorization': 'Bearer $apiKey',
  };

  Future<List<CustomerModel>> getCustomers() async {
    final response = await client.get(
      Uri.parse('$baseUrl/customers'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => CustomerModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load customers: ${response.body}');
    }
  }

  Future<List<ActivityModel>> getActivities() async {
    final response = await client.get(
      Uri.parse('$baseUrl/activities'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => ActivityModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load activities: ${response.body}');
    }
  }
}
