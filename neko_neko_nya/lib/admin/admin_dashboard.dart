import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:neko_neko_nya/admin/pages/Notification.dart';
import 'package:neko_neko_nya/admin/pages/analytics.dart';
import 'package:neko_neko_nya/admin/pages/ordersnack.dart';
import 'package:neko_neko_nya/admin/pages/viewbooking.dart';
import '../login_dashboard/login_dashboard.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int notificationCount = 0;

  @override
  void initState() {
    super.initState();
    _listenToNotificationUpdates();
  }

  void _listenToNotificationUpdates() {
    // Listen to real-time updates in the Detection collection
    FirebaseFirestore.instance.collection('Detection').snapshots().listen((snapshot) {
      _updateNotificationCount();
    });

    // Listen to real-time updates in the Unauthorized collection
    FirebaseFirestore.instance.collection('Unauthorized').snapshots().listen((snapshot) {
      _updateNotificationCount();
    });
  }

  Future<void> _updateNotificationCount() async {
    int detectionCount = await _getCollectionCount('Detection');
    int unauthorizedCount = await _getCollectionCount('Unauthorized');
    setState(() {
      notificationCount = detectionCount + unauthorizedCount;
    });
  }

  Future<int> _getCollectionCount(String collectionName) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection(collectionName).get();
    return snapshot.docs.length;
  }

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginDashboard()),
          (Route<dynamic> route) => false,
    );
  }

  Widget _dashboardOption({
    required BuildContext context,
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    int? notificationCount,
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
            Stack(
              children: [
                Icon(icon, color: Colors.white, size: 30),
                if (notificationCount != null && notificationCount > 0)
                  Positioned(
                    right: -5,
                    top: -5,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$notificationCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
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

  void _navigateToNotifications(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const NotificationsPage()),
    ).then((_) {
      // After returning from the notifications page, reset the badge count
      setState(() {
        notificationCount = 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Admin Dashboard",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              _logout(context);
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
                  Color(0xFF876191),
                  Color(0xFF654E7F),
                  Color(0xFF876191),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 100, 20, 80),
            child: Column(
              children: [
                _dashboardOption(
                  context: context,
                  title: 'Notifications',
                  icon: Icons.notifications,
                  onTap: () {
                    _navigateToNotifications(context);
                  },
                  notificationCount: notificationCount,
                ),
                const SizedBox(height: 20),
                _dashboardOption(
                  context: context,
                  title: 'Analytics',
                  icon: Icons.analytics,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const AnalyticsPage()),
                    );
                  },
                ),
                const SizedBox(height: 20),
                _dashboardOption(
                  context: context,
                  title: 'Bookings',
                  icon: Icons.book_online,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const AdminBookingsPage()),
                    );
                  },
                ),
                const SizedBox(height: 20),
                _dashboardOption(
                  context: context,
                  title: 'Snack Orders',
                  icon: Icons.fastfood,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const SnackOrdersPage()),
                    );
                  },
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'assets/cat.png',
                width: 300,
                height: 200,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
