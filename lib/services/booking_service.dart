import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';
import 'api_config.dart';

class BookingService {
  final String _endpoint = '${ApiConfig.baseUrl}/bookings';

  Future<List<Booking>> fetchBookings() async {
    try {
      final response = await http.get(Uri.parse(_endpoint)).timeout(const Duration(seconds: 10));
      print('Bookings STATUS: ${response.statusCode}');
      print('Bookings BODY: ${response.body}');
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final bookings = data.map((e) => Booking.fromJson(e)).toList();
        for (var b in bookings) {
          print('Booking: ${b.clientName} | Status: "${b.status}"');
        }
        return bookings;
      }
    } catch (e) {
      print('Error fetching bookings: $e');
    }
    return [];
  }

  Future<Map<String, dynamic>> fetchStats() async {
    try {
      final response = await http.get(Uri.parse('$_endpoint/stats'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Error fetching stats: $e');
    }
    return {};
  }

  Future<bool> addBooking(Booking b) async {
    try {
      final jsonBody = b.toJson();
      print('Sending JSON: ${json.encode(jsonBody)}'); // ← এইটা add করুন

      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(jsonBody),
      );
      print('Add Booking STATUS: ${response.statusCode}');
      print('Add Booking BODY: ${response.body}'); // ← backend এর error message আসবে এখানে
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error adding booking: $e');
    }
    return false;
  }

  Future<bool> deleteBooking(int id) async {
    try {
      final response = await http.delete(Uri.parse('$_endpoint/$id'));
      print('Delete STATUS: ${response.statusCode}');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Error deleting booking: $e');
    }
    return false;
  }
}