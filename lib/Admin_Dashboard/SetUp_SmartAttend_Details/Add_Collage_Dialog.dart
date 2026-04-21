import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../app_size/app_size.dart';
import '../../utils/UiHelper.dart';

class AddCollegeDialog extends StatefulWidget {
  const AddCollegeDialog({super.key});

  @override
  State<AddCollegeDialog> createState() => _AddCollegeDialogState();
}

class _AddCollegeDialogState extends State<AddCollegeDialog> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final codeController = TextEditingController();
  final cityController = TextEditingController();
  final emailController = TextEditingController();
  final contactController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isSaving = false;

  Future<bool> _isCollegeCodeUnique(String code) async {
    final snapshot = await _firestore
        .collection('colleges')
        .where(FieldPath.documentId, isEqualTo: code.toUpperCase())
        .get();
    return snapshot.docs.isEmpty;
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
                    "Add College",
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
                            controller: nameController,
                            hint: "College Name",
                            prefixIcon: const Icon(
                              Icons.school,
                              color: Color(0xFF0047AB),
                            ),
                          ),

                          SizedBox(height: 16),

                          UIHelper.customTextField(
                            controller: codeController,
                            hint: "College Code",
                            prefixIcon: const Icon(
                              Icons.code,
                              color: Color(0xFF0047AB),
                            ),
                          ),

                          SizedBox(height: 16),

                          UIHelper.customTextField(
                            controller: cityController,
                            hint: "City",
                            prefixIcon: const Icon(
                              Icons.location_city,
                              color: Color(0xFF0047AB),
                            ),
                          ),

                          SizedBox(height: 16),

                          UIHelper.customTextField(
                            controller: emailController,
                            hint: "Email",
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: const Icon(
                              Icons.email,
                              color: Color(0xFF0047AB),
                            ),
                          ),

                          SizedBox(height: 16),

                          UIHelper.customTextField(
                            controller: contactController,
                            hint: "Contact Number",
                            keyboardType: TextInputType.number,
                            prefixIcon: const Icon(
                              Icons.phone,
                              color: Color(0xFF0047AB),
                            ),
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

                    SizedBox(width: 16),

                    Expanded(
                      child: SizedBox(
                        height: AppSize.height(context) * 0.065, 
                        child: UIHelper.customButton(
                          text: "Save",
                          onPressed: () async {
                            if (!_formKey.currentState!.validate()) return;

                            setState(() => _isSaving = true);

                            final collegeCode =
                            codeController.text.trim().toUpperCase();

                            bool isUnique =
                            await _isCollegeCodeUnique(collegeCode);

                            if (!isUnique) {
                              setState(() => _isSaving = false);
                              UIHelper.showSnackBar(
                                context,
                                "College Code already exists",
                              );
                              return;
                            }

                            try {
                              await _firestore
                                  .collection('colleges')
                                  .doc(collegeCode)
                                  .set({
                                'name': nameController.text.trim(),
                                'city': cityController.text.trim(),
                                'email': emailController.text.trim(),
                                'contact': contactController.text.trim(),
                                'createdAt': FieldValue.serverTimestamp(),
                              });

                              if (mounted) Navigator.pop(context);
                              UIHelper.showSnackBar(
                                context,
                                "College Created Successfully",
                              );
                            } catch (e) {
                              setState(() => _isSaving = false);
                              UIHelper.showSnackBar(
                                context,
                                "Error saving college: $e",
                              );
                            }
                          },
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
