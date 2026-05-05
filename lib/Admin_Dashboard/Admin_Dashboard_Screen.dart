import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../app_size/app_size.dart';

class Admin_Dashboard_Screen extends StatefulWidget {
  const Admin_Dashboard_Screen({super.key});

  @override
  State<Admin_Dashboard_Screen> createState() => _Admin_Dashboard_ScreenState();
}

class _Admin_Dashboard_ScreenState extends State<Admin_Dashboard_Screen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = true;
  String _adminName = "Admin";
  int _totalStudents = 0;
  int _totalFaculty = 0;
  int _totalDepartments = 0;
  
  int _classesToday = 0;
  int _presentToday = 0;
  int _absentToday = 0;
  String _avgAttendance = "0%";

  String _collegeName = "SmartAttend Engineering College";
  String _academicYear = "2025 - 2026";
  String _semesters = "Even Semester (Jan - Jun)";

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    try {
      // 1. Admin Info
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final doc = await _firestore.collection('users').doc(uid).get();
        if (doc.exists) {
          _adminName = doc.data()?['fullName'] ?? doc.data()?['name'] ?? "Admin";
        }
      }

      // 2. Overview Stats (Students, Faculty, Departments)
      final studentsSnap = await _firestore.collection('users').where('role', isEqualTo: 'student').get();
      _totalStudents = studentsSnap.docs.length;

      final facultySnap = await _firestore.collection('users').where('role', isEqualTo: 'faculty').get();
      _totalFaculty = facultySnap.docs.length;

      final deptSnap = await _firestore.collection('departments').get();
      _totalDepartments = deptSnap.docs.length;

      // College Info
      final collegeSnap = await _firestore.collection('colleges').limit(1).get();
      if (collegeSnap.docs.isNotEmpty) {
        _collegeName = collegeSnap.docs.first.data()['name'] ?? "SmartAttend College";
      }

      // 3. Today's Overview (Classes, Present, Absent)
      DateTime now = DateTime.now();
      DateTime startOfDay = DateTime(now.year, now.month, now.day);
      DateTime endOfDay = startOfDay.add(const Duration(days: 1));

      final sessionsSnap = await _firestore
          .collection('attendance_sessions')
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('createdAt', isLessThan: Timestamp.fromDate(endOfDay))
          .get();

      _classesToday = sessionsSnap.docs.length;
      
      int expectedStudents = 0;
      int presentStudents = 0;

      for (var session in sessionsSnap.docs) {
        final sessionId = session.id;
        final classId = session.data()['classId'];

        if (classId != null) {
          final classStudentsSnap = await _firestore
               .collection('users')
               .where('role', isEqualTo: 'student')
               .where('classId', isEqualTo: classId)
               .get();
          expectedStudents += classStudentsSnap.docs.length;
        }

        final recordsSnap = await _firestore
            .collection('attendance_records')
            .where('sessionId', isEqualTo: sessionId)
            .get();
        presentStudents += recordsSnap.docs.length;
      }

      _presentToday = presentStudents;
      _absentToday = (expectedStudents - presentStudents).clamp(0, expectedStudents);
      
      if (expectedStudents > 0) {
        double avg = (presentStudents / expectedStudents) * 100;
        _avgAttendance = "${avg.round()}%";
      } else {
        _avgAttendance = "0%";
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching admin dashboard data: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: w * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: h * 0.012),

              Center(
                child: Column(
                  children: [
                    Text(
                      "Welcome, $_adminName 👨‍💼",
                      style: TextStyle(
                        fontSize: w * 0.052,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: h * 0.003),
                    Text(
                      currentDate,
                      style: TextStyle(fontSize: w * 0.03, color: Colors.black54),
                    ),
                  ],
                ),
              ),

              SizedBox(height: h * 0.015),

              Row(
                children: [
                  _statCard(Icons.people_rounded, "Total Students", _totalStudents.toString(), Colors.blue, w, h),
                  SizedBox(width: w * 0.025),
                  _statCard(Icons.person_rounded, "Total Faculty", _totalFaculty.toString(), Colors.green, w, h),
                ],
              ),
              SizedBox(height: h * 0.008),
              Row(
                children: [
                  _statCard(Icons.class_rounded, "Departments", _totalDepartments.toString(), Colors.orange, w, h),
                  SizedBox(width: w * 0.025),
                  _statCard(Icons.check_circle_outline, "Avg Attendance", _avgAttendance, Colors.purple, w, h),
                ],
              ),

              SizedBox(height: h * 0.015),

              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: h * 0.012),
                decoration: BoxDecoration(
                  color: const Color(0xFF0047AB),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0047AB).withAlpha(77),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Today's Overview",
                      style: TextStyle(
                        fontSize: w * 0.038,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: h * 0.008),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _overviewStat("Classes", _classesToday.toString(), w),
                        Container(height: h * 0.03, width: 1, color: Colors.white38),
                        _overviewStat("Present", _presentToday.toString(), w),
                        Container(height: h * 0.03, width: 1, color: Colors.white38),
                        _overviewStat("Absent", _absentToday.toString(), w),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: h * 0.018),

              Text(
                "College Info",
                style: TextStyle(fontSize: w * 0.04, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: h * 0.008),

              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _infoTile(Icons.account_balance_rounded, "College", _collegeName, Colors.indigo, w, h),
                    _infoTile(Icons.apartment_rounded, "Departments", "$_totalDepartments Departments Registered", Colors.orange, w, h),
                    _infoTile(Icons.school_rounded, "Students", "$_totalStudents Enrolled Students", Colors.blue, w, h),
                    _infoTile(Icons.person_rounded, "Faculty", "$_totalFaculty Faculty Members", Colors.green, w, h),
                    _infoTile(Icons.calendar_today_rounded, "Academic Year", _academicYear, Colors.teal, w, h),
                    _infoTile(Icons.access_time_rounded, "Semesters", _semesters, Colors.deepPurple, w, h),
                    SizedBox(height: h * 0.01),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(IconData icon, String label, String value, Color color, double w, double h) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: h * 0.012, horizontal: w * 0.025),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withAlpha(26),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: w * 0.05),
            ),
            SizedBox(width: w * 0.02),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(fontSize: w * 0.042, fontWeight: FontWeight.bold, color: color),
                  ),
                  Text(
                    label,
                    style: TextStyle(fontSize: w * 0.023, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _overviewStat(String label, String value, double w) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: w * 0.045, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: w * 0.026, color: Colors.white70)),
      ],
    );
  }

  Widget _infoTile(IconData icon, String title, String subtitle, Color color, double w, double h) {
    return Container(
      margin: EdgeInsets.only(bottom: h * 0.006),
      padding: EdgeInsets.symmetric(horizontal: w * 0.03, vertical: h * 0.012),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 3, offset: const Offset(0, 1)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(26),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: w * 0.045),
          ),
          SizedBox(width: w * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: w * 0.03, fontWeight: FontWeight.w600, color: Colors.black54)),
                SizedBox(height: h * 0.002),
                Text(subtitle, style: TextStyle(fontSize: w * 0.033, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}