import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import '../app_size/app_size.dart';
import '../utils/UiHelper.dart';
import 'package:intl/intl.dart';

class GenerateAttendanceDialog extends StatefulWidget {
  final Function(String sessionId, Map<String, dynamic> sessionData) onSessionCreated;

  const GenerateAttendanceDialog({super.key, required this.onSessionCreated});

  @override
  State<GenerateAttendanceDialog> createState() => _GenerateAttendanceDialogState();
}

class _GenerateAttendanceDialogState extends State<GenerateAttendanceDialog> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  bool _isFetchingLocation = false;
  final TextEditingController _facultyNameController = TextEditingController(text: "Loading...");
  
  double? _currentLatitude;
  double? _currentLongitude;

  String? _selectedCollegeId;
  String? _selectedDepartmentId;
  String? _selectedClassId;
  String? _selectedDivisionId;
  String? _selectedSubjectId;

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final TextEditingController _qrDurationController = TextEditingController(text: "1");
  final TextEditingController _geolocatorRangeController = TextEditingController(text: "50");
  final TextEditingController _labController = TextEditingController();

  @override
  void dispose() {
    _facultyNameController.dispose();
    _dateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _qrDurationController.dispose();
    _geolocatorRangeController.dispose();
    _labController.dispose();
    super.dispose();
  }

  String _qrDurationUnit = "Minute";
  final List<String> _qrDurationUnits = ["Minute", "Second", "Hour"];

  String _geolocatorUnit = "Meter";
  final List<String> _geolocatorUnits = ["Meter", "Feet"];

  List<Map<String, dynamic>> _colleges = [];
  List<Map<String, dynamic>> _departments = [];
  List<Map<String, dynamic>> _classes = [];
  List<Map<String, dynamic>> _divisions = [];
  List<Map<String, dynamic>> _subjects = [];

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _loadFacultyName();
    _fetchColleges();
  }

  Future<void> _loadFacultyName() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final doc = await _firestore.collection('users').doc(currentUser.uid).get();
      if (doc.exists && mounted) {
        setState(() {
          _facultyNameController.text = doc.data()?['name'] ?? "Unknown Faculty";
        });
      }
    }
  }

  Future<void> _fetchColleges() async {
    final snapshot = await _firestore.collection('colleges').get();
    if(mounted) {
      setState(() {
        _colleges = snapshot.docs.map((doc) => {'id': doc.id, 'name': doc['name']}).toList();
      });
    }
  }

  Future<void> _fetchDepartments(String collegeId) async {
    final snapshot = await _firestore.collection('departments').where('collegeId', isEqualTo: collegeId).get();
    if(mounted) {
      setState(() {
        _departments = snapshot.docs.map((doc) => {'id': doc.id, 'name': doc['name']}).toList();
        _selectedDepartmentId = null;
        _classes.clear(); _selectedClassId = null;
        _divisions.clear(); _selectedDivisionId = null;
        _subjects.clear(); _selectedSubjectId = null;
      });
    }
  }

  Future<void> _fetchClasses(String departmentId) async {
    final snapshot = await _firestore.collection('classes').where('departmentId', isEqualTo: departmentId).get();
    if(mounted) {
      setState(() {
        _classes = snapshot.docs.map((doc) => {'id': doc.id, 'name': doc['name']}).toList();
        _selectedClassId = null;
        _divisions.clear(); _selectedDivisionId = null;
        _subjects.clear(); _selectedSubjectId = null;
      });
    }
  }

  Future<void> _fetchDivisions(String classId) async {
    final snapshot = await _firestore.collection('divisions').where('classId', isEqualTo: classId).get();
    if(mounted) {
      setState(() {
        _divisions = snapshot.docs.map((doc) => {'id': doc.id, 'name': doc['name']}).toList();
        _selectedDivisionId = null;
        _subjects.clear(); _selectedSubjectId = null;
      });
    }
  }

  Future<void> _fetchSubjects(String classId) async {
    
    final snapshot = await _firestore.collection('subjects').where('classId', isEqualTo: classId).get();
    if(mounted) {
      setState(() {
        _subjects = snapshot.docs.map((doc) => {'id': doc.id, 'name': doc['name']}).toList();
        _selectedSubjectId = null;
      });
    }
  }

  Future<void> _selectTime(TextEditingController controller) async {
    TimeOfDay? picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null && mounted) {
      controller.text = picked.format(context);
    }
  }

  Future<void> _selectDate(TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context, 
      initialDate: DateTime.now(),
      firstDate: DateTime(2000), 
      lastDate: DateTime(2100)
    );
    if (picked != null && mounted) {
      controller.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Future<Position?> _determinePosition() async {
    setState(() => _isFetchingLocation = true);
    
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        UIHelper.showSnackBar(context, "Location services are disabled.");
        return null;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          UIHelper.showSnackBar(context, "Location permissions are denied");
          return null;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        UIHelper.showSnackBar(context, "Location permissions are permanently denied.");
        return null;
      }
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
      setState(() {
        _currentLatitude = position.latitude;
        _currentLongitude = position.longitude;
      });
      return position;
    } catch (e) {
      UIHelper.showSnackBar(context, "Failed to get location: $e");
      return null;
    } finally {
       setState(() => _isFetchingLocation = false);
    }
  }

  Future<void> _createSession() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedCollegeId == null || _selectedDepartmentId == null || 
        _selectedClassId == null || _selectedDivisionId == null || _selectedSubjectId == null) {
      UIHelper.showSnackBar(context, "Please select all dropdown options.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      Position? position;
      if (_currentLatitude == null || _currentLongitude == null) {
        position = await _determinePosition();
        if (position == null) {
           setState(() => _isLoading = false);
           return; 
        }
      }

      String sessionId = _firestore.collection('attendance_sessions').doc().id;
      String uniqueQrToken = _firestore.collection('attendance_keys').doc().id; // Used as auth token
      
      double rangeInput = double.tryParse(_geolocatorRangeController.text) ?? 50.0;
      double rangeInMeters = _geolocatorUnit == "Feet" ? (rangeInput * 0.3048) : rangeInput;
      
      int durationInput = int.tryParse(_qrDurationController.text) ?? 1;
      int durationInSeconds = durationInput;
      if (_qrDurationUnit == "Minute") durationInSeconds *= 60;
      if (_qrDurationUnit == "Hour") durationInSeconds *= 3600;

      Map<String, dynamic> sessionData = {
        'sessionId': sessionId,
        'qrToken': uniqueQrToken,
        'facultyId': FirebaseAuth.instance.currentUser?.uid,
        'facultyName': _facultyNameController.text,
        'collegeId': _selectedCollegeId,
        'departmentId': _selectedDepartmentId,
        'classId': _selectedClassId,
        'divisionId': _selectedDivisionId,
        'subjectId': _selectedSubjectId,
        'labName': _labController.text.trim().isEmpty ? null : _labController.text.trim(),
        'date': _dateController.text,
        'startTime': _startTimeController.text,
        'endTime': _endTimeController.text,
        'qrDurationSeconds': durationInSeconds,
        'latitude': _currentLatitude ?? position?.latitude,
        'longitude': _currentLongitude ?? position?.longitude,
        'allowedRangeMeters': rangeInMeters,
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
      };

      await _firestore.collection('attendance_sessions').doc(sessionId).set(sessionData);

      if(!mounted) return;
      Navigator.pop(context);
      widget.onSessionCreated(sessionId, sessionData);

    } catch (e) {
      UIHelper.showSnackBar(context, "Error creating session: $e");
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    double w = AppSize.width(context);
    double h = AppSize.height(context);

    return Dialog(
      backgroundColor: const Color(0xFFB6BFCA),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: const LinearGradient(colors: [Color(0xFF0047AB), Color(0xFF1565C0)]),
                ),
                child: Center(
                  child: Text("Generate Attendance", 
                    style: TextStyle(color: Colors.white, fontSize: w * 0.05, fontWeight: FontWeight.bold)),
                ),
              ),
              SizedBox(height: 16),

              AbsorbPointer(
                child: UIHelper.customTextField(
                  controller: _facultyNameController,
                  hint: "Faculty Name",
                  prefixIcon: const Icon(Icons.person, color: Color(0xFF0047AB)),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 16),

              _buildDropdown("Select College", _colleges, _selectedCollegeId, (val) {
                setState(() => _selectedCollegeId = val);
                if(val != null) _fetchDepartments(val);
              }),
              SizedBox(height: 16),

              _buildDropdown("Select Department", _departments, _selectedDepartmentId, (val) {
                setState(() => _selectedDepartmentId = val);
                if(val != null) _fetchClasses(val);
              }),
              SizedBox(height: 16),

              _buildDropdown("Select Class", _classes, _selectedClassId, (val) {
                setState(() => _selectedClassId = val);
                if(val != null) {
                   _fetchDivisions(val);
                   _fetchSubjects(val); 
                }
              }),
              SizedBox(height: 16),

              _buildDropdown("Select Division", _divisions, _selectedDivisionId, (val) {
                setState(() => _selectedDivisionId = val);
              }),
              SizedBox(height: 16),

              _buildDropdown("Select Subject", _subjects, _selectedSubjectId, (val) {
                setState(() => _selectedSubjectId = val);
              }),
              const SizedBox(height: 16),

              UIHelper.customTextField(
                controller: _labController,
                hint: "Lab / Room Name (Optional)",
                prefixIcon: const Icon(Icons.meeting_room, color: Color(0xFF0047AB)),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectDate(_dateController),
                      child: AbsorbPointer(
                        child: UIHelper.customTextField(
                          controller: _dateController,
                          hint: "Date",
                          prefixIcon: const Icon(Icons.calendar_today, color: Color(0xFF0047AB)),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ]
              ),
              SizedBox(height: 16),

              Row(
                children: [
                   Expanded(
                     child: GestureDetector(
                       onTap: () => _selectTime(_startTimeController),
                       child: AbsorbPointer(
                         child: UIHelper.customTextField(
                           controller: _startTimeController, 
                           hint: "Start Time", 
                           prefixIcon: const Icon(Icons.access_time, color: Color(0xFF0047AB)),
                           textAlign: TextAlign.center,
                         ),
                       ),
                     )
                   ),
                   SizedBox(width: 8),
                   Expanded(
                     child: GestureDetector(
                       onTap: () => _selectTime(_endTimeController),
                       child: AbsorbPointer(
                         child: UIHelper.customTextField(
                           controller: _endTimeController, 
                           hint: "End Time", 
                           prefixIcon: const Icon(Icons.access_time_filled, color: Color(0xFF0047AB)),
                           textAlign: TextAlign.center,
                         ),
                       ),
                     )
                   ),
                ]
              ),
              SizedBox(height: 16),

              // Dynamic Premium Location Card
              GestureDetector(
                onTap: () {
                  if (_currentLatitude == null && !_isFetchingLocation) {
                    _determinePosition();
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  decoration: BoxDecoration(
                    gradient: _currentLatitude != null
                        ? const LinearGradient(colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)])
                        : const LinearGradient(colors: [Color(0xFF0047AB), Color(0xFF1565C0)]),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: (_currentLatitude != null ? Colors.green : const Color(0xFF0047AB)).withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: _isFetchingLocation 
                            ? const SizedBox(
                                width: 24, height: 24, 
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)
                              )
                            : Icon(
                                _currentLatitude != null ? Icons.check_circle_outline : Icons.add_location_alt, 
                                color: Colors.white, 
                                size: 28
                              ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _currentLatitude != null 
                                  ? "Location Locked Successfully" 
                                  : "Set Attendance Pin",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _currentLatitude != null
                                  ? "Lat: ${_currentLatitude!.toStringAsFixed(4)} | Lng: ${_currentLongitude!.toStringAsFixed(4)}"
                                  : "Tap to lock current GPS coordinates.",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.9), fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: UIHelper.customTextField(
                      controller: _qrDurationController,
                      hint: "QR Duration",
                      keyboardType: TextInputType.number,
                      prefixIcon: const Icon(Icons.timer, color: Color(0xFF0047AB)),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      value: _qrDurationUnit,
                      isExpanded: true,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                        filled: true, fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF0047AB))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF0047AB))),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF0047AB), width: 2)),
                      ),
                      style: const TextStyle(fontSize: 13, color: Colors.black87),
                      items: _qrDurationUnits.map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis))).toList(),
                      onChanged: (val) => setState(() => _qrDurationUnit = val!),
                    )
                  )
                ]
              ),
              SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: UIHelper.customTextField(
                      controller: _geolocatorRangeController,
                      hint: "Allowed Range",
                      keyboardType: TextInputType.number,
                      prefixIcon: const Icon(Icons.location_on, color: Color(0xFF0047AB)),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      value: _geolocatorUnit,
                      isExpanded: true,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                        filled: true, fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF0047AB))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF0047AB))),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF0047AB), width: 2)),
                      ),
                      style: const TextStyle(fontSize: 13, color: Colors.black87),
                      items: _geolocatorUnits.map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis))).toList(),
                      onChanged: (val) => setState(() => _geolocatorUnit = val!),
                    )
                  )
                ]
              ),
              SizedBox(height: 24),

              UIHelper.rowOfButtons(
                text1: "Cancel", 
                onPressed1: () => Navigator.pop(context), 
                text2: "Create", 
                onPressed2: _createSession, 
                isLoading: _isLoading,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(String hint, List<Map<String, dynamic>> items, String? selectedValue, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      isExpanded: true,
      decoration: InputDecoration(
        hintText: items.isEmpty ? "Awaiting previous selection..." : hint,
        hintStyle: TextStyle(color: items.isEmpty ? Colors.black38 : Colors.black54, fontSize: 14),
        filled: true,
        fillColor: items.isEmpty ? Colors.grey.shade200 : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF0047AB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF0047AB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF0047AB), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
      items: items.map((e) => DropdownMenuItem<String>(
            value: e['id'],
            child: Text(e['name'], overflow: TextOverflow.ellipsis),
          )).toList(),
      onChanged: items.isEmpty ? null : onChanged,
      validator: (val) => val == null ? "Please select ${hint.replaceAll('Select ', '')}" : null,
    );
  }
}
