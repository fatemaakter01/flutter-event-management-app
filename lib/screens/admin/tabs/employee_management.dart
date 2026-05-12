import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/models.dart';
import '../../../services/employee_service.dart';

class EmployeeManagementScreen extends StatefulWidget {
  const EmployeeManagementScreen({super.key});

  @override
  State<EmployeeManagementScreen> createState() => _EmployeeManagementScreenState();
}

class _EmployeeManagementScreenState extends State<EmployeeManagementScreen> {
  final EmployeeService _employeeService = EmployeeService();
  List<Employee> _employees = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    setState(() => _isLoading = true);
    try {
      final data = await _employeeService.fetchEmployees();
      setState(() {
        _employees = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading employees: $e')),
      );
    }
  }

  void _showEmployeeForm([Employee? employee]) {
    final nameController = TextEditingController(text: employee?.name);
    final emailController = TextEditingController(text: employee?.email);
    final phoneController = TextEditingController(text: employee?.phone);
    final designationController = TextEditingController(text: employee?.designation);
    final departmentController = TextEditingController(text: employee?.department);
    final salaryController = TextEditingController(text: employee?.salary.toString());
    String status = employee?.status ?? 'Active';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(employee == null ? 'Add New Employee' : 'Edit Employee', 
          style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(nameController, 'Full Name', Icons.person),
              _buildTextField(emailController, 'Email', Icons.email),
              _buildTextField(phoneController, 'Phone', Icons.phone),
              _buildTextField(designationController, 'Designation', Icons.work),
              _buildTextField(departmentController, 'Department', Icons.business),
              _buildTextField(salaryController, 'Salary', Icons.payments, isNumber: true),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: status,
                items: ['Active', 'Inactive'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) => status = val!,
                decoration: InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  prefixIcon: const Icon(Icons.info_outline),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
            onPressed: () async {
              final newEmployee = Employee(
                id: employee?.id,
                name: nameController.text,
                email: emailController.text,
                phone: phoneController.text,
                designation: designationController.text,
                department: departmentController.text,
                joinDate: employee?.joinDate ?? DateTime.now(),
                salary: double.tryParse(salaryController.text) ?? 0,
                status: status,
              );

              bool success;
              if (employee == null) {
                success = await _employeeService.addEmployee(newEmployee);
              } else {
                success = await _employeeService.updateEmployee(employee.id!, newEmployee);
              }

              if (success) {
                _loadEmployees();
                Navigator.pop(context);
              }
            },
            child: Text(employee == null ? 'Save' : 'Update'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.deepPurple),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('All Employees', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
                  onPressed: () => _showEmployeeForm(),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Employee'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _employees.isEmpty
                ? const Center(child: Text('No employees found.'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _employees.length,
                    itemBuilder: (context, index) => _buildEmployeeCard(_employees[index]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeCard(Employee e) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Colors.deepPurple.shade100,
          child: Text(e.name[0].toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
        ),
        title: Text(e.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text('${e.designation} | ${e.department}', style: TextStyle(color: Colors.grey.shade600)),
        trailing: _buildStatusBadge(e.status),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoRow(Icons.email, 'Email', e.email),
                _buildInfoRow(Icons.phone, 'Phone', e.phone),
                _buildInfoRow(Icons.payments, 'Salary', '৳${e.salary}'),
                _buildInfoRow(Icons.calendar_today, 'Joined', DateFormat('yyyy-MM-dd').format(e.joinDate)),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _showEmployeeForm(e),
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      label: const Text('Edit', style: TextStyle(color: Colors.blue)),
                    ),
                    const SizedBox(width: 10),
                    TextButton.icon(
                      onPressed: () async {
                        if (await _employeeService.deleteEmployee(e.id!)) _loadEmployees();
                      },
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: const Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.deepPurple),
          const SizedBox(width: 10),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    bool isActive = status.toLowerCase() == 'active';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isActive ? Colors.green : Colors.red),
      ),
      child: Text(status, style: TextStyle(color: isActive ? Colors.green : Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}
