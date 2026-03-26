import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartattend/Auth/LogIn_Screen.dart';
import 'app_size/app_size.dart';

class PrivacyPolicyPage extends StatefulWidget {
  const PrivacyPolicyPage({super.key});

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  bool _agreeTerms = false;
  bool _agreePrivacy = false;

  @override
  Widget build(BuildContext context) {
    final w = AppSize.width(context);
    final h = AppSize.height(context);

    return Scaffold(
      backgroundColor: const Color(0xFFB6BFCA),
      appBar: AppBar(
        title: Text(
          'Privacy Policy',
          style: TextStyle(
            color: Colors.white,
            fontSize: w * 0.05,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0047AB),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      // ✅ FULL PAGE SCROLLABLE
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: w * 0.06,
          vertical: h * 0.03,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "SmartAttend Privacy Policy",
              style: TextStyle(
                fontSize: w * 0.05,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: h * 0.02),

            Text(
              "We value your privacy and are committed to protecting your personal information while using the SmartAttend application.",
              style: TextStyle(fontSize: w * 0.04),
            ),

            SizedBox(height: h * 0.03),

            Text(
              "Information We Collect:",
              style: TextStyle(
                fontSize: w * 0.045,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: h * 0.01),
            Text("• Student & Teacher Details", style: TextStyle(fontSize: w * 0.038)),
            SizedBox(height: h * 0.008),
            Text("• Attendance Records & timestamps", style: TextStyle(fontSize: w * 0.038)),

            SizedBox(height: h * 0.025),

            Text(
              "Location Permission:",
              style: TextStyle(
                fontSize: w * 0.045,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: h * 0.01),
            Text(
              "• Used only during attendance\n"
                  "• No continuous tracking\n"
                  "• Never shared with third parties",
              style: TextStyle(fontSize: w * 0.038),
            ),

            SizedBox(height: h * 0.03),

            Text(
              "How We Use Your Information:",
              style: TextStyle(
                fontSize: w * 0.045,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: h * 0.01),
            Text("✔ Accurate attendance", style: TextStyle(fontSize: w * 0.038)),
            Text("✔ Prevent proxy attendance", style: TextStyle(fontSize: w * 0.038)),
            Text("✔ Improve app security", style: TextStyle(fontSize: w * 0.038)),

            SizedBox(height: h * 0.03),

            Text(
              "Data Protection:",
              style: TextStyle(
                fontSize: w * 0.045,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: h * 0.01),
            Text("✔ Secure & encrypted storage", style: TextStyle(fontSize: w * 0.038)),
            Text("✔ No data selling", style: TextStyle(fontSize: w * 0.038)),
            Text("✔ Deletion on request", style: TextStyle(fontSize: w * 0.038)),

            SizedBox(height: h * 0.03),

            // ✅ CHECKBOXES
            CheckboxListTile(
              activeColor: const Color(0xFF0047AB), // box color when checked
              checkColor: Colors.white,
              contentPadding: EdgeInsets.zero,
              title: Text(
                "I agree to the Terms & Conditions",
                style: TextStyle(fontSize: w * 0.04),
              ),
              value: _agreeTerms,
              onChanged: (v) => setState(() => _agreeTerms = v!),
              controlAffinity: ListTileControlAffinity.leading,
            ),

            CheckboxListTile(
              activeColor: const Color(0xFF0047AB), // box color when checked
              checkColor: Colors.white,             // tick color
              contentPadding: EdgeInsets.zero,
              title: Text(
                "I agree to the Privacy Policy",
                style: TextStyle(fontSize: w * 0.04),
              ),
              value: _agreePrivacy,
              onChanged: (v) => setState(() => _agreePrivacy = v!),
              controlAffinity: ListTileControlAffinity.leading,
            ),


            SizedBox(height: h * 0.025),

            // ✅ BUTTON
            SizedBox(
              width: double.infinity,
              height: h * 0.065,
              child: ElevatedButton(
                onPressed: _agreeTerms && _agreePrivacy
                    ? () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('isFirstInstall', false);

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0047AB),
                  disabledBackgroundColor: Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(w * 0.03),
                  ),
                ),
                child: Text(
                  "Get Started",
                  style: TextStyle(
                    fontSize: w * 0.045,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            SizedBox(height: h * 0.02),
          ],
        ),
      ),
    );
  }
}
