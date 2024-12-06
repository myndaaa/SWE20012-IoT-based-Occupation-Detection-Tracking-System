import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class CurrentBookingPage extends StatefulWidget {
  const CurrentBookingPage({Key? key}) : super(key: key);

  @override
  State<CurrentBookingPage> createState() => _CurrentBookingPageState();
}

class _CurrentBookingPageState extends State<CurrentBookingPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String userEmail = "";
  Map<String, dynamic>? currentBooking;
  Color selectedColor = Colors.red; // Default color for color picker

  @override
  void initState() {
    super.initState();
    _getCurrentUserEmail();
    _fetchCurrentBooking();
  }

  void _getCurrentUserEmail() {
    final user = _auth.currentUser;
    if (user != null) {
      userEmail = user.email ?? "";
    }
  }

  Future<void> _fetchCurrentBooking() async {
    final Timestamp now = Timestamp.now();
    print("Current Timestamp: ${now.toDate()}");

    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection('Bookings')
          .where('User', isEqualTo: userEmail)
          .where('BookingStart', isLessThanOrEqualTo: now)
          .where('BookingEnd', isGreaterThanOrEqualTo: now)
          .get();

      print("Query Completed. Number of documents found: ${querySnapshot.docs.length}");

      if (querySnapshot.docs.isNotEmpty) {
        final document = querySnapshot.docs.first;
        setState(() {
          currentBooking = document.data() as Map<String, dynamic>;
          currentBooking!['BookingId'] = document.id; // Manually add the document ID
        });
        print("Current Booking Fetched: ${currentBooking.toString()}");
      } else {
        print("No Current Booking Found.");
      }
    } catch (e) {
      print("Error fetching current booking: $e");
    }
  }

  Future<void> _addTableColorBooking(String hexColor) async {
    if (currentBooking != null) {
      await _firestore.collection('Neopixel').add({
        'Booking': currentBooking!['BookingId'],
        'Hexcode': hexColor,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Table color saved successfully!')),
      );
    }
  }

  Widget _buildColorPickerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 30),
        const Text(
          "Select Table Color:",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        BlockPicker(
          pickerColor: selectedColor,
          onColorChanged: (color) {
            setState(() {
              selectedColor = color;
            });
          },
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            String hexColor = '#${selectedColor.value.toRadixString(16).substring(2).toUpperCase()}';
            _addTableColorBooking(hexColor);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF46245E), // Confirm button enabled color
            disabledForegroundColor: const Color(0xFF4F4457).withOpacity(0.38),
            disabledBackgroundColor: const Color(0xFF4F4457).withOpacity(0.12), // Confirm button disabled color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          child: const Text(
            "Confirm Color",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Current Booking",
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
        width: double.infinity, // Ensure full width
        height: double.infinity, // Ensure full height
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 1000),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 100.0),
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (currentBooking != null) ...[
                            const Text(
                              "On-going Booking Details",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
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
                                    "Booking ID: ${currentBooking!['BookingId']}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "Time Start: ${currentBooking!['BookingStart'].toDate()}",
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  Text(
                                    "Time End: ${currentBooking!['BookingEnd'].toDate()}",
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                            _buildColorPickerSection(),
                          ] else ...[
                            const SizedBox(height: 50),
                            Center(
                              child: Image.asset(
                                'assets/cusl.png',
                                width: 300,
                                height: 300,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              "Such Empty Much WOW",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: 'Horror', // Replace with a custom horror-like font in pubspec.yaml
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
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
