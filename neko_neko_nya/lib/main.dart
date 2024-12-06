// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:neko_neko_nya/homepage/homepage.dart';
import 'admin/admin_dashboard.dart';
import 'admin/adminloginpage.dart';
import 'consumer/customer_dashboard.dart';
import 'login_dashboard/login_dashboard.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // Root of your application
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Neko Neko Nya',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: const AuthGate(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  // Function to determine user role
  Future<String?> _getUserRole(User user) async {
    // Check if the user's UID exists in the 'Users' collection
    DocumentSnapshot userDoc =
    await FirebaseFirestore.instance.collection('Users').doc(user.uid).get();
    if (userDoc.exists) {
      return 'customer';
    } else {
      return 'admin';
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // If the snapshot has user data, determine their role
        if (snapshot.hasData) {
          User user = snapshot.data!;
          return FutureBuilder<String?>(
            future: _getUserRole(user),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (roleSnapshot.hasData) {
                String role = roleSnapshot.data!;
                if (role == 'customer') {
                  return const CustDashboard();
                } else if (role == 'admin') {
                  return const AdminDashboard();
                } else {
                  // If role is undefined, navigate to LoginDashboard
                  return const LoginDashboard();
                }
              } else {
                // If unable to determine role, navigate to LoginDashboard
                return const LoginDashboard();
              }
            },
          );
        }

        // If the user is not logged in, navigate to LoginDashboard
        return const HomePage();
      },
    );
  }
}
