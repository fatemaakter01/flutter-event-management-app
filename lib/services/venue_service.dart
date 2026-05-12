import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';
import 'api_config.dart';

class VenueService {
  final String _endpoint = '${ApiConfig.baseUrl}/venues'; // Matches @RequestMapping("/api/venues")

  Future<List<Venue>> fetchVenues() async {
    try {
      final response = await http.get(Uri.parse(_endpoint));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => Venue.fromJson(e)).toList();
      }
    } catch (e) {
      print('Error fetching venues: $e');
    }
    return [];
  }

  Future<bool> addVenue(Venue v) async {
    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(v.toJson()),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error adding venue: $e');
    }
    return false;
  }

  Future<bool> updateVenue(int id, Venue v) async {
    try {
      final response = await http.put(
        Uri.parse('$_endpoint/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(v.toJson()),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error updating venue: $e');
    }
    return false;
  }

  Future<bool> deleteVenue(int id) async {
    try {
      final response = await http.delete(Uri.parse('$_endpoint/$id'));
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Error deleting venue: $e');
    }
    return false;
  }
}
