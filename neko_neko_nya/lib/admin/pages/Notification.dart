import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> newNotifications = [];
  List<Map<String, dynamic>> previousNotifications = [];

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    List<Map<String, dynamic>> allNotifications = [];

    // Fetching Detection collection
    QuerySnapshot detectionSnapshot = await _firestore.collection('Detection').get();
    for (var doc in detectionSnapshot.docs) {
      Timestamp timestamp = doc['Time'];
      String count = doc['Count'];
      allNotifications.add({
        'type': 'Detection',
        'time': timestamp,
        'count': count,
      });
    }

    // Fetching Unauthorized collection
    QuerySnapshot unauthorizedSnapshot = await _firestore.collection('Unauthorized').get();
    for (var doc in unauthorizedSnapshot.docs) {
      Timestamp timestamp = doc['Time'];
      String count = doc['Count'];
      allNotifications.add({
        'type': 'Unauthorized',
        'time': timestamp,
        'count': count,
      });
    }

    // Sorting notifications by time (newest first)
    allNotifications.sort((a, b) => b['time'].compareTo(a['time']));

    DateTime today = DateTime.now();

    // Splitting into new and previous notifications
    for (var notification in allNotifications) {
      DateTime notificationDate = notification['time'].toDate();
      if (notificationDate.isAfter(DateTime(today.year, today.month, today.day))) {
        newNotifications.add(notification);
      } else {
        previousNotifications.add(notification);
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Notifications",
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
        width: double.infinity,
        height: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 100.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (newNotifications.isNotEmpty) ...[
                const Text(
                  "New Notifications",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: newNotifications.length,
                    itemBuilder: (context, index) {
                      return _buildNotificationCard(newNotifications[index]);
                    },
                  ),
                ),
              ],
              if (previousNotifications.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Text(
                  "Previous Notifications",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: previousNotifications.length,
                    itemBuilder: (context, index) {
                      return _buildNotificationCard(previousNotifications[index]);
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    String type = notification['type'];
    DateTime time = notification['time'].toDate();
    String count = notification['count'];
    String formattedTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(time);
    String message = type == 'Detection'
        ? 'Detection found at $formattedTime of $count people'
        : 'Unauthorized access found at $formattedTime of $count people';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
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
      child: Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    );
  }
}
