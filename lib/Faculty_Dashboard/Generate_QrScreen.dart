import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../app_size/app_size.dart';
import '../utils/UiHelper.dart';
import 'Generate_Attendance_Dialog.dart';
import 'View_Attendance_Screen.dart';

class GenerateAttendanceScreen extends StatefulWidget {
  const GenerateAttendanceScreen({super.key});

  @override
  State<GenerateAttendanceScreen> createState() => _GenerateAttendanceScreenState();
}

class _GenerateAttendanceScreenState extends State<GenerateAttendanceScreen> {
  String? _activeSessionId;
  String? _lastSessionId;
  Map<String, dynamic>? _sessionData;
  Timer? _countdownTimer;
  int _secondsRemaining = 0;

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _openGenerateDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return GenerateAttendanceDialog(
          onSessionCreated: (sessionId, sessionData) {
            setState(() {
              _activeSessionId = sessionId;
              _sessionData = sessionData;
              _secondsRemaining = sessionData['qrDurationSeconds'] ?? 60;
            });
            _startTimer();
          },
        );
      },
    );
  }

  void _startTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_secondsRemaining > 0) {
            _secondsRemaining--;
          } else {
            _countdownTimer?.cancel();
            _deactivateSession();
          }
        });
      }
    });
  }

  Future<void> _deactivateSession() async {
    if (_activeSessionId != null) {
      try {
        await FirebaseFirestore.instance
            .collection('attendance_sessions')
            .doc(_activeSessionId)
            .update({'isActive': false});
        if (mounted) {
          UIHelper.showSnackBar(context, "Session Ended!");
          setState(() {
            _lastSessionId = _activeSessionId;
            _activeSessionId = null;
            _sessionData = null;
          });
        }
      } catch (e) {
        
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double w = AppSize.width(context);
    final double h = AppSize.height(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Qr Code', style: TextStyle(color: Colors.white)),
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

              Text("Generate Attendance QR", style: TextStyle(fontSize: w * 0.055, fontWeight: FontWeight.bold)),
              SizedBox(height: h * 0.005),
              Text(
                _activeSessionId == null 
                   ? "Configure session details to create attendance QR" 
                   : "Active Session Running. Ask students to scan.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: w * 0.032, color: Colors.black54),
              ),
              SizedBox(height: h * 0.03),

              if (_activeSessionId != null && _sessionData != null) ...[
                 _infoCard("Subject ID", _sessionData!['subjectId'] ?? "Unknown", Icons.menu_book, w, h),
                 SizedBox(height: h * 0.015),
                 _infoCard("Class ID", _sessionData!['classId'] ?? "Unknown", Icons.class_, w, h),
                 SizedBox(height: h * 0.035),
              ],

              Container(
                height: h * 0.3,
                width: h * 0.3,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF0047AB).withAlpha(51), width: 2),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 8, offset: const Offset(0, 4)),
                  ],
                ),
                child: Stack(
                  children: [
                    Center(
                      child: _activeSessionId == null
                          ? Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.qr_code_2_rounded, size: w * 0.2, color: const Color(0xFF0047AB).withAlpha(51)),
                                SizedBox(height: h * 0.008),
                                Text("No Active Session", style: TextStyle(fontSize: w * 0.03, color: Colors.black38)),
                              ],
                            )
                          : Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: QrImageView(
                                data: "$_activeSessionId|${_sessionData!['qrToken']}",
                                version: QrVersions.auto,
                                size: h * 0.25,
                                backgroundColor: Colors.white,
                              ),
                            ),
                    ),
                    Positioned(top: 0, left: 0, child: _corner(true, true)),
                    Positioned(top: 0, right: 0, child: _corner(true, false)),
                    Positioned(bottom: 0, left: 0, child: _corner(false, true)),
                    Positioned(bottom: 0, right: 0, child: _corner(false, false)),
                  ],
                ),
              ),
              SizedBox(height: h * 0.02),

              if (_activeSessionId != null)
                Text(
                  "Session Expires In: ${_secondsRemaining ~/ 60}:${(_secondsRemaining % 60).toString().padLeft(2, '0')}",
                  style: TextStyle(
                    fontSize: w * 0.04,
                    fontWeight: FontWeight.bold,
                    color: _secondsRemaining <= 10 ? Colors.red : Colors.green.shade700,
                  ),
                ),
              SizedBox(height: h * 0.035),

              if (_activeSessionId == null)
                UIHelper.customButton(text: "Generate New QR", onPressed: _openGenerateDialog),
              
              if (_activeSessionId == null && _lastSessionId != null) ...[
                SizedBox(height: h * 0.02),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewAttendanceScreen(initialSessionId: _lastSessionId),
                      ),
                    );
                  },
                  icon: const Icon(Icons.picture_as_pdf, color: Color(0xFF0047AB)),
                  label: const Text("View & Download Report", style: TextStyle(color: Color(0xFF0047AB), fontSize: 16)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF0047AB)),
                    padding: EdgeInsets.symmetric(vertical: h * 0.015, horizontal: w * 0.1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                ),
              ],
              
              if (_activeSessionId != null)
                OutlinedButton(
                  onPressed: _deactivateSession,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    padding: EdgeInsets.symmetric(vertical: h * 0.015, horizontal: w * 0.1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))
                  ),
                  child: const Text("End Session Early", style: TextStyle(color: Colors.red, fontSize: 16)),
                ),

              SizedBox(height: h * 0.04),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCard(String label, String value, IconData icon, double w, double h) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: h * 0.016),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 6, offset: const Offset(0, 3))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFF0047AB).withAlpha(20), borderRadius: BorderRadius.circular(10)),
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
        ],
      ),
    );
  }

  Widget _corner(bool isTop, bool isLeft) {
    return Container(
      width: 24, height: 24,
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
