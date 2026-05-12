import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/models.dart';
import '../../../services/event_service.dart';
import '../../../services/venue_service.dart';

class EventManagementScreen extends StatefulWidget {
  const EventManagementScreen({super.key});

  @override
  State<EventManagementScreen> createState() => _EventManagementScreenState();
}

class _EventManagementScreenState extends State<EventManagementScreen> {
  final EventService _eventService = EventService();
  final VenueService _venueService = VenueService();
  List<Event> _events = [];
  List<Venue> _venues = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final events = await _eventService.fetchEvents();
      final venues = await _venueService.fetchVenues();
      if (mounted) {
        setState(() {
          _events = events;
          _venues = venues;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  void _showEventForm([Event? event]) {
    final titleController = TextEditingController(text: event?.eventTitle);
    final typeController = TextEditingController(text: event?.eventType);

    int? selectedVenueId = event?.venue?.id;
    DateTime eventDate = event?.eventDate ?? DateTime.now();
    String startTime = event?.startTime ?? '09:00';
    String endTime = event?.endTime ?? '17:00';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(event == null ? 'Schedule New Event' : 'Edit Event',
              style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(titleController, 'Event Title', Icons.title),
                _buildTextField(typeController, 'Event Type (e.g. Wedding)', Icons.category),

                DropdownButtonFormField<int>(
                  value: selectedVenueId,
                  hint: const Text('Select Venue'),
                  items: _venues.map((v) => DropdownMenuItem(value: v.id, child: Text(v.name))).toList(),
                  onChanged: (val) => setModalState(() => selectedVenueId = val),
                  decoration: InputDecoration(
                    labelText: 'Venue',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    prefixIcon: const Icon(Icons.location_on_outlined),
                  ),
                ),
                const SizedBox(height: 10),

                ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: Colors.grey[400]!)),
                  title: Text('Date: ${DateFormat('yyyy-MM-dd').format(eventDate)}'),
                  trailing: const Icon(Icons.calendar_today, color: Colors.deepPurple, size: 20),
                  onTap: () async {
                    final picked = await showDatePicker(
                        context: context,
                        initialDate: eventDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030)
                    );
                    if (picked != null) setModalState(() => eventDate = picked);
                  },
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        title: Text('Start: $startTime'),
                        onTap: () async {
                          final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay(
                                  hour: int.parse(startTime.split(':')[0]),
                                  minute: int.parse(startTime.split(':')[1])
                              )
                          );
                          if (time != null) setModalState(() => startTime = "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}");
                        },
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        title: Text('End: $endTime'),
                        onTap: () async {
                          final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay(
                                  hour: int.parse(endTime.split(':')[0]),
                                  minute: int.parse(endTime.split(':')[1])
                              )
                          );
                          if (time != null) setModalState(() => endTime = "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}");
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
              onPressed: () async {
                if (selectedVenueId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a venue')));
                  return;
                }

                final selectedVenue = _venues.firstWhere((v) => v.id == selectedVenueId);

                final eventData = Event(
                  eventId: event?.eventId,
                  eventTitle: titleController.text,
                  eventType: typeController.text,
                  eventDate: eventDate,
                  startTime: startTime,
                  endTime: endTime,
                  venue: selectedVenue,
                );

                bool success;
                if (event == null) {
                  success = await _eventService.addEvent(eventData);
                } else {
                  success = await _eventService.updateEvent(event.eventId!, eventData);
                }

                if (success) {
                  _loadData();
                  if (context.mounted) Navigator.pop(context);
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to save event')),
                    );
                  }
                }
              },
              child: Text(event == null ? 'Schedule' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
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
          : _events.isEmpty
          ? const Center(child: Text('No events scheduled'))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _events.length,
        itemBuilder: (context, index) {
          final e = _events[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.deepPurple,
                child: Icon(Icons.event_note, color: Colors.white),
              ),
              title: Text(e.eventTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Venue: ${e.venue?.name ?? "N/A"}\nDate: ${DateFormat('yyyy-MM-dd').format(e.eventDate)} (${e.startTime} - ${e.endTime})'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _showEventForm(e),
                  ),
                  IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirm Delete'),
                            content: const Text('Are you sure you want to delete this event?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                            ],
                          ),
                        );
                        if (confirm == true && e.eventId != null) {
                          if (await _eventService.deleteEvent(e.eventId!)) {
                            _loadData();
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
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.deepPurple,
        onPressed: () => _showEventForm(),
        label: const Text('Schedule Event', style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}