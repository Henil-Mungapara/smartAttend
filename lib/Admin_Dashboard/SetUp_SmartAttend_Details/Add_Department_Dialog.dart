import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartattend/app_size/app_size.dart';

import '../../utils/UiHelper.dart';

class AddDepartmentDialog extends StatefulWidget {
  const AddDepartmentDialog({super.key});

  @override
  State<AddDepartmentDialog> createState() => _AddDepartmentDialogState();
}

class _AddDepartmentDialogState extends State<AddDepartmentDialog> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final codeController = TextEditingController();
  String? selectedCollegeId;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    double w = AppSize.width(context);
    double h = AppSize.height(context);

    return Dialog(
      backgroundColor: const Color(0xFFB6BFCA),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(w * 0.06),
      ),
      insetPadding: EdgeInsets.symmetric(
        horizontal: w * 0.05,
        vertical: h * 0.05,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(w * 0.06),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// 🔷 Header
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: h * 0.02),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(w * 0.05),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0047AB), Color(0xFF1565C0)],
                  ),
                ),
                child: Center(
                  child: Text(
                    "Add Department",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: w * 0.055,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              SizedBox(height: h * 0.03),

              /// 🔷 Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    /// Department Name
                    UIHelper.customTextField(
                      controller: nameController,
                      hint: "Department Name",
                      prefixIcon: const Icon(
                        Icons.account_tree,
                        color: Color(0xFF0047AB),
                      ),
                    ),

                    SizedBox(height: h * 0.02),

                    /// Department Code
                    UIHelper.customTextField(
                      controller: codeController,
                      hint: "Department Code",
                      prefixIcon: const Icon(
                        Icons.code,
                        color: Color(0xFF0047AB),
                      ),
                    ),

                    SizedBox(height: h * 0.02),

                    /// College Dropdown (UNCHANGED)
                    StreamBuilder<QuerySnapshot>(
                      stream: _firestore
                          .collection('colleges')
                          .orderBy('name')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Padding(
                            padding: EdgeInsets.all(h * 0.02),
                            child: const CircularProgressIndicator(
                              color: Color(0xFF0047AB),
                            ),
                          );
                        }

                        final colleges = snapshot.data!.docs;

                        return DropdownButtonFormField<String>(
                          value: selectedCollegeId,
                          hint: const Text("Select College"),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.school,
                              color: Color(0xFF0047AB),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(w * 0.04),
                            ),
                          ),
                          items: colleges.map((doc) {
                            return DropdownMenuItem<String>(
                              value: doc.id,
                              child: Text(doc['name']),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedCollegeId = value;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please select a college";
                            }
                            return null;
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),

              SizedBox(height: h * 0.04),

              /// 🔷 Buttons
              Row(
                children: [
                  /// Cancel
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
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                            color: const Color(0xFF0047AB),
                            fontSize: w * 0.04,
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: w * 0.04),

                  Expanded(
                    child: SizedBox(
                      height: AppSize.height(context) * 0.065, // SAME HEIGHT
                      child: _isSaving
                          ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF0047AB),
                        ),
                      )
                          : UIHelper.customButton(
                        text: "Save",
                        onPressed: saveDepartment,
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

  /// 🔷 Save Function (UNCHANGED LOGIC)
  Future<void> saveDepartment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final deptCode = codeController.text.trim().toUpperCase();

      final existingDoc = await _firestore
          .collection('departments')
          .doc(deptCode)
          .get();

      if (existingDoc.exists) {
        setState(() => _isSaving = false);
        UIHelper.showSnackBar(context, "Department code already exists!");
        return;
      }

      await _firestore.collection('departments').doc(deptCode).set({
        'name': nameController.text.trim(),
        'collegeId': selectedCollegeId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      Navigator.pop(context);

      UIHelper.showSnackBar(context, "Department added successfully");
    } catch (e) {
      setState(() => _isSaving = false);
      UIHelper.showSnackBar(context, "Error: $e");
    }
  }
}
