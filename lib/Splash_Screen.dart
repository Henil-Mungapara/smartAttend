import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartattend/Admin_Dashboard/Admin_Main_Navigation_Screen.dart';
import 'package:smartattend/Auth/LogIn_Screen.dart';
import 'package:smartattend/Student_Dashboard/student_main_navigation.dart';
import 'Faculty_Dashboard/faculty_main_navigation.dart';
import 'app_size/app_size.dart';
import 'GetStarted_Screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _checkUserStatus();
  }

  Future<void> _checkUserStatus() async {
    await Future.delayed(const Duration(seconds: 4));

    final prefs = await SharedPreferences.getInstance();

    bool isFirstInstall = prefs.getBool('isFirstInstall') ?? true;
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    String? role = prefs.getString('role')?.toLowerCase();  // Normalize to lowercase

    if (!mounted) return;

    if (isFirstInstall) {
      // First time user
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const GetStartedPage()),
      );
      return;
    }

    if (isLoggedIn && role != null) {
      // Role-based navigation
      if (role == "student") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const StudentMainNavigation()),
        );
      } else if (role == "faculty") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const FacultyMainNavigation()),
        );
      } else if (role == "admin") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Admin_Main_Navigation_Screen()),
        );
      } else {
        // Role missing or invalid
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
    } else {
      // Not logged in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double w = AppSize.width(context);
    final double h = AppSize.height(context);

    return Scaffold(
      backgroundColor: const Color(0xFFB6BFCA),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [

                      SizedBox(height: h * 0.15),

                      SizedBox(
                        height: h * 0.28,
                        child: Lottie.asset(
                          "assets/animation/SmartAttendSplashScreen.json",
                          controller: _controller,
                          onLoaded: (composition) {
                            _controller
                              ..duration = composition.duration
                              ..repeat();
                          },
                          fit: BoxFit.cover,
                        ),
                      ),

                      SizedBox(height: h * 0.05),

                      Text(
                        "SmartAttend",
                        style: TextStyle(
                          fontSize: w * 0.08,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),

                      SizedBox(height: h * 0.01),

                      Text(
                        "Attendance Simplified",
                        style: TextStyle(
                          fontSize: w * 0.042,
                          color: Colors.grey[800],
                        ),
                      ),

                      const Spacer(),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: w * 0.2),
                        child: const LinearProgressIndicator(
                          minHeight: 4,
                          color: Color(0xFF0047AB),
                        ),
                      ),

                      SizedBox(height: h * 0.08),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}