import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../app_size/app_size.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  bool _isLoading = true;
  int _totalClasses = 0;
  int _totalPresent = 0;
  int _totalAbsent = 0;

  List<Map<String, dynamic>> _subjectAttendance = [];

  @override
  void initState() {
    super.initState();
    _fetchAttendanceReport();
  }

  Future<void> _fetchAttendanceReport() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      
      // Fetch student data to know their class & division
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (!userDoc.exists) return;
      final classId = userDoc.data()?['classId'];
      final divisionId = userDoc.data()?['divisionId'];

      if (classId == null || divisionId == null) {
        if(mounted) setState(() => _isLoading = false);
        return;
      }

      // Query sessions
      final sessionsSnap = await _firestore.collection('attendance_sessions')
          .where('classId', isEqualTo: classId)
          .where('divisionId', isEqualTo: divisionId)
          .get();

      // Query records
      final recordsSnap = await _firestore.collection('attendance_records')
          .where('studentId', isEqualTo: uid)
          .get();

      // Subject Meta Dictionary: Map subjectId -> Subject Name
      final subjectsSnap = await _firestore.collection('subjects').where('classId', isEqualTo: classId).get();
      Map<String, String> subjectNames = {
         for (var doc in subjectsSnap.docs) doc.id: doc.data()['name'] ?? "Unknown"
      };

      // Math computations: Map subjectId -> { 'total': 0, 'present': 0 }
      Map<String, Map<String, int>> attendanceTally = {};

      for (var sSnap in sessionsSnap.docs) {
         String subId = sSnap['subjectId'];
         attendanceTally[subId] = attendanceTally[subId] ?? {'total': 0, 'present': 0};
         attendanceTally[subId]!['total'] = attendanceTally[subId]!['total']! + 1;
      }

      for (var rSnap in recordsSnap.docs) {
         String subId = rSnap['subjectId'];
         if (attendanceTally.containsKey(subId)) {
            attendanceTally[subId]!['present'] = attendanceTally[subId]!['present']! + 1;
         }
      }

      // Final processing
      int totalAggregated = 0;
      int presentAggregated = 0;
      List<Map<String, dynamic>> processedSubjectData = [];

      attendanceTally.forEach((subId, counts) {
         int tot = counts['total']!;
         int pres = counts['present']!;
         
         totalAggregated += tot;
         presentAggregated += pres;

         int percentage = tot > 0 ? ((pres / tot) * 100).round() : 0;
         
         processedSubjectData.add({
            'subjectName': subjectNames[subId] ?? "Deleted Subject",
            'percentage': percentage,
            'present': pres,
            'total': tot
         });
      });
      
      if (mounted) {
        setState(() {
          _totalClasses = totalAggregated;
          _totalPresent = presentAggregated;
          _totalAbsent = (_totalClasses - _totalPresent) < 0 ? 0 : (_totalClasses - _totalPresent);
          _subjectAttendance = processedSubjectData;
          _isLoading = false;
        });
      }

    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double w = AppSize.width(context);
    final double h = AppSize.height(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Student Attendance Charts', style: TextStyle(color: Colors.white)),
          centerTitle: true,
          backgroundColor: const Color(0xFF0047AB),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        backgroundColor: const Color(0xFFF5F7FA),
        body: const Center(child: CircularProgressIndicator(color: Color(0xFF0047AB))),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Attendance Charts', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFF0047AB),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(w * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: h * 0.02),

              Row(
                children: [
                  _summaryChip("Total Classes", "$_totalClasses", Icons.class_rounded, w, h),
                  SizedBox(width: w * 0.03),
                  _summaryChip("Present", "$_totalPresent", Icons.check_circle_outline, w, h),
                  SizedBox(width: w * 0.03),
                  _summaryChip("Absent", "$_totalAbsent", Icons.cancel_outlined, w, h),
                ],
              ),
              SizedBox(height: h * 0.035),

              Text("Subject-wise History", style: TextStyle(fontSize: w * 0.05, fontWeight: FontWeight.bold)),
              SizedBox(height: h * 0.02),

              if (_subjectAttendance.isEmpty)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: h * 0.04),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                  child: const Center(child: Text("No attendance records found.", style: TextStyle(color: Colors.black45))),
                )
              else
                ..._subjectAttendance.map((data) => _subjectCard(
                    data['subjectName'], 
                    data['percentage'], 
                    w, h
                )),

              SizedBox(height: h * 0.03),

              Text("Monthly Trend", style: TextStyle(fontSize: w * 0.05, fontWeight: FontWeight.bold)),
              SizedBox(height: h * 0.015),

              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: h * 0.04, horizontal: w * 0.05),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 8, offset: const Offset(0, 3))],
                ),
                child: Column(
                  children: [
                    Icon(Icons.show_chart_rounded, size: w * 0.12, color: const Color(0xFF0047AB).withAlpha(102)),
                    SizedBox(height: h * 0.01),
                    Text("Chart Coming Soon", style: TextStyle(fontSize: w * 0.04, color: Colors.black45, fontWeight: FontWeight.w500)),
                    SizedBox(height: h * 0.005),
                    Text("Your monthly attendance trend will be dynamically plotted here.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: w * 0.03, color: Colors.black38),
                    ),
                  ],
                ),
              ),

              SizedBox(height: h * 0.03),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryChip(String label, String value, IconData icon, double w, double h) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: h * 0.015, horizontal: w * 0.02),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF0047AB), size: w * 0.055),
            SizedBox(height: h * 0.005),
            Text(value, style: TextStyle(fontSize: w * 0.05, fontWeight: FontWeight.bold, color: const Color(0xFF0047AB))),
            SizedBox(height: h * 0.003),
            Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: w * 0.025, color: Colors.black54)),
          ],
        ),
      ),
    );
  }

  Widget _subjectCard(String subject, int percent, double w, double h) {
    return Container(
      margin: EdgeInsets.only(bottom: h * 0.015),
      padding: EdgeInsets.all(w * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(w * 0.02),
                      decoration: BoxDecoration(color: const Color(0xFF0047AB).withAlpha(26), borderRadius: BorderRadius.circular(8)),
                      child: Icon(Icons.menu_book_rounded, color: const Color(0xFF0047AB), size: w * 0.045),
                    ),
                    SizedBox(width: w * 0.03),
                    Expanded(
                      child: Text(subject, style: TextStyle(fontSize: w * 0.04, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: w * 0.03, vertical: h * 0.005),
                decoration: BoxDecoration(
                  color: percent >= 85 ? Colors.green.withAlpha(26)
                        : percent >= 75 ? Colors.orange.withAlpha(26)
                        : Colors.red.withAlpha(26),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text("$percent%",
                  style: TextStyle(
                    fontSize: w * 0.038, fontWeight: FontWeight.bold,
                    color: percent >= 85 ? Colors.green
                         : percent >= 75 ? Colors.orange : Colors.red,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: h * 0.012),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: percent / 100,
              minHeight: 6,
              backgroundColor: const Color(0xFF0047AB).withAlpha(26),
              valueColor: AlwaysStoppedAnimation<Color>(
                percent >= 85 ? Colors.green
                     : percent >= 75 ? Colors.orange : Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}