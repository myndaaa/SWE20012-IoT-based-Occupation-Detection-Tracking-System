import 'package:flutter/material.dart';

class PaperButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const PaperButton({Key? key, required this.label, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Shadow layer
          Positioned(
            top: 5,
            left: 5,
            child: Container(
              height: 50,
              width: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(8, 8),
                  ),
                ],
              ),
            ),
          ),
          // Main button with irregular shape
          CustomPaint(
            painter: PaperButtonBorder(),
            child: Container(
              height: 50,
              width: 120,
              alignment: Alignment.center,
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PaperButtonBorder extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.transparent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeJoin = StrokeJoin.round
      ..color = Colors.black38;

    final path = Path()
      ..moveTo(5, 5)
      ..lineTo(size.width - 10, 0) // Top irregular line
      ..quadraticBezierTo(size.width, 10, size.width - 5, size.height - 10)
      ..lineTo(10, size.height) // Bottom irregular line
      ..quadraticBezierTo(0, size.height - 10, 5, 5);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
