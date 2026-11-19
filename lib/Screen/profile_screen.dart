// ignore_for_file: use_build_context_synchronously
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_config.dart';
import 'home_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  static const routeName = '/profile';
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _currentObscure = true, _newObscure = true, _confirmObscure = true;
  bool _loading = false;
  String _userName = '', _userEmail = '', _userType = '', _userId = '', _token = '';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    _currentCtrl.dispose(); _newCtrl.dispose(); _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('userData');
    if (raw == null) return;
    final d = jsonDecode(raw);
    setState(() {
      _userName = d['name'] ?? ''; _userEmail = d['email'] ?? '';
      _userType = d['usertype'] ?? ''; _userId = d['userId'] ?? '';
      _token = d['token'] ?? '';
    });
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;
    if (_newCtrl.text != _confirmCtrl.text) {
      _snack('New passwords do not match', isError: true); return;
    }
    setState(() => _loading = true);
    try {
      final res = await http.post(
        Uri.parse('$uri/changepassword'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $_token'},
        body: jsonEncode({'user_id': int.tryParse(_userId) ?? 0, 'current_password': _currentCtrl.text, 'new_password': _newCtrl.text}),
      );
      final data = jsonDecode(res.body);
      if (data['code'] == '200') {
        _currentCtrl.clear(); _newCtrl.clear(); _confirmCtrl.clear();
        _snack('Password changed successfully!');
      } else {
        _snack(data['message'] ?? 'Failed to change password', isError: true);
      }
    } catch (_) { _snack('Server error. Check connection.', isError: true); }
    setState(() => _loading = false);
  }

  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? const Color(0xFFe94560) : const Color(0xFF10b981),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomeScreen()), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460)]),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
                      ),
                    ),
                    const Expanded(child: Text('Profile', textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold))),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Avatar card
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 80, height: 80,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [Color(0xFFe94560), Color(0xFF0f3460)]),
                                shape: BoxShape.circle,
                              ),
                              child: Center(child: Text(
                                _userName.isNotEmpty ? _userName[0].toUpperCase() : 'A',
                                style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                              )),
                            ),
                            const SizedBox(height: 16),
                            Text(_userName, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(_userEmail, style: const TextStyle(color: Colors.white54, fontSize: 14)),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFe94560).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFFe94560).withValues(alpha: 0.3)),
                              ),
                              child: Text(_userType.toUpperCase(),
                                  style: const TextStyle(color: Color(0xFFe94560), fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Change password
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(children: [
                              Icon(Icons.lock_outline_rounded, color: Color(0xFFe94560), size: 20),
                              SizedBox(width: 8),
                              Text('Change Password', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            ]),
                            const SizedBox(height: 20),
                            Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  _passField('Current Password', _currentCtrl, _currentObscure,
                                      () => setState(() => _currentObscure = !_currentObscure)),
                                  const SizedBox(height: 14),
                                  _passField('New Password', _newCtrl, _newObscure,
                                      () => setState(() => _newObscure = !_newObscure),
                                      validator: (v) => (v == null || v.length < 6) ? 'Min 6 characters' : null),
                                  const SizedBox(height: 14),
                                  _passField('Confirm New Password', _confirmCtrl, _confirmObscure,
                                      () => setState(() => _confirmObscure = !_confirmObscure)),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    width: double.infinity, height: 50,
                                    child: ElevatedButton(
                                      onPressed: _loading ? null : _changePassword,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFe94560),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      child: _loading
                                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                          : const Text('Update Password', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Logout
                      SizedBox(
                        width: double.infinity, height: 50,
                        child: OutlinedButton.icon(
                          onPressed: _logout,
                          icon: const Icon(Icons.logout_rounded, color: Color(0xFFe94560), size: 18),
                          label: const Text('Logout', style: TextStyle(color: Color(0xFFe94560), fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFe94560)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _passField(String label, TextEditingController ctrl, bool obscure, VoidCallback toggle, {String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          controller: ctrl, obscureText: obscure,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          validator: validator ?? (v) => (v == null || v.isEmpty) ? 'Required' : null,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.lock_outline_rounded, color: Colors.white38, size: 18),
            suffixIcon: IconButton(
              icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.white38, size: 18),
              onPressed: toggle,
            ),
            filled: true, fillColor: Colors.white.withValues(alpha: 0.08),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFe94560), width: 1.5)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFe94560))),
            focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFe94560))),
            errorStyle: const TextStyle(color: Color(0xFFff6b8a)),
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          ),
        ),
      ],
    );
  }
}
