import 'package:flutter/material.dart';
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const CustomButton({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;
    return Center(
      child: Container(
        width: screenWidth * 0.80,
        height: screenHeight * 0.08,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF01AAFF),
              Color(0xFF007AFF)
            ], // Adjust colors as needed
          ),
          borderRadius:
              BorderRadius.circular(8), // Adjust the border radius as needed
        ),
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white, // Set the text color
            ),
          ),
        ),
      ),
    );
  }
}
