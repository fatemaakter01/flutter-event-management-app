import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../services/requirement_service.dart';

class RequirementManagementScreen extends StatefulWidget {
  const RequirementManagementScreen({super.key});

  @override
  State<RequirementManagementScreen> createState() => _RequirementManagementScreenState();
}

class _RequirementManagementScreenState extends State<RequirementManagementScreen> {
  final RequirementService _reqService = RequirementService();
  List<Requirement> _requirements = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRequirements();
  }

  Future<void> _loadRequirements() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final data = await _reqService.fetchRequirements();
      if (mounted) {
        setState(() {
          _requirements = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading requirements: $e')),
        );
      }
    }
  }

  void _showReqForm([Requirement? req]) {
    final nameController = TextEditingController(text: req?.name);
    final costController = TextEditingController(text: req?.cost.toString());
    String category = req?.category ?? 'Decoration';
    String unit = req?.unit ?? 'Pcs';
    String status = req?.status ?? 'Available';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(req == null ? 'Add Requirement' : 'Edit Requirement',
              style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(nameController, 'Requirement Name', Icons.list_alt),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: category,
                  items: ['Decoration', 'Light', 'Security', 'Stage', 'Photo', 'Sound'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (val) => setModalState(() => category = val!),
                  decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: unit,
                  items: ['Hour', 'Pcs', 'Day', 'Set'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (val) => setModalState(() => unit = val!),
                  decoration: const InputDecoration(labelText: 'Unit', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                _buildTextField(costController, 'Cost', Icons.payments_outlined, isNumber: true),
                const SizedBox(height: 5),
                DropdownButtonFormField<String>(
                  value: status,
                  items: ['Available', 'Not Available'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (val) => setModalState(() => status = val!),
                  decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
              onPressed: () async {
                final reqData = Requirement(
                  requirementId: req?.requirementId,
                  name: nameController.text,
                  category: category,
                  unit: unit,
                  cost: double.tryParse(costController.text) ?? 0.0,
                  status: status,
                );

                bool success;
                if (req == null) {
                  success = await _reqService.addRequirement(reqData);
                } else {
                  success = await _reqService.updateRequirement(req.requirementId!, reqData);
                }

                if (success) {
                  _loadRequirements();
                  if (context.mounted) Navigator.pop(context);
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Operation failed')));
                  }
                }
              },
              child: Text(req == null ? 'Save' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
        decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, color: Colors.deepPurple),
            border: const OutlineInputBorder()
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
                const Text('Items & Services', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
                  onPressed: () => _showReqForm(),
                  icon: const Icon(Icons.add),
                  label: const Text('Add New'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _requirements.isEmpty
                ? const Center(child: Text('No requirements found'))
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _requirements.length,
              itemBuilder: (context, index) {
                final r = _requirements[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.deepPurple[50],
                      child: const Icon(Icons.inventory_2_outlined, color: Colors.deepPurple),
                    ),
                    title: Text(r.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${r.category} • \$${r.cost} / ${r.unit}\nStatus: ${r.status}'),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showReqForm(r)),
                        IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete?'),
                                  content: const Text('Are you sure you want to delete this requirement?'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
                                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Yes', style: TextStyle(color: Colors.red))),
                                  ],
                                ),
                              );
                              if (confirm == true && r.requirementId != null) {
                                if (await _reqService.deleteRequirement(r.requirementId!)) {
                                  _loadRequirements();
                                }
                              }
                            }
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
