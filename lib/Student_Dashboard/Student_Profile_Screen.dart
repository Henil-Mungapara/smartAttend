import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_size/app_size.dart';
import '../utils/UiHelper.dart';
import '../Auth/LogIn_Screen.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Screen width & height for responsive sizing
    final double w = AppSize.width(context);
    final double h = AppSize.height(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),

      // ── AppBar ──
      appBar: AppBar(
        title: const Text(
          'Student Profile',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0047AB),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [

              // ══════════════════════════════════════
              // 1) BLUE HEADER — avatar, name, email, role
              // ══════════════════════════════════════
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF0047AB),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(height: h * 0.025),

                    // Profile avatar
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: const CircleAvatar(
                        radius: 48,
                        backgroundColor: Colors.white24,
                        child: Icon(Icons.person, size: 48, color: Colors.white),
                      ),
                    ),

                    SizedBox(height: h * 0.012),

                    // Student name
                    Text(
                      "Jenil",
                      style: TextStyle(
                        fontSize: w * 0.055,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    SizedBox(height: h * 0.005),

                    // Email
                    Text(
                      "jenil@smartattend.com",
                      style: TextStyle(
                        fontSize: w * 0.032,
                        color: Colors.white70,
                      ),
                    ),

                    SizedBox(height: h * 0.012),

                    // Role badge
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: w * 0.05,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "Student",
                        style: TextStyle(
                          fontSize: w * 0.032,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    SizedBox(height: h * 0.028),
                  ],
                ),
              ),

              // ══════════════════════════════════════
              // 2) QUICK STATS ROW — floating card
              // ══════════════════════════════════════
              Padding(
                padding: EdgeInsets.symmetric(horizontal: w * 0.06),
                child: Transform.translate(
                  offset: Offset(0, -h * 0.022),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: h * 0.015),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(18),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _statItem("85%", "Attendance", w),
                        _verticalLine(h),
                        _statItem("42", "Present", w),
                        _verticalLine(h),
                        _statItem("4th", "Semester", w),
                      ],
                    ),
                  ),
                ),
              ),

              // ══════════════════════════════════════
              // 3) PERSONAL INFORMATION CARD
              // ══════════════════════════════════════
              Padding(
                padding: EdgeInsets.symmetric(horizontal: w * 0.06),
                child: _buildCard(
                  title: "Personal Information",
                  titleIcon: Icons.person_outline_rounded,
                  w: w,
                  h: h,
                  children: [
                    _infoTile(Icons.email_outlined, "Email", "jenil@smartattend.com", w),
                    _thinDivider(),
                    _infoTile(Icons.phone_outlined, "Mobile", "+91 98765 43210", w),
                    _thinDivider(),
                    _infoTile(Icons.security_outlined, "Role", "Student", w),
                  ],
                ),
              ),

              SizedBox(height: h * 0.018),

              // ══════════════════════════════════════
              // 4) ACADEMIC INFORMATION CARD
              // ══════════════════════════════════════
              Padding(
                padding: EdgeInsets.symmetric(horizontal: w * 0.06),
                child: _buildCard(
                  title: "Academic Information",
                  titleIcon: Icons.school_outlined,
                  w: w,
                  h: h,
                  children: [
                    _infoTile(Icons.apartment_rounded, "Department", "Software Engineering", w),
                    _thinDivider(),
                    _infoTile(Icons.calendar_today_rounded, "Enrollment Year", "2024", w),
                    _thinDivider(),
                    _infoTile(Icons.class_rounded, "Semester", "4th Semester", w),
                    _thinDivider(),
                    _infoTile(Icons.numbers_rounded, "Roll Number", "CS-2024-042", w),
                  ],
                ),
              ),

              SizedBox(height: h * 0.018),

              // ══════════════════════════════════════
              // 5) SETTINGS CARD
              // ══════════════════════════════════════
              Padding(
                padding: EdgeInsets.symmetric(horizontal: w * 0.06),
                child: _buildCard(
                  title: "Settings",
                  titleIcon: Icons.settings_outlined,
                  w: w,
                  h: h,
                  children: [
                    _settingTile(Icons.notifications_outlined, "Notifications",
                      trailing: Switch(
                        value: true,
                        onChanged: (_) {},
                        activeColor: const Color(0xFF0047AB),
                      ),
                      w: w,
                    ),
                    _thinDivider(),
                    _settingTile(Icons.dark_mode_outlined, "Dark Mode",
                      trailing: Switch(
                        value: false,
                        onChanged: (_) {},
                        activeColor: const Color(0xFF0047AB),
                      ),
                      w: w,
                    ),
                    _thinDivider(),
                    _settingTile(Icons.language_rounded, "Language",
                      trailing: Text(
                        "English",
                        style: TextStyle(fontSize: w * 0.032, color: Colors.black54),
                      ),
                      w: w,
                    ),
                  ],
                ),
              ),

              SizedBox(height: h * 0.03),

              // ══════════════════════════════════════
              // 6) LOGOUT BUTTON
              // ══════════════════════════════════════
              Padding(
                padding: EdgeInsets.symmetric(horizontal: w * 0.06),
                child: UIHelper.customButton(
                  text: "Logout",
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('isLoggedIn', false);

                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                      (route) => false,
                    );
                  },
                ),
              ),

              SizedBox(height: h * 0.015),

              // App version label
              Text(
                "SmartAttend v1.0.0",
                style: TextStyle(fontSize: w * 0.028, color: Colors.black38),
              ),

              SizedBox(height: h * 0.035),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  //  HELPER WIDGETS (simple & reusable)
  // ─────────────────────────────────────────

  /// Small stat column used in the Quick Stats row
  Widget _statItem(String value, String label, double w) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: w * 0.045,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0047AB),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: w * 0.028, color: Colors.black54),
        ),
      ],
    );
  }

  /// Thin vertical divider between stats
  Widget _verticalLine(double h) {
    return Container(height: h * 0.035, width: 1, color: Colors.grey.shade300);
  }

  /// White card with a title header row and a list of children
  Widget _buildCard({
    required String title,
    required IconData titleIcon,
    required double w,
    required double h,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
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
          // Title row
          Padding(
            padding: EdgeInsets.symmetric(horizontal: w * 0.045, vertical: 14),
            child: Row(
              children: [
                Icon(titleIcon, color: const Color(0xFF0047AB), size: w * 0.05),
                SizedBox(width: w * 0.025),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: w * 0.04,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Content rows
          Padding(
            padding: EdgeInsets.symmetric(horizontal: w * 0.045, vertical: 8),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  /// One row inside an info card — icon + label + value
  Widget _infoTile(IconData icon, String label, String value, double w) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          // Icon box
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF0047AB).withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF0047AB), size: w * 0.048),
          ),
          SizedBox(width: w * 0.035),

          // Label + value
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: w * 0.03,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: w * 0.037,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// One row inside the settings card — icon + label + trailing widget
  Widget _settingTile(IconData icon, String label, {
    required Widget trailing,
    required double w,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF0047AB).withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF0047AB), size: w * 0.045),
          ),
          SizedBox(width: w * 0.035),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: w * 0.037,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  /// Simple thin divider between rows
  Widget _thinDivider() {
    return Divider(height: 1, color: Colors.grey.shade200);
  }
}