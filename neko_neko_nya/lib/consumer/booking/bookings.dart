import 'package:flutter/material.dart';
import 'package:booking_calendar/booking_calendar.dart';
import 'booking_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookingCalendarPage extends StatefulWidget {
  const BookingCalendarPage({Key? key}) : super(key: key);

  @override
  State<BookingCalendarPage> createState() => _BookingCalendarPageState();
}

class _BookingCalendarPageState extends State<BookingCalendarPage> {
  final now = DateTime.now();
  late FirestoreBookingService _bookingService;

  @override
  void initState() {
    super.initState();
    _bookingService = FirestoreBookingService();
  }

  // Method to fetch booking slots from Firestore
  Stream<List<DateTimeRange>> getBookingStreamFirebase(
      {required DateTime end, required DateTime start}) {
    return _bookingService.getBookingsStream();
  }

  // Method to upload new booking to Firestore
  Future<void> uploadBookingFirebase({required BookingService newBooking}) async {
    await _bookingService.uploadBooking(
      bookingStart: newBooking.bookingStart,
      bookingEnd: newBooking.bookingEnd,
      user: FirebaseAuth.instance.currentUser?.email ?? 'unknown',
    );
    print('Booking Uploaded to Firestore: ${newBooking.toJson()}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Table Booking",
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
        height: double.infinity, // Make sure container takes full height of the screen
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 50.0),
                  child: Column(
                    children: [
                      // Constrained BookingCalendar to ensure proper layout
                      Container(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: AspectRatio(
                          aspectRatio: 1.1, // Adjust as necessary for better layout
                          child: BookingCalendar(
                            bookingService: BookingService(
                              serviceName: 'Firebase Booking Service',
                              serviceDuration: 60,
                              bookingStart: DateTime(now.year, now.month, now.day, 8, 0),
                              bookingEnd: DateTime(now.year, now.month, now.day, 22, 0),
                            ),
                            convertStreamResultToDateTimeRanges: ({required dynamic streamResult}) {
                              return streamResult as List<DateTimeRange>;
                            },
                            getBookingStream: getBookingStreamFirebase,
                            uploadBooking: uploadBookingFirebase,
                            locale: 'en_US',
                            startingDayOfWeek: StartingDayOfWeek.monday,
                            hideBreakTime: false,
                            pauseSlotText: 'LUNCH',
                            bookingButtonText: "Book Now",

                            // Customization Parameters
                            availableSlotColor: const Color(0xFF6db35f),
                            availableSlotText: 'Available',
                            bookedSlotColor: const Color(0xFFcc5656),
                            bookedSlotText: 'Booked',
                            selectedSlotColor: const Color(0xFFc8cc56),
                            selectedSlotText: 'Selected',

                            // Adjusting grid style
                            bookingGridChildAspectRatio: 1.3, // Adjust this to make the slots smaller or larger
                            bookingGridCrossAxisCount: 9, // Adjust the number to make slots smaller horizontally

                            // Adjust the text style for slot labels
                            availableSlotTextStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            bookedSlotTextStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            selectedSlotTextStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20), // Space between the booking calendar and the footer image
                    ],
                  ),
                ),
              ),
            ),
            // Footer image section
            Center(
              child: Image.asset(
                'assets/cat.png', // Ensure this path is correct and the image is added to pubspec.yaml
                width: 300,
                height: 100,
              ),
            ),
            const SizedBox(height: 30), // Space below the footer image
          ],
        ),
      ),
    );
  }
}
