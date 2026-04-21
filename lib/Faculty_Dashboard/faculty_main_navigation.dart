import 'package:flutter/material.dart';

import 'Faculty_Dashboard_Screen.dart';
import 'Generate_QrScreen.dart';
import 'View_Attendance_Screen.dart';
import 'Manage_Student_Screen.dart';
import 'Faculty_Profile_Screen.dart';

class FacultyMainNavigation extends StatefulWidget {
  const FacultyMainNavigation({super.key});

  @override
  State<FacultyMainNavigation> createState() =>
      _FacultyMainNavigationState();
}

class _FacultyMainNavigationState
    extends State<FacultyMainNavigation> {

  int currentIndex = 0;

  final List<Widget> pages = const [
    FacultyDashboardScreen(),
    GenerateAttendanceScreen(),
    ViewAttendanceScreen(),
    ManageStudentsScreen(),
    FacultyProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF0047AB), 
        selectedItemColor: Colors.white,          
        unselectedItemColor: Colors.white70,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: "Dashboard"),
          BottomNavigationBarItem(
              icon: Icon(Icons.qr_code),
              label: "Generate"),
          BottomNavigationBarItem(
              icon: Icon(Icons.list_alt),
              label: "Attendance"),
          BottomNavigationBarItem(
              icon: Icon(Icons.group),
              label: "Manage"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "Profile"),
        ],
      ),
    );
  }
}