import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartattend/Admin_Dashboard/SetUp_SmartAttend_Details/Add_Student_Dialog.dart';
import 'package:smartattend/app_size/app_size.dart';

class Admin_ManageStudents_Screen extends StatefulWidget {
  const Admin_ManageStudents_Screen({super.key});

  @override
  State<Admin_ManageStudents_Screen> createState() =>
      _Admin_ManageStudents_ScreenState();
}

class _Admin_ManageStudents_ScreenState
    extends State<Admin_ManageStudents_Screen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    double width = AppSize.width(context);
    double height = AppSize.height(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),



      /// 🔹 BODY
      body: Column(
        children: [
          SizedBox(height: height * 0.02),

          /// 🔹 SEARCH BAR
          Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.05),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search by Name, Email or Faculty Code",
                hintStyle: TextStyle(fontSize: width * 0.035),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Color(0xFF0047AB),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(
                  vertical: height * 0.018,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(width * 0.04),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

          SizedBox(height: height * 0.02),

          /// 🔹 STUDENT LIST
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('users')
                  .where('role', isEqualTo: 'student')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF0047AB),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text("No Students Found"),
                  );
                }

                final students = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;

                  final name =
                  (data['fullName'] ?? '').toString().toLowerCase();
                  final enrollment =
                  (data['enrollmentNumber'] ?? '').toString().toLowerCase();

                  if (_searchQuery.isEmpty) return true;

                  return name.contains(_searchQuery) ||
                      enrollment.contains(_searchQuery);
                }).toList();

                if (students.isEmpty) {
                  return const Center(child: Text("No Students Found"));
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 0.05,
                    vertical: height * 0.01,
                  ),
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final doc = students[index];
                    final data = doc.data() as Map<String, dynamic>;

                    final name = data['fullName'] ?? 'N/A';
                    final enrollment = data['enrollmentNumber'] ?? 'N/A';
                    final roll = data['rollNumber'] ?? 'N/A';
                    final phone = data['phone'] ?? 'N/A';

                    return Container(
                      margin: EdgeInsets.only(bottom: height * 0.015),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(width * 0.04),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade300,
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: width * 0.04,
                          vertical: height * 0.015,
                        ),
                        leading: CircleAvatar(
                          radius: width * 0.06,
                          backgroundColor: const Color(0xFF0047AB),
                          child: Text(
                            name.toString()[0].toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: width * 0.045,
                            ),
                          ),
                        ),
                        title: Text(
                          name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: width * 0.042,
                          ),
                        ),
                        subtitle: Padding(
                          padding: EdgeInsets.only(top: height * 0.005),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Enrollment: $enrollment"),
                              Text("Roll No: $roll"),
                              Text("Phone: $phone"),
                            ],
                          ),
                        ),

                        /// 🔹 TRAILING UPDATE + DELETE
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () {
                                // Update logic here
                              },
                              icon: Icon(
                                Icons.edit,
                                color: const Color(0xFF0047AB),
                                size: width * 0.06,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                // Delete logic here
                              },
                              icon: Icon(
                                Icons.delete,
                                color: const Color(0xFF0047AB),
                                size: width * 0.06,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      /// 🔹 FAB
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0047AB),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const AddStudentDialog(),
          );
        },
        child: Icon(Icons.add, size: width * 0.07, color: Colors.white),
      ),
      floatingActionButtonLocation:
      FloatingActionButtonLocation.centerFloat,
    );
  }
}