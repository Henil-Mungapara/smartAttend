import 'package:flutter/material.dart';
import '../app_size/app_size.dart';
import '../utils/UiHelper.dart';

class ManageStudentsScreen extends StatefulWidget {
  const ManageStudentsScreen({super.key});

  @override
  State<ManageStudentsScreen> createState() => _ManageStudentsScreenState();
}

class _ManageStudentsScreenState extends State<ManageStudentsScreen> {

  // Text controller for adding new students
  final TextEditingController nameController = TextEditingController();

  // Static student list
  List<Map<String, String>> students = [
    {"name": "Rahul Sharma", "roll": "CS-01"},
    {"name": "Priya Patel", "roll": "CS-02"},
    {"name": "Amit Kumar", "roll": "CS-03"},
    {"name": "Sneha Gupta", "roll": "CS-04"},
    {"name": "Vikram Singh", "roll": "CS-05"},
  ];

  // Add a new student to the list
  void addStudent() {
    if (nameController.text.trim().isNotEmpty) {
      setState(() {
        int nextRoll = students.length + 1;
        students.add({
          "name": nameController.text.trim(),
          "roll": "CS-${nextRoll.toString().padLeft(2, '0')}",
        });
        nameController.clear();
      });
    }
  }

  // Remove student from the list
  void deleteStudent(int index) {
    setState(() {
      students.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final double w = AppSize.width(context);
    final double h = AppSize.height(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manage Students',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0047AB),
      ),
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [

            // ── Add Student Section ──
            Container(
              margin: EdgeInsets.all(w * 0.05),
              padding: EdgeInsets.all(w * 0.04),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.person_add_rounded, color: const Color(0xFF0047AB), size: w * 0.05),
                      SizedBox(width: w * 0.025),
                      Text(
                        "Add New Student",
                        style: TextStyle(fontSize: w * 0.04, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  SizedBox(height: h * 0.015),

                  // Name text field
                  UIHelper.customTextField(
                    controller: nameController,
                    hint: "Enter Student Name",
                    prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF0047AB)),
                  ),

                  SizedBox(height: h * 0.015),

                  // Add button
                  UIHelper.customButton(
                    text: "Add Student",
                    onPressed: addStudent,
                  ),
                ],
              ),
            ),

            // ── Student Count ──
            Padding(
              padding: EdgeInsets.symmetric(horizontal: w * 0.06),
              child: Row(
                children: [
                  Text(
                    "Students",
                    style: TextStyle(fontSize: w * 0.045, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: w * 0.03, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0047AB).withAlpha(20),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "${students.length} Total",
                      style: TextStyle(
                        fontSize: w * 0.03,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0047AB),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: h * 0.01),

            // ── Student List ──
            Expanded(
              child: students.isEmpty
                  // Empty state
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.group_off_rounded, size: w * 0.15, color: Colors.black26),
                          SizedBox(height: h * 0.01),
                          Text(
                            "No students added yet",
                            style: TextStyle(fontSize: w * 0.035, color: Colors.black45),
                          ),
                        ],
                      ),
                    )
                  // Student list
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: w * 0.05),
                      itemCount: students.length,
                      itemBuilder: (context, index) {
                        final student = students[index];
                        return Container(
                          margin: EdgeInsets.only(bottom: h * 0.01),
                          padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: h * 0.013),
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
                              // Avatar with initial letter
                              CircleAvatar(
                                radius: w * 0.05,
                                backgroundColor: const Color(0xFF0047AB).withAlpha(20),
                                child: Text(
                                  student["name"]![0],
                                  style: TextStyle(
                                    fontSize: w * 0.042,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF0047AB),
                                  ),
                                ),
                              ),
                              SizedBox(width: w * 0.035),

                              // Name & Roll
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      student["name"]!,
                                      style: TextStyle(fontSize: w * 0.037, fontWeight: FontWeight.w600),
                                    ),
                                    SizedBox(height: h * 0.003),
                                    Text(
                                      student["roll"]!,
                                      style: TextStyle(fontSize: w * 0.028, color: Colors.black54),
                                    ),
                                  ],
                                ),
                              ),

                              // Delete button
                              InkWell(
                                onTap: () => deleteStudent(index),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withAlpha(20),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Icons.delete_outline_rounded, color: Colors.red, size: w * 0.05),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}