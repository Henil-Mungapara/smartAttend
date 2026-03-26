import 'package:flutter/material.dart';
import '../app_size/app_size.dart';
import '../utils/UiHelper.dart';

class FacultyDashboardScreen extends StatelessWidget {
  const FacultyDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double w = AppSize.width(context);
    final double h = AppSize.height(context);

    return WillPopScope(
        onWillPop: () async {
      UIHelper.showExitAlert(context);
      return false;
    },
     child: Scaffold(
      appBar: AppBar(
        title: const Text(
          'Faculty Dashboard',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0047AB),
      ),
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: w * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              SizedBox(height: h * 0.025),

              // ── Welcome Section ──
              Center(
                child: Column(
                  children: [
                    Text(
                      "Welcome, Ayush 👨‍🏫",
                      style: TextStyle(
                        fontSize: w * 0.058,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: h * 0.005),
                    Text(
                      "Saturday, 08 Mar 2026",
                      style: TextStyle(
                        fontSize: w * 0.033,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: h * 0.025),

              // ── Stats Row ──
              Row(
                children: [
                  _statCard(Icons.people_rounded, "Total Students", "120", w, h),
                  SizedBox(width: w * 0.035),
                  _statCard(Icons.class_rounded, "Classes Today", "4", w, h),
                  SizedBox(width: w * 0.035),
                  _statCard(Icons.check_circle_outline, "Avg Attendance", "82%", w, h),
                ],
              ),

              SizedBox(height: h * 0.03),

              // ── Quick Actions ──
              Text(
                "Quick Actions",
                style: TextStyle(
                  fontSize: w * 0.048,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: h * 0.015),

              _actionCard(
                icon: Icons.qr_code_rounded,
                title: "Generate Attendance",
                subtitle: "Create QR code for your lecture",
                w: w, h: h,
              ),
              _actionCard(
                icon: Icons.bar_chart_rounded,
                title: "View Attendance",
                subtitle: "Check student attendance records",
                w: w, h: h,
              ),
              _actionCard(
                icon: Icons.group_rounded,
                title: "Manage Students",
                subtitle: "Add or remove students from class",
                w: w, h: h,
              ),

              SizedBox(height: h * 0.03),

              // ── Today's Schedule ──
              Text(
                "Today's Schedule",
                style: TextStyle(
                  fontSize: w * 0.048,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: h * 0.015),

              _scheduleCard("Flutter Development", "09:00 - 10:00 AM", "Lab 301", "3rd Sem", w, h),
              _scheduleCard("Android Development", "10:30 - 11:30 AM", "Lab 102", "5th Sem", w, h),
              _scheduleCard("Data Structures", "12:00 - 01:00 PM", "Room 205", "2nd Sem", w, h),
              _scheduleCard("Python Programming", "02:00 - 03:00 PM", "Lab 104", "1st Sem", w, h),

              SizedBox(height: h * 0.03),

              // ── Recent Activity ──
              Text(
                "Recent Activity",
                style: TextStyle(
                  fontSize: w * 0.048,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: h * 0.015),

              _activityItem("Attendance marked for Flutter Dev", "Today, 09:15 AM", Icons.check_circle_rounded, Colors.green, w, h),
              _activityItem("New student added to Android Dev", "Today, 08:30 AM", Icons.person_add_rounded, const Color(0xFF0047AB), w, h),
              _activityItem("QR generated for Data Structures", "Yesterday, 01:00 PM", Icons.qr_code_rounded, Colors.orange, w, h),

              SizedBox(height: h * 0.04),
            ],
          ),
        ),
      ),
     ),
    );
  }

  // ── Stat Card ──
  Widget _statCard(IconData icon, String label, String value, double w, double h) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: h * 0.018, horizontal: w * 0.02),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF0047AB), size: w * 0.06),
            SizedBox(height: h * 0.006),
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
              style: TextStyle(fontSize: w * 0.025, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  // ── Action Card ──
  Widget _actionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required double w,
    required double h,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: h * 0.012),
      padding: EdgeInsets.all(w * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(w * 0.03),
            decoration: BoxDecoration(
              color: const Color(0xFF0047AB).withAlpha(20),
              borderRadius: BorderRadius.circular(12),
            ),
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
    );
  }

  // ── Schedule Card ──
  Widget _scheduleCard(String subject, String time, String room, String sem, double w, double h) {
    return Container(
      margin: EdgeInsets.only(bottom: h * 0.012),
      padding: EdgeInsets.all(w * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(w * 0.025),
            decoration: BoxDecoration(
              color: const Color(0xFF0047AB).withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: w * 0.02, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF0047AB).withAlpha(20),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(room, style: TextStyle(fontSize: w * 0.026, color: const Color(0xFF0047AB), fontWeight: FontWeight.w500)),
              ),
              SizedBox(height: h * 0.004),
              Text(sem, style: TextStyle(fontSize: w * 0.025, color: Colors.black45)),
            ],
          ),
        ],
      ),
    );
  }

  // ── Activity Item ──
  Widget _activityItem(String title, String time, IconData icon, Color color, double w, double h) {
    return Container(
      margin: EdgeInsets.only(bottom: h * 0.01),
      padding: EdgeInsets.symmetric(vertical: h * 0.012, horizontal: w * 0.035),
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