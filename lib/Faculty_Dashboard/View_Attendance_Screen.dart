import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../app_size/app_size.dart';
import '../utils/Pdf_Report_Service.dart';

class ViewAttendanceScreen extends StatefulWidget {
  const ViewAttendanceScreen({super.key});

  @override
  State<ViewAttendanceScreen> createState() => ViewAttendanceScreenState();
}

// State is PUBLIC so FacultyMainNavigation can call refresh() via GlobalKey
class ViewAttendanceScreenState extends State<ViewAttendanceScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  String _searchQuery = '';
  String? _loadingSessionId; // tracks which card is generating PDF

  List<Map<String, dynamic>> _sessions = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(
      () => setState(() => _searchQuery = _searchController.text.trim()),
    );
    _fetchSessions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Called by FacultyMainNavigation after a QR session ends
  void refresh() {
    setState(() => _isLoading = true);
    _fetchSessions();
  }

  List<Map<String, dynamic>> get _filtered {
    if (_searchQuery.isEmpty) return _sessions;
    final q = _searchQuery.toLowerCase();
    return _sessions.where((s) {
      return s['subjectName'].toString().toLowerCase().contains(q) ||
          s['dateStr'].toString().toLowerCase().contains(q);
    }).toList();
  }

  Future<void> _fetchSessions() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final snap = await _firestore
          .collection('attendance_sessions')
          .where('facultyId', isEqualTo: uid)
          .get();

      final List<Map<String, dynamic>> list = [];

      for (final doc in snap.docs) {
        final data = doc.data();

        String subjectName = 'Unknown Subject';
        String departmentName = '';
        String className = '';

        if (data['subjectId'] != null) {
          final s = await _firestore.collection('subjects').doc(data['subjectId']).get();
          if (s.exists) subjectName = s.data()?['name'] ?? 'Subject';
        }
        if (data['departmentId'] != null) {
          final d = await _firestore.collection('departments').doc(data['departmentId']).get();
          if (d.exists) departmentName = d.data()?['name'] ?? '';
        }
        if (data['classId'] != null) {
          final c = await _firestore.collection('classes').doc(data['classId']).get();
          if (c.exists) className = c.data()?['name'] ?? '';
        }

        final dynamic rawTs = data['createdAt'];
        final DateTime ts = rawTs is Timestamp
            ? rawTs.toDate()
            : DateTime.now();

        list.add({
          'id': doc.id,
          'subjectName': subjectName,
          'dateStr': DateFormat('MMM dd, yyyy').format(ts),
          'startTime': data['startTime'] ?? '',
          'endTime': data['endTime'] ?? '',
          'labName': data['labName'] ?? '',
          'facultyName': data['facultyName'] ?? '',
          'classId': data['classId'],
          'departmentName': departmentName,
          'className': className,
          'date': data['date'] ?? DateFormat('MMM dd, yyyy').format(ts),
          '_sortTs': ts,
        });
      }

      // Sort newest first (client-side — avoids needing a Firestore composite index)
      list.sort((a, b) => (b['_sortTs'] as DateTime).compareTo(a['_sortTs'] as DateTime));

      if (mounted) setState(() { _sessions = list; _isLoading = false; });
    } catch (e) {
      debugPrint('Error fetching sessions: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Fetch students + records → generate PDF
  Future<void> _openPdf(Map<String, dynamic> session) async {
    setState(() => _loadingSessionId = session['id']);
    try {
      final classId = session['classId'];
      final sessionId = session['id'];

      debugPrint('PDF: sessionId=$sessionId, classId=$classId');

      // Fetch students by classId only (avoid composite index)
      final studentsSnap = await _firestore
          .collection('users')
          .where('classId', isEqualTo: classId)
          .get();

      // Filter to students only (client-side)
      final studentDocs = studentsSnap.docs
          .where((doc) => doc.data()['role'] == 'student')
          .toList();

      debugPrint('PDF: found ${studentDocs.length} students');

      // Fetch attendance records for this session
      final recordsSnap = await _firestore
          .collection('attendance_records')
          .where('sessionId', isEqualTo: sessionId)
          .get();

      debugPrint('PDF: found ${recordsSnap.docs.length} attendance records');

      final Set<String> presentIds = {};
      for (var r in recordsSnap.docs) {
        final sid = r.data()['studentId'];
        if (sid is String) presentIds.add(sid);
      }

      final List<Map<String, dynamic>> students = [];
      for (var doc in studentDocs) {
        final d = doc.data();
        students.add({
          'name': d['fullName'] ?? d['name'] ?? 'Unknown',
          'roll': d['rollNumber'] ?? d['rollNo'] ?? 'N/A',
          'status': presentIds.contains(doc.id) ? 'Present' : 'Absent',
        });
      }
      students.sort((a, b) => (a['roll'] ?? '').compareTo(b['roll'] ?? ''));

      final present = students.where((s) => s['status'] == 'Present').length;

      debugPrint('PDF: $present present, ${students.length - present} absent');

      if (!mounted) return;

      await PdfReportService.generateAndPrintAttendanceReport(
        subjectName: session['subjectName'] ?? 'Unknown',
        dateStr: session['dateStr'] ?? '',
        totalStudents: students.length,
        presentCount: present,
        absentCount: students.length - present,
        students: students,
        facultyName: session['facultyName'] ?? '',
        labName: session['labName'] ?? '',
        startTime: session['startTime'] ?? '',
        endTime: session['endTime'] ?? '',
        departmentName: session['departmentName'] ?? '',
        className: session['className'] ?? '',
      );
    } catch (e) {
      debugPrint('PDF generation error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate PDF: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingSessionId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double w = AppSize.width(context);
    final double h = AppSize.height(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Reports',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFF0047AB),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: refresh,
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            // ── Search bar ────────────────────────────────────────────────
            Container(
              color: Colors.white,
              padding: EdgeInsets.fromLTRB(w * 0.05, h * 0.015, w * 0.05, h * 0.015),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by subject or date...',
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF0047AB)),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () => _searchController.clear(),
                        )
                      : null,
                  filled: true,
                  fillColor: const Color(0xFFF5F7FA),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF0047AB))),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: const Color(0xFF0047AB).withAlpha(80))),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF0047AB), width: 2)),
                ),
              ),
            ),

            // ── Body ──────────────────────────────────────────────────────
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF0047AB)))
                  : _filtered.isEmpty
                      ? _emptyState(w, h)
                      : RefreshIndicator(
                          color: const Color(0xFF0047AB),
                          onRefresh: _fetchSessions,
                          child: ListView.builder(
                            padding: EdgeInsets.symmetric(
                                horizontal: w * 0.05, vertical: h * 0.02),
                            itemCount: _filtered.length,
                            itemBuilder: (_, i) => _sessionCard(_filtered[i], w, h),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Session card ──────────────────────────────────────────────────────────
  Widget _sessionCard(Map<String, dynamic> s, double w, double h) {
    final bool isLoading = _loadingSessionId == s['id'];
    final String timeSlot = (s['startTime'] as String).isNotEmpty
        ? '${s['startTime']}  –  ${s['endTime']}'
        : '';
    final String meta = [
      if ((s['departmentName'] as String).isNotEmpty) s['departmentName'],
      if ((s['className'] as String).isNotEmpty) s['className'],
      if ((s['labName'] as String).isNotEmpty) s['labName'],
    ].join('  •  ');

    return GestureDetector(
      onTap: isLoading ? null : () => _openPdf(s),
      child: Container(
        margin: EdgeInsets.only(bottom: h * 0.015),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withAlpha(12),
                blurRadius: 8,
                offset: const Offset(0, 3)),
          ],
        ),
        child: Row(
          children: [
            // Blue left accent bar
            Container(
              width: 5,
              height: h * 0.12,
              decoration: const BoxDecoration(
                color: Color(0xFF0047AB),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: w * 0.04, vertical: h * 0.016),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s['subjectName'],
                      style: TextStyle(
                          fontSize: w * 0.042,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87),
                    ),
                    SizedBox(height: h * 0.004),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded,
                            size: 13, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(s['dateStr'],
                            style: TextStyle(
                                fontSize: w * 0.03, color: Colors.black54)),
                        if (timeSlot.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.access_time_rounded,
                              size: 13, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(timeSlot,
                              style: TextStyle(
                                  fontSize: w * 0.03, color: Colors.black54)),
                        ],
                      ],
                    ),
                    if (meta.isNotEmpty) ...[
                      SizedBox(height: h * 0.003),
                      Text(meta,
                          style: TextStyle(
                              fontSize: w * 0.028, color: Colors.black38)),
                    ],
                  ],
                ),
              ),
            ),

            // PDF icon / loader
            Padding(
              padding: EdgeInsets.symmetric(horizontal: w * 0.04),
              child: isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: Color(0xFF0047AB)),
                    )
                  : const Icon(Icons.picture_as_pdf_rounded,
                      color: Color(0xFF0047AB), size: 28),
            ),
          ],
        ),
      ),
    );
  }

  // ── Empty state ───────────────────────────────────────────────────────────
  Widget _emptyState(double w, double h) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.folder_open_rounded,
              size: w * 0.2, color: const Color(0xFF0047AB).withAlpha(60)),
          SizedBox(height: h * 0.02),
          Text(
            _searchQuery.isNotEmpty
                ? 'No sessions match "$_searchQuery"'
                : 'No attendance sessions yet.',
            style: TextStyle(fontSize: w * 0.038, color: Colors.black45),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}