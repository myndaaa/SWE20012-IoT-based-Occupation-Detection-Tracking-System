import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({Key? key}) : super(key: key);

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<String> _days = List.generate(14, (index) {
    DateTime date = DateTime.now().subtract(Duration(days: 7 - index));
    return DateFormat('yyyy-MM-dd').format(date);
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Analytics",
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
              children: [
                _buildStreamBarChart(
                  "Booking Frequency",
                  _firestore.collection('Bookings'),
                  Colors.orangeAccent,
                  true,
                ),
                const SizedBox(height: 30),
                _buildStreamBarChart(
                  "Traffic Frequency",
                  _firestore.collection('Detection'),
                  Colors.lightBlue,
                  false,
                ),
                const SizedBox(height: 30),
                _buildStreamBarChart(
                  "Unauthorized Walk-ins",
                  _firestore.collection('Unauthorized'),
                  Colors.redAccent,
                  false,
                ),
                const SizedBox(height: 70),
                Center(
                  child: Image.asset(
                    'assets/cat.png', // Ensure this path is correct and the image is added to pubspec.yaml
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

  Widget _buildStreamBarChart(
      String title, CollectionReference collection, Color barColor, bool isBooking) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          constraints: const BoxConstraints(maxWidth: 800),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.all(16),
          child: AspectRatio(
            aspectRatio: 1.5,
            child: StreamBuilder<QuerySnapshot>(
              stream: collection.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Initialize data to count bookings or detections/unauthorized events
                Map<String, int> data = {};
                for (String day in _days) {
                  data[day] = 0;
                }

                // Fill data from Firestore snapshot
                for (var doc in snapshot.data!.docs) {
                  Timestamp timestamp = isBooking ? doc['BookingStart'] : doc['Time'];
                  String day = DateFormat('yyyy-MM-dd').format(timestamp.toDate());

                  if (data.containsKey(day)) {
                    if (isBooking) {
                      data[day] = (data[day] ?? 0) + 1;
                    } else {
                      data[day] = (data[day] ?? 0) + int.parse(doc['Count']);
                    }
                  }
                }

                // Determine max Y value to accommodate larger data
                int maxYValue = data.values.isNotEmpty ? data.values.reduce((a, b) => a > b ? a : b) : 1;
                double maxY = (maxYValue * 1.2).toDouble(); // Set the max Y to be slightly higher to accommodate larger data

                return BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: maxY < 15 ? 15 : maxY, // Ensure max Y is at least 15 for better scaling
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            int index = value.toInt();
                            if (index >= 0 && index < _days.length) {
                              return Text(
                                _days[index].substring(5),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              );
                            }
                            return const Text("");
                          },
                          reservedSize: 32,
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            if (value % 1 == 0) {
                              return Text(
                                value.toInt().toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                          reservedSize: 32,
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(
                      _days.length,
                          (index) => BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: data[_days[index]] != null ? data[_days[index]]!.toDouble() : 0,
                            color: barColor,
                            width: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
