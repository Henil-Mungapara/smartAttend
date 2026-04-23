import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import '../app_size/app_size.dart';
import '../utils/UiHelper.dart';

class ScanQRPage extends StatefulWidget {
  const ScanQRPage({super.key});

  @override
  State<ScanQRPage> createState() => _ScanQRPageState();
}

class _ScanQRPageState extends State<ScanQRPage> {
  final MobileScannerController _scannerController = MobileScannerController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isProcessing = false;
  bool _isScannerActive = false;
  
  List<Map<String, dynamic>> _recentScans = [];

  @override
  void initState() {
    super.initState();
    _fetchRecentScans();
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _fetchRecentScans() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    
    final snapshot = await _firestore.collection('attendance_records')
      .where('studentId', isEqualTo: uid)
      .orderBy('timestamp', descending: true)
      .limit(5)
      .get();

    if(mounted) {
      setState(() {
        _recentScans = snapshot.docs.map((e) => e.data()).toList();
      });
    }
  }

  Future<void> _handleBarcode(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    final barcode = barcodes.first;
    final String? scannedValue = barcode.rawValue;

    if (scannedValue == null || !scannedValue.contains('|')) return;

    final parts = scannedValue.split('|');
    if (parts.length != 2) return;
    
    final sessionId = parts[0];
    final qrToken = parts[1];

    setState(() {
      _isProcessing = true;
      _isScannerActive = false; 
    });
    _scannerController.stop();

    await _processAttendance(sessionId, qrToken);
  }

