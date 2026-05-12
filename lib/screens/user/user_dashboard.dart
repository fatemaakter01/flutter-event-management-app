import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/models.dart';
import '../../services/venue_service.dart';
import '../../services/catering_service.dart';
import '../../services/requirement_service.dart';
import '../../services/booking_service.dart';
import '../login_screen.dart';

class UserDashboard extends StatefulWidget {
  final String userEmail;
  const UserDashboard({super.key, required this.userEmail});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  int _selectedIndex = 0;

  final VenueService _venueService = VenueService();
  final CateringService _cateringService = CateringService();
  final RequirementService _reqService = RequirementService();
  final BookingService _bookingService = BookingService();

  List<Venue> _venues = [];
  List<CateringItem> _cateringItems = [];
  List<Requirement> _requirements = [];
  List<Booking> _myBookings = [];
  bool _isLoading = true;

  final List<Map<String, dynamic>> _sidebarItems = [
    {'icon': Icons.explore, 'label': 'Explore Venues'},
    {'icon': Icons.restaurant_menu, 'label': 'Catering Menu'},
    {'icon': Icons.build_circle_outlined, 'label': 'Extra Services'},
    {'icon': Icons.book_online, 'label': 'My Bookings'},
  ];

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final venues = await _venueService.fetchVenues();
      final catering = await _cateringService.fetchCateringItems();
      final reqs = await _reqService.fetchRequirements();
      final allBookings = await _bookingService.fetchBookings();

      if (mounted) {
        setState(() {
          _venues = venues;
          _cateringItems = catering;
          _requirements = reqs;
          _myBookings = allBookings.where((b) => b.clientName == widget.userEmail).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple.shade900, Colors.blue.shade900],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40, color: Colors.deepPurple),
            ),
            accountName: const Text('Fatema User', style: TextStyle(fontWeight: FontWeight.bold)),
            accountEmail: Text(widget.userEmail),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: _sidebarItems.length,
              itemBuilder: (context, index) {
                final item = _sidebarItems[index];
                final isSelected = _selectedIndex == index;
                return ListTile(
                  leading: Icon(item['icon'], color: isSelected ? Colors.deepPurple : Colors.grey),
                  title: Text(item['label'],
                      style: TextStyle(
                          color: isSelected ? Colors.deepPurple : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
                      )
                  ),
                  selected: isSelected,
                  onTap: () {
                    setState(() => _selectedIndex = index);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text('Logout', style: TextStyle(color: Colors.redAccent)),
            onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_sidebarItems[_selectedIndex]['label'], style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadAllData),
        ],
      ),
      drawer: _buildDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildMainArea(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showBookingForm(),
        backgroundColor: Colors.deepPurple,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Book Now', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildMainArea() {
    switch (_selectedIndex) {
      case 0: return _buildVenuesPage();
      case 1: return _buildCateringPage();
      case 2: return _buildRequirementsPage();
      case 3: return _buildMyBookingsPage();
      default: return _buildVenuesPage();
    }
  }

