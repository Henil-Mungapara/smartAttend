import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../app_size/app_size.dart';
import '../utils/Admin_Pdf_Report_Service.dart';
import '../utils/UiHelper.dart';

class Admin_AttendanceReport_Screen extends StatefulWidget {
  const Admin_AttendanceReport_Screen({super.key});

  @override
  State<Admin_AttendanceReport_Screen> createState() => _Admin_AttendanceReport_ScreenState();
}

class _Admin_AttendanceReport_ScreenState extends State<Admin_AttendanceReport_Screen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _selectedCollegeId;
  String? _selectedDepartmentId;
  String? _selectedClassId;
  String? _selectedDivisionId;
  String? _selectedSubjectId;

  List<Map<String, dynamic>> _colleges = [];
  List<Map<String, dynamic>> _departments = [];
  List<Map<String, dynamic>> _classes = [];
  List<Map<String, dynamic>> _divisions = [];
  List<Map<String, dynamic>> _subjects = [];

  bool _isSpecificDate = true;
  DateTime? _specificDate;
  DateTimeRange? _dateRange;

  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _fetchColleges();
    _specificDate = DateTime.now();
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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _specificDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF0047AB)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _specificDate = picked);
    }
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: _dateRange,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF0047AB)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _dateRange = picked);
    }
  }

  Future<void> _generatePdf() async {
    if (_selectedCollegeId == null || _selectedDepartmentId == null || _selectedClassId == null || _selectedDivisionId == null) {
      UIHelper.showSnackBar(context, "Please select at least up to Division to generate a report.");
      return;
    }

    if (_isSpecificDate && _specificDate == null) {
      UIHelper.showSnackBar(context, "Please select a date.");
      return;
    }
    if (!_isSpecificDate && _dateRange == null) {
      UIHelper.showSnackBar(context, "Please select a date range.");
      return;
    }

    setState(() => _isGenerating = true);

    try {
      // 1. Fetch Students
      Query usersQuery = _firestore.collection('users')
          .where('role', isEqualTo: 'student')
          .where('classId', isEqualTo: _selectedClassId)
          .where('divisionId', isEqualTo: _selectedDivisionId);

      final usersSnap = await usersQuery.get();
      final students = usersSnap.docs.map((doc) {
        final d = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'name': d['fullName'] ?? d['name'] ?? 'Unknown',
          'roll': d['rollNumber'] ?? d['rollNo'] ?? 'N/A',
          'totalClasses': 0,
          'attendedClasses': 0,
        };
      }).toList();

      students.sort((a, b) => (a['roll'] as String).compareTo(b['roll'] as String));

      // 2. Fetch Sessions
      Query sessionsQuery = _firestore.collection('attendance_sessions')
          .where('divisionId', isEqualTo: _selectedDivisionId);
      
      if (_selectedSubjectId != null) {
        sessionsQuery = sessionsQuery.where('subjectId', isEqualTo: _selectedSubjectId);
      }

      final sessionsSnap = await sessionsQuery.get();
      
      List<QueryDocumentSnapshot> validSessions = [];
      for (var doc in sessionsSnap.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final String sessionDateStr = data['date'] ?? ''; // e.g. "2026-05-08"
        if (sessionDateStr.isEmpty) continue;

        try {
          final sessionDate = DateFormat('yyyy-MM-dd').parse(sessionDateStr);
          
          if (_isSpecificDate) {
            if (sessionDate.year == _specificDate!.year &&
                sessionDate.month == _specificDate!.month &&
                sessionDate.day == _specificDate!.day) {
              validSessions.add(doc);
            }
          } else {
            // Include end date up to end of day
            final endDate = _dateRange!.end.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1));
            if (sessionDate.isAfter(_dateRange!.start.subtract(const Duration(milliseconds: 1))) && 
                sessionDate.isBefore(endDate)) {
              validSessions.add(doc);
            }
          }
        } catch (_) {}
      }

      if (validSessions.isEmpty) {
        if (mounted) UIHelper.showSnackBar(context, "No attendance sessions found for the selected filters.");
        setState(() => _isGenerating = false);
        return;
      }

      // 3. Fetch Records & Aggregate
      for (var sessionDoc in validSessions) {
        final sessionId = sessionDoc.id;
        final recordsSnap = await _firestore.collection('attendance_records')
            .where('sessionId', isEqualTo: sessionId).get();
        
        final Set<String> presentStudentIds = {};
        for (var r in recordsSnap.docs) {
           final sid = r.data()['studentId'];
           if (sid is String) presentStudentIds.add(sid);
        }

        for (var student in students) {
          student['totalClasses'] = (student['totalClasses'] as int) + 1;
          if (presentStudentIds.contains(student['id'])) {
            student['attendedClasses'] = (student['attendedClasses'] as int) + 1;
          }
        }
      }

      // Names for header
      String collegeName = _colleges.firstWhere((e) => e['id'] == _selectedCollegeId, orElse: () => {'name': ''})['name'];
      String deptName = _departments.firstWhere((e) => e['id'] == _selectedDepartmentId, orElse: () => {'name': ''})['name'];
      String className = _classes.firstWhere((e) => e['id'] == _selectedClassId, orElse: () => {'name': ''})['name'];
      String divisionName = _divisions.firstWhere((e) => e['id'] == _selectedDivisionId, orElse: () => {'name': ''})['name'];
      
      String reportTitle = "Class Attendance";
      if (_selectedSubjectId != null) {
        String subjName = _subjects.firstWhere((e) => e['id'] == _selectedSubjectId, orElse: () => {'name': 'Subject'})['name'];
        reportTitle = subjName;
      }

      String dateRangeStr = _isSpecificDate 
        ? DateFormat('MMM dd, yyyy').format(_specificDate!)
        : "${DateFormat('MMM dd, yyyy').format(_dateRange!.start)} - ${DateFormat('MMM dd, yyyy').format(_dateRange!.end)}";

      // 4. Generate PDF
      await AdminPdfReportService.generateAndPrintAdminReport(
        reportTitle: reportTitle,
        dateRangeStr: dateRangeStr,
        students: students,
        collegeName: collegeName,
        departmentName: deptName,
        className: className,
        divisionName: divisionName,
        totalSessions: validSessions.length,
      );

      if (mounted) UIHelper.showSnackBar(context, "Report Generated Successfully.");

    } catch (e) {
      if (mounted) UIHelper.showSnackBar(context, "Error generating report: $e");
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double w = AppSize.width(context);
    final double h = AppSize.height(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: w * 0.05, vertical: h * 0.02),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(w * 0.05),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.filter_alt_rounded, color: Color(0xFF0047AB)),
                        SizedBox(width: w * 0.02),
                        Text(
                          "Filter Criteria",
                          style: TextStyle(
                            fontSize: w * 0.045,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0047AB),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: h * 0.02),

                    _buildDropdown("Select College", _colleges, _selectedCollegeId, (val) {
                      setState(() => _selectedCollegeId = val);
                      if(val != null) _fetchDepartments(val);
                    }),
                    SizedBox(height: h * 0.015),

                    _buildDropdown("Select Department", _departments, _selectedDepartmentId, (val) {
                      setState(() => _selectedDepartmentId = val);
                      if(val != null) _fetchClasses(val);
                    }),
                    SizedBox(height: h * 0.015),

                    _buildDropdown("Select Class", _classes, _selectedClassId, (val) {
                      setState(() => _selectedClassId = val);
                      if(val != null) {
                         _fetchDivisions(val);
                         _fetchSubjects(val); 
                      }
                    }),
                    SizedBox(height: h * 0.015),

                    _buildDropdown("Select Division", _divisions, _selectedDivisionId, (val) {
                      setState(() => _selectedDivisionId = val);
                    }),
                    SizedBox(height: h * 0.015),

                    _buildDropdown("Select Subject (Optional)", _subjects, _selectedSubjectId, (val) {
                      setState(() => _selectedSubjectId = val);
                    }, isOptional: true),
                  ],
                ),
              ),

              SizedBox(height: h * 0.02),

              Container(
                width: double.infinity,
                padding: EdgeInsets.all(w * 0.05),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.date_range_rounded, color: Color(0xFF0047AB)),
                        SizedBox(width: w * 0.02),
                        Text(
                          "Date Selection",
                          style: TextStyle(
                            fontSize: w * 0.045,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0047AB),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: h * 0.02),

                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isSpecificDate = true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _isSpecificDate ? const Color(0xFF0047AB) : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "Specific Date",
                                style: TextStyle(
                                  color: _isSpecificDate ? Colors.white : Colors.black87,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: w * 0.03),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isSpecificDate = false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: !_isSpecificDate ? const Color(0xFF0047AB) : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "Date Range",
                                style: TextStyle(
                                  color: !_isSpecificDate ? Colors.white : Colors.black87,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: h * 0.02),

                    if (_isSpecificDate)
                      GestureDetector(
                        onTap: _pickDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _specificDate == null 
                                  ? "Select Date" 
                                  : DateFormat('dd MMM yyyy').format(_specificDate!),
                                style: TextStyle(
                                  fontSize: 15,
                                  color: _specificDate == null ? Colors.black54 : Colors.black87,
                                ),
                              ),
                              const Icon(Icons.calendar_month, color: Color(0xFF0047AB)),
                            ],
                          ),
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: _pickDateRange,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _dateRange == null 
                                  ? "Select Date Range" 
                                  : "${DateFormat('dd MMM').format(_dateRange!.start)} - ${DateFormat('dd MMM yyyy').format(_dateRange!.end)}",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: _dateRange == null ? Colors.black54 : Colors.black87,
                                ),
                              ),
                              const Icon(Icons.date_range, color: Color(0xFF0047AB)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              SizedBox(height: h * 0.04),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: _isGenerating ? null : _generatePdf,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0047AB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  icon: _isGenerating 
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : const Icon(Icons.picture_as_pdf, color: Colors.white),
                  label: Text(
                    _isGenerating ? "Generating Report..." : "Generate PDF Report",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: h * 0.04),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(String hint, List<Map<String, dynamic>> items, String? selectedValue, Function(String?) onChanged, {bool isOptional = false}) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      isExpanded: true,
      decoration: InputDecoration(
        hintText: items.isEmpty && !isOptional ? "Awaiting previous selection..." : hint,
        hintStyle: TextStyle(color: items.isEmpty ? Colors.black38 : Colors.black54, fontSize: 14),
        filled: true,
        fillColor: items.isEmpty && !isOptional ? Colors.grey.shade100 : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF0047AB), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
      items: items.map((e) => DropdownMenuItem<String>(
            value: e['id'],
            child: Text(e['name'], overflow: TextOverflow.ellipsis),
          )).toList(),
      onChanged: items.isEmpty && !isOptional ? null : onChanged,
    );
  }
}