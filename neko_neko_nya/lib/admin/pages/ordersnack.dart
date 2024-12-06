import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SnackOrdersPage extends StatelessWidget {
  const SnackOrdersPage({Key? key}) : super(key: key);

  // Method to fetch all snack orders from Firestore
  Stream<QuerySnapshot> _fetchSnackOrders() {
    return FirebaseFirestore.instance.collection('Snacks').orderBy('Placed', descending: true).snapshots();
  }

  // Method to build the snack order table
  Widget _buildSnackOrderTable(BuildContext context, QuerySnapshot snapshot) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: snapshot.docs.length,
      itemBuilder: (context, index) {
        var order = snapshot.docs[index].data() as Map<String, dynamic>;
        String orderedBy = order['User'] ?? 'Unknown';
        Timestamp placedTime = order['Placed'] ?? Timestamp.now();

        // Filter out snacks with count 0 or empty
        List<String> orderedSnacks = [];
        order.forEach((key, value) {
          if (key != 'User' && key != 'Placed' && value != '0' && value.isNotEmpty) {
            orderedSnacks.add('$key: $value');
          }
        });

        return Container(
          constraints: const BoxConstraints(maxWidth: 350),
          margin: const EdgeInsets.symmetric(vertical: 10),
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
                "Ordered by: $orderedBy",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Ordered Snacks: ${orderedSnacks.join(', ')}",
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 10),
              Text(
                "Time of Order: ${placedTime.toDate()}",
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Snack Orders",
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 100.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                StreamBuilder<QuerySnapshot>(
                  stream: _fetchSnackOrders(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text(
                          'An error occurred while fetching orders.',
                          style: TextStyle(color: Colors.red),
                        ),
                      );
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Text(
                        "No orders found.",
                        style: TextStyle(color: Colors.white),
                      );
                    }
                    return _buildSnackOrderTable(context, snapshot.data!);
                  },
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
