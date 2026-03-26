import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';
import 'package:smartattend/utils/UiHelper.dart';
import '../Faculty_Dashboard/faculty_main_navigation.dart';
import '../Student_Dashboard/student_main_navigation.dart';
import '../Admin_Dashboard/Admin_Main_Navigation_Screen.dart';
import '../app_size/app_size.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  Future<void> loginUser() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      UIHelper.showSnackBar(context, "Please fill all fields");
      return;
    }

    if (!email.contains("@") || !email.contains(".")) {
      UIHelper.showSnackBar(context, "Please enter a valid email");
      return;
    }

    setState(() => _isLoading = true);

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        UIHelper.showSnackBar(context, "User data not found in database");
        setState(() => _isLoading = false);
        return;
      }

      String role = (userDoc["role"] ?? "").toString().toLowerCase();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("role", role);
      await prefs.setBool("isLoggedIn", true);

      emailController.clear();
      passwordController.clear();
      FocusScope.of(context).unfocus();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Login Successful 🎉"),
          backgroundColor: const Color(0xFF0047AB),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );

      // Role-based navigation
      if (role == "student") {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const StudentMainNavigation(),
          ),
          (route) => false,
        );
      } else if (role == "faculty") {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const FacultyMainNavigation(),
          ),
          (route) => false,
        );
      } else if (role == "admin") {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const Admin_Main_Navigation_Screen(),
          ),
          (route) => false,
        );
      } else {
        UIHelper.showSnackBar(context, "Role not assigned properly");
      }
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'user-not-found') {
        message = "No account found. Please sign up first.";
      } else if (e.code == 'wrong-password') {
        message = "Incorrect password";
      } else if (e.code == 'invalid-email') {
        message = "Invalid email address";
      } else {
        message = e.message ?? "Login failed";
      }
      UIHelper.showSnackBar(context, message);
    } catch (e) {
      UIHelper.showSnackBar(context, "Unexpected error occurred");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = AppSize.width(context);
    double screenHeight = AppSize.height(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFB6BFCA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0047AB),
        title: Text(
          "Login",
          style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.05),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.only(
                left: screenWidth * 0.06,
                right: screenWidth * 0.06,
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: AutofillGroup(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: screenHeight * 0.08),
                        Container(
                          width: double.infinity,
                          height: screenHeight * 0.25,
                          child: Lottie.asset(
                            "assets/animation/SmartAttendLottie.json",
                            fit: BoxFit.contain,
                            repeat: true,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        UIHelper.customTextField(
                          controller: emailController,
                          hint: "Email Address",
                          autofillHints: const [AutofillHints.email],
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: const Icon(
                            Icons.email,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        UIHelper.customTextField(
                          controller: passwordController,
                          hint: "Password",
                          autofillHints: const [AutofillHints.password],
                          obscureText: _obscurePassword,
                          prefixIcon: const Icon(
                            Icons.lock,
                            color: Colors.black,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey.shade600,
                            ),
                            onPressed: () {
                              setState(
                                () => _obscurePassword = !_obscurePassword,
                              );
                            },
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: () {
                                UIHelper.showSnackBar(
                                  context,
                                  "OTP verification tapped",
                                );
                              },
                              child: Text(
                                "OTP Verification",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: screenWidth * 0.04,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                UIHelper.showSnackBar(
                                  context,
                                  "Forgot Password tapped",
                                );
                              },
                              child: Text(
                                "Forgot Password?",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: screenWidth * 0.04,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        _isLoading
                            ? const CircularProgressIndicator(
                                color: Color(0xFF0047AB),
                              )
                            : SizedBox(
                                width: screenWidth * 0.9,
                                height: screenHeight * 0.06,
                                child: UIHelper.customButton(
                                  text: "Login",
                                  onPressed: loginUser,
                                ),
                              ),
                        SizedBox(height: screenHeight * 0.02),
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: Colors.black45,
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.03,
                              ),
                              child: Text(
                                "OR",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: screenWidth * 0.04,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: Colors.black45,
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        SizedBox(
                          width: screenWidth * 0.9,
                          height: screenHeight * 0.06,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.04,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  "assets/images/google.png",
                                  height: screenHeight * 0.03,
                                ),
                                SizedBox(width: screenWidth * 0.03),
                                Flexible(
                                  child: Text(
                                    "Continue with Google",
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.045,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.03),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
