// ignore_for_file: use_build_context_synchronously
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/app_config.dart';

class ComplaintHistoryScreen extends StatefulWidget {
  const ComplaintHistoryScreen({super.key});
  static const routeName = '/complaint-history';
  @override
  State<ComplaintHistoryScreen> createState() => _ComplaintHistoryScreenState();
}

class _ComplaintHistoryScreenState extends State<ComplaintHistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _emailCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  bool _loading = false;
  List<dynamic> _complaints = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose(); _emailCtrl.dispose(); _mobileCtrl.dispose();
    super.dispose();
  }

  Future<void> _search({String? email, String? mobile}) async {
    setState(() { _loading = true; _complaints = []; _error = null; });
    try {
      final body = <String, String>{};
      if (email != null && email.isNotEmpty) body['email'] = email;
      if (mobile != null && mobile.isNotEmpty) body['mobile'] = mobile;

      final res = await http.post(
        Uri.parse('$uri/complainthistory'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      final data = jsonDecode(res.body);
      if (data['code'] == '200') {
        final list = data['data']['complaints'] as List? ?? [];
        if (list.isEmpty) setState(() => _error = 'No complaints found for this ${email != null ? "email" : "mobile"}.');
        else setState(() => _complaints = list);
      } else {
        setState(() => _error = 'No complaints found.');
      }
    } catch (_) { setState(() => _error = 'Server error. Check connection.'); }
    setState(() => _loading = false);
  }

  Color _statusColor(String? s) {
    switch (s) {
      case 'resolved': return const Color(0xFF10b981);
      case 'closed': return const Color(0xFF6b7280);
      default: return const Color(0xFFf59e0b);
    }
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
                    const Expanded(child: Text('Complaint History', textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold))),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(12)),
                  child: TabBar(
                    controller: _tabCtrl,
                    indicator: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFe94560), Color(0xFFc62a47)]),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white38,
                    labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    tabs: const [Tab(text: 'By Email'), Tab(text: 'By Mobile')],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  height: 110,
                  child: TabBarView(
                    controller: _tabCtrl,
                    children: [
                      _searchBox(_emailCtrl, 'your@email.com', Icons.email_outlined, TextInputType.emailAddress,
                          () => _search(email: _emailCtrl.text.trim())),
                      _searchBox(_mobileCtrl, '+91 XXXXX XXXXX', Icons.phone_outlined, TextInputType.phone,
                          () => _search(mobile: _mobileCtrl.text.trim())),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFFe94560)))
                    : _error != null
                        ? Center(child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                              const Icon(Icons.inbox_rounded, color: Colors.white12, size: 64),
                              const SizedBox(height: 12),
                              Text(_error!, style: const TextStyle(color: Colors.white38, fontSize: 14), textAlign: TextAlign.center),
                            ]),
                          ))
                        : _complaints.isEmpty
                            ? const Center(child: Text('Search by email or mobile to see history',
                                style: TextStyle(color: Colors.white24, fontSize: 14), textAlign: TextAlign.center))
                            : ListView.builder(
                                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                                itemCount: _complaints.length,
                                itemBuilder: (_, i) => _historyCard(_complaints[i]),
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _searchBox(TextEditingController ctrl, String hint, IconData icon, TextInputType type, VoidCallback onSearch) {
    return Column(
      children: [
        TextFormField(
          controller: ctrl, keyboardType: type,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          onFieldSubmitted: (_) => onSearch(),
          decoration: InputDecoration(
            hintText: hint, hintStyle: const TextStyle(color: Colors.white30),
            prefixIcon: Icon(icon, color: Colors.white38, size: 18),
            filled: true, fillColor: Colors.white.withValues(alpha: 0.08),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFe94560), width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity, height: 46,
          child: ElevatedButton(
            onPressed: onSearch,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFe94560),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Search History', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _historyCard(Map<String, dynamic> c) {
    final color = _statusColor(c['status_type']);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(c['complaint_type'] ?? 'Complaint',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
                child: Text((c['status_type'] ?? '').toUpperCase(),
                    style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(c['complaintDetails'] ?? c['complentDetails'] ?? '—',
              style: const TextStyle(color: Colors.white54, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.tag_rounded, color: Colors.white24, size: 14),
              const SizedBox(width: 4),
              Expanded(child: Text(c['complaint_id']?.toString() ?? '—',
                  style: const TextStyle(color: Colors.white24, fontSize: 11), overflow: TextOverflow.ellipsis)),
            ],
          ),
        ],
      ),
    );
  }
}
