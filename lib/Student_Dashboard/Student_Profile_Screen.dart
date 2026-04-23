import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../app_size/app_size.dart';
import '../utils/UiHelper.dart';
import '../Auth/LogIn_Screen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  String _divisionName = "N/A";
  String _className = "N/A";
  String _departmentName = "N/A";
  String _collegeName = "N/A";

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && mounted) {
        final data = doc.data()!;
        String? divId = data['divisionId'];
        if (divId != null && divId.isNotEmpty) {
          try {
            final divDoc = await _firestore.collection('divisions').doc(divId).get();
            if (divDoc.exists) {
              _divisionName = divDoc.data()?['name'] ?? "N/A";
            }
          } catch (e) {
            // keep N/A
          }
        }
        
        String? clsId = data['classId'];
        if (clsId != null && clsId.isNotEmpty) {
          try {
            final clsDoc = await _firestore.collection('classes').doc(clsId).get();
            if (clsDoc.exists) {
              _className = clsDoc.data()?['name'] ?? "N/A";
              
              String? deptId = clsDoc.data()?['departmentId'];
              if (deptId != null && deptId.isNotEmpty) {
                final deptDoc = await _firestore.collection('departments').doc(deptId).get();
                if (deptDoc.exists) {
                  _departmentName = deptDoc.data()?['name'] ?? "N/A";

                  String? colId = deptDoc.data()?['collegeId'];
                  if (colId != null && colId.isNotEmpty) {
                     final colDoc = await _firestore.collection('colleges').doc(colId).get();
                     if (colDoc.exists) {
                       _collegeName = colDoc.data()?['name'] ?? "N/A";
                     }
                  }
                }
              }
            }
          } catch (e) {
            // keep N/A
          }
        }
        setState(() {
          _userData = data;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await FirebaseAuth.instance.signOut();
    
    if(!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  void _showEditProfileModal() {
    final nameCtrl = TextEditingController(text: _userData?['fullName'] ?? _userData?['name'] ?? "");
    final mobileCtrl = TextEditingController(text: _userData?['phone'] ?? _userData?['mobile'] ?? "");
    
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20, right: 20, top: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Edit Profile", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    UIHelper.customTextField(controller: nameCtrl, hint: "Name", prefixIcon: const Icon(Icons.person), textAlign: TextAlign.center),
                    const SizedBox(height: 15),
                    UIHelper.customTextField(controller: mobileCtrl, hint: "Mobile", keyboardType: TextInputType.phone, prefixIcon: const Icon(Icons.phone), textAlign: TextAlign.center),
                    const SizedBox(height: 25),
                    
                    isSaving ? const CircularProgressIndicator() : UIHelper.customButton(
                      text: "Save Changes",
                      onPressed: () async {
                        setModalState(() => isSaving = true);
                        try {
                          final uid = FirebaseAuth.instance.currentUser?.uid;
                          if (uid != null) {
                            await _firestore.collection('users').doc(uid).update({
                              'fullName': nameCtrl.text.trim(),
                              'name': nameCtrl.text.trim(),
                              'phone': mobileCtrl.text.trim(),
                              'mobile': mobileCtrl.text.trim(),
                            });
                            await _fetchProfileData();
                            if(!ctx.mounted) return;
                            UIHelper.showSnackBar(ctx, "Profile updated successfully");
                            Navigator.pop(ctx);
                          }
                        } catch (e) {
                          UIHelper.showSnackBar(ctx, "Failed to update profile: $e");
                        } finally {
                          setModalState(() => isSaving = false);
                        }
                      }
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          }
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: Color(0xFF0047AB))));
    }

    final double w = AppSize.width(context);
    final double h = AppSize.height(context);

    final name = _userData?['fullName'] ?? _userData?['name'] ?? "Unknown";
    final email = _userData?['email'] ?? "N/A";
    final mobile = _userData?['phone'] ?? _userData?['mobile'] ?? "N/A";
    final role = _userData?['role'] ?? "Student";
    final enrollmentNo = _userData?['enrollmentNumber'] ?? _userData?['enrollmentNo'] ?? "N/A";
    final rollNo = _userData?['rollNumber'] ?? _userData?['rollNo'] ?? "N/A";

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: const Text('Student Profile', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFF0047AB),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: _showEditProfileModal,
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF0047AB),
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
                ),
                child: Column(
                  children: [
                    SizedBox(height: h * 0.025),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3)),
                      child: const CircleAvatar(radius: 48, backgroundColor: Colors.white24, child: Icon(Icons.person, size: 48, color: Colors.white)),
                    ),
                    SizedBox(height: h * 0.012),
                    Text(name, style: TextStyle(fontSize: w * 0.055, fontWeight: FontWeight.bold, color: Colors.white)),
                    SizedBox(height: h * 0.005),
                    Text(email, style: TextStyle(fontSize: w * 0.032, color: Colors.white70)),
                    SizedBox(height: h * 0.012),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: w * 0.05, vertical: 6),
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
                      child: Text(role, style: TextStyle(fontSize: w * 0.032, color: Colors.white, fontWeight: FontWeight.w600)),
                    ),
                    SizedBox(height: h * 0.028),
                  ],
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: w * 0.06),
                child: Transform.translate(
                  offset: Offset(0, -h * 0.022),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: h * 0.015),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withAlpha(18), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _statItem("Good", "Attendance", w),
                        _verticalLine(h),
                        _statItem("Active", "Status", w),
                        _verticalLine(h),
                        _statItem(_divisionName, "Division", w),
                      ],
                    ),
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: w * 0.06),
                child: _buildCard("Personal Information", Icons.person_outline_rounded, w, h, [
                  _infoTile(Icons.email_outlined, "Email", email, w), _thinDivider(),
                  _infoTile(Icons.phone_outlined, "Mobile", mobile, w), _thinDivider(),
                  _infoTile(Icons.security_outlined, "Role", role, w),
                ]),
              ),
              SizedBox(height: h * 0.018),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: w * 0.06),
                child: _buildCard("Academic Information", Icons.school_outlined, w, h, [
                  _infoTile(Icons.account_balance, "College", _collegeName, w), _thinDivider(),
                  _infoTile(Icons.domain, "Department", _departmentName, w), _thinDivider(),
                  _infoTile(Icons.class_, "Class", _className, w), _thinDivider(),
                  _infoTile(Icons.group, "Division", _divisionName, w), _thinDivider(),
                  _infoTile(Icons.badge, "Enrollment Number", enrollmentNo, w), _thinDivider(),
                  _infoTile(Icons.format_list_numbered, "Roll Number", rollNo, w),
                ]),
              ),
              SizedBox(height: h * 0.018),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: w * 0.06),
                child: UIHelper.rowOfButtons(
                  text1: "Edit Profile", 
                  onPressed1: _showEditProfileModal, 
                  text2: "Logout", 
                  onPressed2: () => _logout(context),
                )
              ),

              SizedBox(height: h * 0.015),
              Text("SmartAttend v1.0.0", style: TextStyle(fontSize: w * 0.028, color: Colors.black38)),
              SizedBox(height: h * 0.035),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statItem(String value, String label, double w) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: w * 0.045, fontWeight: FontWeight.bold, color: const Color(0xFF0047AB))),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: w * 0.028, color: Colors.black54)),
      ],
    );
  }

  Widget _verticalLine(double h) => Container(height: h * 0.035, width: 1, color: Colors.grey.shade300);

  Widget _buildCard(String title, IconData titleIcon, double w, double h, List<Widget> children) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: w * 0.045, vertical: 14),
            child: Row(
              children: [
                Icon(titleIcon, color: const Color(0xFF0047AB), size: w * 0.05),
                SizedBox(width: w * 0.025),
                Text(title, style: TextStyle(fontSize: w * 0.04, fontWeight: FontWeight.w700, color: Colors.black87)),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(padding: EdgeInsets.symmetric(horizontal: w * 0.045, vertical: 8), child: Column(children: children)),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value, double w) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFF0047AB).withAlpha(20), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: const Color(0xFF0047AB), size: w * 0.048),
          ),
          SizedBox(width: w * 0.035),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: w * 0.03, color: Colors.grey, fontWeight: FontWeight.w500)),
                const SizedBox(height: 3),
                Text(value, style: TextStyle(fontSize: w * 0.037, fontWeight: FontWeight.w600, color: Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _thinDivider() => Divider(height: 1, color: Colors.grey.shade200);
}