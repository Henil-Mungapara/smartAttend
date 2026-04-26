import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../app_size/app_size.dart';
import '../utils/Pdf_Report_Service.dart';

class ViewAttendanceScreen extends StatefulWidget {
  final String? initialSessionId;
  const ViewAttendanceScreen({super.key, this.initialSessionId});

  @override
  State<ViewAttendanceScreen> createState() => _ViewAttendanceScreenState();
}

class _ViewAttendanceScreenState extends State<ViewAttendanceScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  bool _isLoadingSessions = true;
  bool _isLoadingAttendance = false;
  
  List<Map<String, dynamic>> _sessions = [];
  String? _selectedSessionId;
  Map<String, dynamic>? _selectedSessionData;

  List<Map<String, dynamic>> _students = [];

  @override
  void initState() {
    super.initState();
    _fetchSessions().then((_) {
      if (widget.initialSessionId != null && _sessions.any((s) => s['id'] == widget.initialSessionId)) {
        _fetchAttendanceForSession(widget.initialSessionId!);
      }
    });
  }

  Future<void> _fetchSessions() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final snapshot = await _firestore.collection('attendance_sessions')
          .where('facultyId', isEqualTo: uid)
          .orderBy('timestamp', descending: true)
          .get();

      List<Map<String, dynamic>> sessionList = [];

      for (var doc in snapshot.docs) {
        var data = doc.data();
        String subName = "Unknown Subject";
        if (data['subjectId'] != null) {
          final subDoc = await _firestore.collection('subjects').doc(data['subjectId']).get();
          if (subDoc.exists) subName = subDoc.data()?['name'] ?? "Subject";
        }

        DateTime ts = (data['timestamp'] as Timestamp).toDate();
        String timeStr = DateFormat('MMM dd, yyyy - hh:mm a').format(ts);

        sessionList.add({
          'id': doc.id,
          'label': "$subName ($timeStr)",
          'classId': data['classId'],
          'subjectName': subName,
          'dateStr': DateFormat('MMM dd, yyyy').format(ts),
        });
      }

      if (mounted) {
        setState(() {
          _sessions = sessionList;
          _isLoadingSessions = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingSessions = false);
    }
  }

  Future<void> _fetchAttendanceForSession(String sessionId) async {
    setState(() {
      _isLoadingAttendance = true;
      _selectedSessionId = sessionId;
      _selectedSessionData = _sessions.firstWhere((s) => s['id'] == sessionId);
      _students.clear();
    });

    try {
      final classId = _selectedSessionData!['classId'];
      
      final studentsSnap = await _firestore.collection('users')
          .where('role', isEqualTo: 'student')
          .where('classId', isEqualTo: classId)
          .get();
      
      final recordsSnap = await _firestore.collection('attendance_records')
          .where('sessionId', isEqualTo: sessionId)
          .get();
          
      Set<String> presentStudentIds = {};
      for (var record in recordsSnap.docs) {
        presentStudentIds.add(record.data()['studentId']);
      }

      List<Map<String, dynamic>> resultList = [];
      for (var doc in studentsSnap.docs) {
        var data = doc.data();
        bool isPresent = presentStudentIds.contains(doc.id);
        resultList.add({
          'name': data['fullName'] ?? data['name'] ?? "Unknown",
          'roll': data['rollNumber'] ?? data['rollNo'] ?? "N/A",
          'status': isPresent ? "Present" : "Absent",
        });
      }

      resultList.sort((a, b) => a['roll'].compareTo(b['roll']));

      if (mounted) {
        setState(() {
          _students = resultList;
          _isLoadingAttendance = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingAttendance = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double w = AppSize.width(context);
    final double h = AppSize.height(context);

    int presentCount = _students.where((s) => s["status"] == "Present").length;
    int absentCount = _students.length - presentCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('View Attendance', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFF0047AB),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_selectedSessionData != null && !_isLoadingAttendance)
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              onPressed: () async {
                await PdfReportService.generateAndPrintAttendanceReport(
                  subjectName: _selectedSessionData!['subjectName'],
                  dateStr: _selectedSessionData!['dateStr'],
                  totalStudents: _students.length,
                  presentCount: presentCount,
                  absentCount: absentCount,
                  students: _students,
                );
              },
            ),
        ],
      ),
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: w * 0.05, vertical: h * 0.02),
              color: Colors.white,
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Select Session", style: TextStyle(fontSize: w * 0.04, fontWeight: FontWeight.bold, color: Colors.black87)),
                  SizedBox(height: h * 0.01),
                  if (_isLoadingSessions)
                    const Center(child: CircularProgressIndicator(color: Color(0xFF0047AB)))
                  else if (_sessions.isEmpty)
                    Text("No attendance sessions found.", style: TextStyle(color: Colors.red, fontSize: w * 0.035))
                  else
                    DropdownButtonFormField<String>(
                      value: _selectedSessionId,
                      isExpanded: true,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        filled: true,
                        fillColor: const Color(0xFFF5F7FA),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF0047AB))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF0047AB))),
                      ),
                      hint: const Text("Select Session"),
                      items: _sessions.map((s) => DropdownMenuItem<String>(
                        value: s['id'],
                        child: Text(s['label'], overflow: TextOverflow.ellipsis),
                      )).toList(),
                      onChanged: (val) {
                        if (val != null) _fetchAttendanceForSession(val);
                      },
                    ),
                ],
              ),
            ),

            if (_selectedSessionData != null && !_isLoadingAttendance)
              Container(
                width: double.infinity,
                margin: EdgeInsets.all(w * 0.05),
                padding: EdgeInsets.all(w * 0.04),
                decoration: BoxDecoration(
                  color: const Color(0xFF0047AB),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: const Color(0xFF0047AB).withAlpha(77), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Column(
                  children: [
                    Text(_selectedSessionData!['subjectName'], style: TextStyle(fontSize: w * 0.048, fontWeight: FontWeight.bold, color: Colors.white)),
                    SizedBox(height: h * 0.005),
                    Text(_selectedSessionData!['dateStr'], style: TextStyle(fontSize: w * 0.032, color: Colors.white70)),
                    SizedBox(height: h * 0.015),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _miniStat("Total", "${_students.length}", Colors.white, w),
                        Container(height: h * 0.03, width: 1, color: Colors.white38),
                        _miniStat("Present", "$presentCount", Colors.greenAccent, w),
                        Container(height: h * 0.03, width: 1, color: Colors.white38),
                        _miniStat("Absent", "$absentCount", Colors.redAccent, w),
                      ],
                    ),
                  ],
                ),
              ),

            if (_isLoadingAttendance)
               Expanded(child: Center(child: CircularProgressIndicator(color: const Color(0xFF0047AB)))),

            if (_selectedSessionData != null && !_isLoadingAttendance)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: w * 0.06),
                child: Row(
                  children: [
                    Text("Student List", style: TextStyle(fontSize: w * 0.042, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Text("${_students.length} Students", style: TextStyle(fontSize: w * 0.03, color: Colors.black54)),
                  ],
                ),
              ),

            if (_selectedSessionData != null && !_isLoadingAttendance) SizedBox(height: h * 0.01),

            if (_selectedSessionData != null && !_isLoadingAttendance && _students.isEmpty)
              Padding(
                padding: EdgeInsets.only(top: h * 0.05),
                child: const Text("No students enrolled in this class.", style: TextStyle(color: Colors.black54)),
              ),

            if (_selectedSessionData != null && !_isLoadingAttendance && _students.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: w * 0.05),
                  itemCount: _students.length,
                  itemBuilder: (context, index) {
                    final student = _students[index];
                    bool isPresent = student["status"] == "Present";

                    return Container(
                      margin: EdgeInsets.only(bottom: h * 0.01),
                      padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: h * 0.014),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 4, offset: const Offset(0, 2))],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: w * 0.05,
                            backgroundColor: const Color(0xFF0047AB).withAlpha(20),
                            child: Text(student["name"][0].toUpperCase(), style: TextStyle(fontSize: w * 0.042, fontWeight: FontWeight.bold, color: const Color(0xFF0047AB))),
                          ),
                          SizedBox(width: w * 0.035),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(student["name"], style: TextStyle(fontSize: w * 0.037, fontWeight: FontWeight.w600)),
                                SizedBox(height: h * 0.003),
                                Text(student["roll"], style: TextStyle(fontSize: w * 0.028, color: Colors.black54)),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: w * 0.03, vertical: 5),
                            decoration: BoxDecoration(
                              color: isPresent ? Colors.green.withAlpha(26) : Colors.red.withAlpha(26),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(isPresent ? Icons.check_circle_rounded : Icons.cancel_rounded, size: w * 0.035, color: isPresent ? Colors.green : Colors.red),
                                SizedBox(width: w * 0.01),
                                Text(student["status"], style: TextStyle(fontSize: w * 0.028, fontWeight: FontWeight.w600, color: isPresent ? Colors.green : Colors.red)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _miniStat(String label, String value, Color valueColor, double w) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: w * 0.048, fontWeight: FontWeight.bold, color: valueColor)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: w * 0.028, color: Colors.white70)),
      ],
    );
  }
}