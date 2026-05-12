import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';
import 'api_config.dart';

class EventService {
  final String _endpoint = '${ApiConfig.baseUrl}/events'; // Matches @RequestMapping("/api/events")

  Future<List<Event>> fetchEvents() async {
    try {
      final response = await http.get(Uri.parse(_endpoint));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => Event.fromJson(e)).toList();
      }
    } catch (e) {
      print('Error fetching events: $e');
    }
    return [];
  }

  Future<bool> addEvent(Event e) async {
    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(e.toJson()),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error adding event: $e');
    }
    return false;
  }

  Future<bool> updateEvent(int id, Event e) async {
    try {
      final response = await http.put(
        Uri.parse('$_endpoint/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(e.toJson()),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error updating event: $e');
    }
    return false;
  }

  Future<bool> deleteEvent(int id) async {
    try {
      final response = await http.delete(Uri.parse('$_endpoint/$id'));
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Error deleting event: $e');
    }
    return false;
  }
}
