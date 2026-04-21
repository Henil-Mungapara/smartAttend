import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartattend/app_size/app_size.dart';

import '../../utils/UiHelper.dart';

class AddDivisionDialog extends StatefulWidget {
  const AddDivisionDialog({super.key});

  @override
  State<AddDivisionDialog> createState() => _AddDivisionDialogState();
}

class _AddDivisionDialogState extends State<AddDivisionDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController divisionNameController = TextEditingController();
  final TextEditingController divisionCodeController = TextEditingController();

  String? selectedClassId;
  bool _isSaving = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<QueryDocumentSnapshot> classes = [];

  @override
  void initState() {
    super.initState();
    _fetchClasses();
  }

  Future<void> _fetchClasses() async {
    final snapshot = await _firestore.collection('classes').get();
    setState(() {
      classes = snapshot.docs;
    });
  }

  Future<bool> _isDivisionCodeUnique(String code) async {
    final snapshot = await _firestore
        .collection('divisions')
        .where('code', isEqualTo: code.toUpperCase())
        .get();
    return snapshot.docs.isEmpty;
  }

  Future<void> _saveDivision() async {
    if (!_formKey.currentState!.validate() || selectedClassId == null) return;

    setState(() => _isSaving = true);

    String code = divisionCodeController.text.trim().toUpperCase();
    bool isUnique = await _isDivisionCodeUnique(code);

    if (!isUnique) {
      setState(() => _isSaving = false);
      if (mounted) UIHelper.showSnackBar(context, "Division Code already exists");
      return;
    }

    await _firestore.collection('divisions').doc(code).set({
      'name': divisionNameController.text.trim(),
      'code': code,
      'classId': selectedClassId,
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (mounted) Navigator.pop(context);
    if (mounted) UIHelper.showSnackBar(context, "Division Added Successfully");
  }

  @override
  Widget build(BuildContext context) {
    double w = AppSize.width(context);
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
                    "Add Division",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: w * 0.055,
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
                            controller: divisionNameController,
                            hint: "Division Name",
                            prefixIcon: const Icon(
                              Icons.group,
                              color: Color(0xFF0047AB),
                            ),
                          ),

                          SizedBox(height: 16),

                          UIHelper.customTextField(
                            controller: divisionCodeController,
                            hint: "Division Code",
                            prefixIcon: const Icon(
                              Icons.code,
                              color: Color(0xFF0047AB),
                            ),
                          ),

                          SizedBox(height: 16),

                          DropdownButtonFormField<String>(
                            value: selectedClassId,
                            hint: const Text("Select Class"),
                            items: classes.map((doc) {
                              return DropdownMenuItem(
                                value: doc.id,
                                child: Text(doc['name']),
                              );
                            }).toList(),
                            onChanged: (val) =>
                                setState(() => selectedClassId = val),
                            validator: (val) =>
                                val == null ? "Select a class" : null,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(
                                Icons.class_,
                                color: Color(0xFF0047AB),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

              SizedBox(height: 32),

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
                        child: UIHelper.customButton(
                          text: "Save",
                          onPressed: _saveDivision,
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
