import 'package:flutter/material.dart';
import '../app_size/app_size.dart';

class AttendancePage extends StatelessWidget {
  const AttendancePage({super.key});

  @override
  Widget build(BuildContext context) {

    final double w = AppSize.width(context);
    final double h = AppSize.height(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Student Attendance Charts',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0047AB),


      ),
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(w * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              SizedBox(height: h * 0.02),

              // ── Summary Stats Row ──
              Row(
                children: [
                  _summaryChip("Total Classes", "50", Icons.class_rounded, w, h),
                  SizedBox(width: w * 0.03),
                  _summaryChip("Present", "42", Icons.check_circle_outline, w, h),
                  SizedBox(width: w * 0.03),
                  _summaryChip("Absent", "8", Icons.cancel_outlined, w, h),
                ],
              ),

              SizedBox(height: h * 0.035),

              Text(
                "Attendance History",
                style: TextStyle(
                  fontSize: w * 0.05,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: h * 0.02),

              _subjectCard("Flutter Development", 90, w, h),
              _subjectCard("Android Development", 80, w, h),
              _subjectCard("Data Structures", 95, w, h),
              _subjectCard("Python Programming", 75, w, h),
              _subjectCard("Database Management", 88, w, h),

              SizedBox(height: h * 0.03),

              // ── Monthly Trend Section ──
              Text(
                "Monthly Trend",
                style: TextStyle(
                  fontSize: w * 0.05,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: h * 0.015),

              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: h * 0.04, horizontal: w * 0.05),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(13),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.show_chart_rounded,
                      size: w * 0.12,
                      color: const Color(0xFF0047AB).withAlpha(102),
                    ),
                    SizedBox(height: h * 0.01),
                    Text(
                      "Chart Coming Soon",
                      style: TextStyle(
                        fontSize: w * 0.04,
                        color: Colors.black45,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: h * 0.005),
                    Text(
                      "Your monthly attendance trend will be displayed here",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: w * 0.03,
                        color: Colors.black38,
                      ),
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

  // ── Summary Chip Widget ──
  Widget _summaryChip(String label, String value, IconData icon, double w, double h) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: h * 0.015, horizontal: w * 0.02),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF0047AB), size: w * 0.055),
            SizedBox(height: h * 0.005),
            Text(
              value,
              style: TextStyle(
                fontSize: w * 0.05,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0047AB),
              ),
            ),
            SizedBox(height: h * 0.003),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: w * 0.025,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Subject Card Widget with Progress Bar ──
  Widget _subjectCard(String subject, int percent, double w, double h) {
    return Container(
      margin: EdgeInsets.only(bottom: h * 0.015),
      padding: EdgeInsets.all(w * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(w * 0.02),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0047AB).withAlpha(26),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.menu_book_rounded,
                      color: const Color(0xFF0047AB),
                      size: w * 0.045,
                    ),
                  ),
                  SizedBox(width: w * 0.03),
                  Text(
                    subject,
                    style: TextStyle(
                      fontSize: w * 0.04,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: w * 0.03, vertical: h * 0.005),
                decoration: BoxDecoration(
                  color: percent >= 85
                      ? Colors.green.withAlpha(26)
                      : percent >= 75
                          ? Colors.orange.withAlpha(26)
                          : Colors.red.withAlpha(26),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "$percent%",
                  style: TextStyle(
                    fontSize: w * 0.038,
                    fontWeight: FontWeight.bold,
                    color: percent >= 85
                        ? Colors.green
                        : percent >= 75
                            ? Colors.orange
                            : Colors.red,
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
                percent >= 85
                    ? Colors.green
                    : percent >= 75
                        ? Colors.orange
                        : Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}