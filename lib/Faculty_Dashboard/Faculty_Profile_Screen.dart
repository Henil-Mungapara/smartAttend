import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../app_size/app_size.dart';
import '../utils/UiHelper.dart';
import '../Auth/LogIn_Screen.dart';

class FacultyProfileScreen extends StatelessWidget {
  const FacultyProfileScreen({super.key});

  // Logout Function
  Future<void> logout(BuildContext context) async {
    // Firebase Logout
    await FirebaseAuth.instance.signOut();

    // SharedPreferences Logout
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);

    // Navigate to Login Page
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double w = AppSize.width(context);
    final double h = AppSize.height(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Faculty Profile',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0047AB),
      ),
      backgroundColor: const Color(0xFFF4F6FA),

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // HEADER
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

                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: const CircleAvatar(
                        radius: 48,
                        backgroundColor: Colors.white24,
                        child: Icon(
                          Icons.person,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    SizedBox(height: h * 0.012),

                    Text(
                      "Ayush",
                      style: TextStyle(
                        fontSize: w * 0.055,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    SizedBox(height: h * 0.005),

                    Text(
                      "ayush@smartattend.com",
                      style: TextStyle(
                        fontSize: w * 0.032,
                        color: Colors.white70,
                      ),
                    ),

                    SizedBox(height: h * 0.02),
                  ],
                ),
              ),

              SizedBox(height: h * 0.02),

              // PERSONAL INFO
              Padding(
                padding: EdgeInsets.symmetric(horizontal: w * 0.06),
                child: _buildCard("Personal Information", [
                  _infoTile(Icons.email, "Email", "ayush@smartattend.com"),
                  _divider(),
                  _infoTile(Icons.phone, "Mobile", "+91 99887 65432"),
                  _divider(),
                  _infoTile(Icons.security, "Role", "Faculty"),
                ]),
              ),

              SizedBox(height: h * 0.02),

              // ACADEMIC INFO
              Padding(
                padding: EdgeInsets.symmetric(horizontal: w * 0.06),
                child: _buildCard("Academic Information", [
                  _infoTile(
                    Icons.apartment,
                    "Department",
                    "Software Engineering",
                  ),
                  _divider(),
                  _infoTile(Icons.work, "Designation", "Assistant Professor"),
                  _divider(),
                  _infoTile(Icons.badge, "Faculty ID", "FAC-2018-015"),
                  _divider(),
                  _infoTile(Icons.calendar_today, "Joining Year", "2018"),
                ]),
              ),

              SizedBox(height: h * 0.03),

              // LOGOUT BUTTON
              Padding(
                padding: EdgeInsets.symmetric(horizontal: w * 0.06),
                child: UIHelper.customButton(
                  text: "Logout",
                  onPressed: () {
                    logout(context);
                  },
                ),
              ),

              SizedBox(height: h * 0.02),

              const Text(
                "SmartAttend v1.0.0",
                style: TextStyle(color: Colors.black38),
              ),

              SizedBox(height: h * 0.04),
            ],
          ),
        ),
      ),
    );
  }

  // CARD WIDGET
  Widget _buildCard(String title, List<Widget> children) {
    return Container(
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
          Padding(
            padding: const EdgeInsets.all(14),
            child: Text(
              title,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  // INFO TILE
  Widget _infoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF0047AB)),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              "$label : $value",
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Divider(color: Colors.grey.shade300);
  }
}
