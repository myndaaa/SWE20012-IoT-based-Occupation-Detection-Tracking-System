import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SnacksPage extends StatefulWidget {
  const SnacksPage({Key? key}) : super(key: key);

  @override
  State<SnacksPage> createState() => _SnacksPageState();
}

class _SnacksPageState extends State<SnacksPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String userEmail = "";
  final Map<String, int> _orderCounts = {
    '100plus': 0,
    'Apollo': 0,
    'Cocacola': 0,
    'CottageChips': 0,
    'Milo': 0,
    'Pringles': 0,
    'Water': 0,
  };

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

  void _placeOrder() async {
    final Timestamp now = Timestamp.now();

    await _firestore.collection('Snacks').add({
      'User': userEmail,
      'Placed': now,
      '100plus': _orderCounts['100plus'].toString(),
      'Apollo': _orderCounts['Apollo'].toString(),
      'Cocacola': _orderCounts['Cocacola'].toString(),
      'CottageChips': _orderCounts['CottageChips'].toString(),
      'Milo': _orderCounts['Milo'].toString(),
      'Pringles': _orderCounts['Pringles'].toString(),
      'Water': _orderCounts['Water'].toString(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order placed successfully!')),
    );

    setState(() {
      _orderCounts.updateAll((key, value) => 0);
    });
  }

  void _showPastOrdersDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder<QuerySnapshot>(
          future: _firestore
              .collection('Snacks')
              .where('User', isEqualTo: userEmail)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return AlertDialog(
                backgroundColor: Colors.white.withOpacity(0.9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: const Text(
                  'Past Orders',
                  style: TextStyle(
                    color: Color(0xFF876191),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: const Text('An error occurred while fetching orders.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Close',
                      style: TextStyle(color: Color(0xFF876191)),
                    ),
                  ),
                ],
              );
            }
            if (snapshot.hasData && snapshot.data != null) {
              return AlertDialog(
                backgroundColor: Colors.white.withOpacity(0.9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Past Orders',
                      style: TextStyle(
                        color: Color(0xFF876191),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFF876191)),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
                content: Container(
                  width: 500, // Set width of the popup to 500
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: snapshot.data!.docs.map((doc) {
                      var data = doc.data() as Map<String, dynamic>;
                      return Container(
                        width: 350, // Set the width of the order details container to 350
                        padding: const EdgeInsets.all(8.0),
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFF40294A), // Updated background color
                          borderRadius: BorderRadius.circular(10),
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
                          children: _orderCounts.keys.map((key) {
                            return Text(
                              "$key: ${data[key]}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              );
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        );
      },
    );
  }

  Widget _buildOrderItem(String itemName) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              itemName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      if (_orderCounts[itemName]! > 0) {
                        _orderCounts[itemName] = _orderCounts[itemName]! - 1;
                      }
                    });
                  },
                  icon: const Icon(Icons.remove, color: Colors.white),
                ),
                Text(
                  '${_orderCounts[itemName]}',
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _orderCounts[itemName] = _orderCounts[itemName]! + 1;
                    });
                  },
                  icon: const Icon(Icons.add, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Order Snacks",
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
                ..._orderCounts.keys.map((key) => _buildOrderItem(key)).toList(),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _placeOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF46245E),
                    disabledForegroundColor: const Color(0xFF4F4457).withOpacity(0.38),
                    disabledBackgroundColor: const Color(0xFF4F4457).withOpacity(0.12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    "Place Order",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: _showPastOrdersDialog,
                  child: const Text(
                    "Past Orders",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      decoration: TextDecoration.underline,
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
