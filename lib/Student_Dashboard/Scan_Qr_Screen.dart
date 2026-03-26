import 'package:flutter/material.dart';
import '../app_size/app_size.dart';
import '../utils/UiHelper.dart';

class ScanQRPage extends StatelessWidget {
  const ScanQRPage({super.key});

  @override
  Widget build(BuildContext context) {

    final double w = AppSize.width(context);
    final double h = AppSize.height(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Scan Qr Code',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0047AB),


      ),
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: w * 0.06),
          child: Column(
            children: [

              SizedBox(height: h * 0.03),

              Text(
                "Scan QR Code",
                style: TextStyle(
                  fontSize: w * 0.06,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: h * 0.005),

              Text(
                "Mark your attendance by scanning the QR code",
                style: TextStyle(
                  fontSize: w * 0.032,
                  color: Colors.black54,
                ),
              ),

              SizedBox(height: h * 0.03),

              // ── Step-by-step Instructions ──
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(w * 0.04),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(13),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "How to Scan",
                      style: TextStyle(
                        fontSize: w * 0.04,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: h * 0.015),
                    _stepItem("1", "Point your camera at the QR code", Icons.camera_alt_rounded, w),
                    SizedBox(height: h * 0.012),
                    _stepItem("2", "Align the QR code within the frame", Icons.crop_free_rounded, w),
                    SizedBox(height: h * 0.012),
                    _stepItem("3", "Attendance marked automatically", Icons.check_circle_rounded, w),
                  ],
                ),
              ),

              SizedBox(height: h * 0.035),

              // ── QR Scanner Frame with Corner Decorations ──
              Stack(
                children: [
                  Container(
                    height: h * 0.32,
                    width: h * 0.32,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFF0047AB).withAlpha(51), width: 2),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.qr_code_scanner,
                            size: w * 0.18,
                            color: const Color(0xFF0047AB).withAlpha(77),
                          ),
                          SizedBox(height: h * 0.01),
                          Text(
                            "Place QR Code Here",
                            style: TextStyle(
                              fontSize: w * 0.032,
                              color: Colors.black38,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Top-left corner
                  Positioned(
                    top: 0, left: 0,
                    child: _cornerDecoration(true, true),
                  ),
                  // Top-right corner
                  Positioned(
                    top: 0, right: 0,
                    child: _cornerDecoration(true, false),
                  ),
                  // Bottom-left corner
                  Positioned(
                    bottom: 0, left: 0,
                    child: _cornerDecoration(false, true),
                  ),
                  // Bottom-right corner
                  Positioned(
                    bottom: 0, right: 0,
                    child: _cornerDecoration(false, false),
                  ),
                ],
              ),

              SizedBox(height: h * 0.035),

              UIHelper.customButton(
                text: "Start Scanning",
                onPressed: () {
                  UIHelper.showSnackBar(context, "Scanner Coming Soon");
                },
              ),

              SizedBox(height: h * 0.035),

              // ── Recent Scans Section ──
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Recent Scans",
                  style: TextStyle(
                    fontSize: w * 0.048,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: h * 0.015),

              _recentScanCard(
                subject: "Flutter Development",
                dateTime: "08 Mar 2026, 09:15 AM",
                icon: Icons.check_circle_rounded,
                w: w,
                h: h,
              ),
              _recentScanCard(
                subject: "Android Development",
                dateTime: "07 Mar 2026, 10:45 AM",
                icon: Icons.check_circle_rounded,
                w: w,
                h: h,
              ),

              SizedBox(height: h * 0.04),
            ],
          ),
        ),
      ),
    );
  }

  // ── Step Item Widget ──
  Widget _stepItem(String number, String text, IconData icon, double w) {
    return Row(
      children: [
        Container(
          width: w * 0.085,
          height: w * 0.085,
          decoration: BoxDecoration(
            color: const Color(0xFF0047AB).withAlpha(26),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                fontSize: w * 0.038,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0047AB),
              ),
            ),
          ),
        ),
        SizedBox(width: w * 0.03),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: w * 0.034,
              color: Colors.black87,
            ),
          ),
        ),
        Icon(icon, color: const Color(0xFF0047AB), size: w * 0.05),
      ],
    );
  }

  // ── Corner Decoration for Scanner Frame ──
  Widget _cornerDecoration(bool isTop, bool isLeft) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        border: Border(
          top: isTop
              ? const BorderSide(color: Color(0xFF0047AB), width: 4)
              : BorderSide.none,
          bottom: !isTop
              ? const BorderSide(color: Color(0xFF0047AB), width: 4)
              : BorderSide.none,
          left: isLeft
              ? const BorderSide(color: Color(0xFF0047AB), width: 4)
              : BorderSide.none,
          right: !isLeft
              ? const BorderSide(color: Color(0xFF0047AB), width: 4)
              : BorderSide.none,
        ),
      ),
    );
  }

  // ── Recent Scan Card Widget ──
  Widget _recentScanCard({
    required String subject,
    required String dateTime,
    required IconData icon,
    required double w,
    required double h,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: h * 0.012),
      padding: EdgeInsets.all(w * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(w * 0.025),
            decoration: BoxDecoration(
              color: Colors.green.withAlpha(26),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.green, size: w * 0.055),
          ),
          SizedBox(width: w * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject,
                  style: TextStyle(
                    fontSize: w * 0.038,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: h * 0.004),
                Text(
                  dateTime,
                  style: TextStyle(
                    fontSize: w * 0.03,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: w * 0.025, vertical: h * 0.005),
            decoration: BoxDecoration(
              color: Colors.green.withAlpha(26),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "Present",
              style: TextStyle(
                fontSize: w * 0.028,
                color: Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}