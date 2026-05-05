import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../app_size/app_size.dart';
import '../utils/UiHelper.dart';
import 'package:intl/intl.dart';

import 'View_Attendance_Screen.dart';
import 'Generate_QrScreen.dart';

class FacultyDashboardScreen extends StatefulWidget {
  const FacultyDashboardScreen({super.key});

  @override
  State<FacultyDashboardScreen> createState() => _FacultyDashboardScreenState();
}

class _FacultyDashboardScreenState extends State<FacultyDashboardScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  String _facultyName = "Loading...";
  int _totalStudents = 0;
  int _classesToday = 0;
  
  List<Map<String, dynamic>> _assignedSubjects = [];
  List<Map<String, dynamic>> _recentActivities = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return;

      final data = doc.data()!;
      if (mounted) {
        setState(() {
          _facultyName = data['fullName'] ?? data['name'] ?? "Faculty";
        });
      }

      List<dynamic> classIds = data['classIds'] ?? [];
      List<dynamic> subjectIds = data['subjectIds'] ?? [];

      if (classIds.isNotEmpty) {
        final studentsQuery = await _firestore.collection('users').where('role', isEqualTo: 'student').where('classId', whereIn: classIds).get();
        _totalStudents = studentsQuery.docs.length;
      }

      if (subjectIds.isNotEmpty) {
        final subDocs = await _firestore.collection('subjects').where(FieldPath.documentId, whereIn: subjectIds).get();
        _assignedSubjects = subDocs.docs.map((e) => {
          'id': e.id,
          'name': e['name'],
        }).toList();
      }

      // Fetch all sessions for this faculty (no orderBy = no composite index needed)
      final allSessionsSnap = await _firestore.collection('attendance_sessions')
          .where('facultyId', isEqualTo: uid)
          .get();

      DateTime now = DateTime.now();
      DateTime startOfDay = DateTime(now.year, now.month, now.day);

      // Count today's classes
      _classesToday = allSessionsSnap.docs.where((doc) {
        final raw = doc.data()['createdAt'];
        if (raw is! Timestamp) return false;
        final dt = raw.toDate();
        return dt.isAfter(startOfDay) && dt.isBefore(startOfDay.add(const Duration(days: 1)));
      }).length;

      // Sort all sessions by createdAt descending, take top 3
      final sortedDocs = allSessionsSnap.docs.toList()
        ..sort((a, b) {
          final aTs = a.data()['createdAt'];
          final bTs = b.data()['createdAt'];
          if (aTs is! Timestamp || bTs is! Timestamp) return 0;
          return bTs.compareTo(aTs);
        });

      List<Map<String, dynamic>> activities = [];
      for (var session in sortedDocs.take(3)) {
        var sData = session.data();
        final raw = sData['createdAt'];
        DateTime ts = raw is Timestamp ? raw.toDate() : DateTime.now();
        String timeStr = DateFormat('hh:mm a').format(ts);
        
        String subName = "Unknown Subject";
        if (sData['subjectId'] != null) {
          final sDoc = await _firestore.collection('subjects').doc(sData['subjectId']).get();
          if (sDoc.exists) subName = sDoc.data()?['name'] ?? "Subject";
        }
        
        activities.add({
          'title': "Attendance generated for $subName",
          'time': "${DateFormat('MMM dd').format(ts)}, $timeStr",
        });
      }

      _recentActivities = activities;

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching dashboard: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F7FA),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF0047AB))),
      );
    }

    final double w = AppSize.width(context);
    final double h = AppSize.height(context);
    final String currentDate = DateFormat('EEEE, dd MMM yyyy').format(DateTime.now());

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        UIHelper.showExitAlert(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Faculty Dashboard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: const Color(0xFF0047AB),
          elevation: 0,
        ),
        backgroundColor: const Color(0xFFF5F7FA),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: w * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: h * 0.03),
                Center(
                  child: Column(
                    children: [
                      Text("Welcome back, $_facultyName 👨‍🏫", style: TextStyle(fontSize: w * 0.055, fontWeight: FontWeight.bold, color: const Color(0xFF0047AB))),
                      SizedBox(height: h * 0.005),
                      Text(currentDate, style: TextStyle(fontSize: w * 0.035, color: Colors.black54)),
                    ],
                  ),
                ),
                SizedBox(height: h * 0.03),

                Row(
                  children: [
                    _statCard(Icons.people_rounded, "Total Students", _totalStudents.toString(), w, h),
                    SizedBox(width: w * 0.035),
                    _statCard(Icons.class_rounded, "Classes Today", _classesToday.toString(), w, h),
                  ],
                ),
                SizedBox(height: h * 0.03),

                Text("Quick Actions", style: TextStyle(fontSize: w * 0.048, fontWeight: FontWeight.bold)),
                SizedBox(height: h * 0.015),

                _actionCard(
                  icon: Icons.qr_code_rounded,
                  title: "Generate Attendance",
                  subtitle: "Create QR code for your lecture",
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const GenerateAttendanceScreen()));
                  },
                  w: w, h: h,
                ),
                _actionCard(
                  icon: Icons.bar_chart_rounded,
                  title: "View Attendance",
                  subtitle: "Check student attendance records",
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ViewAttendanceScreen()));
                  },
                  w: w, h: h,
                ),

                SizedBox(height: h * 0.03),
                Text("Assigned Subjects", style: TextStyle(fontSize: w * 0.048, fontWeight: FontWeight.bold)),
                SizedBox(height: h * 0.015),

                if (_assignedSubjects.isEmpty)
                   const Text("No subjects assigned", style: TextStyle(color: Colors.grey))
                else
                   ..._assignedSubjects.map((sub) => _scheduleCard(sub['name'], "Dynamic Assignment", w, h)),

                SizedBox(height: h * 0.03),
                Text("Recent Activity", style: TextStyle(fontSize: w * 0.048, fontWeight: FontWeight.bold)),
                SizedBox(height: h * 0.015),

                if (_recentActivities.isEmpty)
                   const Text("No recent activities", style: TextStyle(color: Colors.grey))
                else
                   ..._recentActivities.map((act) => _activityItem(act['title'], act['time'], Icons.check_circle_rounded, Colors.green, w, h)),

                SizedBox(height: h * 0.04),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statCard(IconData icon, String label, String value, double w, double h) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: h * 0.02, horizontal: w * 0.02),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF0047AB), size: w * 0.07),
            SizedBox(height: h * 0.01),
            Text(value, style: TextStyle(fontSize: w * 0.055, fontWeight: FontWeight.bold, color: const Color(0xFF0047AB))),
            SizedBox(height: h * 0.003),
            Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: w * 0.03, color: Colors.black54)),
          ],
        ),
      ),
    );
  }

  Widget _actionCard({required IconData icon, required String title, required String subtitle, required VoidCallback onTap, required double w, required double h}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: EdgeInsets.only(bottom: h * 0.012),
        padding: EdgeInsets.all(w * 0.04),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 6, offset: const Offset(0, 3))]),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(w * 0.03),
              decoration: BoxDecoration(color: const Color(0xFF0047AB).withAlpha(20), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: const Color(0xFF0047AB), size: w * 0.06),
            ),
            SizedBox(width: w * 0.04),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: w * 0.04, fontWeight: FontWeight.w600)),
                  SizedBox(height: h * 0.003),
                  Text(subtitle, style: TextStyle(fontSize: w * 0.03, color: Colors.black54)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: w * 0.04, color: Colors.black38),
          ],
        ),
      ),
    );
  }

  Widget _scheduleCard(String subject, String time, double w, double h) {
    return Container(
      margin: EdgeInsets.only(bottom: h * 0.012),
      padding: EdgeInsets.all(w * 0.04),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 6, offset: const Offset(0, 3))]),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(w * 0.025),
            decoration: BoxDecoration(color: const Color(0xFF0047AB).withAlpha(20), borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.menu_book_rounded, color: const Color(0xFF0047AB), size: w * 0.05),
          ),
          SizedBox(width: w * 0.035),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(subject, style: TextStyle(fontSize: w * 0.038, fontWeight: FontWeight.w600)),
                SizedBox(height: h * 0.003),
                Text(time, style: TextStyle(fontSize: w * 0.03, color: Colors.black54)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _activityItem(String title, String time, IconData icon, Color color, double w, double h) {
    return Container(
      margin: EdgeInsets.only(bottom: h * 0.01),
      padding: EdgeInsets.symmetric(vertical: h * 0.015, horizontal: w * 0.035),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 4, offset: const Offset(0, 2))]),
      child: Row(
        children: [
          Icon(icon, color: color, size: w * 0.05),
          SizedBox(width: w * 0.035),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: w * 0.033, fontWeight: FontWeight.w500)),
                SizedBox(height: h * 0.003),
                Text(time, style: TextStyle(fontSize: w * 0.027, color: Colors.black45)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}