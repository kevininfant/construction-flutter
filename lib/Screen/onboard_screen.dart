import 'package:construction_app/Screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

class OnboardingScreen extends StatelessWidget {
  OnboardingScreen({super.key});
  static const routeName = "/Onboard-screen";
  final introKey = GlobalKey<IntroductionScreenState>();

  @override
  Widget build(BuildContext context) {
    const pageDecoration = PageDecoration(
      bodyFlex: 2,
      imageFlex: 4,
      imageAlignment: Alignment.bottomCenter,
      bodyTextStyle: TextStyle(fontSize: 14, color: Colors.grey),
    );

    return IntroductionScreen(
      key: introKey,
      pages: [
        PageViewModel(
          title: "T.R CONSTRUCTION",
          body:
              "Explore the world of construction with our app. Discover the latest tools, techniques, and projects to elevate your construction experience.",
          image: const Image(
              image: AssetImage('assets/images/onboardscreen/onboard1.jpg')),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "CONSTRUCTION REWORK",
          body:
              "Experience the power of our app in managing construction rework efficiently. Easily track and resolve issues, ensuring your construction projects stay on schedule and within budget.",
          image: const Image(
              image: AssetImage('assets/images/onboardscreen/onboard2.jpg')),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "CONSTRUCTION DEVELOPMENT",
          body:
              "Dive into the world of construction development with our app. Streamline your project planning, collaborate seamlessly with your team, and stay ahead in the fast-paced construction industry.",
          image: const Image(
              image: AssetImage('assets/images/onboardscreen/onboard3.jpg')),
          decoration: pageDecoration,
        ),
      ],
      onDone: () => goToHome(context),
      showSkipButton: true,
      skip: const Icon(Icons.skip_next, size: 45, color: Colors.blue),
      next: const Icon(
        Icons.navigate_next,
        size: 45,
        color: Colors.blue,
      ),
      done: const Text(
        "Done",
        style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.blue // Adjust the font size as needed
            ),
      ),
      dotsDecorator: const DotsDecorator(
        color: Colors.grey, // Change the color of the dots
        activeColor: Colors.blue, // Change the color of the active dot
      ),
    );
  }

  void goToHome(context) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => const HomeScreen(),
    ));
  }
}
