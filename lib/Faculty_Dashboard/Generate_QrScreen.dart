import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../app_size/app_size.dart';
import '../utils/UiHelper.dart';

class GenerateAttendanceScreen extends StatefulWidget {
  const GenerateAttendanceScreen({super.key});

  @override
  State<GenerateAttendanceScreen> createState() => _GenerateAttendanceScreenState();
}

class _GenerateAttendanceScreenState extends State<GenerateAttendanceScreen> {
  String? _qrData;
  Timer? _qrUpdateTimer;
  Timer? _countdownTimer;
  int _secondsRemaining = 0;

  // Selected values (simulated static for this screen, can be dynamic later)
  final String _subject = "Flutter Development";
  final String _semester = "3rd Semester";

  @override
  void dispose() {
    _qrUpdateTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _generateQRCode() {
    _updateQrData();

    // Cancel existing timers if any
    _qrUpdateTimer?.cancel();
    _countdownTimer?.cancel();

    // Timer to regenerate QR code every 60 seconds
    _qrUpdateTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _updateQrData();
    });

    // Timer to update countdown every second
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_secondsRemaining > 0) {
            _secondsRemaining--;
          } else {
            _secondsRemaining = 60; // Reset countdown just in case
          }
        });
      }
    });

    UIHelper.showSnackBar(context, "QR Code Generated Successfully!");
  }

  void _updateQrData() {
    if (mounted) {
      setState(() {
        // Dynamic data with timestamp to ensure the QR code changes
        final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
        _qrData = "Subject: $_subject | Semester: $_semester | ID: $timestamp";
        _secondsRemaining = 60; // Reset countdown
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double w = AppSize.width(context);
    final double h = AppSize.height(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Generate Qr Code',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0047AB),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: w * 0.06),
          child: Column(
            children: [
              SizedBox(height: h * 0.03),

              // ── Title ──
              Text(
                "Generate Attendance QR",
                style: TextStyle(
                  fontSize: w * 0.055,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: h * 0.005),
              Text(
                "Select your class details and generate a QR code",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: w * 0.032, color: Colors.black54),
              ),

              SizedBox(height: h * 0.03),

              // ── Select Subject ──
              _dropdownCard(
                icon: Icons.menu_book_rounded,
                label: "Select Subject",
                value: _subject,
                w: w, h: h,
              ),

              SizedBox(height: h * 0.015),

              // ── Select Semester ──
              _dropdownCard(
                icon: Icons.class_rounded,
                label: "Select Semester",
                value: _semester,
                w: w, h: h,
              ),

              SizedBox(height: h * 0.035),

              // ── QR Preview Area ──
              Container(
                height: h * 0.3,
                width: h * 0.3,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF0047AB).withAlpha(51), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(10),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Center(
                      child: _qrData == null
                          ? Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.qr_code_2_rounded,
                                  size: w * 0.2,
                                  color: const Color(0xFF0047AB).withAlpha(51),
                                ),
                                SizedBox(height: h * 0.008),
                                Text(
                                  "QR Preview",
                                  style: TextStyle(fontSize: w * 0.03, color: Colors.black38),
                                ),
                              ],
                            )
                          : Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: QrImageView(
                                data: _qrData!,
                                version: QrVersions.auto,
                                size: h * 0.25,
                                backgroundColor: Colors.white,
                              ),
                            ),
                    ),
                    // Corner decorations
                    Positioned(top: 0, left: 0, child: _corner(true, true)),
                    Positioned(top: 0, right: 0, child: _corner(true, false)),
                    Positioned(bottom: 0, left: 0, child: _corner(false, true)),
                    Positioned(bottom: 0, right: 0, child: _corner(false, false)),
                  ],
                ),
              ),

              SizedBox(height: h * 0.02),

              // ── Timer Text ──
              if (_qrData != null)
                Text(
                  "QR regenerates in $_secondsRemaining seconds",
                  style: TextStyle(
                    fontSize: w * 0.035,
                    fontWeight: FontWeight.bold,
                    color: _secondsRemaining <= 10 ? Colors.red : Colors.green.shade700,
                  ),
                ),

              SizedBox(height: h * 0.035),

              // ── Generate Button ──
              UIHelper.customButton(
                text: _qrData == null ? "Generate QR Code" : "Regenerate Now",
                onPressed: _generateQRCode,
              ),

              SizedBox(height: h * 0.025),

              // ── Info Note ──
              Container(
                padding: EdgeInsets.all(w * 0.04),
                decoration: BoxDecoration(
                  color: const Color(0xFF0047AB).withAlpha(15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded, color: const Color(0xFF0047AB), size: w * 0.05),
                    SizedBox(width: w * 0.03),
                    Expanded(
                      child: Text(
                        "QR code changes automatically every minute for maximum security.",
                        style: TextStyle(fontSize: w * 0.03, color: const Color(0xFF0047AB)),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: h * 0.04),
            ],
          ),
        ),
      ),
    );
  }

  // ── Dropdown-style Selection Card ──
  Widget _dropdownCard({
    required IconData icon,
    required String label,
    required String value,
    required double w,
    required double h,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: h * 0.016),
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
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF0047AB).withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF0047AB), size: w * 0.05),
          ),
          SizedBox(width: w * 0.035),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: w * 0.028, color: Colors.grey)),
                SizedBox(height: h * 0.003),
                Text(value, style: TextStyle(fontSize: w * 0.037, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black38, size: w * 0.06),
        ],
      ),
    );
  }

  // ── Corner Decoration ──
  Widget _corner(bool isTop, bool isLeft) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        border: Border(
          top: isTop ? const BorderSide(color: Color(0xFF0047AB), width: 3) : BorderSide.none,
          bottom: !isTop ? const BorderSide(color: Color(0xFF0047AB), width: 3) : BorderSide.none,
          left: isLeft ? const BorderSide(color: Color(0xFF0047AB), width: 3) : BorderSide.none,
          right: !isLeft ? const BorderSide(color: Color(0xFF0047AB), width: 3) : BorderSide.none,
        ),
      ),
    );
  }
}
