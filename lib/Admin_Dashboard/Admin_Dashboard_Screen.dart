import 'package:flutter/material.dart';
import '../app_size/app_size.dart';

class Admin_Dashboard_Screen extends StatelessWidget {
  const Admin_Dashboard_Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final double w = AppSize.width(context);
    final double h = AppSize.height(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: w * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              SizedBox(height: h * 0.012),

              // ── Welcome Header ──
              Center(
                child: Column(
                  children: [
                    Text(
                      "Welcome, Henil 👨‍💼",
                      style: TextStyle(
                        fontSize: w * 0.052,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: h * 0.003),
                    Text(
                      "Sunday, 09 Mar 2026",
                      style: TextStyle(fontSize: w * 0.03, color: Colors.black54),
                    ),
                  ],
                ),
              ),

              SizedBox(height: h * 0.015),

              // ── Stats Grid (2x2) ──
              Row(
                children: [
                  _statCard(Icons.people_rounded, "Total Students", "350", Colors.blue, w, h),
                  SizedBox(width: w * 0.025),
                  _statCard(Icons.person_rounded, "Total Faculty", "28", Colors.green, w, h),
                ],
              ),
              SizedBox(height: h * 0.008),
              Row(
                children: [
                  _statCard(Icons.class_rounded, "Departments", "6", Colors.orange, w, h),
                  SizedBox(width: w * 0.025),
                  _statCard(Icons.check_circle_outline, "Avg Attendance", "85%", Colors.purple, w, h),
                ],
              ),

              SizedBox(height: h * 0.015),

              // ── Today's Overview Card ──
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
                        _overviewStat("Classes", "24", w),
                        Container(height: h * 0.03, width: 1, color: Colors.white38),
                        _overviewStat("Present", "298", w),
                        Container(height: h * 0.03, width: 1, color: Colors.white38),
                        _overviewStat("Absent", "52", w),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: h * 0.018),

              // ── College Info Section ──
              Text(
                "College Info",
                style: TextStyle(fontSize: w * 0.04, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: h * 0.008),

              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _infoTile(Icons.account_balance_rounded, "College", "SmartAttend Engineering College", Colors.indigo, w, h),
                    _infoTile(Icons.apartment_rounded, "Departments", "SE, CS, IT, Electronics, Mechanical, Civil", Colors.orange, w, h),
                    _infoTile(Icons.school_rounded, "Students", "350 Enrolled Students", Colors.blue, w, h),
                    _infoTile(Icons.person_rounded, "Faculty", "28 Faculty Members", Colors.green, w, h),
                    _infoTile(Icons.calendar_today_rounded, "Academic Year", "2025 – 2026", Colors.teal, w, h),
                    _infoTile(Icons.access_time_rounded, "Semesters", "Even Semester (Jan – Jun)", Colors.deepPurple, w, h),
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

  // ── Stat Card ──
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

  // ── Overview Stat (inside blue card) ──
  Widget _overviewStat(String label, String value, double w) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: w * 0.045, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: w * 0.026, color: Colors.white70)),
      ],
    );
  }

  // ── College Info Tile ──
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