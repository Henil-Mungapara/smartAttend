import 'package:flutter/material.dart';
import 'package:smartattend/Admin_Dashboard/SetUp_SmartAttend_Details/Add_Class_Dialog.dart';
import 'package:smartattend/Admin_Dashboard/SetUp_SmartAttend_Details/Add_Collage_Dialog.dart';
import 'package:smartattend/Admin_Dashboard/SetUp_SmartAttend_Details/Add_Division_Dialog.dart';
import 'package:smartattend/Admin_Dashboard/SetUp_SmartAttend_Details/Add_Subject_Dialog.dart';
import 'package:smartattend/Admin_Dashboard/SetUp_SmartAttend_Details/View_Class_Screen.dart';
import 'package:smartattend/Admin_Dashboard/SetUp_SmartAttend_Details/View_Collage_Screen.dart';
import 'package:smartattend/Admin_Dashboard/SetUp_SmartAttend_Details/View_Department_Screen.dart';
import 'package:smartattend/Admin_Dashboard/SetUp_SmartAttend_Details/View_Division_Screen.dart';
import 'package:smartattend/Admin_Dashboard/SetUp_SmartAttend_Details/View_Subject_Screen.dart';
import 'package:smartattend/app_size/app_size.dart';
import 'package:smartattend/utils/UiHelper.dart';

import 'SetUp_SmartAttend_Details/Add_Department_Dialog.dart';

class Admin_SetUp_Screen extends StatelessWidget {
  const Admin_SetUp_Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      body: Column(
        children: [

          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              vertical: AppSize.height(context) * 0.03,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFFE3F2FD),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
            child: const Center(
              child: Text(
                "Setup Your SmartAttend System",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28, 
                  fontWeight: FontWeight.w800, 
                  color: const Color(0xFF0047AB),
                  letterSpacing: 1.2, 
                  shadows: const [
                    Shadow(
                      offset: Offset(1, 1),
                      blurRadius: 3,
                      color: Colors.black26, 
                    ),
                    Shadow(
                      offset: Offset(0, 0),
                      blurRadius: 2,
                      color: Colors.white24, 
                    ),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: Padding(
              padding: EdgeInsets.all(AppSize.width(context) * 0.05),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: AppSize.width(context) * 0.05,
                mainAxisSpacing: AppSize.height(context) * 0.025,
                children: [

                  buildSetupCard(
                    context,
                    icon: Icons.school,
                    title: "College",
                    onAdd: () {
                      
                      showDialog(
                        context: context,
                        builder: (_) => const AddCollegeDialog(),
                      );
                    },
                    onView: () {
                      
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ViewCollegeScreen(),
                        ),
                      );
                    },
                  ),

                  buildSetupCard(
                    context,
                    icon: Icons.account_balance,
                    title: "Department",
                    onAdd: () {
                      showDialog(
                        context: context,
                        builder: (_) => const AddDepartmentDialog(),
                      );
                    },
                    onView: () {
                      
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ViewDepartmentScreen(),
                        ),
                      );
                    },
                  ),

                  buildSetupCard(
                    context,
                    icon: Icons.class_,
                    title: "Class",
                    onAdd: () {
                      
                      showDialog(
                        context: context,
                        builder: (_) => const AddClassDialog(),
                      );
                    },
                    onView: () {
                      
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ViewClassScreen(),
                        ),
                      );
                    },
                  ),

                  buildSetupCard(
                    context,
                    icon: Icons.group,
                    title: "Division",
                    onAdd: () {
                      
                      showDialog(
                        context: context,
                        builder: (_) => const AddDivisionDialog(),
                      );
                    },
                    onView: () {
                      
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ViewDivisionScreen(),
                        ),
                      );
                    },
                  ),
                  
                  buildSetupCard(
                    context,
                    icon: Icons.menu_book, 
                    title: "Subject",
                    onAdd: () {
                      
                      showDialog(
                        context: context,
                        builder: (_) => const AddSubjectDialog(),
                      );
                    },
                    onView: () {
                      
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ViewSubjectScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSetupCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        VoidCallback? onAdd,
        VoidCallback? onView,
      }) {
    return InkWell(
      onTap: () {
        UIHelper.showSetupOptions(
          context: context,
          title: "$title Options",
          message: "What would you like to do with $title?",
          onAdd: onAdd ??
                  () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Add $title Coming Soon")),
                );
              },
          onView: onView??() {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("View $title Coming Soon")),
            );
          },
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF0047AB),
              Color(0xFF1565C0),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(51),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: AppSize.width(context) * 0.09,
                color: Colors.white,
              ),
            ),
            SizedBox(height: AppSize.height(context) * 0.015),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: AppSize.width(context) * 0.04,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}