import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../app_size/app_size.dart';
import '../../utils/UiHelper.dart';

class AddFacultyDialog extends StatefulWidget {
  const AddFacultyDialog({super.key});

  @override
  State<AddFacultyDialog> createState() => _AddFacultyDialogState();
}

class _AddFacultyDialogState extends State<AddFacultyDialog> {
  final _formKey = GlobalKey<FormState>();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? selectedCollegeId;
  String? selectedDepartmentId;

  List<Map<String, dynamic>> colleges = [];
  List<Map<String, dynamic>> departments = [];
  List<Map<String, dynamic>> classes = [];
  List<Map<String, dynamic>> subjects = [];

  List<String> selectedClassIds = [];
  List<String> selectedSubjectIds = [];

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    fetchColleges();
  }

  // ================= FETCH DATA =================
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
      classes = [];
      subjects = [];
      selectedClassIds.clear();
      selectedSubjectIds.clear();
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
      subjects = [];
      selectedClassIds.clear();
      selectedSubjectIds.clear();
    });
  }

  Future<void> fetchSubjects(List<String> classIds) async {
    if (classIds.isEmpty) {
      setState(() {
        subjects = [];
        selectedSubjectIds.clear();
      });
      return;
    }

    final snapshot = await _firestore
        .collection('subjects')
        .where('classId', whereIn: classIds)
        .get();

    setState(() {
      subjects = snapshot.docs
          .map((doc) => {'id': doc.id, 'name': doc['name']})
          .toList();
      selectedSubjectIds.clear();
    });
  }

  // ================= SAVE =================
  Future<void> saveFaculty() async {
    if (!_formKey.currentState!.validate() ||
        selectedClassIds.isEmpty ||
        selectedSubjectIds.isEmpty) {
      UIHelper.showSnackBar(context, "Please complete all selections");
      return;
    }

    setState(() => _isSaving = true);

    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final uid = credential.user!.uid;

      await _firestore.collection('users').doc(uid).set({
        'name': nameController.text.trim(),
        'facultyCode': codeController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'classIds': selectedClassIds,
        'subjectIds': selectedSubjectIds,
        'role': 'faculty',
        'createdAt': FieldValue.serverTimestamp(),
      });

      Navigator.pop(context);
      UIHelper.showSnackBar(context, "Faculty Added Successfully");
    } catch (e) {
      setState(() => _isSaving = false);
      UIHelper.showSnackBar(context, "Error: $e");
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    final screenHeight = AppSize.height(context);
    final screenWidth = AppSize.width(context);

    return Dialog(
      backgroundColor: const Color(0xFFF5F7FA),
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
                    "Add Faculty",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.03),

              _isSaving
                  ? Padding(
                      padding: EdgeInsets.all(screenHeight * 0.05),
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
                          UIHelper.customTextField(
                            controller: nameController,
                            hint: "Faculty Name",
                            prefixIcon: const Icon(
                              Icons.person,
                              color: Color(0xFF0047AB),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.02),

                          UIHelper.customTextField(
                            controller: codeController,
                            hint: "Faculty Code",
                            prefixIcon: const Icon(
                              Icons.badge,
                              color: Color(0xFF0047AB),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.02),

                          UIHelper.customTextField(
                            controller: emailController,
                            hint: "Email",
                            prefixIcon: const Icon(
                              Icons.email,
                              color: Color(0xFF0047AB),
                            ),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          SizedBox(height: screenHeight * 0.02),

                          UIHelper.customTextField(
                            controller: passwordController,
                            hint: "Password",
                            prefixIcon: const Icon(
                              Icons.lock,
                              color: Color(0xFF0047AB),
                            ),
                            obscureText: true,
                          ),
                          SizedBox(height: screenHeight * 0.03),

                          UIHelper.customTextField(
                            controller: phoneController,
                            hint: "Phone",
                            prefixIcon: const Icon(
                              Icons.phone,
                              color: Color(0xFF0047AB),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          SizedBox(height: screenHeight * 0.02),

                          /// College Dropdown
                          buildDropdown(
                            title: "Select College",
                            value: selectedCollegeId,
                            items: colleges,
                            onChanged: (val) {
                              setState(() => selectedCollegeId = val);
                              if (val != null) fetchDepartments(val);
                            },
                          ),
                          SizedBox(height: screenHeight * 0.02),

                          /// Department Dropdown
                          buildDropdown(
                            title: "Select Department",
                            value: selectedDepartmentId,
                            items: departments,
                            onChanged: (val) {
                              setState(() => selectedDepartmentId = val);
                              if (val != null) fetchClasses(val);
                            },
                          ),
                          SizedBox(height: screenHeight * 0.02),

                          /// Classes Multi-Select
                          buildMultiSelect(
                            title: "Select Classes",
                            items: classes,
                            selectedIds: selectedClassIds,
                            onChanged: (ids) {
                              setState(() => selectedClassIds = ids);

                              // Call async safely
                              Future.microtask(() async {
                                await fetchSubjects(ids);
                              });
                            },
                          ),
                          SizedBox(height: screenHeight * 0.02),

                          /// Subjects Multi-Select
                          buildMultiSelect(
                            title: "Select Subjects",
                            items: subjects,
                            selectedIds: selectedSubjectIds,
                            onChanged: (ids) =>
                                setState(() => selectedSubjectIds = ids),
                          ),
                        ],
                      ),
                    ),
              SizedBox(height: screenHeight * 0.03),

              if (!_isSaving)
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height:
                            screenHeight * 0.065, // Fix height for both buttons
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF0047AB)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: EdgeInsets
                                .zero, // Remove internal padding since height is fixed
                          ),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(color: Color(0xFF0047AB)),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.04),
                    Expanded(
                      child: SizedBox(
                        height: screenHeight * 0.065, // Same height as Cancel
                        child: UIHelper.customButton(
                          text: "Save",
                          onPressed: saveFaculty,
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

  // ================= Dropdown & MultiSelect remain same =================
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF0047AB)),
        ),
      ),
      items: items.isEmpty
          ? [
              const DropdownMenuItem<String>(
                value: "",
                child: Text("No data available"),
              ),
            ]
          : items.map((item) {
              return DropdownMenuItem<String>(
                value: item['id'].toString(),
                child: Text(
                  item['name'].toString(),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
      onChanged: onChanged,
    );
  }

  Widget buildMultiSelect({
    required String title,
    required List<Map<String, dynamic>> items,
    required List<String> selectedIds,
    required Function(List<String>) onChanged,
  }) {
    return InkWell(
      onTap: () async {
        List<String> tempSelected = List.from(selectedIds);

        final result = await showDialog<List<String>>(
          context: context,
          builder: (context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: StatefulBuilder(
                builder: (context, setDialogState) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    constraints: const BoxConstraints(maxHeight: 500),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0047AB), Color(0xFF1565C0)],
                            ),
                          ),
                          child: Center(
                            child: Text(
                              title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Expanded(
                          child: items.isEmpty
                              ? const Center(
                                  child: Text(
                                    "No Data Available",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: items.length,
                                  itemBuilder: (context, index) {
                                    final item = items[index];
                                    final isSelected = tempSelected.contains(
                                      item['id'],
                                    );
                                    return CheckboxListTile(
                                      title: Text(item['name']),
                                      value: isSelected,
                                      onChanged: (val) {
                                        setDialogState(() {
                                          if (val == true) {
                                            tempSelected.add(item['id']);
                                          } else {
                                            tempSelected.remove(item['id']);
                                          }
                                        });
                                      },
                                      controlAffinity:
                                          ListTileControlAffinity.trailing,
                                      activeColor: const Color(0xFF0047AB),
                                    );
                                  },
                                ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: Color(0xFF0047AB),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () => Navigator.pop(context),
                                child: const Text(
                                  "Cancel",
                                  style: TextStyle(color: Color(0xFF0047AB)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0047AB),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () =>
                                    Navigator.pop(context, tempSelected),
                                child: const Text(
                                  "Done",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        );

        if (result != null) {
          onChanged(result);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: title,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: Text(
          selectedIds.isEmpty
              ? "Select"
              : items
                    .where((i) => selectedIds.contains(i['id']))
                    .map((e) => e['name'])
                    .join(", "),
          style: TextStyle(
            color: selectedIds.isEmpty ? Colors.grey : const Color(0xFF0047AB),
            fontWeight: selectedIds.isEmpty
                ? FontWeight.normal
                : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
