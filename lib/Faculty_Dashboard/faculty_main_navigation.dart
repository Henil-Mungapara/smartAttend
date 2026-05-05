import 'package:flutter/material.dart';

import 'Faculty_Dashboard_Screen.dart';
import 'Generate_QrScreen.dart';
import 'View_Attendance_Screen.dart';
import 'Manage_Student_Screen.dart';
import 'Faculty_Profile_Screen.dart';

class FacultyMainNavigation extends StatefulWidget {
  const FacultyMainNavigation({super.key});

  @override
  State<FacultyMainNavigation> createState() => _FacultyMainNavigationState();
}

class _FacultyMainNavigationState extends State<FacultyMainNavigation> {
  int _currentIndex = 0;

  // GlobalKey lets us call refresh() on View Attendance after QR session ends
  final GlobalKey<ViewAttendanceScreenState> _attendanceKey = GlobalKey();

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const FacultyDashboardScreen(),
      GenerateAttendanceScreen(onSessionEnded: _onQrSessionEnded),
      ViewAttendanceScreen(key: _attendanceKey),
      const ManageStudentsScreen(),
      const FacultyProfileScreen(),
    ];
  }

  // Called by QR screen when a session expires or is ended early
  void _onQrSessionEnded() {
    setState(() => _currentIndex = 2);
    // Refresh the attendance list after the frame renders
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _attendanceKey.currentState?.refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack keeps all tab states alive — QR timer never resets
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF0047AB),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code), label: "Generate"),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: "Attendance"),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: "Manage"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}