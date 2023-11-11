import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  // Add children and onPressed to your properties
  final List<Widget>? children;
  final VoidCallback onPressed;

  const CustomButton({
    super.key,
    required this.children,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 10.0, vertical: 8.0), // Increased vertical padding
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: const [
              Color(0xFFf8c85c),
              Color(0xFFfc8c3e)
            ], // Orange gradient
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              offset: const Offset(0, 4),
              blurRadius: 4.0,
            ),
          ],
          borderRadius: BorderRadius.circular(10.0), // Slightly rounded corners
          border: Border.all(
            color:
                const Color(0xFFae3d0b), // Adjusted for a darker border color
            width: 2.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: children!,
        ),
      ),
    );
  }
}
