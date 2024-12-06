// lib/cust_dashboard/cust_dashboard.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../login_dashboard/login_dashboard.dart';
import 'booking/bookings.dart';
import 'booking/currentbooking.dart';
import 'booking/mybookings.dart';
import 'booking/ordersnack.dart';



class CustDashboard extends StatelessWidget {
  const CustDashboard({Key? key}) : super(key: key);

  // Function to handle logout
  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginDashboard()),
          (Route<dynamic> route) => false,
    );
  }

  // Function to fetch user profile
  Future<Map<String, dynamic>?> _fetchUserProfile() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      QuerySnapshot userQuery = await FirebaseFirestore.instance
          .collection('Users')
          .where('Email', isEqualTo: user.email)
          .get();

      if (userQuery.docs.isNotEmpty) {
        return userQuery.docs.first.data() as Map<String, dynamic>;
      }
    }
    return null;
  }

  // Function to show profile dialog
  void _showProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder<Map<String, dynamic>?>(
          future: _fetchUserProfile(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasData && snapshot.data != null) {
              var userData = snapshot.data!;
              return AlertDialog(
                backgroundColor: Colors.white.withOpacity(0.9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Profile',
                      style: TextStyle(color: Color(0xFF876191), fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFF876191)),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Display user information
                    ListTile(
                      leading: const Icon(Icons.person, color: Color(0xFF876191)),
                      title: Text(
                        '${userData['FName'] ?? 'First Name'} ${userData['LName'] ?? 'Last Name'}',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ListTile(
                      leading: const Icon(Icons.email, color: Color(0xFF876191)),
                      title: Text(
                        userData['Email'] ?? 'Email',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return AlertDialog(
                backgroundColor: Colors.white.withOpacity(0.9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: const Text(
                  'Profile',
                  style: TextStyle(color: Color(0xFF876191), fontWeight: FontWeight.bold),
                ),
                content: const Text('No profile information available.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Close',
                      style: TextStyle(color: Color(0xFF876191)),
                    ),
                  ),
                ],
              );
            }
          },
        );
      },
    );
  }

  // Widget for individual dashboard options
  Widget _dashboardOption({
    required BuildContext context,
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
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
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 30),
            const SizedBox(width: 20),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, color: Colors.white),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Transparent AppBar to allow gradient background
      appBar: AppBar(
        title: const Text(
          "User Dashboard",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24, // Increased font size for emphasis
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // User icon with dropdown menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.person, color: Colors.white),
            onSelected: (String choice) {
              if (choice == 'Profile') {
                _showProfileDialog(context);
              } else if (choice == 'Logout') {
                _logout(context);
              }
            },
            itemBuilder: (BuildContext context) {
              return {'Profile', 'Logout'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(
                    choice,
                    style: const TextStyle(color: Color(0xFF876191)),
                  ),
                );
              }).toList();
            },
          ),
          const SizedBox(width: 20),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF876191), // Base color
                  Color(0xFF654E7F), // Darker shade for the center
                  Color(0xFF876191), // Base color
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 100, 20, 80), // Adjust padding as needed
            child: Column(
              children: [
                // Dashboard Options
                _dashboardOption(
                  context: context,
                  title: 'Book Table',
                  icon: Icons.table_restaurant,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const BookingCalendarPage()),
                    );
                  },
                ),
                const SizedBox(height: 20),
                _dashboardOption(
                  context: context,
                  title: 'Your Bookings',
                  icon: Icons.book_online,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const MyBookingsPage()),
                    );
                  },
                ),
                const SizedBox(height: 20),
                _dashboardOption(
                  context: context,
                  title: 'Current Booking',
                  icon: Icons.event_available,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const CurrentBookingPage()),
                    );
                  },
                ),
                const SizedBox(height: 20),
                _dashboardOption(
                  context: context,
                  title: 'Order Snacks',
                  icon: Icons.fastfood,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const SnacksPage()),
                    );
                  },
                ),
              ],
            ),
          ),
          // Centered Footer with cat.png
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'assets/cat.png', // Ensure this path is correct and the image is added to pubspec.yaml
                width: 300, // Adjust the size as needed
                height: 200,
              ),
            ),
          ),
        ],
      ),
    );
  }
}










