import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../services/venue_service.dart';

class VenueManagementScreen extends StatefulWidget {
  const VenueManagementScreen({super.key});

  @override
  State<VenueManagementScreen> createState() => _VenueManagementScreenState();
}

class _VenueManagementScreenState extends State<VenueManagementScreen> {
  final VenueService _venueService = VenueService();
  List<Venue> _venues = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVenues();
  }

  Future<void> _loadVenues() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final data = await _venueService.fetchVenues();
      if (mounted) {
        setState(() {
          _venues = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading venues: $e')),
        );
      }
    }
  }

  void _showVenueForm([Venue? venue]) {
    final nameController = TextEditingController(text: venue?.name);
    final locationController = TextEditingController(text: venue?.location);
    final capacityController = TextEditingController(text: venue?.capacity.toString());
    final priceController = TextEditingController(text: venue?.price.toString());
    String status = venue?.status ?? 'Available';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(venue == null ? 'Add New Venue' : 'Edit Venue', 
            style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(nameController, 'Venue Name', Icons.location_city),
                _buildTextField(locationController, 'Location', Icons.map),
                _buildTextField(capacityController, 'Capacity', Icons.people_outline, isNumber: true),
                _buildTextField(priceController, 'Price', Icons.payments_outlined, isNumber: true),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: status,
                  items: ['Available', 'Booked', 'Maintenance'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (val) => setModalState(() => status = val!),
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
                final newVenue = Venue(
                  id: venue?.id,
                  name: nameController.text,
                  location: locationController.text,
                  capacity: double.tryParse(capacityController.text) ?? 0.0,
                  price: double.tryParse(priceController.text) ?? 0.0,
                  status: status,
                );
                
                bool success;
                if (venue == null) {
                  success = await _venueService.addVenue(newVenue);
                } else {
                  success = await _venueService.updateVenue(venue.id!, newVenue);
                }

                if (success) {
                  _loadVenues();
                  if (context.mounted) Navigator.pop(context);
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to save venue')),
                    );
                  }
                }
              },
              child: Text(venue == null ? 'Save' : 'Update'),
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
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _venues.isEmpty
          ? const Center(child: Text('No venues found'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _venues.length,
              itemBuilder: (context, index) {
                final v = _venues[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.deepPurple[50], borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.location_on, color: Colors.deepPurple, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(v.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                              Text('${v.location} • Cap: ${v.capacity}', style: TextStyle(color: Colors.grey[600])),
                              Text('\$${v.price}', style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue), 
                              onPressed: () => _showVenueForm(v)
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red), 
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Confirm Delete'),
                                    content: const Text('Are you sure you want to delete this venue?'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                      TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                                    ],
                                  ),
                                );
                                if (confirm == true && v.id != null) {
                                  if (await _venueService.deleteVenue(v.id!)) {
                                    _loadVenues();
                                  }
                                }
                              }
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.deepPurple,
        onPressed: () => _showVenueForm(),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Venue', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
