import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Auth/LogIn_Screen.dart';
import '../app_size/app_size.dart';
import '../utils/UiHelper.dart';

class Admin_Profile_Screen extends StatefulWidget {
  const Admin_Profile_Screen({super.key});

  @override
  State<Admin_Profile_Screen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<Admin_Profile_Screen> {
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isLoggedIn", false);
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  void _showEditProfileModal() {
    final nameCtrl = TextEditingController(text: _userData?['name'] ?? "");
    final mobileCtrl = TextEditingController(text: _userData?['mobile'] ?? "");
    
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final w = AppSize.width(context);
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24, right: 24, top: 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                    ),
                    const SizedBox(height: 24),
                    const Text("Edit Profile", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 24),
                    UIHelper.customTextField(controller: nameCtrl, hint: "Name", prefixIcon: const Icon(Icons.person, color: Color(0xFF0047AB)), textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    UIHelper.customTextField(controller: mobileCtrl, hint: "Mobile", keyboardType: TextInputType.phone, prefixIcon: const Icon(Icons.phone, color: Color(0xFF0047AB)), textAlign: TextAlign.center),
                    const SizedBox(height: 32),
                    
                    isSaving 
                        ? const Center(child: CircularProgressIndicator(color: Color(0xFF0047AB))) 
                        : Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    side: const BorderSide(color: Color(0xFF0047AB), width: 1.5),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                  ),
                                  child: const Text("Cancel", style: TextStyle(color: Color(0xFF0047AB), fontSize: 16, fontWeight: FontWeight.bold)),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if(nameCtrl.text.isEmpty) return;
                                    setModalState(() => isSaving = true);
                                    try {
                                      final uid = FirebaseAuth.instance.currentUser?.uid;
                                      if (uid != null) {
                                        await _firestore.collection('users').doc(uid).update({
                                          'name': nameCtrl.text.trim(),
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
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    backgroundColor: const Color(0xFF0047AB),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                    elevation: 5,
                                    shadowColor: const Color(0xFF0047AB).withAlpha(102),
                                  ),
                                  child: const Text("Save Changes", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                    const SizedBox(height: 32),
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
    final name = _userData?['name'] ?? "Admin";
    final email = _userData?['email'] ?? "admin@smartattend.com";
    final mobile = _userData?['mobile'] ?? "Not Provided";

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Admin Profile", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        centerTitle: true,
        backgroundColor: const Color(0xFF0047AB),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Header Profile Banner
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(bottom: h * 0.04, top: h * 0.02),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF0047AB), Color(0xFF1565C0)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
                boxShadow: [BoxShadow(color: const Color(0xFF0047AB).withAlpha(76), blurRadius: 15, offset: const Offset(0, 5))],
              ),
              child: Column(
                children: [
                  Container(
                    height: w * 0.28,
                    width: w * 0.28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      color: Colors.white,
                      boxShadow: [BoxShadow(color: Colors.black.withAlpha(25), blurRadius: 10, spreadRadius: 2)],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : "A",
                      style: TextStyle(fontSize: w * 0.12, fontWeight: FontWeight.bold, color: const Color(0xFF0047AB)),
                    ),
                  ),
                  SizedBox(height: h * 0.02),
                  Text(name, style: TextStyle(fontSize: w * 0.06, fontWeight: FontWeight.bold, color: Colors.white)),
                  SizedBox(height: h * 0.005),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white.withAlpha(51), borderRadius: BorderRadius.circular(20)),
                    child: const Text("Administrator", style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: h * 0.03),

            // Profile Information Cards
            Padding(
              padding: EdgeInsets.symmetric(horizontal: w * 0.06),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Account Information", style: TextStyle(fontSize: w * 0.045, fontWeight: FontWeight.bold, color: Colors.black87)),
                  SizedBox(height: h * 0.02),

                  _buildInfoCard(Icons.email_outlined, "Email Address", email),
                  const SizedBox(height: 12),
                  _buildInfoCard(Icons.phone_outlined, "Mobile Number", mobile),
                  const SizedBox(height: 12),
                  _buildInfoCard(Icons.admin_panel_settings_outlined, "Access Level", "Full Administrator"),
                  
                  SizedBox(height: h * 0.04),

                  // Actions
                  ElevatedButton(
                    onPressed: _showEditProfileModal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF0047AB),
                      elevation: 2,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.edit, size: 20),
                        SizedBox(width: 10),
                        Text("Edit Profile Details", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _logout(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFF0F0),
                      foregroundColor: Colors.redAccent,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: const BorderSide(color: Colors.redAccent, width: 1)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.logout, size: 20),
                        SizedBox(width: 10),
                        Text("Logout Securely", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  SizedBox(height: h * 0.04),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(7), blurRadius: 8, offset: const Offset(0, 2))],
        border: Border.all(color: Colors.grey.withAlpha(25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFF0047AB).withAlpha(12), shape: BoxShape.circle),
            child: Icon(icon, color: const Color(0xFF0047AB), size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}