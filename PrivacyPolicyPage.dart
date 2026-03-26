import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Privacy Policy"),
        centerTitle: true,
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.08,
          vertical: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// Introduction
            _sectionTitle("Introduction"),
            _sectionContent(
                "SmartAttend respects your privacy and is committed to protecting your personal information. "
                    "This Privacy Policy explains how we collect, use, and safeguard your data when you use our application."
            ),

            const SizedBox(height: 25),

            /// Information We Collect
            _sectionTitle("Information We Collect"),
            _sectionContent(
                "• Name and email address\n"
                    "• Student ID or college ID\n"
                    "• Attendance records\n"
                    "• Device information (for app performance)"
            ),

            const SizedBox(height: 25),

            /// How We Use Information
            _sectionTitle("How We Use Your Information"),
            _sectionContent(
                "We use your information to:\n"
                    "• Manage attendance records\n"
                    "• Improve app functionality\n"
                    "• Provide secure login access\n"
                    "• Enhance user experience"
            ),

            const SizedBox(height: 25),

            /// Data Security
            _sectionTitle("Data Security"),
            _sectionContent(
                "We implement appropriate security measures to protect your personal data. "
                    "Your information is stored securely and is not shared with third parties without your consent."
            ),

            const SizedBox(height: 25),

            /// Third-Party Services
            _sectionTitle("Third-Party Services"),
            _sectionContent(
                "SmartAttend may use secure third-party services such as Firebase for authentication and data storage. "
                    "These services comply with industry security standards."
            ),

            const SizedBox(height: 25),

            /// Changes
            _sectionTitle("Changes to This Policy"),
            _sectionContent(
                "We may update this Privacy Policy from time to time. "
                    "Any changes will be posted within the app."
            ),

            const SizedBox(height: 25),

            /// Contact
            _sectionTitle("Contact Us"),
            _sectionContent(
                "If you have any questions about this Privacy Policy, please contact your institution administrator."
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  /// Section Title Widget
  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFF3F3D56),
      ),
    );
  }

  /// Section Content Widget
  Widget _sectionContent(String content) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        content,
        style: const TextStyle(
          fontSize: 15,
          height: 1.6,
          color: Colors.black87,
        ),
      ),
    );
  }
}
