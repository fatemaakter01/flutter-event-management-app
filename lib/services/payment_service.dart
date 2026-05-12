import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';
import 'api_config.dart';

class PaymentService {
  final String _endpoint = '${ApiConfig.baseUrl}/payments';

  Future<List<Payment>> fetchPayments() async {
    try {
      final response = await http.get(Uri.parse(_endpoint));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => Payment.fromJson(e)).toList();
      }
    } catch (e) {
      print('Error fetching payments: $e');
    }
    return [];
  }

  Future<bool> addPayment(int bookingId, Payment p) async {
    try {
      final response = await http.post(
        Uri.parse('$_endpoint/booking/$bookingId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(p.toJson()),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error adding payment: $e');
    }
    return false;
  }

  Future<List<Payment>> getByBookingId(int bookingId) async {
    try {
      final response = await http.get(Uri.parse('$_endpoint/booking/$bookingId'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => Payment.fromJson(e)).toList();
      }
    } catch (e) {
      print('Error fetching payments for booking: $e');
    }
    return [];
  }
}
