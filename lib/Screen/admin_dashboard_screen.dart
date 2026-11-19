// ignore_for_file: use_build_context_synchronously
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_config.dart';
import '../Screen/home_screen.dart';
import '../Screen/profile_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});
  static const routeName = '/admin-dashboard';

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  List<dynamic> _complaints = [];
  List<dynamic> _filtered = [];
  bool _loading = true;
  String _search = '';
  String _statusFilter = 'all';
  String _userName = '';
  String _userType = '';
  String _token = '';
  String _userId = '';
  int _selectedTab = 0; // 0=Dashboard(stats), 1=Complaints

  @override
  void initState() {
    super.initState();
    _loadUserAndFetch();
  }

  Future<void> _loadUserAndFetch() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('userData');
    if (raw == null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      return;
    }
    final data = jsonDecode(raw);
    setState(() {
      _token = data['token'] ?? '';
      _userName = data['name'] ?? 'Admin';
      _userType = data['usertype'] ?? '';
      _userId = data['userId'] ?? '';
    });
    await _fetchComplaints();
  }

  Future<void> _fetchComplaints() async {
    setState(() => _loading = true);
    try {
      final res = await http.post(
        Uri.parse('$uri/complaintslist'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $_token'},
        body: jsonEncode({'user_type': _userType, 'user_id': int.tryParse(_userId) ?? 0}),
      );
      final data = jsonDecode(res.body);
      if (data['code'] == '200') {
        setState(() {
          _complaints = data['data']['complaintList'] ?? [];
          _applyFilter();
        });
      }
    } catch (_) {}
    setState(() => _loading = false);
  }

  void _applyFilter() {
    List<dynamic> list = _complaints;
    if (_statusFilter != 'all') list = list.where((c) => c['status_type'] == _statusFilter).toList();
    if (_search.isNotEmpty) {
      list = list.where((c) =>
        (c['name'] ?? '').toLowerCase().contains(_search.toLowerCase()) ||
        (c['email'] ?? '').toLowerCase().contains(_search.toLowerCase()) ||
        (c['mobile'] ?? '').contains(_search)
      ).toList();
    }
    setState(() => _filtered = list);
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
  }

  Color _statusColor(String? s) {
    switch (s) {
      case 'resolved': return const Color(0xFF10b981);
      case 'closed':   return const Color(0xFF6b7280);
      default:         return const Color(0xFFf59e0b);
    }
  }

  int get _total    => _complaints.length;
  int get _process  => _complaints.where((c) => c['status_type'] == 'process').length;
  int get _resolved => _complaints.where((c) => c['status_type'] == 'resolved').length;
  int get _closed   => _complaints.where((c) => c['status_type'] == 'closed').length;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;
    return Scaffold(
      backgroundColor: const Color(0xFF0d1117),
      body: SafeArea(
        child: isWide
            ? Row(children: [_buildSidebar(), Expanded(child: _buildMain())])
            : Column(children: [_buildTopBar(), Expanded(child: _buildMain())]),
      ),
      bottomNavigationBar: isWide ? null : _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1a1a2e),
        border: Border(top: BorderSide(color: Color(0x15FFFFFF))),
      ),
      child: Row(
        children: [
          _bottomNavItem(Icons.dashboard_rounded, 'Dashboard', 0),
          _bottomNavItem(Icons.list_alt_rounded, 'Complaints', 1),
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person_outline_rounded, color: Colors.white54, size: 22),
                    SizedBox(height: 3),
                    Text('Profile', style: TextStyle(color: Colors.white54, fontSize: 10)),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: _logout,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.logout_rounded, color: Color(0xFFe94560), size: 22),
                    SizedBox(height: 3),
                    Text('Logout', style: TextStyle(color: Color(0xFFe94560), fontSize: 10)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomNavItem(IconData icon, String label, int tab) {
    final active = _selectedTab == tab;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = tab),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: active ? const Color(0xFFe94560) : Colors.white38, size: 22),
              const SizedBox(height: 3),
              Text(label, style: TextStyle(
                color: active ? const Color(0xFFe94560) : Colors.white38, fontSize: 10,
                fontWeight: active ? FontWeight.bold : FontWeight.normal,
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 200,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
        ),
        border: Border(right: BorderSide(color: Color(0x10FFFFFF))),
      ),
      child: Column(
        children: [
          const SizedBox(height: 24),
          const Text('🏗️', style: TextStyle(fontSize: 32)),
          const SizedBox(height: 8),
          const Text('Construction', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
          const Text('Admin Panel', style: TextStyle(color: Colors.white38, fontSize: 11)),
          const SizedBox(height: 20),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFe94560), Color(0xFF0f3460)]),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      _userName.isNotEmpty ? _userName[0].toUpperCase() : 'A',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_userName, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                      Text(_userType, style: const TextStyle(color: Colors.white38, fontSize: 10)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _sidebarItem(Icons.dashboard_rounded, 'Dashboard', 0),
          _sidebarItem(Icons.list_alt_rounded, 'Complaints', 1),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(10)),
              child: const Row(children: [
                Icon(Icons.person_outline_rounded, color: Colors.white38, size: 18),
                SizedBox(width: 10),
                Text('Profile', style: TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.w500)),
              ]),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: _logout,
            child: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFe94560).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFe94560).withValues(alpha: 0.3)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout_rounded, color: Color(0xFFe94560), size: 16),
                  SizedBox(width: 6),
                  Text('Logout', style: TextStyle(color: Color(0xFFe94560), fontSize: 13, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _sidebarItem(IconData icon, String label, int tab) {
    final active = _selectedTab == tab;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = tab),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          gradient: active ? const LinearGradient(colors: [Color(0xFFe94560), Color(0xFFc62a47)]) : null,
          color: active ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: active ? Colors.white : Colors.white38, size: 18),
            const SizedBox(width: 10),
            Text(label, style: TextStyle(color: active ? Colors.white : Colors.white54, fontSize: 13, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildMain() {
    return Column(
      children: [
        _buildTopBar(),
        Expanded(child: _selectedTab == 0 ? _buildStatsTab() : _buildComplaintsTab()),
      ],
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: Color(0xFF0d1117),
        border: Border(bottom: BorderSide(color: Color(0x10FFFFFF))),
      ),
      child: Row(
        children: [
          Text(
            _selectedTab == 0 ? 'Dashboard' : 'Complaints',
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const Spacer(),
          GestureDetector(
            onTap: _fetchComplaints,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.refresh_rounded, color: Colors.white54, size: 16),
                  SizedBox(width: 6),
                  Text('Refresh', style: TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFe94560), Color(0xFF0f3460)]),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(_userName.isNotEmpty ? _userName[0].toUpperCase() : 'A',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Welcome back, $_userName!',
                      style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                  Text(_userType, style: const TextStyle(color: Colors.white38, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Overview', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _statCard('Total', _total.toString(), Icons.list_alt_rounded, const Color(0xFFe94560)),
              _statCard('In Process', _process.toString(), Icons.hourglass_top_rounded, const Color(0xFFf59e0b)),
              _statCard('Resolved', _resolved.toString(), Icons.check_circle_rounded, const Color(0xFF10b981)),
              _statCard('Closed', _closed.toString(), Icons.lock_rounded, const Color(0xFF6b7280)),
            ],
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => setState(() => _selectedTab = 1),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.list_alt_rounded, color: Color(0xFFe94560), size: 20),
                  SizedBox(width: 12),
                  Text('View All Complaints', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                  Spacer(),
                  Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 14),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 18),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: TextStyle(color: color, fontSize: 26, fontWeight: FontWeight.w800)),
              Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: Column(
            children: [
              TextField(
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search by name, email, mobile...',
                  hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
                  prefixIcon: const Icon(Icons.search_rounded, color: Colors.white30, size: 20),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.06),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onChanged: (v) { _search = v; _applyFilter(); },
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['all', 'process', 'resolved', 'closed'].map((s) {
                    final active = _statusFilter == s;
                    return GestureDetector(
                      onTap: () { setState(() => _statusFilter = s); _applyFilter(); },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                        decoration: BoxDecoration(
                          gradient: active ? const LinearGradient(colors: [Color(0xFFe94560), Color(0xFFc62a47)]) : null,
                          color: active ? null : Colors.white.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: active ? Colors.transparent : Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: Text(
                          s == 'all' ? 'All' : s[0].toUpperCase() + s.substring(1),
                          style: TextStyle(color: active ? Colors.white : Colors.white54, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFFe94560)))
              : _filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox_rounded, color: Colors.white12, size: 64),
                          const SizedBox(height: 12),
                          const Text('No complaints found', style: TextStyle(color: Colors.white38, fontSize: 15)),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchComplaints,
                      color: const Color(0xFFe94560),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        itemCount: _filtered.length,
                        itemBuilder: (_, i) => _complaintCard(_filtered[i]),
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _complaintCard(Map<String, dynamic> c) {
    final color = _statusColor(c['status_type']);
    return GestureDetector(
      onTap: () => _showComplaintDetail(c),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
              child: Center(
                child: Text(
                  (c['name'] ?? 'U')[0].toUpperCase(),
                  style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c['name'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(c['email'] ?? '', style: const TextStyle(color: Colors.white38, fontSize: 12), overflow: TextOverflow.ellipsis),
                  Text(c['mobile'] ?? '', style: const TextStyle(color: Colors.white38, fontSize: 12)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
                  child: Text((c['status_type'] ?? '').toUpperCase(),
                      style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 6),
                const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 13),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showComplaintDetail(Map<String, dynamic> c) {
    int selectedStatusId = c['status_id'] ?? 1;
    final statusOptions = [
      {'id': 1, 'name': 'Process'},
      {'id': 2, 'name': 'Resolved'},
      {'id': 3, 'name': 'Closed'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Color(0xFF1a1a2e),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 16),
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Text('Complaint Details',
                        style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: _statusColor(c['status_type']).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        (c['status_type'] ?? '').toUpperCase(),
                        style: TextStyle(color: _statusColor(c['status_type']), fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _detailRow('Name', c['name']),
                      _detailRow('Email', c['email']),
                      _detailRow('Mobile', c['mobile']),
                      _detailRow('Address', c['address']),
                      _detailRow('Type', c['complent_type'] ?? c['complaint_type'] ?? '—'),
                      _detailRow('Details', c['complentDetails'] ?? c['complaintDetails'] ?? '—', isLast: true),
                      const SizedBox(height: 20),
                      if (_userType == 'superadmin' || _userType == 'subadmin') ...[
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Update Status',
                              style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: selectedStatusId,
                              dropdownColor: const Color(0xFF1a1a2e),
                              isExpanded: true,
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                              iconEnabledColor: Colors.white38,
                              items: statusOptions.map((s) => DropdownMenuItem<int>(
                                value: s['id'] as int,
                                child: Text(s['name'] as String),
                              )).toList(),
                              onChanged: (v) => setModalState(() => selectedStatusId = v!),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              await _changeStatus(c['complaint_id'], selectedStatusId);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFe94560),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Update Status',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
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

  Widget _detailRow(String key, String? val, {bool isLast = false}) => Container(
    padding: const EdgeInsets.symmetric(vertical: 12),
    decoration: BoxDecoration(
      border: isLast ? null : const Border(bottom: BorderSide(color: Color(0x10FFFFFF))),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 80, child: Text(key, style: const TextStyle(color: Colors.white38, fontSize: 13))),
        Expanded(child: Text(val ?? '—',
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500))),
      ],
    ),
  );

  Future<void> _changeStatus(dynamic complaintId, int statusId) async {
    try {
      final res = await http.post(
        Uri.parse('$uri/complaintstatuschange'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $_token'},
        body: jsonEncode({'complaint_id': complaintId, 'status_id': statusId}),
      );
      final data = jsonDecode(res.body);
      if (data['code'] == '200') {
        // Remove resolved/closed complaints from the list view
        if (statusId == 2 || statusId == 3) {
          setState(() {
            _complaints.removeWhere((c) => c['complaint_id'] == complaintId);
            _applyFilter();
          });
        } else {
          await _fetchComplaints();
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Status updated successfully!'),
            backgroundColor: const Color(0xFF10b981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to update status'),
            backgroundColor: const Color(0xFFe94560),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (_) {}
  }
}
