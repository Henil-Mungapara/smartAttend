import 'package:flutter/material.dart';
import 'package:smartattend/Admin_Dashboard/Admin_SetUp_Screen.dart';
import 'Admin_Dashboard_Screen.dart';
import 'Admin_ManageFaculty_Screen.dart';
import 'Admin_ManageStudents_Screen.dart';
import 'Admin_AttendanceReport_Screen.dart';
import 'Admin_Profile_Screen.dart';
import 'package:smartattend/utils/UiHelper.dart';

class Admin_Main_Navigation_Screen extends StatefulWidget {
  const Admin_Main_Navigation_Screen({super.key});

  @override
  State<Admin_Main_Navigation_Screen> createState() =>
      _Admin_Main_Navigation_ScreenState();
}

class _Admin_Main_Navigation_ScreenState
    extends State<Admin_Main_Navigation_Screen> {
  int _currentIndex = 0;

  final List<String> _titles = const [
    "Dashboard",
    "Manage Faculty",
    "Manage Students",
    "Attendance Reports",
    "Setup", // ✅ Changed from Settings
  ];

  final List<Widget> _pages = const [
    Admin_Dashboard_Screen(),
    Admin_ManageFaculty_Screen(),
    Admin_ManageStudents_Screen(),
    Admin_AttendanceReport_Screen(),
    Admin_SetUp_Screen(), // you can rename file later if needed
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_currentIndex == 0) {
          UIHelper.showExitAlert(context);
        } else {
          setState(() {
            _currentIndex = 0;
          });
        }
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false, // disables back arrow
          title: Text(
            _titles[_currentIndex],
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF0047AB),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(
                Icons.account_circle,
                color: Colors.white,
                size: 28,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Admin_Profile_Screen(),
                  ),
                );
              },
            ),
          ],
        ),
        body: _pages[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          selectedItemColor: const Color(0xFF0047AB),
          unselectedItemColor: Colors.grey,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: "Dashboard",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "Faculty",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.school),
              label: "Students",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics),
              label: "Reports",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_suggest), // ✅ Better icon for Setup
              label: "Setup",
            ),
          ],
        ),
      ),
    );
  }
}