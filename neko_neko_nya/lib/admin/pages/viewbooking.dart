import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminBookingsPage extends StatefulWidget {
  const AdminBookingsPage({Key? key}) : super(key: key);

  @override
  State<AdminBookingsPage> createState() => _AdminBookingsPageState();
}

class _AdminBookingsPageState extends State<AdminBookingsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> _fetchUpcomingBookings() {
    Timestamp now = Timestamp.now();
    return _firestore
        .collection('Bookings')
        .where('BookingStart', isGreaterThanOrEqualTo: now)
        .snapshots();
  }

  Stream<QuerySnapshot> _fetchCompletedBookings() {
    Timestamp now = Timestamp.now();
    return _firestore
        .collection('Bookings')
        .where('BookingEnd', isLessThanOrEqualTo: now)
        .snapshots();
  }

  Widget _buildBookingList({
    required Stream<QuerySnapshot> bookingStream,
    required String title,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        StreamBuilder<QuerySnapshot>(
          stream: bookingStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(
                child: Text(
                  'An error occurred while fetching bookings.',
                  style: TextStyle(color: Colors.red),
                ),
              );
            }
            if (snapshot.hasData && snapshot.data != null) {
              if (snapshot.data!.docs.isEmpty) {
                return const Text(
                  "No bookings found.",
                  style: TextStyle(color: Colors.white),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var booking = snapshot.data!.docs[index].data() as Map;
                  Timestamp bookingStart = booking['BookingStart'];
                  Timestamp bookingEnd = booking['BookingEnd'];
                  Timestamp created = booking['Created'];
                  String user = booking['User'] ?? 'Unknown User';

                  return Container(
                    constraints: const BoxConstraints(maxWidth: 800),
                    margin: const EdgeInsets.symmetric(vertical: 10.0),
                    padding: const EdgeInsets.all(15.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF40294a),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Table Booked By: $user",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Booking Created: ${DateFormat.yMMMd().add_jm().format(created.toDate())}",
                          style: const TextStyle(color: Colors.white),
                        ),
                        Text(
                          "Booking Start Time: ${DateFormat.yMMMd().add_jm().format(bookingStart.toDate())}",
                          style: const TextStyle(color: Colors.white),
                        ),
                        Text(
                          "Booking End Time: ${DateFormat.yMMMd().add_jm().format(bookingEnd.toDate())}",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  );
                },
              );
            }
            return const Text(
              "No bookings found.",
              style: TextStyle(color: Colors.white),
            );
          },
        ),
        const SizedBox(height: 50),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "All Bookings",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF876191),
              Color(0xFF654E7F),
              Color(0xFF876191),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 100.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Upcoming Bookings Section
                _buildBookingList(
                  bookingStream: _fetchUpcomingBookings(),
                  title: "Upcoming Bookings",
                ),
                // Completed Bookings Section
                _buildBookingList(
                  bookingStream: _fetchCompletedBookings(),
                  title: "Completed Bookings",
                ),
                const SizedBox(height: 70),
                Center(
                  child: Image.asset(
                    'assets/cat.png',
                    width: 300,
                    height: 100,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}