  Widget _buildVenuesPage() {
    return _venues.isEmpty
        ? const Center(child: Text('No venues available'))
        : GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _venues.length,
      itemBuilder: (context, i) => _venueCard(_venues[i]),
    );
  }

  Widget _venueCard(Venue v) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 80,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.deepPurple.shade200, Colors.blue.shade200]),
            ),
            child: const Icon(Icons.business, size: 35, color: Colors.white),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(v.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(v.location, style: const TextStyle(fontSize: 10, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const Spacer(),
                  Text('৳${v.price.toStringAsFixed(0)}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 5),
                  SizedBox(
                    width: double.infinity,
                    height: 28,
                    child: ElevatedButton(
                      onPressed: () => _showBookingForm(v),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, padding: EdgeInsets.zero),
                      child: const Text('Book', style: TextStyle(fontSize: 11, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCateringPage() {
    final categories = _cateringItems.map((i) => i.category).toSet().toList();
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        final items = _cateringItems.where((i) => i.category == cat).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(cat, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2.8,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8
              ),
              itemCount: items.length,
              itemBuilder: (context, i) => _cateringCard(items[i]),
            ),
            const SizedBox(height: 10),
          ],
        );
      },
    );
  }

  Widget _cateringCard(CateringItem item) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            Icon(item.type == 'Veg' ? Icons.eco : Icons.lunch_dining, size: 16, color: item.type == 'Veg' ? Colors.green : Colors.red),
            const SizedBox(width: 5),
            Expanded(
              child: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            Text('৳${item.price.toStringAsFixed(0)}', style: const TextStyle(color: Colors.green, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirementsPage() {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2.4,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10
      ),
      itemCount: _requirements.length,
      itemBuilder: (context, i) => _requirementCard(_requirements[i]),
    );
  }

  Widget _requirementCard(Requirement r) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(r.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), maxLines: 1),
            Text('৳${r.cost.toStringAsFixed(0)} / ${r.unit}', style: const TextStyle(color: Colors.green, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildMyBookingsPage() {
    return _myBookings.isEmpty
        ? const Center(child: Text('No bookings found for you.'))
        : ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _myBookings.length,
      itemBuilder: (context, i) {
        final b = _myBookings[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: [
              ListTile(
                title: Text(b.event, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Venue: ${b.venue}'),
                    Text('Date: ${b.date}'),
                    Text('Time: ${b.startTime} - ${b.endTime}'),
                    Text('Total: ৳${b.total}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                  ],
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: b.status == 'Confirmed' ? Colors.green.shade100 : Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(20)
                  ),
                  child: Text(b.status, style: TextStyle(color: b.status == 'Confirmed' ? Colors.green.shade800 : Colors.orange.shade800, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _showInvoice(b),
                      icon: const Icon(Icons.receipt_long, size: 16),
                      label: const Text('View Invoice'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey, foregroundColor: Colors.white),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  void _showInvoice(Booking b) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Center(child: Text('BOOKING INVOICE', style: TextStyle(fontWeight: FontWeight.bold))),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(thickness: 2),
              Text('Invoice To: ${b.clientName}'),
              Text('Occasion: ${b.event}'),
              const SizedBox(height: 10),
              Text('Venue: ${b.venue}'),
              Text('Date: ${b.date}'),
              Text('Time Slot: ${b.startTime} - ${b.endTime}'),
              const SizedBox(height: 10),
              const Text('Summary of Charges:', style: TextStyle(fontWeight: FontWeight.bold)),
              const Divider(),
              _invoiceRow('Food Items', 'Starters, Mains, etc'),
              _invoiceRow('Services', 'Decoration, Security, etc'),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('GRAND TOTAL:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('৳${b.total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('PAID (Full):', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  Text('৳${b.paid.toStringAsFixed(2)}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 15),
              const Center(child: Text('Thank you for choosing EventPro!', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey))),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  Widget _invoiceRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          Text(value, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  void _showBookingForm([Venue? initialVenue]) {
    final eventController = TextEditingController();
    final guestController = TextEditingController(text: '50');
    final bkashController = TextEditingController();
    final nagadController = TextEditingController();
    final bankNameController = TextEditingController();
    final bankAccController = TextEditingController();

    String? selectedVenueName = initialVenue?.name;
    List<String> selectedStarters = [];
    List<String> selectedMains = [];
    List<String> selectedDrinks = [];
    List<String> selectedDesserts = [];
    List<String> selectedReqs = [];

    String paymentMethod = 'Bkash';
    DateTime selectedDate = DateTime.now().add(const Duration(days: 7));
    String startTime = '10:00';
    String endTime = '18:00';

    bool isSlotChecked = false;
    bool isSlotAvailable = false;
    String statusMsg = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {

          Future<void> checkAvailability() async {
            if (selectedVenueName == null) {
              setModalState(() => statusMsg = "Please select a venue first.");
              return;
            }

            final allBookings = await _bookingService.fetchBookings();
            final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);

            bool overlap = allBookings.any((b) =>
            b.venue == selectedVenueName &&
                b.date == dateStr &&
                !( (endTime.compareTo(b.startTime) <= 0) || (startTime.compareTo(b.endTime) >= 0) )
            );

            setModalState(() {
              isSlotChecked = true;
              isSlotAvailable = !overlap;
              statusMsg = overlap
                  ? "This slot is already booked. Please select another venue or a different time/date."
                  : "The slot is available! You can proceed with booking.";
            });
          }

          double calculateFoodCost() {
            double fCost = 0;
            int guests = int.tryParse(guestController.text) ?? 0;
            for (var name in [...selectedStarters, ...selectedMains, ...selectedDrinks, ...selectedDesserts]) {
              fCost += (_cateringItems.firstWhere((c) => c.name == name, orElse: () => CateringItem(name: '', category: '', price: 0, type: '', status: '')).price * guests);
            }
            return fCost;
          }

          double calculateReqCost() {
            double rCost = 0;
            for (var name in selectedReqs) {
              rCost += _requirements.firstWhere((r) => r.name == name, orElse: () => Requirement(name: '', category: '', unit: '', cost: 0, status: '')).cost;
            }
            return rCost;
          }

          double calculateTotal() {
            double vCost = selectedVenueName != null
                ? _venues.firstWhere((v) => v.name == selectedVenueName, orElse: () => Venue(name: '', location: '', capacity: 0, price: 0, status: '')).price
                : 0;
            return vCost + calculateFoodCost() + calculateReqCost();
          }

          return Container(
            height: MediaQuery.of(context).size.height * 0.9,
            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
            padding: const EdgeInsets.all(25),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Plan Your Event', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                  const SizedBox(height: 20),

                  // Availability Check Section
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade300)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Before you booking, make sure that the slot is unbooked.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          value: selectedVenueName,
                          decoration: const InputDecoration(labelText: 'Select Venue', border: OutlineInputBorder()),
                          items: _venues.map((v) => DropdownMenuItem(value: v.name, child: Text(v.name))).toList(),
                          onChanged: (v) => setModalState(() { selectedVenueName = v; isSlotChecked = false; }),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextButton.icon(
                                onPressed: () async {
                                  final picked = await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime.now(), lastDate: DateTime(2030));
                                  if (picked != null) setModalState(() { selectedDate = picked; isSlotChecked = false; });
                                },
                                icon: const Icon(Icons.calendar_today),
                                label: Text(DateFormat('yyyy-MM-dd').format(selectedDate)),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () async {
                                  final t = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 10, minute: 0));
                                  if (t != null) setModalState(() { startTime = "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}"; isSlotChecked = false; });
                                },
                                child: Text('Start: $startTime'),
                              ),
                            ),
                            Expanded(
                              child: TextButton(
                                onPressed: () async {
                                  final t = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 18, minute: 0));
                                  if (t != null) setModalState(() { endTime = "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}"; isSlotChecked = false; });
                                },
                                child: Text('End: $endTime'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: checkAvailability,
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                            child: const Text('Check Availability', style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        if (isSlotChecked) ...[
                          const SizedBox(height: 12),
                          Text(statusMsg, textAlign: TextAlign.center, style: TextStyle(color: isSlotAvailable ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 13)),
                        ]
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),
                  TextField(controller: eventController, decoration: const InputDecoration(labelText: 'Event Occasion (e.g. Wedding)', border: OutlineInputBorder())),
                  const SizedBox(height: 15),
                  TextField(controller: guestController, decoration: const InputDecoration(labelText: 'Estimated Guests', border: OutlineInputBorder()), keyboardType: TextInputType.number, onChanged: (_) => setModalState(() {})),

                  _buildSelectionSection('Starters', 'Starter', selectedStarters, setModalState),
                  _buildSelectionSection('Main Course', 'Main Course', selectedMains, setModalState),
                  _buildSelectionSection('Requirements', null, selectedReqs, setModalState, isReq: true),

                  const SizedBox(height: 25),
                  const Text('Select Payment Method', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: paymentMethod,
                    items: ['Bkash', 'Nagad', 'Bank'].map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                    onChanged: (v) => setModalState(() => paymentMethod = v!),
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 15),

                  // Conditional Payment Fields
                  if (paymentMethod == 'Bkash')
                    TextField(controller: bkashController, decoration: const InputDecoration(labelText: 'Bkash Number', border: OutlineInputBorder(), prefixIcon: Icon(Icons.phone_android))),
                  if (paymentMethod == 'Nagad')
                    TextField(controller: nagadController, decoration: const InputDecoration(labelText: 'Nagad Number', border: OutlineInputBorder(), prefixIcon: Icon(Icons.phone_android))),
                  if (paymentMethod == 'Bank') ...[
                    TextField(controller: bankNameController, decoration: const InputDecoration(labelText: 'Bank Name', border: OutlineInputBorder(), prefixIcon: Icon(Icons.account_balance))),
                    const SizedBox(height: 10),
                    TextField(controller: bankAccController, decoration: const InputDecoration(labelText: 'Bank Account Number', border: OutlineInputBorder(), prefixIcon: Icon(Icons.numbers))),
                  ],

                  const SizedBox(height: 30),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: Colors.deepPurple.shade700, borderRadius: BorderRadius.circular(15)),
                    child: Column(
                      children: [
                        Text('Grand Total: ৳${calculateTotal().toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                        const Text('Note: Full payment is mandatory to confirm booking.', style: TextStyle(color: Colors.white70, fontSize: 11)),
                        const SizedBox(height: 15),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.deepPurple, minimumSize: const Size(double.infinity, 50)),
                          onPressed: () async {
                            if (!isSlotAvailable) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please verify slot availability first.')));
                              return;
                            }
                            if (eventController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter event occasion.')));
                              return;
                            }

                            // Check payment fields
                            if (paymentMethod == 'Bkash' && bkashController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter Bkash number.')));
                              return;
                            }
                            if (paymentMethod == 'Nagad' && nagadController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter Nagad number.')));
                              return;
                            }
                            if (paymentMethod == 'Bank' && (bankNameController.text.isEmpty || bankAccController.text.isEmpty)) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter bank details.')));
                              return;
                            }

                            double total = calculateTotal();
                            double venueCost = selectedVenueName != null
                                ? _venues.firstWhere((v) => v.name == selectedVenueName).price
                                : 0;

                            final b = Booking(
                              clientName: widget.userEmail,
                              event: eventController.text,
                              venue: selectedVenueName ?? '',
                              date: DateFormat('yyyy-MM-dd').format(selectedDate),
                              startTime: startTime, endTime: endTime,
                              guests: int.tryParse(guestController.text) ?? 0,
                              starters: selectedStarters, mains: selectedMains, drinks: selectedDrinks, desserts: selectedDesserts,
                              requirements: selectedReqs,
                              venueCost: venueCost,
                              foodCost: calculateFoodCost(),
                              decorationCost: calculateReqCost(),
                              otherCost: 0,
                              total: total, paid: total, remaining: 0,
                              paymentStatus: 'Paid', paymentMethod: paymentMethod, status: 'Confirmed',
                              bkashNumber: paymentMethod == 'Bkash' ? bkashController.text : null,
                              nagadNumber: paymentMethod == 'Nagad' ? nagadController.text : null,
                              bankName: paymentMethod == 'Bank' ? bankNameController.text : null,
                              bankAccountNumber: paymentMethod == 'Bank' ? bankAccController.text : null,
                            );

                            try {
                              bool success = await _bookingService.addBooking(b);
                              if (success) {
                                Navigator.pop(context);
                                _loadAllData();
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking Confirmed Successfully!')));
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to add booking. Please try again.')));
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                            }
                          },
                          child: const Text('Confirm & Pay Full Amount', style: TextStyle(fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSelectionSection(String title, String? category, List<String> selectedList, StateSetter setModalState, {bool isReq = false}) {
    final items = isReq ? _requirements.map((r) => r.name).toList() : _cateringItems.where((i) => i.category == category).map((i) => i.name).toList();
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 15),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        Wrap(
          spacing: 8,
          children: items.map((name) {
            final isSelected = selectedList.contains(name);
            return FilterChip(
              label: Text(name, style: const TextStyle(fontSize: 12)),
              selected: isSelected,
              onSelected: (v) => setModalState(() => v ? selectedList.add(name) : selectedList.remove(name)),
            );
          }).toList(),
        ),
      ],
    );
  }
}
