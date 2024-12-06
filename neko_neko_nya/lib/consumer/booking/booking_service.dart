// lib/firestore_booking_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirestoreBookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> uploadBooking({
    required DateTime bookingStart,
    required DateTime bookingEnd,
    required String user,
  }) async {
    await _firestore.collection('Bookings').add({
      'Created': Timestamp.now(),
      'BookingStart': bookingStart,
      'BookingEnd': bookingEnd,
      'User': user,
    });
  }

  Stream<List<DateTimeRange>> getBookingsStream() {
    return _firestore.collection('Bookings').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return DateTimeRange(
          start: (doc['BookingStart'] as Timestamp).toDate(),
          end: (doc['BookingEnd'] as Timestamp).toDate(),
        );
      }).toList();
    });
  }
}
