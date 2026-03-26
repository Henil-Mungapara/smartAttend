import 'package:flutter/material.dart';
import '../app_size/app_size.dart';
import '../utils/UiHelper.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
          'Student Dashboard',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0047AB),


      ),
      backgroundColor: const Color(0xFFB6BFCA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: w * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              SizedBox(height: h * 0.03),

              // ── Welcome Section ──
              Center(
                child: Column(
                  children: [
                    Text(
                      "Welcome, Jenil 👋",
                      style: TextStyle(
                        fontSize: w * 0.06,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: h * 0.005),
                    Text(
                      "Saturday, 08 Mar 2026",
                      style: TextStyle(
                        fontSize: w * 0.035,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: h * 0.03),

              // ── Stats Row ──
              Row(
                children: [
                  Expanded(
                    child: _statCard(
                      icon: Icons.check_circle_outline,
                      label: "Total Present",
                      value: "42",
                      w: w,
                      h: h,
                    ),
                  ),
                  SizedBox(width: w * 0.04),
                  Expanded(
                    child: _statCard(
                      icon: Icons.cancel_outlined,
                      label: "Total Absent",
                      value: "8",
                      w: w,
                      h: h,
                    ),
                  ),
                ],
              ),

              SizedBox(height: h * 0.025),

              // ── Overall Attendance Card with Circular Indicator ──
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(w * 0.05),
                decoration: BoxDecoration(
                  color: const Color(0xFF0047AB),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0047AB).withAlpha(77),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Overall Attendance",
                            style: TextStyle(
                              fontSize: w * 0.04,
                              color: Colors.white70,
                            ),
                          ),
                          SizedBox(height: h * 0.01),
                          Text(
                            "85%",
                            style: TextStyle(
                              fontSize: w * 0.1,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: h * 0.005),
                          Text(
                            "50 Total Classes",
                            style: TextStyle(
                              fontSize: w * 0.032,
                              color: Colors.white60,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: w * 0.22,
                      height: w * 0.22,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: w * 0.2,
                            height: w * 0.2,
                            child: CircularProgressIndicator(
                              value: 0.85,
                              strokeWidth: 8,
                              backgroundColor: Colors.white24,
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          Icon(
                            Icons.school_rounded,
                            color: Colors.white,
                            size: w * 0.08,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: h * 0.035),

              // ── Today's Schedule ──
              Text(
                "Today's Schedule",
                style: TextStyle(
                  fontSize: w * 0.048,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: h * 0.015),

              _scheduleCard(
                subject: "Flutter Development",
                time: "09:00 - 10:00 AM",
                room: "Lab 301",
                icon: Icons.phone_android_rounded,
                w: w,
                h: h,
              ),
              _scheduleCard(
                subject: "Android Development",
                time: "10:30 - 11:30 AM",
                room: "Lab 102",
                icon: Icons.adb_rounded,
                w: w,
                h: h,
              ),
              _scheduleCard(
                subject: "Data Structures",
                time: "12:00 - 01:00 PM",
                room: "Room 205",
                icon: Icons.account_tree_rounded,
                w: w,
                h: h,
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

              Row(
                children: [
                  Expanded(
                    child: _quickActionCard(
                      icon: Icons.qr_code_scanner_rounded,
                      label: "Scan QR",
                      w: w,
                      h: h,
                    ),
                  ),
                  SizedBox(width: w * 0.04),
                  Expanded(
                    child: _quickActionCard(
                      icon: Icons.bar_chart_rounded,
                      label: "View Report",
                      w: w,
                      h: h,
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

  // ── Stat Card Widget ──
  Widget _statCard({
    required IconData icon,
    required String label,
    required String value,
    required double w,
    required double h,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: h * 0.02, horizontal: w * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF0047AB), size: w * 0.07),
          SizedBox(height: h * 0.008),
          Text(
            value,
            style: TextStyle(
              fontSize: w * 0.06,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0047AB),
            ),
          ),
          SizedBox(height: h * 0.004),
          Text(
            label,
            style: TextStyle(
              fontSize: w * 0.032,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  // ── Schedule Card Widget ──
  Widget _scheduleCard({
    required String subject,
    required String time,
    required String room,
    required IconData icon,
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
            padding: EdgeInsets.all(w * 0.025),
            decoration: BoxDecoration(
              color: const Color(0xFF0047AB).withAlpha(26),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF0047AB), size: w * 0.06),
          ),
          SizedBox(width: w * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject,
                  style: TextStyle(
                    fontSize: w * 0.04,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: h * 0.004),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: w * 0.032,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: w * 0.025, vertical: h * 0.006),
            decoration: BoxDecoration(
              color: const Color(0xFF0047AB).withAlpha(26),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              room,
              style: TextStyle(
                fontSize: w * 0.03,
                color: const Color(0xFF0047AB),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Quick Action Card Widget ──
  Widget _quickActionCard({
    required IconData icon,
    required String label,
    required double w,
    required double h,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: h * 0.025),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(w * 0.035),
            decoration: BoxDecoration(
              color: const Color(0xFF0047AB).withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF0047AB), size: w * 0.07),
          ),
          SizedBox(height: h * 0.01),
          Text(
            label,
            style: TextStyle(
              fontSize: w * 0.036,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}