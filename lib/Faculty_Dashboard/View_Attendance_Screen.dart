import 'package:flutter/material.dart';
import '../app_size/app_size.dart';

class ViewAttendanceScreen extends StatelessWidget {
  const ViewAttendanceScreen({super.key});

  // Static student attendance data
  static const List<Map<String, dynamic>> _students = [
    {"name": "Rahul Sharma", "roll": "CS-01", "status": "Present"},
    {"name": "Priya Patel", "roll": "CS-02", "status": "Present"},
    {"name": "Amit Kumar", "roll": "CS-03", "status": "Absent"},
    {"name": "Sneha Gupta", "roll": "CS-04", "status": "Present"},
    {"name": "Vikram Singh", "roll": "CS-05", "status": "Present"},
    {"name": "Anjali Desai", "roll": "CS-06", "status": "Absent"},
    {"name": "Rohan Mehta", "roll": "CS-07", "status": "Present"},
    {"name": "Kavita Joshi", "roll": "CS-08", "status": "Present"},
    {"name": "Arjun Nair", "roll": "CS-09", "status": "Present"},
    {"name": "Deepika Rao", "roll": "CS-10", "status": "Absent"},
  ];

  @override
  Widget build(BuildContext context) {
    final double w = AppSize.width(context);
    final double h = AppSize.height(context);

    // Count present/absent
    int presentCount = _students.where((s) => s["status"] == "Present").length;
    int absentCount = _students.length - presentCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'View Attendance',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0047AB),
      ),
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [

            // ── Subject & Date Info ──
            Container(
              width: double.infinity,
              margin: EdgeInsets.all(w * 0.05),
              padding: EdgeInsets.all(w * 0.04),
              decoration: BoxDecoration(
                color: const Color(0xFF0047AB),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0047AB).withAlpha(77),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    "Flutter Development",
                    style: TextStyle(
                      fontSize: w * 0.048,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: h * 0.005),
                  Text(
                    "3rd Semester  •  08 Mar 2026",
                    style: TextStyle(fontSize: w * 0.032, color: Colors.white70),
                  ),
                  SizedBox(height: h * 0.015),

                  // Stats row
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

            // ── Section Header ──
            Padding(
              padding: EdgeInsets.symmetric(horizontal: w * 0.06),
              child: Row(
                children: [
                  Text(
                    "Student List",
                    style: TextStyle(fontSize: w * 0.042, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Text(
                    "${_students.length} Students",
                    style: TextStyle(fontSize: w * 0.03, color: Colors.black54),
                  ),
                ],
              ),
            ),

            SizedBox(height: h * 0.01),

            // ── Student List ──
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
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(8),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Avatar
                        CircleAvatar(
                          radius: w * 0.05,
                          backgroundColor: const Color(0xFF0047AB).withAlpha(20),
                          child: Text(
                            student["name"]![0],
                            style: TextStyle(
                              fontSize: w * 0.042,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0047AB),
                            ),
                          ),
                        ),
                        SizedBox(width: w * 0.035),

                        // Name & Roll
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                student["name"]!,
                                style: TextStyle(fontSize: w * 0.037, fontWeight: FontWeight.w600),
                              ),
                              SizedBox(height: h * 0.003),
                              Text(
                                student["roll"]!,
                                style: TextStyle(fontSize: w * 0.028, color: Colors.black54),
                              ),
                            ],
                          ),
                        ),

                        // Status badge
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: w * 0.03, vertical: 5),
                          decoration: BoxDecoration(
                            color: isPresent ? Colors.green.withAlpha(26) : Colors.red.withAlpha(26),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isPresent ? Icons.check_circle_rounded : Icons.cancel_rounded,
                                size: w * 0.035,
                                color: isPresent ? Colors.green : Colors.red,
                              ),
                              SizedBox(width: w * 0.01),
                              Text(
                                student["status"]!,
                                style: TextStyle(
                                  fontSize: w * 0.028,
                                  fontWeight: FontWeight.w600,
                                  color: isPresent ? Colors.green : Colors.red,
                                ),
                              ),
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

  // ── Mini Stat inside blue card ──
  Widget _miniStat(String label, String value, Color valueColor, double w) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: w * 0.048,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: w * 0.028, color: Colors.white70),
        ),
      ],
    );
  }
}