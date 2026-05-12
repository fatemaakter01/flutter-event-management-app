import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../services/booking_service.dart';
import '../../../services/venue_service.dart';
import '../../../services/catering_service.dart';
import '../../../services/requirement_service.dart';

class BookingManagementScreen extends StatefulWidget {
  const BookingManagementScreen({super.key});

  @override
  State<BookingManagementScreen> createState() => _BookingManagementScreenState();
}

class _BookingManagementScreenState extends State<BookingManagementScreen>
    with SingleTickerProviderStateMixin {
  final BookingService _bookingService = BookingService();
  final VenueService _venueService = VenueService();
  final CateringService _cateringService = CateringService();
  final RequirementService _reqService = RequirementService();

  late TabController _tabController;
  List<Booking> _bookings = [];
  List<Venue> _venues = [];
  List<CateringItem> _cateringItems = [];
  List<Requirement> _requirements = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    final bookings = await _bookingService.fetchBookings();
    final venues = await _venueService.fetchVenues();
    final catering = await _cateringService.fetchCateringItems();
    final requirements = await _reqService.fetchRequirements();

    print('Bookings loaded: ${bookings.length}');
    print('Venues loaded: ${venues.length}');
    print('Catering loaded: ${catering.length}');
    print('Requirements loaded: ${requirements.length}');

    setState(() {
      _bookings = bookings;
      _venues = venues;
      _cateringItems = catering;
      _requirements = requirements;
      _isLoading = false;
    });
  }

  Future<void> _pickDate(StateSetter setModalState, Function(String) onPicked) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      onPicked(picked.toIso8601String().split('T')[0]);
    }
  }

  Future<void> _pickTime(StateSetter setModalState, Function(String) onPicked) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      onPicked('${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}');
    }
  }

  void _showBookingForm([Booking? booking]) {
    final clientNameController = TextEditingController(text: booking?.clientName);
    final eventController = TextEditingController(text: booking?.event);
    final guestController = TextEditingController(
        text: booking?.guests == 0 ? '' : booking?.guests.toString());
    final paidController = TextEditingController(
        text: booking?.paid == 0 ? '' : booking?.paid.toString());

    String? selectedVenueName =
    booking?.venue.isEmpty == true ? null : booking?.venue;
    List<String> selectedStarters = List.from(booking?.starters ?? []);
    List<String> selectedMains = List.from(booking?.mains ?? []);
    List<String> selectedDrinks = List.from(booking?.drinks ?? []);
    List<String> selectedDesserts = List.from(booking?.desserts ?? []);
    List<String> selectedReqs = List.from(booking?.requirements ?? []);

    String paymentMethod = booking?.paymentMethod ?? 'Cash';
    String date =
        booking?.date ?? DateTime.now().toIso8601String().split('T')[0];
    String startTime = booking?.startTime ?? '10:00';
    String endTime = booking?.endTime ?? '14:00';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          double calculateTotal() {
            double venueCost = 0;
            if (selectedVenueName != null) {
              final venue = _venues.firstWhere(
                    (v) => v.name == selectedVenueName,
                orElse: () =>
                    Venue(name: '', location: '', capacity: 0, price: 0, status: ''),
              );
              venueCost = venue.price;
            }

            int guests = int.tryParse(guestController.text) ?? 0;
            double foodCost = 0;
            for (var name in [
              ...selectedStarters,
              ...selectedMains,
              ...selectedDrinks,
              ...selectedDesserts
            ]) {
              final item = _cateringItems.firstWhere(
                    (c) => c.name == name,
                orElse: () => CateringItem(
                    name: '', category: '', price: 0, type: 'Veg', status: ''),
              );
              foodCost += item.price * guests;
            }

            double reqCost = 0;
            for (var name in selectedReqs) {
              final req = _requirements.firstWhere(
                    (r) => r.name == name,
                orElse: () => Requirement(
                    name: '', category: '', unit: '', cost: 0, status: ''),
              );
              reqCost += req.cost;
            }

            return venueCost + foodCost + reqCost;
          }

          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    booking == null ? 'New Booking' : 'Edit Booking',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),

                  TextField(
                    controller: clientNameController,
                    decoration: const InputDecoration(labelText: 'Client Name'),
                  ),
                  TextField(
                    controller: eventController,
                    decoration: const InputDecoration(labelText: 'Event Name'),
                  ),
                  TextField(
                    controller: guestController,
                    decoration:
                    const InputDecoration(labelText: 'Number of Guests'),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setModalState(() {}),
                  ),

                  const SizedBox(height: 15),
                  const Text('Date & Time',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.calendar_today, size: 16),
                          label: Text(date),
                          onPressed: () => _pickDate(
                              setModalState, (v) => setModalState(() => date = v)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.access_time, size: 16),
                          label: Text('$startTime - $endTime'),
                          onPressed: () async {
                            await _pickTime(setModalState,
                                    (v) => setModalState(() => startTime = v));
                            await _pickTime(setModalState,
                                    (v) => setModalState(() => endTime = v));
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),
                  const Text('Venue',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _venues.isEmpty
                      ? const Text('No venues available',
                      style: TextStyle(color: Colors.grey))
                      : DropdownButtonFormField<String>(
                    value: selectedVenueName,
                    hint: const Text('Select Venue'),
                    items: _venues
                        .map((v) => DropdownMenuItem(
                      value: v.name,
                      child: Text('${v.name} (৳${v.price})'),
                    ))
                        .toList(),
                    onChanged: (v) =>
                        setModalState(() => selectedVenueName = v),
                    decoration: const InputDecoration(
                        border: OutlineInputBorder()),
                  ),

                  const SizedBox(height: 15),
                  const Text('Catering',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  _buildCateringChipSection(
                    'Starters',
                    _cateringItems
                        .where((i) => i.category == 'Starter')
                        .toList(),
                    selectedStarters,
                    setModalState,
                  ),
                  _buildCateringChipSection(
                    'Main Course',
                    _cateringItems
                        .where((i) => i.category == 'Main Course')
                        .toList(),
                    selectedMains,
                    setModalState,
                  ),
                  _buildCateringChipSection(
                    'Drinks',
                    _cateringItems
                        .where((i) => i.category == 'Drinks')
                        .toList(),
                    selectedDrinks,
                    setModalState,
                  ),
                  _buildCateringChipSection(
                    'Desserts',
                    _cateringItems
                        .where((i) => i.category == 'Dessert')
                        .toList(),
                    selectedDesserts,
                    setModalState,
                  ),

                  const SizedBox(height: 15),
                  const Text('Requirements',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  _requirements.isEmpty
                      ? const Text('No requirements available',
                      style: TextStyle(color: Colors.grey))
                      : Wrap(
                    spacing: 8,
                    children: _requirements.map((r) {
                      final isSelected = selectedReqs.contains(r.name);
                      return FilterChip(
                        label: Text('${r.name} (৳${r.cost})'),
                        selected: isSelected,
                        onSelected: (v) => setModalState(() =>
                        v
                            ? selectedReqs.add(r.name)
                            : selectedReqs.remove(r.name)),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 15),
                  const Text('Payment',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: paymentMethod,
                    items: ['Cash', 'Bkash', 'Nagad', 'Card']
                        .map((m) =>
                        DropdownMenuItem(value: m, child: Text(m)))
                        .toList(),
                    onChanged: (v) =>
                        setModalState(() => paymentMethod = v!),
                    decoration: const InputDecoration(
                      labelText: 'Payment Method',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: paidController,
                    decoration:
                    const InputDecoration(labelText: 'Paid Amount (৳)'),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setModalState(() {}),
                  ),

                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple[50],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Builder(builder: (_) {
                      final total = calculateTotal();
                      final paid =
                          double.tryParse(paidController.text) ?? 0;
                      final remaining = total - paid;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total: ৳${total.toStringAsFixed(0)}',
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple),
                          ),
                          Text('Paid: ৳${paid.toStringAsFixed(0)}',
                              style:
                              const TextStyle(color: Colors.green)),
                          Text(
                            'Remaining: ৳${remaining.toStringAsFixed(0)}',
                            style: TextStyle(
                                color: remaining > 0
                                    ? Colors.red
                                    : Colors.green),
                          ),
                        ],
                      );
                    }),
                  ),

                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        if (clientNameController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Client name দিন')),
                          );
                          return;
                        }
                        if (eventController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Event name দিন')),
                          );
                          return;
                        }

                        double total = calculateTotal();
                        double paid =
                            double.tryParse(paidController.text) ?? 0;

                        final newBooking = Booking(
                          id: booking?.id,
                          clientName: clientNameController.text.trim(),
                          event: eventController.text.trim(),
                          venue: selectedVenueName ?? '',
                          date: date,
                          startTime: startTime,
                          endTime: endTime,
                          guests:
                          int.tryParse(guestController.text) ?? 0,
                          starters: selectedStarters,
                          mains: selectedMains,
                          drinks: selectedDrinks,
                          desserts: selectedDesserts,
                          requirements: selectedReqs,
                          venueCost: selectedVenueName != null
                              ? _venues
                              .firstWhere(
                                  (v) => v.name == selectedVenueName,
                              orElse: () => Venue(
                                  name: '',
                                  location: '',
                                  capacity: 0,
                                  price: 0,
                                  status: ''))
                              .price
                              : 0,
                          foodCost: 0,
                          decorationCost: 0,
                          otherCost: 0,
                          total: total,
                          paid: paid,
                          remaining: total - paid,
                          paymentStatus: paid >= total
                              ? 'Paid'
                              : (paid > 0 ? 'Partial' : 'Pending'),
                          paymentMethod: paymentMethod,
                          status: paid >= total ? 'Confirmed' : 'Pending',
                        );

                        print('Saving booking: ${newBooking.toJson()}');

                        final success =
                        await _bookingService.addBooking(newBooking);
                        if (success) {
                          await _loadAllData();
                          if (mounted) Navigator.pop(context);
                        } else {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Booking save হয়নি। API check করুন।'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      child: Text(booking == null
                          ? 'Save Booking'
                          : 'Update Booking'),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCateringChipSection(
      String title,
      List<CateringItem> items,
      List<String> selectedList,
      StateSetter setModalState,
      ) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Text(title,
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ),
        Wrap(
          spacing: 8,
          children: items.map((i) {
            final isSelected = selectedList.contains(i.name);
            return FilterChip(
              label: Text('${i.name} (৳${i.price})'),
              selected: isSelected,
              onSelected: (v) => setModalState(
                    () => v
                    ? selectedList.add(i.name)
                    : selectedList.remove(i.name),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _showInvoice(Booking b) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('INVOICE',
                          style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple)),
                      Text(
                          '# INV-${b.id?.toString().padLeft(4, '0') ?? '0000'}',
                          style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: b.status == 'Confirmed'
                          ? Colors.green[50]
                          : Colors.orange[50],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: b.status == 'Confirmed'
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ),
                    child: Text(
                      b.status,
                      style: TextStyle(
                        color: b.status == 'Confirmed'
                            ? Colors.green
                            : Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const Divider(height: 30),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('BILLED TO',
                            style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(b.clientName,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('EVENT DETAILS',
                            style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(b.event,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        Text('Date: ${b.date}',
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 13)),
                        if (b.startTime.isNotEmpty)
                          Text('Time: ${b.startTime} - ${b.endTime}',
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 13)),
                        Text('Guests: ${b.guests}',
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              if (b.venue.isNotEmpty) ...[
                const Text('VENUE',
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                _invoiceRow(Icons.location_on, b.venue,
                    '৳${b.venueCost.toStringAsFixed(0)}'),
                const SizedBox(height: 16),
              ],

              if (b.starters.isNotEmpty ||
                  b.mains.isNotEmpty ||
                  b.drinks.isNotEmpty ||
                  b.desserts.isNotEmpty) ...[
                const Text('CATERING',
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                if (b.starters.isNotEmpty)
                  _invoiceCategoryRow('Starters', b.starters),
                if (b.mains.isNotEmpty)
                  _invoiceCategoryRow('Main Course', b.mains),
                if (b.drinks.isNotEmpty)
                  _invoiceCategoryRow('Drinks', b.drinks),
                if (b.desserts.isNotEmpty)
                  _invoiceCategoryRow('Desserts', b.desserts),
                const SizedBox(height: 16),
              ],

              if (b.requirements.isNotEmpty) ...[
                const Text('REQUIREMENTS',
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                _invoiceCategoryRow('Items', b.requirements),
                const SizedBox(height: 16),
              ],

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  children: [
                    _summaryRow('Venue Cost',
                        '৳${b.venueCost.toStringAsFixed(0)}'),
                    _summaryRow('Food Cost',
                        '৳${b.foodCost.toStringAsFixed(0)}'),
                    if (b.decorationCost > 0)
                      _summaryRow('Decoration',
                          '৳${b.decorationCost.toStringAsFixed(0)}'),
                    if (b.otherCost > 0)
                      _summaryRow(
                          'Other', '৳${b.otherCost.toStringAsFixed(0)}'),
                    const Divider(),
                    _summaryRow('Total', '৳${b.total.toStringAsFixed(0)}',
                        bold: true, color: Colors.deepPurple),
                    _summaryRow('Paid', '৳${b.paid.toStringAsFixed(0)}',
                        bold: true, color: Colors.green),
                    _summaryRow(
                        'Remaining', '৳${b.remaining.toStringAsFixed(0)}',
                        bold: true,
                        color:
                        b.remaining > 0 ? Colors.red : Colors.green),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.deepPurple[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Payment Method',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey)),
                        Text(
                            b.paymentMethod.isNotEmpty
                                ? b.paymentMethod
                                : 'N/A',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Payment Status',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey)),
                        Text(
                          b.paymentStatus,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: b.paymentStatus == 'Paid'
                                ? Colors.green
                                : b.paymentStatus == 'Partial'
                                ? Colors.orange
                                : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _invoiceRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 6),
          Expanded(
              child: Text(label, style: const TextStyle(fontSize: 14))),
          Text(value,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _invoiceCategoryRow(String category, List<String> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(category,
                style:
                TextStyle(fontSize: 13, color: Colors.grey[600])),
          ),
          Expanded(
            child: Text(items.join(', '),
                style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value,
      {bool bold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontWeight:
                  bold ? FontWeight.bold : FontWeight.normal,
                  fontSize: bold ? 15 : 14)),
          Text(value,
              style: TextStyle(
                  fontWeight:
                  bold ? FontWeight.bold : FontWeight.normal,
                  fontSize: bold ? 15 : 14,
                  color: color)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: Colors.deepPurple,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.deepPurple,
            tabs: const [
              Tab(text: 'Confirmed'),
              Tab(text: 'Pending'),
            ],
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: [
          _buildBookingList('Confirmed'),
          _buildBookingList('Pending'),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showBookingForm(),
        label: const Text('New Booking'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildBookingList(String status) {
    final filteredList =
    _bookings.where((b) => b.status == status).toList();
    if (filteredList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 10),
            Text('No $status bookings',
                style: TextStyle(color: Colors.grey[400])),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        final b = filteredList[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 5),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: status == 'Confirmed'
                  ? Colors.green[50]
                  : Colors.orange[50],
              child: Icon(
                Icons.receipt,
                color: status == 'Confirmed'
                    ? Colors.green
                    : Colors.orange,
              ),
            ),
            title: Text(b.event,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
              'Client: ${b.clientName}\nVenue: ${b.venue} | Date: ${b.date}\nTotal: ৳${b.total.toStringAsFixed(0)} | Paid: ৳${b.paid.toStringAsFixed(0)}',
            ),
            isThreeLine: true,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.receipt_long,
                      color: Colors.deepPurple),
                  onPressed: () => _showInvoice(b),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.red),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Delete Booking?'),
                        content: Text(
                            '${b.clientName} এর booking delete করবেন?'),
                        actions: [
                          TextButton(
                              onPressed: () =>
                                  Navigator.pop(ctx, false),
                              child: const Text('Cancel')),
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(ctx, true),
                            child: const Text('Delete',
                                style:
                                TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true && b.id != null) {
                      if (await _bookingService.deleteBooking(b.id!))
                        _loadAllData();
                    }
                  },
                ),
              ],
            ),
            onTap: () => _showBookingForm(b),
          ),
        );
      },
    );
  }
}