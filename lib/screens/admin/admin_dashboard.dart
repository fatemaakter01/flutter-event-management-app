import 'package:flutter/material.dart';
import '../../services/booking_service.dart';
import '../../services/employee_service.dart';
import '../../services/venue_service.dart';
import '../login_screen.dart';
import 'tabs/employee_management.dart';
import 'tabs/venue_management.dart';
import 'tabs/event_management.dart';
import 'tabs/requirement_management.dart';
import 'tabs/catering_management.dart';
import 'tabs/booking_management.dart';
import 'tabs/payment_management.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  final BookingService _bookingService = BookingService();
  final EmployeeService _employeeService = EmployeeService();
  final VenueService _venueService = VenueService();

  Map<String, dynamic> _stats = {};
  int _employeeCount = 0;
  bool _isLoadingStats = true;

  final List<String> _titles = [
    'Dashboard Overview',
    'Employee Management',
    'Venue Management',
    'Event Management',
    'Requirement Management',
    'Catering Management',
    'Booking Management',
    'Payment Management',
  ];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoadingStats = true);
    try {
      final stats = await _bookingService.fetchStats();
      final employees = await _employeeService.fetchEmployees();
      
      if (mounted) {
        setState(() {
          _stats = stats;
          _employeeCount = employees.length;
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      print('Error loading dashboard stats: $e');
      if (mounted) {
        setState(() => _isLoadingStats = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isWideScreen = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex], style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: _selectedIndex != 0 
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                setState(() => _selectedIndex = 0);
                _loadDashboardData(); // Refresh stats when returning to dashboard
              },
            )
          : (isWideScreen ? const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.admin_panel_settings, color: Colors.deepPurple)),
            ) : null),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
          )
        ],
      ),
      drawer: isWideScreen ? null : Drawer(
        child: _buildSidebarContent(),
      ),
      body: Row(
        children: [
          if (isWideScreen)
            Container(
              width: 280,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: _buildSidebarContent(),
            ),
          Expanded(
            child: Container(
              color: Colors.grey[50],
              child: _buildBody(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarContent() {
    return Column(
      children: [
        UserAccountsDrawerHeader(
          decoration: const BoxDecoration(color: Colors.deepPurple),
          currentAccountPicture: const CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 40, color: Colors.deepPurple),
          ),
          accountName: const Text('Fatema Admin', style: TextStyle(fontWeight: FontWeight.bold)),
          accountEmail: const Text('admin@event.com'),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              _buildSidebarItem(Icons.dashboard_rounded, 'Dashboard', 0),
              _buildSidebarItem(Icons.people_alt_rounded, 'Employee Management', 1),
              _buildSidebarItem(Icons.location_on_rounded, 'Venue Management', 2),
              _buildSidebarItem(Icons.event_available_rounded, 'Event Management', 3),
              _buildSidebarItem(Icons.task_alt_rounded, 'Requirement Management', 4),
              _buildSidebarItem(Icons.restaurant_menu_rounded, 'Catering Management', 5),
              _buildSidebarItem(Icons.book_online_rounded, 'Booking Management', 6),
              _buildSidebarItem(Icons.payments_rounded, 'Payment Management', 7),
              const Divider(height: 30),
              _buildSidebarItem(Icons.logout_rounded, 'Logout', -1),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSidebarItem(IconData icon, String title, int index) {
    bool isSelected = _selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Icon(icon, color: isSelected ? Colors.white : Colors.grey[700]),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        selectedTileColor: Colors.deepPurple,
        onTap: () {
          if (index == -1) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
          } else {
            setState(() {
              _selectedIndex = index;
            });
            if (index == 0) _loadDashboardData();
            if (MediaQuery.of(context).size.width <= 900) {
              Navigator.pop(context);
            }
          }
        },
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0: return _buildDashboardOverview();
      case 1: return const EmployeeManagementScreen();
      case 2: return const VenueManagementScreen();
      case 3: return const EventManagementScreen();
      case 4: return const RequirementManagementScreen();
      case 5: return const CateringManagementScreen();
      case 6: return const BookingManagementScreen();
      case 7: return const PaymentManagementScreen();
      default: return const Center(child: Text('Select an Option'));
    }
  }

  Widget _buildDashboardOverview() {
    if (_isLoadingStats) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quick Statistics', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = constraints.maxWidth > 1200 ? 4 : (constraints.maxWidth > 700 ? 2 : 1);
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 1.5,
                children: [
                  _buildStatCard('Total Bookings', _stats['totalBookings']?.toString() ?? '0', Icons.book_online, Colors.blue),
                  _buildStatCard('Total Employees', _employeeCount.toString(), Icons.people, Colors.purple),
                  _buildStatCard('Venues Available', _stats['totalVenues']?.toString() ?? '0', Icons.location_city, Colors.green),
                  _buildStatCard('Total Events', _stats['totalEvents']?.toString() ?? '0', Icons.event, Colors.orange),
                ],
              );
            },
          ),
          const SizedBox(height: 30),
          const Text('Booking Summary', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(child: _buildSimpleStatTile('Online Bookings', _stats['totalOnline']?.toString() ?? '0', Icons.language, Colors.teal)),
              const SizedBox(width: 20),
              Expanded(child: _buildSimpleStatTile('Offline Bookings', _stats['totalOffline']?.toString() ?? '0', Icons.store, Colors.brown)),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(child: _buildSimpleStatTile('New Today (Online)', _stats['todayOnline']?.toString() ?? '0', Icons.today, Colors.indigo)),
              const SizedBox(width: 20),
              Expanded(child: _buildSimpleStatTile('New Today (Offline)', _stats['todayOffline']?.toString() ?? '0', Icons.history, Colors.blueGrey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
        border: Border(bottom: BorderSide(color: color, width: 4)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(fontSize: 16, color: Colors.grey[600], fontWeight: FontWeight.w500)),
              Icon(icon, color: color, size: 28),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSimpleStatTile(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5)],
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
