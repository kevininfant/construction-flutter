import 'package:flutter/material.dart';

class CustomLoadingWidget extends StatelessWidget {
  const CustomLoadingWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child:TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: 0.85),
          duration: const Duration(seconds: 2),
          builder: (context, double vale, child) => Padding(
            padding: const EdgeInsets.all(15.0),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              CircularProgressIndicator(
                strokeWidth: 20,
                value: vale,
                color: const Color.fromARGB(255, 7, 147, 255),
                backgroundColor: const Color.fromARGB(255, 255, 255, 255),
              ),
              Text(
                "${(vale * 100).toInt()}%",
                style: const TextStyle(
                    color: Color.fromARGB(255, 0, 0, 0), fontSize: 14),
              ),
            ]),
          ),
        ),
    );
  }
}
