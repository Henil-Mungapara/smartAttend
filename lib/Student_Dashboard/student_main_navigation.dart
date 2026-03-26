import 'package:flutter/material.dart';
import '../app_size/app_size.dart';
import 'Attendance_Report_Screen.dart';
import 'Student_Dashboard_Screen.dart';
import 'Student_Profile_Screen.dart';
import 'Scan_Qr_Screen.dart';


class StudentMainNavigation extends StatefulWidget {
  const StudentMainNavigation({super.key});

  @override
  State<StudentMainNavigation> createState() => _StudentMainNavigationState();
}

class _StudentMainNavigationState extends State<StudentMainNavigation> {

  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    ScanQRPage(),
    AttendancePage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {

    final double w = AppSize.width(context);

    return Scaffold(
      body: _pages[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: const Color(0xFF0047AB), // Blue background
        selectedItemColor: Colors.white,          // Selected icon/text
        unselectedItemColor: Colors.white70,      // Unselected icon/text
        selectedLabelStyle: TextStyle(fontSize: w * 0.035),
        unselectedLabelStyle: TextStyle(fontSize: w * 0.032),
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner_rounded),
            label: "Scan",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_rounded),
            label: "Attendance",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}