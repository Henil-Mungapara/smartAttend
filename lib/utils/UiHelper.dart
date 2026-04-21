import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

class UIHelper {

  static Widget customTextField({
    required TextEditingController controller,
    required String hint,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    Widget? prefixIcon,
    Iterable<String>? autofillHints,
    TextAlign textAlign = TextAlign.start,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      textAlign: textAlign,
      keyboardType: keyboardType,
      autofillHints: autofillHints,
      style: const TextStyle(
        color: Colors.black,   
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,  

        hintText: hint,
        hintStyle: const TextStyle(
          color: Colors.black,
        ),

        prefixIcon: prefixIcon,   
        suffixIcon: suffixIcon,   

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.black),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.black),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF000080), width: 1.5),
        ),
      ),
    );
  }

  static Widget customButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0047AB),
          elevation: 5, 
          shadowColor: Color(0xFF000080), 
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  static Widget rowOfButtons({
    required String text1,
    required VoidCallback onPressed1,
    required String text2,
    required VoidCallback onPressed2,
    bool isLoading = false,
  }) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 50,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF0047AB)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: isLoading ? null : onPressed1,
              child: Text(text1, style: const TextStyle(color: Color(0xFF0047AB), fontSize: 16)),
            ),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: isLoading 
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF0047AB)))
            : customButton(text: text2, onPressed: onPressed2),
        ),
      ],
    );
  }

  static Widget customTextButton({
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  static void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  static void showAlert(
      BuildContext context,
      String title,
      String message,
      ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  static void showExitAlert(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  SizedBox(
                    height: 70,
                    width: 70,
                    child: Lottie.asset(
                      "assets/animation/SmartAttendAlert.json",
                      repeat: true,
                    ),
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    "Exit Application?",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "Are you sure you want to close SmartAttend?\nYou will need to login again.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.grey),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(color: Colors.black54),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0047AB),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            SystemNavigator.pop();
                          },
                          child: const Text(
                            "Exit",
                            style: TextStyle(color: Colors.white),
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

  static void showSetupOptions({
    required BuildContext context,
    required String title,
    required String message,
    required VoidCallback onAdd,
    required VoidCallback onView,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              SizedBox(
                height: 70,
                width: 70,
                child: Lottie.asset(
                  "assets/animation/SmartAttendLottie.json",
                  repeat: true,
                ),
              ),

              const SizedBox(height: 15),

              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [

                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Color(0xFF0047AB),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        onView();
                      },
                      child: const Text(
                        "View",
                        style: TextStyle(
                          color: Color(0xFF0047AB),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0047AB),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        onAdd();
                      },
                      child: const Text(
                        "Add",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.black38),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  }
