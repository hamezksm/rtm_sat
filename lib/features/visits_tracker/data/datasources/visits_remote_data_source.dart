import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rtm_sat/core/constants/api.dart';
import 'package:rtm_sat/core/error/exceptions.dart';
import '../models/visit_model.dart';

abstract class VisitsRemoteDataSource {
  Future<List<VisitModel>> getVisits();
  Future<int> createVisit(VisitModel visit);
  Future updateVisit(VisitModel visit);
  Future<void> deleteVisit(int id);
  Future<VisitModel?> getVisitById(int id);
}

class VisitsRemoteDataSourceImpl implements VisitsRemoteDataSource {
  final http.Client client;
  final String baseUrl;
  final String apiKey;

  VisitsRemoteDataSourceImpl({
    required this.client,
    required this.baseUrl,
    required this.apiKey,
  });

  @override
  Future<List<VisitModel>> getVisits() async {
    final response = await client.get(
      Uri.parse('$baseUrl/visits'),
      headers: {
        'Content-Type': 'application/json',
        'apiKey': apiKey,
        'Authorization': 'Bearer $apiKey',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => VisitModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load visits: ${response.body}');
    }
  }

  @override
  Future<int> createVisit(VisitModel visit) async {
    final response = await client.post(
      Uri.parse('${Api.baseUrl}/visits'),
      headers: {
        'Content-Type': 'application/json',
        'apikey': Api.apiKey,
        'Authorization': 'Bearer ${Api.apiKey}',
      },
      body: json.encode(visit.toJson()),
    );

    if (response.statusCode == 201) {
      // If the API doesn't return data but returns 201, we need to fetch all visits
      // and try to identify the one we just created to get its ID
      final allVisitsResponse = await client.get(
        Uri.parse('${Api.baseUrl}/visits?order=created_at.desc'),
        headers: {
          'Content-Type': 'application/json',
          'apikey': Api.apiKey,
          'Authorization': 'Bearer ${Api.apiKey}',
        },
      );

      if (allVisitsResponse.statusCode == 200) {
        final List<dynamic> visits = json.decode(allVisitsResponse.body);

        // We assume the first item is our newly created visit (as we sorted by created_at desc)
        if (visits.isNotEmpty) {
          final createdVisit = VisitModel.fromJson(visits[0]);
          return createdVisit.id!;
        }
      }

      // If we couldn't determine the ID, return a temporary one
      // The next sync will fix this
      return DateTime.now().millisecondsSinceEpoch;
    } else {
      throw ServerException(
        'Failed to create visit: ${response.statusCode} ${response.body}',
      );
    }
  }

  @override
  Future<void> updateVisit(VisitModel visit) async {
    if (visit.id == null) throw Exception('Visit ID cannot be null');

    final response = await client.patch(
      Uri.parse('$baseUrl/visits?id=eq.${visit.id}'),
      headers: {
        'Content-Type': 'application/json',
        'apiKey': apiKey,
        'Authorization': 'Bearer $apiKey',
      },
      body: () {
        final visitJson = visit.toJson();
        visitJson.remove('id');
        return json.encode(visitJson);
      }(),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to update visit: ${response.body}');
    }
  }

  @override
  Future<void> deleteVisit(int id) async {
    final response = await client.delete(
      Uri.parse('$baseUrl/visits?id=eq.$id'),
      headers: {
        'Content-Type': 'application/json',
        'apiKey': apiKey,
        'Authorization': 'Bearer $apiKey',
      },
    );

    if (response.statusCode != 204 ) {
      throw Exception('Failed to delete visit: ${response.body}');
    }
  }

  @override
  Future<VisitModel?> getVisitById(int id) async {
    try {
      final response = await client.get(
        Uri.parse('${Api.baseUrl}/visits?id=eq.$id'),
        headers: {
          'Content-Type': 'application/json',
          'apikey': Api.apiKey,
          'Authorization': 'Bearer ${Api.apiKey}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        if (jsonList.isEmpty) {
          return null; // Visit not found
        }
        return VisitModel.fromJson(jsonList.first);
      } else {
        throw ServerException('Failed to load visit: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException('Network error: $e');
    }
  }
}
