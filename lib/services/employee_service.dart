import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';
import 'api_config.dart';

class EmployeeService {
  final String _endpoint = '${ApiConfig.baseUrl}/employee';

  Future<List<Employee>> fetchEmployees() async {
    try {
      final response = await http.get(Uri.parse(_endpoint)).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => Employee.fromJson(e)).toList();
      } else {
        throw Exception('Server Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Connection failed: $e');
    }
  }

  Future<bool> addEmployee(Employee e) async {
    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(e.toJson()),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Add Error: $e');
      return false;
    }
  }

  Future<bool> updateEmployee(int id, Employee e) async {
    try {
      final response = await http.put(
        Uri.parse('$_endpoint/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(e.toJson()),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteEmployee(int id) async {
    try {
      final response = await http.delete(Uri.parse('$_endpoint/$id'));
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }
}
