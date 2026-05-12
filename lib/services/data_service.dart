import '../models/models.dart';

// This file is now deprecated. Please use the individual service files 
// (employee_service.dart, venue_service.dart, etc.) for API calls.
class DataService {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  final List<Employee> employees = [];
  final List<Venue> venues = [];
  final List<Event> events = [];
  final List<Requirement> requirements = [];
  final List<CateringItem> cateringItems = [];
  final List<Booking> bookings = [];

  // Placeholder methods to prevent compilation errors in legacy code
  Future<void> fetchEmployees() async {}
  Future<bool> addEmployee(Employee e) async => true;
  Future<bool> updateEmployee(int id, Employee e) async => true;
  Future<bool> deleteEmployee(int id) async => true;
  
  void addVenue(Venue v) {}
  void deleteVenue(dynamic id) {}
  void addBooking(Booking b) {}
  void deleteBooking(dynamic id) {}
}
