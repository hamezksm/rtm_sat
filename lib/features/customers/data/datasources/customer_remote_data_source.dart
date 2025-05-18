import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/customer_model.dart';
import '../../../../core/error/exceptions.dart';

abstract class CustomerRemoteDataSource {
  Future<List<CustomerModel>> getCustomers();
}

class CustomerRemoteDataSourceImpl implements CustomerRemoteDataSource {
  final http.Client client;
  final String baseUrl;
  final String apiKey;

  CustomerRemoteDataSourceImpl({
    required this.client,
    required this.baseUrl,
    required this.apiKey,
  });

  @override
  Future<List<CustomerModel>> getCustomers() async {
    final response = await client.get(
      Uri.parse('$baseUrl/customers'),
      headers: {
        'Content-Type': 'application/json',
        'apikey': apiKey,
        'Authorization': 'Bearer $apiKey',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => CustomerModel.fromJson(json)).toList();
    } else {
      throw ServerException('Failed to load customers');
    }
  }
}