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
        borderRadius: BorderRadius.circular(24),
      ),
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

              SizedBox(height: 24),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    
                    UIHelper.customTextField(
                      controller: nameController,
                      hint: "Department Name",
                      prefixIcon: const Icon(
                        Icons.account_tree,
                        color: Color(0xFF0047AB),
                      ),
                    ),

                    SizedBox(height: 16),

                    UIHelper.customTextField(
                      controller: codeController,
                      hint: "Department Code",
                      prefixIcon: const Icon(
                        Icons.code,
                        color: Color(0xFF0047AB),
                      ),
                    ),

                    SizedBox(height: 16),

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
                              borderRadius: BorderRadius.circular(15),
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

              SizedBox(height: 32),

              Row(
                children: [
                  
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

                  SizedBox(width: 16),

                  Expanded(
                    child: SizedBox(
                      height: AppSize.height(context) * 0.065, 
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
        if (mounted) UIHelper.showSnackBar(context, "Department code already exists!");
        return;
      }

      await _firestore.collection('departments').doc(deptCode).set({
        'name': nameController.text.trim(),
        'collegeId': selectedCollegeId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) Navigator.pop(context);

      if (mounted) UIHelper.showSnackBar(context, "Department added successfully");
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) UIHelper.showSnackBar(context, "Error: $e");
    }
  }
}
