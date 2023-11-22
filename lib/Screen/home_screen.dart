import 'package:construction_app/Screen/auth_screen.dart';
import 'package:flutter/material.dart';
import '../Componets/widgets/custom_button.dart';
import '../utils/theme_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static const routeName = "/home-screen";
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;
    return Scaffold(
      backgroundColor: MyThemes.lightTheme.scaffoldBackgroundColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CustomButton(
              text: 'USER',
              onTap: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (_) => const AuthScreen(),
                ));
              }),
          SizedBox(height: screenHeight * 0.08),
          CustomButton(
              text: 'ADMIN',
              onTap: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (_) => const AuthScreen(),
                ));
              })
        ],
      ),
    );
  }
}
