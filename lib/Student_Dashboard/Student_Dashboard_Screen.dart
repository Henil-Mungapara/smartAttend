import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../app_size/app_size.dart';
import '../utils/UiHelper.dart';
import 'Attendance_Report_Screen.dart';
import 'Scan_Qr_Screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? _userData;
  
  int _totalClasses = 0;
  int _present = 0;
  int _absent = 0;
  double _attendancePercentage = 0.0;
  
  bool _isLoading = true;
  List<Map<String, dynamic>> _recentSessions = [];

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      // 1. Fetch User Data
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return;
      final userData = doc.data()!;
      
      final classId = userData['classId'];
      final divisionId = userData['divisionId'];

      if (classId != null && divisionId != null) {
        // 2. Fetch Total Sessions for Student's Class & Division
        final sessionsSnap = await _firestore.collection('attendance_sessions')
            .where('classId', isEqualTo: classId)
            .where('divisionId', isEqualTo: divisionId)
            .get();
        
        _totalClasses = sessionsSnap.docs.length;

        // Populate recent schedule from sessions
        _recentSessions = sessionsSnap.docs.map((e) {
             var data = e.data();
             data['id'] = e.id;
             return data;
        }).toList();
        
        _recentSessions.sort((a, b) {
           Timestamp t1 = a['createdAt'] ?? Timestamp.now();
           Timestamp t2 = b['createdAt'] ?? Timestamp.now();
           return t2.compareTo(t1); // Descending
        });
        _recentSessions = _recentSessions.take(3).toList();

        // 3. Fetch Student's Attendance Records
        final recordsSnap = await _firestore.collection('attendance_records')
            .where('studentId', isEqualTo: uid)
            .get();

        _present = recordsSnap.docs.length;
        _absent = (_totalClasses - _present) < 0 ? 0 : (_totalClasses - _present);
        
        if (_totalClasses > 0) {
           _attendancePercentage = (_present / _totalClasses);
        }
      }

      if (mounted) {
        setState(() {
          _userData = userData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
           _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double w = AppSize.width(context);
    final double h = AppSize.height(context);

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFB6BFCA),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF0047AB))),
      );
    }

    final name = _userData?['name'] ?? "Student";
    final todayStr = DateFormat('EEEE, dd MMM yyyy').format(DateTime.now());

    return WillPopScope(
      onWillPop: () async {
        UIHelper.showExitAlert(context);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Student Dashboard', style: TextStyle(color: Colors.white)),
          centerTitle: true,
          backgroundColor: const Color(0xFF0047AB),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        backgroundColor: const Color(0xFFB6BFCA),
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
                      Text("Welcome, $name 👋", style: TextStyle(fontSize: w * 0.06, fontWeight: FontWeight.bold)),
                      SizedBox(height: h * 0.005),
                      Text(todayStr, style: TextStyle(fontSize: w * 0.035, color: Colors.black54)),
                    ],
                  ),
                ),
                SizedBox(height: h * 0.03),

                Row(
                  children: [
                    Expanded(
                      child: _statCard(
                        icon: Icons.check_circle_outline, label: "Total Present",
                        value: "$_present", w: w, h: h,
                      ),
                    ),
                    SizedBox(width: w * 0.04),
                    Expanded(
                      child: _statCard(
                        icon: Icons.cancel_outlined, label: "Total Absent",
                        value: "$_absent", w: w, h: h,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: h * 0.025),

                // Overall Progress Card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(w * 0.05),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0047AB),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [BoxShadow(color: const Color(0xFF0047AB).withAlpha(77), blurRadius: 12, offset: const Offset(0, 6))],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Overall Attendance", style: TextStyle(fontSize: w * 0.04, color: Colors.white70)),
                            SizedBox(height: h * 0.01),
                            Text("${(_attendancePercentage * 100).toStringAsFixed(1)}%", style: TextStyle(fontSize: w * 0.1, fontWeight: FontWeight.bold, color: Colors.white)),
                            SizedBox(height: h * 0.005),
                            Text("$_totalClasses Total Classes", style: TextStyle(fontSize: w * 0.032, color: Colors.white60)),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: w * 0.22, height: w * 0.22,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: w * 0.2, height: w * 0.2,
                              child: CircularProgressIndicator(
                                value: _attendancePercentage, strokeWidth: 8,
                                backgroundColor: Colors.white24,
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            Icon(Icons.school_rounded, color: Colors.white, size: w * 0.08),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: h * 0.035),

                Text("Recent Sessions", style: TextStyle(fontSize: w * 0.048, fontWeight: FontWeight.bold)),
                SizedBox(height: h * 0.015),

                if (_recentSessions.isEmpty) ...[
                   Container(
                     width: double.infinity,
                     padding: EdgeInsets.all(w * 0.05),
                     decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                     child: const Center(child: Text("No sessions available.", style: TextStyle(color: Colors.black45))),
                   )
                ] else ...[
                   ..._recentSessions.map((session) {
                       return _scheduleCard(
                         subject: "Date: ${session['date']}", 
                         time: "${session['startTime']} - ${session['endTime']}",
                         room: "Faculty: ${session['facultyName']}", 
                         icon: Icons.calendar_today,
                         w: w, h: h,
                       );
                   })
                ],

                SizedBox(height: h * 0.03),

                Text("Quick Actions", style: TextStyle(fontSize: w * 0.048, fontWeight: FontWeight.bold)),
                SizedBox(height: h * 0.015),

                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScanQRPage())),
                        child: _quickActionCard(icon: Icons.qr_code_scanner_rounded, label: "Scan QR", w: w, h: h),
                      ),
                    ),
                    SizedBox(width: w * 0.04),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendancePage())),
                        child: _quickActionCard(icon: Icons.bar_chart_rounded, label: "View Report", w: w, h: h),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: h * 0.04),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statCard({required IconData icon, required String label, required String value, required double w, required double h}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: h * 0.02, horizontal: w * 0.04),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF0047AB), size: w * 0.07),
          SizedBox(height: h * 0.008),
          Text(value, style: TextStyle(fontSize: w * 0.06, fontWeight: FontWeight.bold, color: const Color(0xFF0047AB))),
          SizedBox(height: h * 0.004),
          Text(label, style: TextStyle(fontSize: w * 0.032, color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _scheduleCard({required String subject, required String time, required String room, required IconData icon, required double w, required double h}) {
    return Container(
      margin: EdgeInsets.only(bottom: h * 0.012),
      padding: EdgeInsets.all(w * 0.04),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 6, offset: const Offset(0, 3))],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(w * 0.025),
            decoration: BoxDecoration(color: const Color(0xFF0047AB).withAlpha(26), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: const Color(0xFF0047AB), size: w * 0.06),
          ),
          SizedBox(width: w * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(subject, style: TextStyle(fontSize: w * 0.04, fontWeight: FontWeight.w600)),
                SizedBox(height: h * 0.004),
                Text(time, style: TextStyle(fontSize: w * 0.032, color: Colors.black54)),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: w * 0.025, vertical: h * 0.006),
            decoration: BoxDecoration(color: const Color(0xFF0047AB).withAlpha(26), borderRadius: BorderRadius.circular(8)),
            child: Text(room, style: TextStyle(fontSize: w * 0.024, color: const Color(0xFF0047AB), fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _quickActionCard({required IconData icon, required String label, required double w, required double h}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: h * 0.025),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(w * 0.035),
            decoration: BoxDecoration(color: const Color(0xFF0047AB).withAlpha(26), shape: BoxShape.circle),
            child: Icon(icon, color: const Color(0xFF0047AB), size: w * 0.07),
          ),
          SizedBox(height: h * 0.01),
          Text(label, style: TextStyle(fontSize: w * 0.036, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}