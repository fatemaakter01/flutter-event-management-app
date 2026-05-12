import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';
import 'api_config.dart';

class CateringService {
  final String _endpoint = '${ApiConfig.baseUrl}/catering';

  Future<List<CateringItem>> fetchCateringItems() async {
    try {
      final response = await http.get(Uri.parse(_endpoint));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => CateringItem.fromJson(e)).toList();
      }
    } catch (e) {
      print('Error fetching catering items: $e');
    }
    return [];
  }

  Future<bool> addCateringItem(CateringItem c) async {
    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(c.toJson()),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error adding catering item: $e');
    }
    return false;
  }

  Future<bool> updateCateringItem(int id, CateringItem c) async {
    try {
      final response = await http.put(
        Uri.parse('$_endpoint/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(c.toJson()),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error updating catering item: $e');
    }
    return false;
  }

  Future<bool> deleteCateringItem(int id) async {
    try {
      final response = await http.delete(Uri.parse('$_endpoint/$id'));
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Error deleting catering item: $e');
    }
    return false;
  }
}
