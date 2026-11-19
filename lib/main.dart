import 'package:construction_app/Screen/home_screen.dart';
import 'package:construction_app/Screen/onboard_screen.dart';
import 'package:construction_app/Screen/user_screen.dart';
import 'package:construction_app/Screen/track_complaint_screen.dart';
import 'package:construction_app/Screen/complaint_history_screen.dart';
import 'package:construction_app/Screen/auth_screen.dart';
import 'package:construction_app/Screen/admin_dashboard_screen.dart';
import 'package:construction_app/Screen/profile_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'T.R Construction',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFe94560)),
        useMaterial3: true,
      ),
      home: OnboardingScreen(),
      routes: {
        OnboardingScreen.routeName: (context) => OnboardingScreen(),
        HomeScreen.routeName: (context) => const HomeScreen(),
        AuthScreen.routeName: (context) => const AuthScreen(),
        UsersScreen.routeName: (context) => const UsersScreen(),
        TrackComplaintScreen.routeName: (context) => const TrackComplaintScreen(),
        ComplaintHistoryScreen.routeName: (context) => const ComplaintHistoryScreen(),
        AdminDashboardScreen.routeName: (context) => const AdminDashboardScreen(),
        ProfileScreen.routeName: (context) => const ProfileScreen(),
      },
    );
  }
}
