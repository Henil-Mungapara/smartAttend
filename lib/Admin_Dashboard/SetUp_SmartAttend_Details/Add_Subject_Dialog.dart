import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../app_size/app_size.dart';
import '../../utils/UiHelper.dart';

class AddSubjectDialog extends StatefulWidget {
  const AddSubjectDialog({super.key});

  @override
  State<AddSubjectDialog> createState() => _AddSubjectDialogState();
}

class _AddSubjectDialogState extends State<AddSubjectDialog> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController codeController = TextEditingController();

  String? selectedClassId;
  String? selectedDepartmentId;

  bool _isSaving = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> departments = [];
  List<Map<String, dynamic>> classes = [];

  @override
  void initState() {
    super.initState();
    fetchDepartments();
  }

  Future<void> fetchDepartments() async {
    final deptSnapshot = await _firestore.collection('departments').get();
    setState(() {
      departments = deptSnapshot.docs
          .map((doc) => {'id': doc.id, 'name': doc['name']})
          .toList();
    });
  }

  Future<void> fetchClassesForDepartment(String departmentId) async {
    final classSnapshot = await _firestore
        .collection('classes')
        .where('departmentId', isEqualTo: departmentId)
        .get();

    setState(() {
      classes = classSnapshot.docs
          .map((doc) => {'id': doc.id, 'name': doc['name']})
          .toList();
      selectedClassId = null;
    });
  }

  Future<bool> isSubjectCodeUnique(String code) async {
    final snapshot = await _firestore
        .collection('subjects')
        .where(FieldPath.documentId, isEqualTo: code.toUpperCase())
        .get();
    return snapshot.docs.isEmpty;
  }

  Future<void> saveSubject() async {
    if (!_formKey.currentState!.validate() ||
        selectedDepartmentId == null ||
        selectedClassId == null) {
      UIHelper.showSnackBar(
        context,
        "Please fill all fields and select dropdowns",
      );
      return;
    }

    setState(() => _isSaving = true);

    final subjectCode = codeController.text.trim().toUpperCase();
    final isUnique = await isSubjectCodeUnique(subjectCode);

    if (!isUnique) {
      setState(() => _isSaving = false);
      UIHelper.showSnackBar(context, "Subject code already exists");
      return;
    }

    try {
      await _firestore.collection('subjects').doc(subjectCode).set({
        'name': nameController.text.trim(),
        'classId': selectedClassId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      Navigator.pop(context);
      UIHelper.showSnackBar(context, "Subject created successfully");
    } catch (e) {
      setState(() => _isSaving = false);
      UIHelper.showSnackBar(context, "Error saving subject: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = AppSize.height(context);
    double screenWidth = AppSize.width(context);

    return Dialog(
      backgroundColor: const Color(0xFFB6BFCA),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      insetPadding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05,
        vertical: screenHeight * 0.05,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.06),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// Header
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0047AB), Color(0xFF1565C0)],
                  ),
                ),
                child: const Center(
                  child: Text(
                    "Add Subject",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.03),

              _isSaving
                  ? Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.05,
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF0047AB),
                        ),
                      ),
                    )
                  : Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          /// Subject Name
                          UIHelper.customTextField(
                            controller: nameController,
                            hint: "Subject Name",
                            prefixIcon: const Icon(
                              Icons.book,
                              color: Color(0xFF0047AB),
                            ),
                          ),

                          SizedBox(height: screenHeight * 0.02),

                          /// Subject Code
                          UIHelper.customTextField(
                            controller: codeController,
                            hint: "Subject Code",
                            prefixIcon: const Icon(
                              Icons.code,
                              color: Color(0xFF0047AB),
                            ),
                          ),

                          SizedBox(height: screenHeight * 0.02),

                          DropdownButtonFormField<String>(
                            value: selectedDepartmentId,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.school, color: Color(0xFF0047AB)),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            hint: const Text("Select Department"),
                            items: departments.isEmpty
                                ? [
                              const DropdownMenuItem<String>(
                                value: "",
                                child: Text("No departments available"),
                              )
                            ]
                                : departments.map((dept) {
                              return DropdownMenuItem<String>(
                                value: dept['id'],
                                child: Text(dept['name']),
                              );
                            }).toList(),
                            onChanged: (val) async {
                              setState(() {
                                selectedDepartmentId = val;
                                selectedClassId = null;
                                classes = [];
                              });
                              if (val != null && val.isNotEmpty) {
                                await fetchClassesForDepartment(val);
                              }
                            },
                            validator: (val) =>
                            val == null || val.isEmpty ? "Select a department" : null,
                          ),

                          SizedBox(height: screenHeight * 0.02),

                          /// Class Dropdown
                          DropdownButtonFormField<String>(
                            value: selectedClassId,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(
                                Icons.class_,
                                color: Color(0xFF0047AB),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            hint: const Text("Select Class"),
                            items: classes.isEmpty
                                ? [
                              const DropdownMenuItem<String>(
                                value: "",
                                child: Text("No classes available"),
                              )
                            ]
                                : classes.map((cls) {
                              return DropdownMenuItem<String>(
                                value: cls['id'],
                                child: Text(cls['name']),
                              );
                            }).toList(),
                            onChanged: classes.isEmpty
                                ? null
                                : (val) =>
                                      setState(() => selectedClassId = val),
                            validator: (val) =>
                                val == null ? "Select a class" : null,
                          ),
                        ],
                      ),
                    ),

              SizedBox(height: screenHeight * 0.03),

              if (!_isSaving)
                Row(
                  children: [
                    /// Cancel Button
                    Expanded(
                      child: SizedBox(
                        height: AppSize.height(context) * 0.065,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF0047AB)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(
                              color: Color(0xFF0047AB),
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: screenWidth * 0.04),

                    Expanded(
                      child: SizedBox(
                        height: AppSize.height(context) * 0.065, // SAME HEIGHT
                        child: UIHelper.customButton(
                          text: "Save",
                          onPressed: saveSubject,
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
}
