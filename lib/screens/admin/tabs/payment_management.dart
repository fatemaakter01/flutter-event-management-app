import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../services/payment_service.dart';
import '../../../services/booking_service.dart';
import 'package:intl/intl.dart';

class PaymentManagementScreen extends StatefulWidget {
  const PaymentManagementScreen({super.key});

  @override
  State<PaymentManagementScreen> createState() => _PaymentManagementScreenState();
}

class _PaymentManagementScreenState extends State<PaymentManagementScreen> {
  final PaymentService _paymentService = PaymentService();
  final BookingService _bookingService = BookingService();
  List<Booking> _pendingBookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPendingBookings();
  }

  Future<void> _loadPendingBookings() async {
    setState(() => _isLoading = true);
    final allBookings = await _bookingService.fetchBookings();
    setState(() {
      // Filter bookings that are not fully paid
      _pendingBookings = allBookings.where((b) => b.status == 'Pending' || b.remaining > 0).toList();
      _isLoading = false;
    });
  }

  void _showPaymentForm(Booking booking) {
    final amountController = TextEditingController(text: booking.remaining.toString());
    final noteController = TextEditingController();
    String paymentMethod = 'Cash';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: Text('Process Payment for ${booking.clientName}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Total Due: \$${booking.remaining}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                const SizedBox(height: 15),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(labelText: 'Payment Amount', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: paymentMethod,
                  items: ['Cash', 'Bkash', 'Nagad', 'Bank Transfer', 'Card'].map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                  onChanged: (v) => setModalState(() => paymentMethod = v!),
                  decoration: const InputDecoration(labelText: 'Payment Method', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: noteController,
                  decoration: const InputDecoration(labelText: 'Note (Optional)', border: OutlineInputBorder()),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                double amount = double.tryParse(amountController.text) ?? 0;
                if (amount <= 0) return;

                final p = Payment(
                  amount: amount,
                  paymentType: amount >= booking.remaining ? 'Full' : 'Partial',
                  paymentMethod: paymentMethod,
                  paymentDate: DateTime.now(),
                  note: noteController.text,
                );

                if (booking.id != null && await _paymentService.addPayment(booking.id!, p)) {
                  _loadPendingBookings();
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text('Confirm Payment'),
            ),
          ],
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
          : _pendingBookings.isEmpty
              ? const Center(child: Text('No pending payments found.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _pendingBookings.length,
                  itemBuilder: (context, index) {
                    final b = _pendingBookings[index];
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: ListTile(
                        leading: const CircleAvatar(backgroundColor: Colors.orange, child: Icon(Icons.payment, color: Colors.white)),
                        title: Text(b.clientName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Event: ${b.event}\nTotal: \$${b.total} | Remaining: \$${b.remaining}'),
                        trailing: ElevatedButton(
                          onPressed: () => _showPaymentForm(b),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                          child: const Text('Pay Now'),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
