import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../app_size/app_size.dart';
import '../utils/UiHelper.dart';

class ManageStudentsScreen extends StatefulWidget {
  const ManageStudentsScreen({super.key});

  @override
  State<ManageStudentsScreen> createState() => _ManageStudentsScreenState();
}

class _ManageStudentsScreenState extends State<ManageStudentsScreen> {

  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _searchQuery = "";

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
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [

            // Search Bar Container
            Container(
              margin: EdgeInsets.all(w * 0.05),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(10),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val.toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: "Search student by name or roll no...",
                  hintStyle: const TextStyle(color: Colors.black45),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF0047AB)),
                  suffixIcon: _searchQuery.isNotEmpty 
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = "";
                          });
                        },
                      ) 
                    : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: w * 0.06),
              child: Row(
                children: [
                  Text(
                    "Student Roster",
                    style: TextStyle(fontSize: w * 0.045, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            SizedBox(height: h * 0.01),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('users').where('role', isEqualTo: 'student').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFF0047AB)));
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Error fetching students: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
                  }
                  
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.group_off_rounded, size: w * 0.15, color: Colors.black26),
                          SizedBox(height: h * 0.01),
                          Text(
                            "No students found",
                            style: TextStyle(fontSize: w * 0.035, color: Colors.black45),
                          ),
                        ],
                      ),
                    );
                  }

                  // Local Filtering for Search
                  var studentDocs = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final name = (data['fullName'] ?? "").toString().toLowerCase();
                    final rollNo = (data['rollNumber'] ?? "").toString().toLowerCase();
                    final enrollmentNo = (data['enrollmentNumber'] ?? "").toString().toLowerCase();
                    
                    return name.contains(_searchQuery) || rollNo.contains(_searchQuery) || enrollmentNo.contains(_searchQuery);
                  }).toList();

                  if (studentDocs.isEmpty) {
                    return const Center(child: Text("No matches found.", style: TextStyle(color: Colors.black45)));
                  }

                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: w * 0.05),
                    itemCount: studentDocs.length,
                    itemBuilder: (context, index) {
                      final data = studentDocs[index].data() as Map<String, dynamic>;
                      final String name = data['fullName'] ?? "Unknown";
                      final String roll = data['rollNumber'] ?? "N/A";
                      final String enrollment = data['enrollmentNumber'] ?? "N/A";
                      final String email = data['email'] ?? "No Email";
                      
                      return InkWell(
                        onTap: () => _showStudentDetailsBottomsheet(context, data),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          margin: EdgeInsets.only(bottom: h * 0.015),
                          padding: EdgeInsets.all(w * 0.04),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFF0047AB).withOpacity(0.08)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                height: w * 0.13,
                                width: w * 0.13,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF0047AB), Color(0xFF1565C0)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF0047AB).withOpacity(0.3),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3)
                                    )
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  name.isNotEmpty ? name[0].toUpperCase() : "?",
                                  style: TextStyle(
                                    fontSize: w * 0.05,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(width: w * 0.04),
  
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: TextStyle(fontSize: w * 0.04, fontWeight: FontWeight.bold, color: Colors.black87),
                                    ),
                                    SizedBox(height: h * 0.004),
                                    Row(
                                      children: [
                                        Icon(Icons.badge, size: w * 0.035, color: const Color(0xFF0047AB).withOpacity(0.7)),
                                        SizedBox(width: 4),
                                        Text(
                                          "Enrollment: $enrollment",
                                          style: TextStyle(fontSize: w * 0.03, color: Colors.black54),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Icon(Icons.confirmation_number, size: w * 0.035, color: const Color(0xFF0047AB).withOpacity(0.7)),
                                        SizedBox(width: 4),
                                        Text(
                                          "Roll No: $roll",
                                          style: TextStyle(fontSize: w * 0.03, color: Colors.black54),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0047AB).withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(Icons.arrow_forward_ios_rounded, color: const Color(0xFF0047AB), size: w * 0.04),
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
      ),
    );
  }

  void _showStudentDetailsBottomsheet(BuildContext context, Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final w = AppSize.width(context);
        final h = AppSize.height(context);
        final String name = data['fullName'] ?? "Unknown";
        final String roll = data['rollNumber'] ?? "N/A";
        final String enrollment = data['enrollmentNumber'] ?? "N/A";
        final String email = data['email'] ?? "No Email";
        final String phone = data['phone'] ?? "No Phone";
        final String gender = data['gender'] ?? "N/A";
        final String dob = data['dateOfBirth'] ?? "N/A";

        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
          ),
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: w * 0.08, vertical: h * 0.04),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: w * 0.15,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  SizedBox(height: h * 0.03),
                  Container(
                    height: w * 0.22,
                    width: w * 0.22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0047AB), Color(0xFF1565C0)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(color: const Color(0xFF0047AB).withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 5))
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      name.isNotEmpty ? name.substring(0, 1).toUpperCase() : "?",
                      style: TextStyle(fontSize: w * 0.08, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  SizedBox(height: h * 0.02),
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: w * 0.06, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  SizedBox(height: h * 0.005),
                  Text(
                    "Student Profile",
                    style: TextStyle(fontSize: w * 0.035, color: Colors.grey[600]),
                  ),
                  SizedBox(height: h * 0.04),

                  _buildDetailRow(Icons.badge, "Enrollment", enrollment, w),
                  _buildDetailRow(Icons.confirmation_number, "Roll No.", roll, w),
                  _buildDetailRow(Icons.email, "Email", email, w),
                  _buildDetailRow(Icons.phone, "Phone", phone, w),
                  _buildDetailRow(Icons.person_outline, "Gender", gender, w),
                  _buildDetailRow(Icons.calendar_today, "DOB", dob, w),

                  SizedBox(height: h * 0.02),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, double w) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: const Color(0xFF0047AB), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87)),
              ],
            ),
          )
        ],
      ),
    );
  }
}