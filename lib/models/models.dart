import 'dart:convert';
import 'package:intl/intl.dart';

class Employee {
  int? id;
  String name;
  String email;
  String phone;
  String designation;
  String department;
  DateTime joinDate;
  double salary;
  String status;

  Employee({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.designation,
    required this.department,
    required this.joinDate,
    required this.salary,
    required this.status,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      designation: json['designation'] ?? '',
      department: json['department'] ?? '',
      joinDate: json['joinDate'] != null ? DateTime.parse(json['joinDate']) : DateTime.now(),
      salary: (json['salary'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'designation': designation,
      'department': department,
      'joinDate': joinDate.toIso8601String().split('T')[0],
      'salary': salary,
      'status': status,
    };
  }
}

class Venue {
  int? id;
  String name;
  String location;
  double capacity;
  double price;
  String status;

  Venue({
    this.id,
    required this.name,
    required this.location,
    required this.capacity,
    required this.price,
    required this.status,
  });

  factory Venue.fromJson(Map<String, dynamic> json) {
    return Venue(
      id: json['id'],
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      capacity: (json['capacity'] as num?)?.toDouble() ?? 0.0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'location': location,
      'capacity': capacity,
      'price': price,
      'status': status,
    };
  }
}

class Event {
  int? eventId;
  String eventTitle;
  String eventType;
  DateTime eventDate;
  String startTime;
  String endTime;
  Venue? venue;

  Event({
    this.eventId,
    required this.eventTitle,
    required this.eventType,
    required this.eventDate,
    required this.startTime,
    required this.endTime,
    this.venue,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      eventId: json['eventId'],
      eventTitle: json['eventTitle'] ?? '',
      eventType: json['eventType'] ?? '',
      eventDate: json['eventDate'] != null ? DateTime.parse(json['eventDate']) : DateTime.now(),
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      venue: json['venue'] != null ? Venue.fromJson(json['venue']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    return {
      if (eventId != null) 'eventId': eventId,
      'eventTitle': eventTitle,
      'eventType': eventType,
      'eventDate': formatter.format(eventDate),
      'startTime': startTime,
      'endTime': endTime,
      if (venue != null) 'venue': venue!.toJson(),
    };
  }
}

class Requirement {
  int? requirementId;
  String name;
  String category;
  String unit;
  double cost;
  String status;
  String? createdAt;

  Requirement({
    this.requirementId,
    required this.name,
    required this.category,
    required this.unit,
    required this.cost,
    required this.status,
    this.createdAt,
  });

  factory Requirement.fromJson(Map<String, dynamic> json) {
    return Requirement(
      requirementId: json['requirementId'],
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      unit: json['unit'] ?? '',
      cost: (json['cost'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? '',
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (requirementId != null) 'requirementId': requirementId,
      'name': name,
      'category': category,
      'unit': unit,
      'cost': cost,
      'status': status,
    };
  }
}

class CateringItem {
  int? cateringId;
  String name;
  String category;
  double price;
  String type;
  String status;
  String? createdAt;

  CateringItem({
    this.cateringId,
    required this.name,
    required this.category,
    required this.price,
    required this.type,
    required this.status,
    this.createdAt,
  });

  factory CateringItem.fromJson(Map<String, dynamic> json) {
    return CateringItem(
      cateringId: json['cateringId'],
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      type: json['type'] ?? 'Veg',
      status: json['status'] ?? '',
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (cateringId != null) 'cateringId': cateringId,
      'name': name,
      'category': category,
      'price': price,
      'type': type,
      'status': status,
    };
  }
}

class Booking {
  int? id;
  String clientName;
  String event;
  String venue;
  String date;
  String startTime;
  String endTime;
  int guests;

  List<String> starters;
  List<String> mains;
  List<String> drinks;
  List<String> desserts;
  List<String> requirements;

  double venueCost;
  double foodCost;
  double decorationCost;
  double otherCost;
  double total;
  double paid;
  double remaining;

  String paymentStatus;
  String paymentMethod;
  String status;

  String? bkashNumber;
  String? nagadNumber;
  String? bankName;
  String? bankAccountNumber;
  String? bookingFromNumber;
  String? bookingType;
  String? createdAt;

  Booking({
    this.id,
    required this.clientName,
    required this.event,
    required this.venue,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.guests,
    required this.starters,
    required this.mains,
    required this.drinks,
    required this.desserts,
    required this.requirements,
    required this.venueCost,
    required this.foodCost,
    required this.decorationCost,
    required this.otherCost,
    required this.total,
    required this.paid,
    required this.remaining,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.status,
    this.bkashNumber,
    this.nagadNumber,
    this.bankName,
    this.bankAccountNumber,
    this.bookingFromNumber,
    this.bookingType,
    this.createdAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    List<String> parseList(dynamic value) {
      if (value == null) return [];
      if (value is String) {
        try {
          final decoded = jsonDecode(value);
          if (decoded is List) {
            return decoded
                .map((e) => e is Map ? (e['name'] ?? '').toString() : e.toString())
                .toList();
          }
        } catch (_) {}
        return [value];
      }
      if (value is List) {
        return value
            .map((e) => e is Map ? (e['name'] ?? '').toString() : e.toString())
            .toList();
      }
      return [];
    }

    return Booking(
      id: json['id'],
      clientName: json['clientName'] ?? '',
      event: json['event'] ?? '',
      venue: json['venue'] is Map
          ? (json['venue']['name'] ?? '')
          : (json['venue'] ?? ''),
      date: json['date'] ?? '',
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      guests: json['guests'] ?? 0,
      starters: parseList(json['starters']),
      mains: parseList(json['mains']),
      drinks: parseList(json['drinks']),
      desserts: parseList(json['desserts']),
      requirements: parseList(json['requirements']),
      venueCost: (json['venueCost'] as num?)?.toDouble() ?? 0.0,
      foodCost: (json['foodCost'] as num?)?.toDouble() ?? 0.0,
      decorationCost: (json['decorationCost'] as num?)?.toDouble() ?? 0.0,
      otherCost: (json['otherCost'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      paid: (json['paid'] as num?)?.toDouble() ?? 0.0,
      remaining: (json['remaining'] as num?)?.toDouble() ?? 0.0,
      paymentStatus: json['paymentStatus'] ?? '',
      paymentMethod: json['paymentMethod'] ?? '',
      status: json['status'] ?? '',
      bkashNumber: json['bkashNumber'],
      nagadNumber: json['nagadNumber'],
      bankName: json['bankName'],
      bankAccountNumber: json['bankAccountNumber'],
      bookingFromNumber: json['bookingFromNumber'],
      bookingType: json['bookingType'],
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'clientName': clientName,
      'event': event,
      'venue': {'name': venue},
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'guests': guests,
      'starters': starters.map((name) => {'name': name}).toList(),
      'mains': mains.map((name) => {'name': name}).toList(),
      'drinks': drinks.map((name) => {'name': name}).toList(),
      'desserts': desserts.map((name) => {'name': name}).toList(),
      'requirements': requirements.map((name) => {'name': name}).toList(),
      'venueCost': venueCost,
      'foodCost': foodCost,
      'decorationCost': decorationCost,
      'otherCost': otherCost,
      'total': total,
      'paid': paid,
      'remaining': remaining,
      'paymentStatus': paymentStatus,
      'paymentMethod': paymentMethod,
      'status': status,
      'bkashNumber': bkashNumber,
      'nagadNumber': nagadNumber,
      'bankName': bankName,
      'bankAccountNumber': bankAccountNumber,
      'bookingFromNumber': bookingFromNumber,
      'bookingType': bookingType,
    };
  }
}

class Payment {
  int? id;
  Booking? booking;
  double amount;
  String paymentType;
  String paymentMethod;
  DateTime paymentDate;
  String? note;
  String? accountNumber;
  String? bankName;

  Payment({
    this.id,
    this.booking,
    required this.amount,
    required this.paymentType,
    required this.paymentMethod,
    required this.paymentDate,
    this.note,
    this.accountNumber,
    this.bankName,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      booking: json['booking'] != null ? Booking.fromJson(json['booking']) : null,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      paymentType: json['paymentType'] ?? '',
      paymentMethod: json['paymentMethod'] ?? '',
      paymentDate: json['paymentDate'] != null
          ? DateTime.parse(json['paymentDate'])
          : DateTime.now(),
      note: json['note'],
      accountNumber: json['accountNumber'],
      bankName: json['bankName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (booking != null) 'booking': {'id': booking!.id},
      'amount': amount,
      'paymentType': paymentType,
      'paymentMethod': paymentMethod,
      'paymentDate': paymentDate.toIso8601String().split('T')[0],
      'note': note,
      'accountNumber': accountNumber,
      'bankName': bankName,
    };
  }
}