import 'package:flutter/material.dart';
import '../app_size/app_size.dart';

class Admin_AttendanceReport_Screen extends StatelessWidget {
  const Admin_AttendanceReport_Screen({super.key});

  static const List<Map<String, dynamic>> _reportData = [
    {"dept": "Software Engineering", "total": 60, "present": 55, "absent": 5},
    {"dept": "Computer Science", "total": 55, "present": 48, "absent": 7},
    {"dept": "Information Technology", "total": 50, "present": 42, "absent": 8},
    {"dept": "Electronics", "total": 45, "present": 35, "absent": 10},
    {"dept": "Mechanical", "total": 40, "present": 32, "absent": 8},
    {"dept": "Civil Engineering", "total": 35, "present": 30, "absent": 5},
  ];

  @override
  Widget build(BuildContext context) {
    final double w = AppSize.width(context);
    final double h = AppSize.height(context);
    int totalStudents = 0, totalPresent = 0, totalAbsent = 0;
    for (var d in _reportData) {
      totalStudents += d["total"] as int;
      totalPresent += d["present"] as int;
      totalAbsent += d["absent"] as int;
    }
    int avgPercent = (totalPresent * 100 / totalStudents).round();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [

            Container(
              width: double.infinity,
              margin: EdgeInsets.fromLTRB(w * 0.04, w * 0.03, w * 0.04, 0),
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
                children: [
                  Text(
                    "Attendance Summary",
                    style: TextStyle(
                      fontSize: w * 0.04,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: h * 0.003),
                  Text(
                    "08 Mar 2026 • All Departments",
                    style: TextStyle(fontSize: w * 0.027, color: Colors.white70),
                  ),
                  SizedBox(height: h * 0.012),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _summaryItem("Total", "$totalStudents", Colors.white, w),
                      Container(height: h * 0.03, width: 1, color: Colors.white38),
                      _summaryItem("Present", "$totalPresent", Colors.greenAccent, w),
                      Container(height: h * 0.03, width: 1, color: Colors.white38),
                      _summaryItem("Absent", "$totalAbsent", Colors.redAccent, w),
                      Container(height: h * 0.03, width: 1, color: Colors.white38),
                      _summaryItem("Avg %", "$avgPercent%", Colors.amberAccent, w),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: h * 0.01),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: w * 0.04),
              child: Row(
                children: [
                  _filterChip("Today", true, w),
                  SizedBox(width: w * 0.02),
                  _filterChip("This Week", false, w),
                  SizedBox(width: w * 0.02),
                  _filterChip("This Month", false, w),
                ],
              ),
            ),

            SizedBox(height: h * 0.01),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: w * 0.05),
              child: Row(
                children: [
                  Text(
                    "Department Wise",
                    style: TextStyle(fontSize: w * 0.038, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Text(
                    "${_reportData.length} Departments",
                    style: TextStyle(fontSize: w * 0.026, color: Colors.black54),
                  ),
                ],
              ),
            ),

            SizedBox(height: h * 0.006),

            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: w * 0.04),
                itemCount: _reportData.length,
                itemBuilder: (context, index) {
                  final dept = _reportData[index];
                  int total = dept["total"] as int;
                  int present = dept["present"] as int;
                  int absent = dept["absent"] as int;
                  int percent = (present * 100 / total).round();

                  return Container(
                    margin: EdgeInsets.only(bottom: h * 0.008),
                    padding: EdgeInsets.all(w * 0.03),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(10),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0047AB).withAlpha(20),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.apartment_rounded, color: const Color(0xFF0047AB), size: w * 0.04),
                            ),
                            SizedBox(width: w * 0.025),
                            Expanded(
                              child: Text(
                                dept["dept"],
                                style: TextStyle(fontSize: w * 0.033, fontWeight: FontWeight.w600),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: w * 0.02, vertical: 3),
                              decoration: BoxDecoration(
                                color: percent >= 85
                                    ? Colors.green.withAlpha(26)
                                    : (percent >= 75 ? Colors.orange.withAlpha(26) : Colors.red.withAlpha(26)),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                "$percent%",
                                style: TextStyle(
                                  fontSize: w * 0.03,
                                  fontWeight: FontWeight.bold,
                                  color: percent >= 85 ? Colors.green : (percent >= 75 ? Colors.orange : Colors.red),
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: h * 0.008),

                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: percent / 100,
                            backgroundColor: Colors.grey.shade200,
                            color: percent >= 85 ? Colors.green : (percent >= 75 ? Colors.orange : Colors.red),
                            minHeight: 5,
                          ),
                        ),

                        SizedBox(height: h * 0.006),

                        Row(
                          children: [
                            _miniLabel(Icons.people_rounded, "Total: $total", Colors.black54, w),
                            SizedBox(width: w * 0.03),
                            _miniLabel(Icons.check_circle_rounded, "Present: $present", Colors.green, w),
                            SizedBox(width: w * 0.03),
                            _miniLabel(Icons.cancel_rounded, "Absent: $absent", Colors.red, w),
                          ],
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

  Widget _summaryItem(String label, String value, Color valueColor, double w) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: w * 0.038, fontWeight: FontWeight.bold, color: valueColor)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: w * 0.024, color: Colors.white70)),
      ],
    );
  }

  Widget _filterChip(String label, bool isSelected, double w) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: w * 0.03, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF0047AB) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isSelected ? const Color(0xFF0047AB) : Colors.grey.shade300,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: w * 0.028,
          fontWeight: FontWeight.w600,
          color: isSelected ? Colors.white : Colors.black54,
        ),
      ),
    );
  }

  Widget _miniLabel(IconData icon, String text, Color color, double w) {
    return Row(
      children: [
        Icon(icon, size: w * 0.028, color: color),
        SizedBox(width: w * 0.008),
        Text(text, style: TextStyle(fontSize: w * 0.023, color: color)),
      ],
    );
  }
}