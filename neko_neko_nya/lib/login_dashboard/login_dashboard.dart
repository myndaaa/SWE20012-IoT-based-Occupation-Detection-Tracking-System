// lib/login_dashboard/login_dashboard.dart

import 'package:flutter/material.dart';
import '../admin/adminloginpage.dart';
import '../consumer/userloginpage.dart';
import '../homepage/homepage.dart'; // Adjust the path as necessary

class LoginDashboard extends StatelessWidget {
  const LoginDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Screen size for responsive design
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      // Background with gradient
      body: Container(
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
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Top Center Image
                const Text(
                  'Login Portal',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Image.asset(
                  'assets/login.png',
                  height: 200, // Adjust the height as needed
                ),
                const SizedBox(height: 20),
                const SizedBox(height: 60),

                // Login Modules Container
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Admin Login Module
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AdminLoginPage(),
                          ),
                        );
                      },
                      child: Container(
                        width: width < 600 ? width * 0.4 : 200,
                        padding: const EdgeInsets.all(16),
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
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Admin Login',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Image.asset('assets/neko1.png', height: 160),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    // User Login Module
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CustomerLoginPage(),
                          ),
                        );
                      },
                      child: Container(
                        width: width < 600 ? width * 0.4 : 200,
                        padding: const EdgeInsets.all(16),
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
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'User Login',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Image.asset('assets/neko2.png', height: 160),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // Footer: Go back to home
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Go back to ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const HomePage()),
                        );
                      },
                      child: const Text(
                        'Home',
                        style: TextStyle(
                          color: Colors.white,
                          decoration: TextDecoration.underline,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}




