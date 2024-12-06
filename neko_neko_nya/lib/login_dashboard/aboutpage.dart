import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  // Corrected to use Uri for Google Maps URL
  static final Uri googleMapsUrl = Uri.parse(
      "https://www.google.com/maps/dir/?api=1&destination=1.5180207132737%2C110.36657614569");

  // Updated function to use launchUrl and canLaunchUrl with Uri
  void _launchGoogleMaps() async {
    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl);
    } else {
      throw 'Could not launch $googleMapsUrl';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "About Neko Neko Nyaa",
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 100.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Once upon a time, nestled in the heart of Sarawak, in the vibrant city of Kuching, a magical place was born—a place where hobbies flourish, imaginations soar, and friendships grow. This enchanted spot is none other than Neko Neko Nyaa. Founded as a haven for all things fun and creative, Neko Neko Nyaa quickly became a beloved gathering place for enthusiasts of trading card games, board games, Warhammer, and cosplay. It is where laughter echoes and where people from all walks of life come together to connect and explore their passions.",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                const Text(
                  "In the charming space of Neko Neko Nyaa, time flows differently. Here, surrounded by shelves of trading cards, figures, and colorful game boards, visitors find a community—a group of people who share their interests and a love for all things playful and imaginative. The store has become a beacon for newcomers and veterans alike, where anyone can pick up a new hobby or simply find comfort in the warmth of community. Neko will always be here to heal your soul—so let’s Nyannnn together!",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                const Text(
                  "Our flagship store is alive with the spirit of adventure and joy, providing everything from trading card tournaments to cosplay meetups. Whether you’re painting your first Warhammer figure or challenging your friends to a board game duel, this is a place to learn, grow, and experience something new. As the shop’s motto says, \"Neko will heal you up here!! Let’s Nyannnn ✻*⁽⁰＼(⁰˙˘｀*)ノ✻*⁽⁰\".",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Image.asset(
                  'assets/shop1.png',
                  width: 300,
                  height: 200,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 20),
                Image.asset(
                  'assets/shop2.png',
                  width: 300,
                  height: 200,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 40),
                const Text(
                  "Opening Hours",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Monday to Thursday: 1:00 PM - 8:30 PM\nFriday & Saturday: 1:00 PM - 12:00 AM\nSunday: 1:00 PM - 8:30 PM",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                const Text(
                  "Visit Us!",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: _launchGoogleMaps,
                  child: Image.asset(
                    'assets/map.png', // Ensure the image is added to pubspec.yaml
                    width: 300,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  "Contact Us",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Phone: 013-818 3616\nEmail: nekonekonyaannn@gmail.com",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                const Text(
                  "Neko Neko Nyaa—a magical place where everyone finds something to love, and the adventure never ends. Come join the fun and let’s make memories together!",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
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
