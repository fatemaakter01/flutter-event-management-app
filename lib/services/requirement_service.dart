import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';
import 'api_config.dart';

class RequirementService {
  // Common mistake: singular instead of plural. Trying plural '/requirements'
  final String _endpoint = '${ApiConfig.baseUrl}/requirements'; 

  Future<List<Requirement>> fetchRequirements() async {
    try {
      final response = await http.get(Uri.parse(_endpoint)).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => Requirement.fromJson(e)).toList();
      } else {
        // Try singular if plural fails
        final singularResponse = await http.get(Uri.parse('${ApiConfig.baseUrl}/requirement'));
        if (singularResponse.statusCode == 200) {
          final List<dynamic> data = json.decode(singularResponse.body);
          return data.map((e) => Requirement.fromJson(e)).toList();
        }
      }
    } catch (e) {
      print('Error fetching requirements: $e');
    }
    return [];
  }

  Future<bool> addRequirement(Requirement r) async {
    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(r.toJson()),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error adding requirement: $e');
    }
    return false;
  }

  Future<bool> updateRequirement(int id, Requirement r) async {
    try {
      final response = await http.put(
        Uri.parse('$_endpoint/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(r.toJson()),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteRequirement(int id) async {
    try {
      final response = await http.delete(Uri.parse('$_endpoint/$id'));
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Error deleting requirement: $e');
    }
    return false;
  }
}
