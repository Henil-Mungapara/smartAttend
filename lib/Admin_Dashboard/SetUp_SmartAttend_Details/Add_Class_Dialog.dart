import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../app_size/app_size.dart';
import '../../utils/UiHelper.dart';

class AddClassDialog extends StatefulWidget {
  const AddClassDialog({super.key});

  @override
  State<AddClassDialog> createState() => _AddClassDialogState();
}

class _AddClassDialogState extends State<AddClassDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController classNameController = TextEditingController();
  final TextEditingController classCodeController = TextEditingController();

  String? selectedDepartmentId;
  bool _isSaving = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<QueryDocumentSnapshot> departments = [];

  @override
  void initState() {
    super.initState();
    _fetchDepartments();
  }

  Future<void> _fetchDepartments() async {
    final snapshot = await _firestore.collection('departments').get();
    setState(() {
      departments = snapshot.docs;
    });
  }

  Future<bool> _isClassCodeUnique(String code) async {
    final snapshot = await _firestore
        .collection('classes')
        .where('code', isEqualTo: code.toUpperCase())
        .get();
    return snapshot.docs.isEmpty;
  }

  Future<void> _saveClass() async {
    if (!_formKey.currentState!.validate() || selectedDepartmentId == null)
      return;

    setState(() => _isSaving = true);

    String code = classCodeController.text.trim().toUpperCase();
    bool isUnique = await _isClassCodeUnique(code);

    if (!isUnique) {
      setState(() => _isSaving = false);
      if (mounted) UIHelper.showSnackBar(context, "Class Code already exists");
      return;
    }

    await _firestore.collection('classes').doc(code).set({
      'name': classNameController.text.trim(),
      'code': code,
      'departmentId': selectedDepartmentId,
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (mounted) Navigator.pop(context);
    if (mounted) UIHelper.showSnackBar(context, "Class Added Successfully");
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = AppSize.height(context);
    double screenWidth = AppSize.width(context);

    return Dialog(
      backgroundColor: const Color(0xFFB6BFCA),
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
                    "Add Class",
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
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: const CircularProgressIndicator(
                        color: Color(0xFF0047AB),
                      ),
                    )
                  : Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          
                          UIHelper.customTextField(
                            controller: classNameController,
                            hint: "Class Name",
                            prefixIcon: const Icon(
                              Icons.class_,
                              color: Color(0xFF0047AB),
                            ),
                          ),

                          SizedBox(height: 16),

                          UIHelper.customTextField(
                            controller: classCodeController,
                            hint: "Class Code",
                            prefixIcon: const Icon(
                              Icons.code,
                              color: Color(0xFF0047AB),
                            ),
                          ),

                          SizedBox(height: 16),

                          DropdownButtonFormField<String>(
                            value: selectedDepartmentId,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(
                                Icons.school,
                                color: Color(0xFF0047AB),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            hint: const Text("Select Department"),
                            items: departments.map((doc) {
                              return DropdownMenuItem(
                                value: doc.id,
                                child: Text(doc['name']),
                              );
                            }).toList(),
                            onChanged: (val) =>
                                setState(() => selectedDepartmentId = val),
                            validator: (val) =>
                                val == null ? "Select a department" : null,
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
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF0047AB)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: EdgeInsets.zero,
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

                    SizedBox(width: 16),

                    Expanded(
                      child: SizedBox(
                        height: screenHeight * 0.065,
                        child: UIHelper.customButton(
                          text: "Save",
                          onPressed: _saveClass,
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