  Future<void> _processAttendance(String sessionId, String scannedToken) async {
    try {
      final sessionDoc = await _firestore.collection('attendance_sessions').doc(sessionId).get();
      if (!sessionDoc.exists) {
        throw Exception("Invalid Session QR Code.");
      }

      final sessionData = sessionDoc.data()!;
      if (sessionData['isActive'] != true) {
        throw Exception("This attendance session has already expired or ended.");
      }

      if (sessionData['qrToken'] != scannedToken) {
        throw Exception("Invalid or spoofed QR code detected. Session tokens do not match.");
      }

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception("Location services are disabled. Please enable them.");
      
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) throw Exception("Location permissions are required to mark attendance.");
      }
      if (permission == LocationPermission.deniedForever) {
         throw Exception("Location permissions permanently denied. Go to settings.");
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
      
      double distanceInMeters = Geolocator.distanceBetween(
        position.latitude, 
        position.longitude, 
        sessionData['latitude'], 
        sessionData['longitude']
      );

      num allowedRange = sessionData['allowedRangeMeters'] ?? 50.0;
      double effectiveRange = allowedRange + position.accuracy;

      if (distanceInMeters > effectiveRange) {
         throw Exception("You are too far from the classroom! Distance: ${distanceInMeters.toStringAsFixed(1)}m. Allowed: ${allowedRange}m (Accuracy Offset: ${position.accuracy.toStringAsFixed(1)}m)");
      }

      final uid = FirebaseAuth.instance.currentUser!.uid;
      final duplicateCheck = await _firestore.collection('attendance_records')
          .where('sessionId', isEqualTo: sessionId)
          .where('studentId', isEqualTo: uid)
          .get();

      if (duplicateCheck.docs.isNotEmpty) {
        throw Exception("Attendance already marked for this session.");
      }

      final userDoc = await _firestore.collection('users').doc(uid).get();
      final userData = userDoc.data() ?? {};

      String recordId = _firestore.collection('attendance_records').doc().id;
      
      Map<String, dynamic> record = {
        'recordId': recordId,
        'sessionId': sessionId,
        'studentId': uid,
        'studentName': userData['fullName'] ?? userData['name'] ?? "Unknown",
        'enrollmentNo': userData['enrollmentNumber'] ?? userData['enrollmentNo'] ?? "N/A",
        'rollNo': userData['rollNumber'] ?? userData['rollNo'] ?? "N/A",
        'subjectId': sessionData['subjectId'],
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'Present'
      };

      await _firestore.collection('attendance_records').doc(recordId).set(record);
      
      if(mounted) {
        _showStatusBottomSheet(true, "Attendance Marked!", "You have been successfully marked present for this session.", Icons.check_circle_rounded, Colors.green);
        _fetchRecentScans();
      }

    } catch (e) {
      if(mounted) {
         _showStatusBottomSheet(false, "Scan Failed", e.toString().replaceFirst("Exception: ", ""), Icons.error_outline_rounded, Colors.red);
      }
    } finally {
      if(mounted) setState(() => _isProcessing = false);
    }
  }

  void _showStatusBottomSheet(bool isSuccess, String title, String message, IconData icon, Color color) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
          ),
          padding: EdgeInsets.only(
            left: 24, 
            right: 24, 
            top: 20, 
            bottom: MediaQuery.of(context).padding.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 5,
                width: 50,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 60),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, color: Colors.black54, height: 1.4),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Continue", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final double w = AppSize.width(context);
    final double h = AppSize.height(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code', style: TextStyle(color: Colors.white)),
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
              Text("Scan QR Code", style: TextStyle(fontSize: w * 0.06, fontWeight: FontWeight.bold)),
              SizedBox(height: h * 0.005),
              Text("Mark your attendance by scanning the QR code", style: TextStyle(fontSize: w * 0.032, color: Colors.black54)),
              SizedBox(height: h * 0.03),

              Container(
                width: double.infinity,
                padding: EdgeInsets.all(w * 0.04),
                decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 8, offset: const Offset(0, 3))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("How to Scan", style: TextStyle(fontSize: w * 0.04, fontWeight: FontWeight.w600)),
                    SizedBox(height: h * 0.015),
                    _stepItem("1", "Point your camera at the QR code", Icons.camera_alt_rounded, w),
                    SizedBox(height: h * 0.012),
                    _stepItem("2", "Stay within the designated location", Icons.location_on, w),
                    SizedBox(height: h * 0.012),
                    _stepItem("3", "Attendance marked automatically", Icons.check_circle_rounded, w),
                  ],
                ),
              ),
              SizedBox(height: h * 0.035),

              if (_isScannerActive)
                Stack(
                  children: [
                    Container(
                      height: h * 0.35,
                      width: h * 0.35,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF0047AB), width: 3),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(17),
                        child: MobileScanner(
                          controller: _scannerController,
                          onDetect: _handleBarcode,
                        ),
                      ),
                    ),
                    if (_isProcessing)
                       Positioned.fill(
                         child: Container(
                           color: Colors.white70,
                           child: const Center(child: CircularProgressIndicator()),
                         )
                       )
                  ],
                )
              else
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
                            Icon(Icons.qr_code_scanner, size: w * 0.18, color: const Color(0xFF0047AB).withAlpha(77)),
                            SizedBox(height: h * 0.01),
                            Text("Ready to Scan", style: TextStyle(fontSize: w * 0.032, color: Colors.black38)),
                          ],
                        ),
                      ),
                    ),
                    Positioned(top: 0, left: 0, child: _cornerDecoration(true, true)),
                    Positioned(top: 0, right: 0, child: _cornerDecoration(true, false)),
                    Positioned(bottom: 0, left: 0, child: _cornerDecoration(false, true)),
                    Positioned(bottom: 0, right: 0, child: _cornerDecoration(false, false)),
                  ],
                ),

              SizedBox(height: h * 0.035),

              if (!_isScannerActive)
                UIHelper.customButton(
                  text: "Start Scanning",
                  onPressed: () {
                    setState(() {
                      _isScannerActive = true;
                    });
                    _scannerController.start();
                  },
                )
              else 
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    padding: EdgeInsets.symmetric(horizontal: w * 0.1, vertical: h * 0.015),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: () {
                     setState(() {
                       _isScannerActive = false;
                     });
                     _scannerController.stop();
                  },
                  child: const Text("Stop Scanning", style: TextStyle(color: Colors.red, fontSize: 16)),
                ),

              SizedBox(height: h * 0.035),

              Align(
                alignment: Alignment.centerLeft,
                child: Text("Recent Scans", style: TextStyle(fontSize: w * 0.048, fontWeight: FontWeight.bold)),
              ),
              SizedBox(height: h * 0.015),

              if (_recentScans.isEmpty)
                 Padding(
                   padding: EdgeInsets.all(w * 0.05),
                   child: Text("No recents scans found.", style: TextStyle(color: Colors.black54)),
                 )
              else
                 ..._recentScans.map((scan) => _recentScanCard(
                      subject: scan['subjectId'] ?? "Unknown",
                      dateTime: "Marked on time", 
                      icon: Icons.check_circle_rounded,
                      w: w, h: h,
                 )),

              SizedBox(height: h * 0.04),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stepItem(String number, String text, IconData icon, double w) {
    return Row(
      children: [
        Container(
          width: w * 0.085, height: w * 0.085,
          decoration: BoxDecoration(color: const Color(0xFF0047AB).withAlpha(26), shape: BoxShape.circle),
          child: Center(child: Text(number, style: TextStyle(fontSize: w * 0.038, fontWeight: FontWeight.bold, color: const Color(0xFF0047AB)))),
        ),
        SizedBox(width: w * 0.03),
        Expanded(child: Text(text, style: TextStyle(fontSize: w * 0.034, color: Colors.black87))),
        Icon(icon, color: const Color(0xFF0047AB), size: w * 0.05),
      ],
    );
  }

  Widget _cornerDecoration(bool isTop, bool isLeft) {
    return Container(
      width: 28, height: 28,
      decoration: BoxDecoration(
        border: Border(
          top: isTop ? const BorderSide(color: Color(0xFF0047AB), width: 4) : BorderSide.none,
          bottom: !isTop ? const BorderSide(color: Color(0xFF0047AB), width: 4) : BorderSide.none,
          left: isLeft ? const BorderSide(color: Color(0xFF0047AB), width: 4) : BorderSide.none,
          right: !isLeft ? const BorderSide(color: Color(0xFF0047AB), width: 4) : BorderSide.none,
        ),
      ),
    );
  }

  Widget _recentScanCard({required String subject, required String dateTime, required IconData icon, required double w, required double h}) {
    return Container(
      margin: EdgeInsets.only(bottom: h * 0.012),
      padding: EdgeInsets.all(w * 0.04),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 6, offset: const Offset(0, 3))],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(w * 0.025),
            decoration: BoxDecoration(color: Colors.green.withAlpha(26), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: Colors.green, size: w * 0.055),
          ),
          SizedBox(width: w * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(subject, style: TextStyle(fontSize: w * 0.038, fontWeight: FontWeight.w600)),
                SizedBox(height: h * 0.004),
                Text(dateTime, style: TextStyle(fontSize: w * 0.03, color: Colors.black54)),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: w * 0.025, vertical: h * 0.005),
            decoration: BoxDecoration(color: Colors.green.withAlpha(26), borderRadius: BorderRadius.circular(20)),
            child: Text("Present", style: TextStyle(fontSize: w * 0.028, color: Colors.green, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}