// ignore_for_file: use_build_context_synchronously
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Screen/admin_dashboard_screen.dart';
import '../Screen/home_screen.dart';
import '../utils/app_config.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);
  static const routeName = '/auth-screen';

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Login fields
  final _loginFormKey = GlobalKey<FormState>();
  final _loginEmailCtrl = TextEditingController();
  final _loginPasswordCtrl = TextEditingController();
  bool _loginObscure = true;
  bool _loginLoading = false;
  String? _loginError;

  // Signup fields
  final _signupFormKey = GlobalKey<FormState>();
  final _signupNameCtrl = TextEditingController();
  final _signupEmailCtrl = TextEditingController();
  final _signupPasswordCtrl = TextEditingController();
  String _signupUserType = 'subadmin';
  bool _signupObscure = true;
  bool _signupLoading = false;
  String? _signupError;
  String? _signupSuccess;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailCtrl.dispose();
    _loginPasswordCtrl.dispose();
    _signupNameCtrl.dispose();
    _signupEmailCtrl.dispose();
    _signupPasswordCtrl.dispose();
    super.dispose();
  }

  // ── LOGIN ──────────────────────────────────────────────
  Future<void> _login() async {
    if (!_loginFormKey.currentState!.validate()) return;
    setState(() { _loginLoading = true; _loginError = null; });
    try {
      final res = await http.post(
        Uri.parse('$uri/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _loginEmailCtrl.text.trim(),
          'password': _loginPasswordCtrl.text,
        }),
      );
      final data = jsonDecode(res.body);
      if (data['code'] == '200') {
        final userDetails = data['data']['userDetails'];
        final token = data['data']['token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userData', jsonEncode({
          'token': token,
          'userId': userDetails['id'].toString(),
          'email': userDetails['email'],
          'name': userDetails['name'],
          'usertype': userDetails['user_type'],
        }));
        final userType = userDetails['user_type'];
        if (userType == 'superadmin' || userType == 'subadmin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
          );
        } else {
          setState(() => _loginError = 'Access denied. Admin credentials required.');
        }
      } else {
        setState(() => _loginError = data['message'] ?? 'Invalid email or password');
      }
    } catch (_) {
      setState(() => _loginError = 'Cannot connect to server. Make sure backend is running on port 3307.');
    }
    setState(() => _loginLoading = false);
  }

  // ── SIGNUP ─────────────────────────────────────────────
  Future<void> _signup() async {
    if (!_signupFormKey.currentState!.validate()) return;
    setState(() { _signupLoading = true; _signupError = null; _signupSuccess = null; });
    try {
      final res = await http.post(
        Uri.parse('$uri/createuser'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'login_type': 'superadmin', // required by backend to authorize creation
          'name': _signupNameCtrl.text.trim(),
          'email': _signupEmailCtrl.text.trim(),
          'password': _signupPasswordCtrl.text,
          'user_type': _signupUserType,
        }),
      );
      final data = jsonDecode(res.body);
      if (data['code'] == '200') {
        setState(() {
          _signupSuccess = 'User created successfully! You can now login.';
          _signupNameCtrl.clear();
          _signupEmailCtrl.clear();
          _signupPasswordCtrl.clear();
        });
        // Switch to login tab after 1.5s
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) _tabController.animateTo(0);
        });
      } else {
        setState(() => _signupError = data['message'] ?? 'Failed to create user');
      }
    } catch (_) {
      setState(() => _signupError = 'Cannot connect to server. Make sure backend is running on port 3307.');
    }
    setState(() => _signupLoading = false);
  }

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
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back
                    GestureDetector(
                      onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen())),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Logo + Title
                    Row(
                      children: [
                        Container(
                          width: 52, height: 52,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFFe94560), Color(0xFF0f3460)]),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Center(child: Text('🏗️', style: TextStyle(fontSize: 26))),
                        ),
                        const SizedBox(width: 14),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Construction CRM', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                            Text('Admin Portal', style: TextStyle(color: Colors.white38, fontSize: 13)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // Tab Bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFFe94560), Color(0xFFc62a47)]),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.white38,
                        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        tabs: const [
                          Tab(text: 'Sign In'),
                          Tab(text: 'Sign Up'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Tab Views
                    SizedBox(
                      height: 420,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildLoginForm(),
                          _buildSignupForm(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Center(
                      child: Text('© 2024 T.R Construction', style: TextStyle(color: Colors.white24, fontSize: 11)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── LOGIN FORM ─────────────────────────────────────────
  Widget _buildLoginForm() {
    return Form(
      key: _loginFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_loginError != null) ...[
            _errorBox(_loginError!),
            const SizedBox(height: 16),
          ],
          _label('Email Address'),
          _field(
            controller: _loginEmailCtrl,
            hint: 'admin@example.com',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (v) => (v == null || v.isEmpty) ? 'Enter your email' : null,
          ),
          const SizedBox(height: 16),
          _label('Password'),
          _field(
            controller: _loginPasswordCtrl,
            hint: '••••••••',
            icon: Icons.lock_outline_rounded,
            obscure: _loginObscure,
            suffix: IconButton(
              icon: Icon(_loginObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.white38, size: 18),
              onPressed: () => setState(() => _loginObscure = !_loginObscure),
            ),
            validator: (v) => (v == null || v.isEmpty) ? 'Enter your password' : null,
          ),
          const SizedBox(height: 28),
          _gradientButton(
            label: 'Sign In →',
            loading: _loginLoading,
            onTap: _login,
          ),
        ],
      ),
    );
  }

  // ── SIGNUP FORM ────────────────────────────────────────
  Widget _buildSignupForm() {
    return Form(
      key: _signupFormKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_signupError != null) ...[
              _errorBox(_signupError!),
              const SizedBox(height: 16),
            ],
            if (_signupSuccess != null) ...[
              _successBox(_signupSuccess!),
              const SizedBox(height: 16),
            ],
            _label('Full Name'),
            _field(
              controller: _signupNameCtrl,
              hint: 'John Doe',
              icon: Icons.person_outline_rounded,
              validator: (v) => (v == null || v.isEmpty) ? 'Enter full name' : null,
            ),
            const SizedBox(height: 14),
            _label('Email Address'),
            _field(
              controller: _signupEmailCtrl,
              hint: 'user@example.com',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (v) => (v == null || v.isEmpty) ? 'Enter email' : null,
            ),
            const SizedBox(height: 14),
            _label('Password'),
            _field(
              controller: _signupPasswordCtrl,
              hint: '••••••••',
              icon: Icons.lock_outline_rounded,
              obscure: _signupObscure,
              suffix: IconButton(
                icon: Icon(_signupObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.white38, size: 18),
                onPressed: () => setState(() => _signupObscure = !_signupObscure),
              ),
              validator: (v) => (v == null || v.length < 6) ? 'Min 6 characters' : null,
            ),
            const SizedBox(height: 14),
            _label('Role'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _signupUserType,
                  dropdownColor: const Color(0xFF1a1a2e),
                  isExpanded: true,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  iconEnabledColor: Colors.white38,
                  items: const [
                    DropdownMenuItem(value: 'subadmin', child: Text('Sub Admin')),
                    DropdownMenuItem(value: 'superadmin', child: Text('Super Admin')),
                  ],
                  onChanged: (v) => setState(() => _signupUserType = v!),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _gradientButton(
              label: 'Create Account →',
              loading: _signupLoading,
              onTap: _signup,
            ),
          ],
        ),
      ),
    );
  }

  // ── HELPERS ────────────────────────────────────────────
  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
  );

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white30),
        prefixIcon: Icon(icon, color: Colors.white38, size: 18),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.08),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFe94560), width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFe94560))),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFe94560))),
        errorStyle: const TextStyle(color: Color(0xFFff6b8a)),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      ),
    );
  }

  Widget _gradientButton({required String label, required bool loading, required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: loading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: EdgeInsets.zero,
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFe94560), Color(0xFFc62a47)]),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            alignment: Alignment.center,
            child: loading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(label, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  Widget _errorBox(String msg) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFFe94560).withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xFFe94560).withValues(alpha: 0.3)),
    ),
    child: Row(
      children: [
        const Icon(Icons.error_outline_rounded, color: Color(0xFFe94560), size: 16),
        const SizedBox(width: 8),
        Expanded(child: Text(msg, style: const TextStyle(color: Color(0xFFff6b8a), fontSize: 13))),
      ],
    ),
  );

  Widget _successBox(String msg) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFF10b981).withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xFF10b981).withValues(alpha: 0.3)),
    ),
    child: Row(
      children: [
        const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF10b981), size: 16),
        const SizedBox(width: 8),
        Expanded(child: Text(msg, style: const TextStyle(color: Color(0xFF10b981), fontSize: 13))),
      ],
    ),
  );
}
