// ignore_for_file: use_build_context_synchronously
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/app_config.dart';

class TrackComplaintScreen extends StatefulWidget {
  const TrackComplaintScreen({super.key});
  static const routeName = '/track-complaint';

  @override
  State<TrackComplaintScreen> createState() => _TrackComplaintScreenState();
}

class _TrackComplaintScreenState extends State<TrackComplaintScreen> {
  final _ctrl = TextEditingController();
  bool _loading = false;
  Map<String, dynamic>? _result;
  String? _error;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _track() async {
    if (_ctrl.text.trim().isEmpty) return;
    setState(() { _loading = true; _result = null; _error = null; });
    try {
      final res = await http.post(
        Uri.parse('$uri/complainttracking'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'complaint_id': _ctrl.text.trim()}),
      );
      final data = jsonDecode(res.body);
      if (data['code'] == '200') {
        setState(() => _result = data['data']['complaintDetail']);
      } else {
        setState(() => _error = 'Complaint not found. Check your tracking ID.');
      }
    } catch (_) {
      setState(() => _error = 'Server error. Check your connection.');
    }
    setState(() => _loading = false);
  }

  Color _statusColor(String? s) {
    switch (s) {
      case 'resolved': return const Color(0xFF10b981);
      case 'closed':   return const Color(0xFF6b7280);
      default:         return const Color(0xFFf59e0b);
    }
  }

  IconData _statusIcon(String? s) {
    switch (s) {
      case 'resolved': return Icons.check_circle_rounded;
      case 'closed':   return Icons.lock_rounded;
      default:         return Icons.hourglass_top_rounded;
    }
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
                      child: Text('Track Complaint',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      // Search card
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
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10b981).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.search_rounded, color: Color(0xFF10b981), size: 20),
                                ),
                                const SizedBox(width: 12),
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Track Your Complaint',
                                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                    Text('Enter your tracking ID below',
                                        style: TextStyle(color: Colors.white38, fontSize: 12)),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _ctrl,
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                              decoration: InputDecoration(
                                hintText: 'Enter Tracking ID...',
                                hintStyle: const TextStyle(color: Colors.white30),
                                prefixIcon: const Icon(Icons.tag_rounded, color: Colors.white38, size: 18),
                                filled: true,
                                fillColor: Colors.white.withValues(alpha: 0.08),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFF10b981), width: 1.5)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              ),
                              onFieldSubmitted: (_) => _track(),
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _loading ? null : _track,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF10b981),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: _loading
                                    ? const SizedBox(height: 20, width: 20,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                    : const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.search_rounded, color: Colors.white, size: 18),
                                          SizedBox(width: 8),
                                          Text('Track Complaint',
                                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                                        ],
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Error
                      if (_error != null)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFe94560).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFe94560).withValues(alpha: 0.3)),
                          ),
                          child: Row(children: [
                            const Icon(Icons.error_outline_rounded, color: Color(0xFFe94560), size: 20),
                            const SizedBox(width: 10),
                            Expanded(child: Text(_error!,
                                style: const TextStyle(color: Color(0xFFff6b8a), fontSize: 14))),
                          ]),
                        ),
                      // Result
                      if (_result != null) ...[
                        const Text('Complaint Details',
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 14),
                        // Status banner
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _statusColor(_result!['status_type']).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: _statusColor(_result!['status_type']).withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(_statusIcon(_result!['status_type']),
                                  color: _statusColor(_result!['status_type']), size: 28),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Current Status',
                                      style: TextStyle(color: Colors.white54, fontSize: 12)),
                                  Text(
                                    (_result!['status_type'] ?? '').toUpperCase(),
                                    style: TextStyle(
                                        color: _statusColor(_result!['status_type']),
                                        fontSize: 18, fontWeight: FontWeight.w800),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        // Details card
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                          ),
                          child: Column(
                            children: [
                              _resultRow(Icons.person_outline_rounded, 'Name', _result!['name']),
                              _resultRow(Icons.email_outlined, 'Email', _result!['email']),
                              _resultRow(Icons.phone_outlined, 'Mobile', _result!['mobile']),
                              _resultRow(Icons.location_on_outlined, 'Address', _result!['address']),
                              _resultRow(Icons.category_outlined, 'Type',
                                  _result!['complent_type'] ?? _result!['complaint_type'] ?? '—', isLast: true),
                            ],
                          ),
                        ),
                      ],
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

  Widget _resultRow(IconData icon, String key, String? val, {bool isLast = false}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    decoration: BoxDecoration(
      border: isLast ? null : const Border(bottom: BorderSide(color: Color(0x10FFFFFF))),
    ),
    child: Row(
      children: [
        Icon(icon, color: Colors.white38, size: 16),
        const SizedBox(width: 10),
        SizedBox(width: 70, child: Text(key, style: const TextStyle(color: Colors.white38, fontSize: 13))),
        Expanded(
          child: Text(val ?? '—',
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
              textAlign: TextAlign.right),
        ),
      ],
    ),
  );
}
