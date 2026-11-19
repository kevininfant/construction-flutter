import 'package:construction_app/Screen/auth_screen.dart';
import 'package:construction_app/Screen/complaint_history_screen.dart';
import 'package:construction_app/Screen/track_complaint_screen.dart';
import 'package:construction_app/Screen/user_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  static const routeName = "/home-screen";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text('🏗️', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 16),
                const Text('T.R Construction', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                const Text('Building Excellence, Delivering Quality', style: TextStyle(color: Colors.white54, fontSize: 14)),
                const Spacer(),
                _HomeCard(
                  icon: '👤',
                  title: 'User Portal',
                  subtitle: 'Submit & track your complaints',
                  color: const Color(0xFFe94560),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UsersScreen())),
                ),
                const SizedBox(height: 16),
                _HomeCard(
                  icon: '🔍',
                  title: 'Track Complaint',
                  subtitle: 'Check status with tracking ID',
                  color: const Color(0xFF10b981),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TrackComplaintScreen())),
                ),
                const SizedBox(height: 16),
                _HomeCard(
                  icon: '📋',
                  title: 'Complaint History',
                  subtitle: 'View all your past complaints',
                  color: const Color(0xFF8b5cf6),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ComplaintHistoryScreen())),
                ),
                const SizedBox(height: 16),
                _HomeCard(
                  icon: '🔐',
                  title: 'Admin Login',
                  subtitle: 'Access admin dashboard',
                  color: const Color(0xFF6366f1),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthScreen())),
                ),
                const Spacer(),
                const Center(
                  child: Text('© 2024 Phuzhal Builders', style: TextStyle(color: Colors.white24, fontSize: 12)),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeCard extends StatelessWidget {
  final String icon, title, subtitle;
  final Color color;
  final VoidCallback onTap;

  const _HomeCard({required this.icon, required this.title, required this.subtitle, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14)),
              child: Center(child: Text(icon, style: const TextStyle(fontSize: 24))),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 13)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 16),
          ],
        ),
      ),
    );
  }
}
