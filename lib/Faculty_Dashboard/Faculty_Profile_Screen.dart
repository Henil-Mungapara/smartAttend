import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../app_size/app_size.dart';
import '../utils/UiHelper.dart';
import '../Auth/LogIn_Screen.dart';

class FacultyProfileScreen extends StatefulWidget {
  const FacultyProfileScreen({super.key});

  @override
  State<FacultyProfileScreen> createState() => _FacultyProfileScreenState();
}

class _FacultyProfileScreenState extends State<FacultyProfileScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

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
        setState(() {
          _userData = doc.data();
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
    await FirebaseAuth.instance.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    
    if(!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  void _showEditProfileModal() {
    final nameCtrl = TextEditingController(text: _userData?['name'] ?? "");
    final mobileCtrl = TextEditingController(text: _userData?['mobile'] ?? "");
    final departmentCtrl = TextEditingController(text: _userData?['department'] ?? "");
    final designationCtrl = TextEditingController(text: _userData?['designation'] ?? "");
    
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
                    const SizedBox(height: 15),
                    UIHelper.customTextField(controller: departmentCtrl, hint: "Department", prefixIcon: const Icon(Icons.apartment), textAlign: TextAlign.center),
                    const SizedBox(height: 15),
                    UIHelper.customTextField(controller: designationCtrl, hint: "Designation", prefixIcon: const Icon(Icons.work), textAlign: TextAlign.center),
                    const SizedBox(height: 25),
                    
                    isSaving ? const CircularProgressIndicator() : UIHelper.customButton(
                      text: "Save Changes",
                      onPressed: () async {
                        setModalState(() => isSaving = true);
                        try {
                          final uid = FirebaseAuth.instance.currentUser?.uid;
                          if (uid != null) {
                            await _firestore.collection('users').doc(uid).update({
                              'name': nameCtrl.text.trim(),
                              'mobile': mobileCtrl.text.trim(),
                              'department': departmentCtrl.text.trim(),
                              'designation': designationCtrl.text.trim(),
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

    final name = _userData?['name'] ?? "Unknown";
    final email = _userData?['email'] ?? "N/A";
    final mobile = _userData?['mobile'] ?? "N/A";
    final role = _userData?['role'] ?? "Faculty";
    final department = _userData?['department'] ?? "N/A";
    final designation = _userData?['designation'] ?? "N/A";
    final facultyId = _userData?['facultyId'] ?? "N/A";
    final joiningYear = _userData?['joiningYear'] ?? "N/A";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Faculty Profile', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFF0047AB),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: _showEditProfileModal,
          )
        ],
      ),
      backgroundColor: const Color(0xFFF4F6FA),
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
                    SizedBox(height: h * 0.02),
                  ],
                ),
              ),

              SizedBox(height: h * 0.02),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: w * 0.06),
                child: _buildCard("Personal Information", [
                  _infoTile(Icons.email, "Email", email), _divider(),
                  _infoTile(Icons.phone, "Mobile", mobile), _divider(),
                  _infoTile(Icons.security, "Role", role),
                ]),
              ),

              SizedBox(height: h * 0.02),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: w * 0.06),
                child: _buildCard("Academic Information", [
                  _infoTile(Icons.apartment, "Department", department), _divider(),
                  _infoTile(Icons.work, "Designation", designation), _divider(),
                  _infoTile(Icons.badge, "Faculty ID", facultyId), _divider(),
                  _infoTile(Icons.calendar_today, "Joining Year", joiningYear.toString()),
                ]),
              ),

              SizedBox(height: h * 0.03),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: w * 0.06),
                child: UIHelper.rowOfButtons(
                  text1: "Edit Profile", 
                  onPressed1: _showEditProfileModal, 
                  text2: "Logout", 
                  onPressed2: () => _logout(context),
                )
              ),

              SizedBox(height: h * 0.02),
              const Text("SmartAttend v1.0.0", style: TextStyle(color: Colors.black38)),
              SizedBox(height: h * 0.04),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          ),
          const Divider(height: 1),
          Padding(padding: const EdgeInsets.all(12), child: Column(children: children)),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF0047AB)), const SizedBox(width: 15),
          Expanded(child: Text("$label : $value", style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }

  Widget _divider() => Divider(color: Colors.grey.shade300);
}
