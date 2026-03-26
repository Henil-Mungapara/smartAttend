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
      UIHelper.showSnackBar(context, "Division Code already exists");
      return;
    }

    await _firestore.collection('divisions').doc(code).set({
      'name': divisionNameController.text.trim(),
      'code': code,
      'classId': selectedClassId,
      'createdAt': FieldValue.serverTimestamp(),
    });

    Navigator.pop(context);
    UIHelper.showSnackBar(context, "Division Added Successfully");
  }

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
              /// Header
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
                    "Add Division",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: w * 0.055,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              SizedBox(height: h * 0.03),

              _isSaving
                  ? Padding(
                      padding: EdgeInsets.symmetric(vertical: h * 0.05),
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

                          SizedBox(height: h * 0.02),

                          UIHelper.customTextField(
                            controller: divisionCodeController,
                            hint: "Division Code",
                            prefixIcon: const Icon(
                              Icons.code,
                              color: Color(0xFF0047AB),
                            ),
                          ),

                          SizedBox(height: h * 0.02),

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
                                borderRadius: BorderRadius.circular(w * 0.04),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

              SizedBox(height: h * 0.04),

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

                    SizedBox(width: w * 0.04),

                    Expanded(
                      child: SizedBox(
                        height: AppSize.height(context) * 0.065, // SAME HEIGHT
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
