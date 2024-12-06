import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({Key? key}) : super(key: key);

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String userEmail = "";

  @override
  void initState() {
    super.initState();
    _getCurrentUserEmail();
  }

  void _getCurrentUserEmail() {
    final user = _auth.currentUser;
    if (user != null) {
      userEmail = user.email ?? "";
    }
  }

  Stream<QuerySnapshot> _fetchUpcomingBookings() {
    Timestamp now = Timestamp.now();
    return _firestore
        .collection('Bookings')
        .where('User', isEqualTo: userEmail)
        .where('BookingStart', isGreaterThanOrEqualTo: now)
        .snapshots();
  }

  Stream<QuerySnapshot> _fetchCompletedBookings() {
    Timestamp now = Timestamp.now();
    return _firestore
        .collection('Bookings')
        .where('User', isEqualTo: userEmail)
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
              return Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var booking = snapshot.data!.docs[index].data() as Map;
                      var bookingId = snapshot.data!.docs[index].id;
                      Timestamp bookingStart = booking['BookingStart'];
                      Timestamp bookingEnd = booking['BookingEnd'];
                      Timestamp created = booking['Created'];

                      return Container(
                        margin: const EdgeInsets.only(top: 10.0), // Reduced gap between containers
                        padding: const EdgeInsets.all(15.0),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
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
                              "Booking No: ${index + 1}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Booking ID: $bookingId",
                              style: const TextStyle(color: Colors.white),
                            ),
                            Text(
                              "Time Start: ${bookingStart.toDate()}",
                              style: const TextStyle(color: Colors.white),
                            ),
                            Text(
                              "Time End: ${bookingEnd.toDate()}",
                              style: const TextStyle(color: Colors.white),
                            ),
                            Text(
                              "Created: ${created.toDate()}",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              );
            }
            return const Text(
              "No bookings found.",
              style: TextStyle(color: Colors.white),
            );
          },
        ),
        const SizedBox(height: 50), // Adjusted gap between booking sections
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Bookings",
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
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 800),
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
                    const SizedBox(height: 70), // Space for the footer image
                    Center(
                      child: Image.asset(
                        'assets/cat.png', // Ensure this path is correct and the image is added to pubspec.yaml
                        width: 300,
                        height: 100,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
