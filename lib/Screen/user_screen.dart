// ignore_for_file: use_build_context_synchronously
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../utils/app_config.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});
  static const routeName = "/complaint-screen";

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _detailsCtrl = TextEditingController();
  String _complaintType = 'Rework';
  bool _isLoading = false;
  File? _imageFile;
  final _picker = ImagePicker();

  final List<String> _types = ['Rework', 'Maintenance', 'Development', 'Other'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _mobileCtrl.dispose();
    _addressCtrl.dispose();
    _detailsCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitComplaint() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final request = http.MultipartRequest('POST', Uri.parse('$uri/createcomplaints'));
      request.fields.addAll({
        'name': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'mobile': _mobileCtrl.text.trim(),
        'address': _addressCtrl.text.trim(),
        'complaint_type': _complaintType,
        'complaintDetails': _detailsCtrl.text.trim(),
        'user_type': 'user',
      });
      if (_imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath('image_proof', _imageFile!.path));
      }
      final streamedRes = await request.send();
      final res = await http.Response.fromStream(streamedRes);
      final data = jsonDecode(res.body);
      if (data['code'] == '200') {
        final trackingId = data['data']['trackingId'].toString();
        _nameCtrl.clear(); _emailCtrl.clear(); _mobileCtrl.clear();
        _addressCtrl.clear(); _detailsCtrl.clear();
        setState(() { _complaintType = 'Rework'; _imageFile = null; });
        _showTrackingDialog(trackingId);
      } else {
        _showSnack('Failed: ${data['data']?['message'] ?? 'Unknown error'}');
      }
    } catch (_) {
      _showSnack('Cannot connect to server. Check your connection.');
    }
    setState(() => _isLoading = false);
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFFe94560),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showTrackingDialog(String trackingId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1a1a2e),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF10b981).withValues(alpha: 0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFF10b981).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, color: Color(0xFF10b981), size: 36),
              ),
              const SizedBox(height: 16),
              const Text('Complaint Submitted!',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Save your tracking ID to check status later.',
                  style: TextStyle(color: Colors.white54, fontSize: 13), textAlign: TextAlign.center),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF10b981).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF10b981).withValues(alpha: 0.4)),
                ),
                child: Column(
                  children: [
                    const Text('Tracking ID', style: TextStyle(color: Colors.white38, fontSize: 12)),
                    const SizedBox(height: 6),
                    Text(trackingId,
                        style: const TextStyle(
                            color: Color(0xFF10b981), fontSize: 22, fontWeight: FontWeight.w800,
                            letterSpacing: 2)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10b981),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Done', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
          child: Column(
            children: [
              // AppBar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
                      ),
                    ),
                    const Expanded(
                      child: Text('Submit Complaint',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
              // Form
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Full Name'),
                        _field(controller: _nameCtrl, hint: 'Your full name', icon: Icons.person_outline_rounded,
                            validator: (v) => (v == null || v.isEmpty) ? 'Enter your name' : null),
                        const SizedBox(height: 16),
                        _label('Email Address'),
                        _field(controller: _emailCtrl, hint: 'your@email.com', icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) => (v == null || v.isEmpty) ? 'Enter your email' : null),
                        const SizedBox(height: 16),
                        _label('Mobile Number'),
                        _field(controller: _mobileCtrl, hint: '+91 XXXXX XXXXX', icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            validator: (v) => (v == null || v.isEmpty) ? 'Enter mobile number' : null),
                        const SizedBox(height: 16),
                        _label('Complaint Type'),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _complaintType,
                              dropdownColor: const Color(0xFF1a1a2e),
                              isExpanded: true,
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                              iconEnabledColor: Colors.white38,
                              items: _types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                              onChanged: (v) => setState(() => _complaintType = v!),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _label('Address'),
                        _field(controller: _addressCtrl, hint: 'Site / property address',
                            icon: Icons.location_on_outlined, maxLines: 2,
                            validator: (v) => (v == null || v.isEmpty) ? 'Enter address' : null),
                        const SizedBox(height: 16),
                        _label('Complaint Details'),
                        _field(controller: _detailsCtrl, hint: 'Describe your complaint in detail...',
                            icon: Icons.description_outlined, maxLines: 4,
                            validator: (v) => (v == null || v.isEmpty) ? 'Enter complaint details' : null),
                        const SizedBox(height: 16),
                        _label('Attach Image (Optional)'),
                        GestureDetector(
                          onTap: () async {
                            final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
                            if (picked != null) setState(() => _imageFile = File(picked.path));
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _imageFile != null
                                  ? const Color(0xFF10b981).withValues(alpha: 0.5)
                                  : Colors.white.withValues(alpha: 0.1)),
                            ),
                            child: _imageFile != null
                                ? Row(children: [
                                    const Icon(Icons.check_circle_rounded, color: Color(0xFF10b981), size: 20),
                                    const SizedBox(width: 10),
                                    Expanded(child: Text(_imageFile!.path.split('/').last,
                                        style: const TextStyle(color: Color(0xFF10b981), fontSize: 13), overflow: TextOverflow.ellipsis)),
                                    GestureDetector(
                                      onTap: () => setState(() => _imageFile = null),
                                      child: const Icon(Icons.close_rounded, color: Colors.white38, size: 18),
                                    ),
                                  ])
                                : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                    Icon(Icons.add_photo_alternate_outlined, color: Colors.white38, size: 22),
                                    SizedBox(width: 10),
                                    Text('Tap to attach image', style: TextStyle(color: Colors.white38, fontSize: 14)),
                                  ]),
                          ),
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submitComplaint,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              padding: EdgeInsets.zero,
                            ),
                            child: Ink(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [Color(0xFFe94560), Color(0xFFc62a47)]),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Container(
                                alignment: Alignment.center,
                                child: _isLoading
                                    ? const SizedBox(width: 22, height: 22,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                    : const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.send_rounded, color: Colors.white, size: 18),
                                          SizedBox(width: 8),
                                          Text('Submit Complaint',
                                              style: TextStyle(color: Colors.white, fontSize: 15,
                                                  fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
  );

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white30),
        prefixIcon: Padding(
          padding: EdgeInsets.only(bottom: maxLines > 1 ? (maxLines * 10.0) : 0),
          child: Icon(icon, color: Colors.white38, size: 18),
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.08),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFe94560), width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFe94560))),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFe94560))),
        errorStyle: const TextStyle(color: Color(0xFFff6b8a)),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      ),
    );
  }
}
