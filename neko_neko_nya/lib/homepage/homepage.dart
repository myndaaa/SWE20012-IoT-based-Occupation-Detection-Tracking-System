import 'package:flutter/material.dart';
import 'package:metaballs/metaballs.dart';
import '../login_dashboard/aboutpage.dart';
import '../login_dashboard/login_dashboard.dart';
import 'button.dart';
import 'color_pair.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int colorEffectIndex = 0;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double padding = width < 600 ? 20 : 40; // Responsive padding

    return Material(
      child: GestureDetector(
        onDoubleTap: () {
          setState(() {
            colorEffectIndex = (colorEffectIndex + 1) % colorsAndEffects.length;
          });
        },
        child: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.bottomCenter,
              radius: 1.5,
              colors: [
                Color.fromARGB(255, 13, 35, 61),
                Colors.black,
              ],
            ),
          ),
          child: Stack(
            children: [
              Metaballs(
                effect: colorsAndEffects[colorEffectIndex].effect,
                glowRadius: 1,
                glowIntensity: 0.6,
                maxBallRadius: 50,
                minBallRadius: 20,
                metaballs: 40,
                color: Colors.grey,
                gradient: LinearGradient(
                  colors: colorsAndEffects[colorEffectIndex].colors,
                  begin: Alignment.bottomRight,
                  end: Alignment.topLeft,
                ),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: padding),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Welcome to neko neko nyaa',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 44,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                offset: Offset(1, 1),
                                color: Colors.black,
                                blurRadius: 3,
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 30),
                        Text(
                          'Your one stop solution: From cardgames, cosplays to the multiverse',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w500,
                            shadows: [
                              Shadow(
                                offset: Offset(1, 1),
                                color: Colors.black,
                                blurRadius: 3,
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: padding,
                right: padding,
                child: Row(
                  children: [
                    PaperButton(
                      //text: 'Loooogin',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginDashboard()),
                        );
                      }, label: 'Login',
                    ),
                    const SizedBox(width: 10),
                    PaperButton(
                      //text: 'About',
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AboutPage()),
                        );
                      },
                      label: 'About',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


