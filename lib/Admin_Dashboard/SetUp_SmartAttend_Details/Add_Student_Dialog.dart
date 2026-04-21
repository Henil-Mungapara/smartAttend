import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../app_size/app_size.dart';
import '../../utils/UiHelper.dart';

class AddStudentDialog extends StatefulWidget {
  const AddStudentDialog({super.key});

  @override
  State<AddStudentDialog> createState() => _AddStudentDialogState();
}

class _AddStudentDialogState extends State<AddStudentDialog> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController enrollmentController = TextEditingController();
  final TextEditingController rollController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? selectedCollegeId;
  String? selectedDepartmentId;
  String? selectedClassId;
  String? selectedDivisionId;
  String? selectedGender;

  List<Map<String, dynamic>> colleges = [];
  List<Map<String, dynamic>> departments = [];
  List<Map<String, dynamic>> classes = [];
  List<Map<String, dynamic>> divisions = [];

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    fetchColleges();
  }

  Future<void> fetchColleges() async {
    final snapshot = await _firestore.collection('colleges').get();
    setState(() {
      colleges = snapshot.docs
          .map((doc) => {'id': doc.id, 'name': doc['name']})
          .toList();
    });
  }

  Future<void> fetchDepartments(String collegeId) async {
    final snapshot = await _firestore
        .collection('departments')
        .where('collegeId', isEqualTo: collegeId)
        .get();

    setState(() {
      departments = snapshot.docs
          .map((doc) => {'id': doc.id, 'name': doc['name']})
          .toList();

      selectedDepartmentId = null;
      selectedClassId = null;
      selectedDivisionId = null;
      classes = [];
      divisions = [];
    });
  }

  Future<void> fetchClasses(String deptId) async {
    final snapshot = await _firestore
        .collection('classes')
        .where('departmentId', isEqualTo: deptId)
        .get();

    setState(() {
      classes = snapshot.docs
          .map((doc) => {'id': doc.id, 'name': doc['name']})
          .toList();

      selectedClassId = null;
      selectedDivisionId = null;
      divisions = [];
    });
  }

  Future<void> fetchDivisions(String classId) async {
    final snapshot = await _firestore
        .collection('divisions')
        .where('classId', isEqualTo: classId)
        .get();

    setState(() {
      divisions = snapshot.docs
          .map((doc) => {'id': doc.id, 'name': doc['name']})
          .toList();

      selectedDivisionId = null;
    });
  }

  Future<void> saveStudent() async {
    if (!_formKey.currentState!.validate() ||
        selectedClassId == null ||
        selectedDivisionId == null ||
        selectedGender == null) {
      if (mounted) UIHelper.showSnackBar(context, "Please complete all fields");
      return;
    }

    setState(() => _isSaving = true);

    try {
      final existing = await _firestore
          .collection('users')
          .where(
            'enrollmentNumber',
            isEqualTo: enrollmentController.text.trim(),
          )
          .get();

      if (existing.docs.isNotEmpty) {
        setState(() => _isSaving = false);
        if (mounted) UIHelper.showSnackBar(context, "Enrollment Number already exists");
        return;
      }

      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      String uid = userCredential.user!.uid;

      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'fullName': nameController.text.trim(),
        'enrollmentNumber': enrollmentController.text.trim(),
        'rollNumber': rollController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'gender': selectedGender,
        'dateOfBirth': dobController.text.trim(),
        'classId': selectedClassId,
        'divisionId': selectedDivisionId,
        'role': 'student',
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
      });

      setState(() => _isSaving = false);

      if (mounted) Navigator.pop(context);
      if (mounted) UIHelper.showSnackBar(context, "Student Added Successfully");
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) UIHelper.showSnackBar(context, "Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = AppSize.height(context);
    final screenWidth = AppSize.width(context);

    return Dialog(
      backgroundColor: const Color(0xFFF5F7FA),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0047AB), Color(0xFF1565C0)],
                  ),
                ),
                child: const Center(
                  child: Text(
                    "Add Student",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24),

              _isSaving
                  ? const CircularProgressIndicator(color: Color(0xFF0047AB))
                  : Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          UIHelper.customTextField(
                            controller: nameController,
                            hint: "Full Name",
                            prefixIcon: const Icon(
                              Icons.person,
                              color: Color(0xFF0047AB),
                            ),
                          ),
                          SizedBox(height: 16),

                          UIHelper.customTextField(
                            controller: enrollmentController,
                            hint: "Enrollment Number",
                            prefixIcon: const Icon(
                              Icons.badge,
                              color: Color(0xFF0047AB),
                            ),
                          ),
                          SizedBox(height: 16),

                          UIHelper.customTextField(
                            controller: rollController,
                            hint: "Roll Number",
                            prefixIcon: const Icon(
                              Icons.confirmation_number,
                              color: Color(0xFF0047AB),
                            ),
                          ),
                          SizedBox(height: 16),

                          UIHelper.customTextField(
                            controller: emailController,
                            hint: "Email",
                            prefixIcon: const Icon(
                              Icons.email,
                              color: Color(0xFF0047AB),
                            ),
                          ),
                          SizedBox(height: 16),

                          UIHelper.customTextField(
                            controller: passwordController,
                            hint: "Password",
                            prefixIcon: const Icon(
                              Icons.lock,
                              color: Color(0xFF0047AB),
                            ),
                            obscureText: true,
                          ),
                          SizedBox(height: 16),

                          UIHelper.customTextField(
                            controller: phoneController,
                            hint: "Phone",
                            prefixIcon: const Icon(
                              Icons.phone,
                              color: Color(0xFF0047AB),
                            ),
                          ),
                          SizedBox(height: 16),

                          buildGenderDropdown(),
                          SizedBox(height: 16),

                          buildDatePicker(context),
                          SizedBox(height: 16),

                          buildDropdown(
                            title: "Select College",
                            value: selectedCollegeId,
                            items: colleges,
                            onChanged: (val) {
                              setState(() => selectedCollegeId = val);
                              if (val != null) fetchDepartments(val);
                            },
                          ),
                          SizedBox(height: 16),

                          buildDropdown(
                            title: "Select Department",
                            value: selectedDepartmentId,
                            items: departments,
                            onChanged: (val) {
                              setState(() => selectedDepartmentId = val);
                              if (val != null) fetchClasses(val);
                            },
                          ),
                          SizedBox(height: 16),

                          buildDropdown(
                            title: "Select Class",
                            value: selectedClassId,
                            items: classes,
                            onChanged: (val) {
                              setState(() => selectedClassId = val);
                              if (val != null) fetchDivisions(val);
                            },
                          ),
                          SizedBox(height: 16),

                          buildDropdown(
                            title: "Select Division",
                            value: selectedDivisionId,
                            items: divisions,
                            onChanged: (val) =>
                                setState(() => selectedDivisionId = val),
                          ),
                        ],
                      ),
                    ),

              SizedBox(height: 24),

              if (!_isSaving)
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: screenHeight * 0.065,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Color(0xFF0047AB),
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(
                              color: Color(0xFF0047AB),
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: SizedBox(
                        height: screenHeight * 0.065,
                        child: UIHelper.customButton(
                          text: "Save",
                          onPressed: saveStudent,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedGender,
      decoration: InputDecoration(
        labelText: "Select Gender",
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      ),
      items: [
        "Male",
        "Female",
        "Other",
      ].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
      onChanged: (val) => setState(() => selectedGender = val),
    );
  }

  Widget buildDatePicker(BuildContext context) {
    return TextFormField(
      controller: dobController,
      readOnly: true,
      decoration: InputDecoration(
        hintText: "Date of Birth",
        prefixIcon: const Icon(Icons.calendar_today, color: Color(0xFF0047AB)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      ),
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime(2005),
          firstDate: DateTime(1990),
          lastDate: DateTime.now(),
        );

        if (pickedDate != null) {
          dobController.text =
              "${pickedDate.day.toString().padLeft(2, '0')}/"
              "${pickedDate.month.toString().padLeft(2, '0')}/"
              "${pickedDate.year}";
        }
      },
    );
  }

  Widget buildDropdown({
    required String title,
    required String? value,
    required List<Map<String, dynamic>> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: items.any((item) => item['id'] == value) ? value : null,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: title,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      ),
      items: items.map<DropdownMenuItem<String>>((item) {
        return DropdownMenuItem<String>(
          value: item['id'].toString(),
          child: Text(item['name'].toString(), overflow: TextOverflow.ellipsis),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
