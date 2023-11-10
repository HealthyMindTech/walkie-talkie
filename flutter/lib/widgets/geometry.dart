import 'package:flutter/material.dart';

class CirclePainter extends CustomPainter {
  final Color strokeColor;
  final PaintingStyle paintingStyle;
  final double strokeWidth;

  CirclePainter({this.strokeColor = Colors.black, this.strokeWidth = 3, this.paintingStyle = PaintingStyle.stroke});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = strokeColor
      ..strokeWidth = strokeWidth
      ..style = paintingStyle;

    canvas.drawPath(getCirclePath(size.width, size.height), paint);
  }

  Path getCirclePath(double x, double y) {
    return Path()
      ..moveTo(0, 0)
      ..addOval(Rect.fromLTRB(0, 0, x, y));
  }

  @override
  bool shouldRepaint(CirclePainter oldDelegate) {
    return oldDelegate.strokeColor != strokeColor ||
        oldDelegate.paintingStyle != paintingStyle ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

class TrianglePainter extends CustomPainter {
  final Color strokeColor;
  final PaintingStyle paintingStyle;
  final double strokeWidth;

  TrianglePainter({this.strokeColor = Colors.black, this.strokeWidth = 3, this.paintingStyle = PaintingStyle.stroke});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = strokeColor
      ..strokeWidth = strokeWidth
      ..style = paintingStyle;

    canvas.drawPath(getTrianglePath(size.width, size.height), paint);
  }

  Path getTrianglePath(double x, double y) {
    return Path()
      ..moveTo(0, y)
      ..lineTo(x / 2, 0)
      ..lineTo(x, y)
      ..lineTo(0, y);
  }

  @override
  bool shouldRepaint(TrianglePainter oldDelegate) {
    return oldDelegate.strokeColor != strokeColor ||
        oldDelegate.paintingStyle != paintingStyle ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

class CircleWidget extends StatelessWidget {
  final Size size;
  final MaterialColor color;
  const CircleWidget({Key? key, required this.size,  this.color = Colors.blue }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: CirclePainter(
        strokeColor: color,
        strokeWidth: 10,
        paintingStyle: PaintingStyle.fill,
      ),
      child: SizedBox(
        height: size.height,
        width: size.width,
      ),
    );
  }
}

class TriangleWidget extends StatelessWidget {
  final Size size;
  final MaterialColor color;
  const TriangleWidget({Key? key, required this.size,  this.color = Colors.blue }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: TrianglePainter(
        strokeColor: color,
        strokeWidth: 10,
        paintingStyle: PaintingStyle.fill,
      ),
      child: SizedBox(
        height: size.height,
        width: size.width,
      ),
    );
  }

}
