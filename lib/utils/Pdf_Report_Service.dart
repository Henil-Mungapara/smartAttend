import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class PdfReportService {
  // Brand colors
  static const PdfColor _primaryColor = PdfColor.fromInt(0xFF0047AB);
  static const PdfColor _primaryLight = PdfColor.fromInt(0xFFE8EEF8);
  static const PdfColor _divider = PdfColor.fromInt(0xFFDDE1E9);
  static const PdfColor _textDark = PdfColor.fromInt(0xFF000000);
  static const PdfColor _textMid = PdfColor.fromInt(0xFF4A5568);
  static const PdfColor _textLight = PdfColor.fromInt(0xFF718096);
  static const PdfColor _white = PdfColors.white;
  static const PdfColor _greyBg = PdfColor.fromInt(0xFFF7F9FC);

  static Future<void> generateAndPrintAttendanceReport({
    required String subjectName,
    required String dateStr,
    required int totalStudents,
    required int presentCount,
    required int absentCount,
    required List<Map<String, dynamic>> students,
    String facultyName = '',
    String labName = '',
    String startTime = '',
    String endTime = '',
    String departmentName = '',
    String className = '',
  }) async {
    final pdf = pw.Document();

    pw.MemoryImage? logoImage;
    try {
      final ByteData data =
          await rootBundle.load('assets/images/SmartAttendance.png');
      logoImage = pw.MemoryImage(data.buffer.asUint8List());
    } catch (_) {}

    final generatedAt =
        DateFormat('MMMM dd, yyyy  •  hh:mm a').format(DateTime.now());
    final double attendancePct =
        totalStudents > 0 ? (presentCount / totalStudents) : 0.0;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (pw.Context context) {
          return [
            _buildPageHeader(logoImage, generatedAt),
            pw.SizedBox(height: 20),
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 32),
              child: pw.Column(
                children: [
                  _buildSessionInfoBanner(
                    subjectName: subjectName,
                    dateStr: dateStr,
                    facultyName: facultyName,
                    labName: labName,
                    startTime: startTime,
                    endTime: endTime,
                    departmentName: departmentName,
                    className: className,
                  ),
                  pw.SizedBox(height: 18),
                  _buildStatCards(
                      totalStudents, presentCount, absentCount, attendancePct),
                  pw.SizedBox(height: 18),
                  _buildAttendanceBar(attendancePct),
                  pw.SizedBox(height: 22),
                  _buildStudentTable(students),
                ],
              ),
            ),
            pw.SizedBox(height: 32),
          ];
        },
        footer: (pw.Context context) {
          return _buildFooter(
              context, facultyName, subjectName, dateStr, students.length);
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name:
          'SmartAttend_Report_${subjectName.replaceAll(" ", "_")}_$dateStr.pdf',
    );
  }

  // ─── PAGE HEADER ──────────────────────────────────────────────────────────────

  static pw.Widget _buildPageHeader(
      pw.MemoryImage? logoImage, String generatedAt) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.fromLTRB(32, 28, 32, 24),
      decoration: const pw.BoxDecoration(
        color: _primaryColor,
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'SmartAttend',
                style: pw.TextStyle(
                  fontSize: 28,
                  fontWeight: pw.FontWeight.bold,
                  color: _white,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'OFFICIAL ATTENDANCE REPORT',
                style: pw.TextStyle(
                  fontSize: 9,
                  color: const PdfColor(0.8, 0.88, 1.0),
                  letterSpacing: 2.0,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Container(
                padding:
                    const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: pw.BoxDecoration(
                  color: _white,
                  borderRadius:
                      const pw.BorderRadius.all(pw.Radius.circular(6)),
                ),
                child: pw.Text(
                  'Generated: $generatedAt',
                  style: pw.TextStyle(
                    fontSize: 9,
                    color: _textDark,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              if (logoImage != null)
                pw.Container(
                  height: 60,
                  width: 80,
                  padding: const pw.EdgeInsets.all(6),
                  decoration: pw.BoxDecoration(
                    color: _white,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                  ),
                  child: pw.Center(
                    child: pw.Image(logoImage, fit: pw.BoxFit.contain),
                  ),
                ),
              pw.SizedBox(height: 6),
              pw.Text(
                'Powered by SmartAttend™',
                style: pw.TextStyle(
                  fontSize: 8,
                  color: const PdfColor(0.7, 0.8, 1.0),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── SESSION INFO BANNER ───────────────────────────────────────────────────────

  static pw.Widget _buildSessionInfoBanner({
    required String subjectName,
    required String dateStr,
    required String facultyName,
    required String labName,
    required String startTime,
    required String endTime,
    required String departmentName,
    required String className,
  }) {
    final bool hasRow2 = facultyName.isNotEmpty || departmentName.isNotEmpty;
    final bool hasRow3 =
        labName.isNotEmpty || className.isNotEmpty || startTime.isNotEmpty;

    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: _white,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: _divider, width: 1),
      ),
      child: pw.Column(
        children: [
          pw.Row(
            children: [
              _infoCell('Subject', subjectName),
              _infoCell('Date', dateStr),
            ],
          ),
          if (hasRow2) ...[
            pw.SizedBox(height: 10),
            pw.Divider(color: _divider, thickness: 0.5),
            pw.SizedBox(height: 10),
            pw.Row(
              children: [
                if (facultyName.isNotEmpty) _infoCell('Faculty', facultyName),
                if (departmentName.isNotEmpty)
                  _infoCell('Department', departmentName),
              ],
            ),
          ],
          if (hasRow3) ...[
            pw.SizedBox(height: 10),
            pw.Divider(color: _divider, thickness: 0.5),
            pw.SizedBox(height: 10),
            pw.Row(
              children: [
                if (labName.isNotEmpty) _infoCell('Room / Lab', labName),
                if (className.isNotEmpty) _infoCell('Class', className),
                if (startTime.isNotEmpty && endTime.isNotEmpty)
                  _infoCell('Time Slot', '$startTime – $endTime'),
              ],
            ),
          ],
        ],
      ),
    );
  }

  static pw.Widget _infoCell(String label, String value) {
    return pw.Expanded(
      child: pw.Padding(
        padding: const pw.EdgeInsets.only(right: 12),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              label.toUpperCase(),
              style: pw.TextStyle(
                fontSize: 7,
                color: _textLight,
                fontWeight: pw.FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
            pw.SizedBox(height: 3),
            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                color: _textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── STAT CARDS ───────────────────────────────────────────────────────────────

  static pw.Widget _buildStatCards(
      int total, int present, int absent, double pct) {
    final String pctStr = '${(pct * 100).toStringAsFixed(1)}%';

    return pw.Row(
      children: [
        _statCard('TOTAL', total.toString(), 'Students', _primaryColor),
        pw.SizedBox(width: 10),
        _statCard('PRESENT', present.toString(), 'Attended', _primaryColor),
        pw.SizedBox(width: 10),
        _statCard('ABSENT', absent.toString(), 'Missed', _primaryColor),
        pw.SizedBox(width: 10),
        _statCard('ATTENDANCE', pctStr, 'Rate', _primaryColor),
      ],
    );
  }

  static pw.Widget _statCard(String label, String value, String sublabel,
      PdfColor accent) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: pw.BoxDecoration(
          color: _white,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
          border: pw.Border.all(color: _divider, width: 1.0),
        ),
        child: pw.Column(
          children: [
            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
                color: accent,
              ),
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              sublabel,
              style: pw.TextStyle(fontSize: 8, color: _textMid),
            ),
            pw.SizedBox(height: 6),
            pw.Container(height: 1, color: _divider),
            pw.SizedBox(height: 5),
            pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 7,
                color: _textLight,
                fontWeight: pw.FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── ATTENDANCE PROGRESS BAR ──────────────────────────────────────────────────

  static pw.Widget _buildAttendanceBar(double pct) {
    final String pctStr = '${(pct * 100).toStringAsFixed(1)}%';
    
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Overall Attendance Rate',
              style: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                color: _textDark,
              ),
            ),
            pw.Container(
              padding:
                  const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: pw.BoxDecoration(
                color: _primaryColor,
                borderRadius:
                    const pw.BorderRadius.all(pw.Radius.circular(20)),
              ),
              child: pw.Text(
                pctStr,
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  color: _white,
                ),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Stack(
          children: [
            pw.Container(
              height: 10,
              width: double.infinity,
              decoration: pw.BoxDecoration(
                color: _primaryLight,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
              ),
            ),
            pw.Container(
              height: 10,
              width: (595 - 64) * pct.clamp(0.0, 1.0),
              decoration: pw.BoxDecoration(
                color: _primaryColor,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─── STUDENT TABLE ────────────────────────────────────────────────────────────

  static pw.Widget _buildStudentTable(List<Map<String, dynamic>> students) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Student Attendance Details',
              style: pw.TextStyle(
                fontSize: 13,
                fontWeight: pw.FontWeight.bold,
                color: _textDark,
              ),
            ),
            pw.Container(
              padding:
                  const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: pw.BoxDecoration(
                color: _primaryLight,
                borderRadius:
                    const pw.BorderRadius.all(pw.Radius.circular(20)),
              ),
              child: pw.Text(
                '${students.length} Students Enrolled',
                style: pw.TextStyle(fontSize: 9, color: _primaryColor,
                  fontWeight: pw.FontWeight.bold),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 10),

        // Header row
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: const pw.BoxDecoration(
            color: _primaryColor,
            borderRadius: pw.BorderRadius.only(
              topLeft: pw.Radius.circular(6),
              topRight: pw.Radius.circular(6),
            ),
          ),
          child: pw.Row(
            children: [
              pw.SizedBox(
                width: 36,
                child: pw.Text('#',
                    style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                        color: _white)),
              ),
              pw.SizedBox(
                width: 90,
                child: pw.Text('Roll No.',
                    style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                        color: _white)),
              ),
              pw.Expanded(
                child: pw.Text('Student Name',
                    style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                        color: _white)),
              ),
              pw.SizedBox(
                width: 75,
                child: pw.Center(
                  child: pw.Text('Status',
                      style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                          color: _white)),
                ),
              ),
            ],
          ),
        ),

        // Data rows
        ...students.asMap().entries.map((entry) {
          final int idx = entry.key;
          final student = entry.value;
          final bool isPresent = student['status'] == 'Present';
          final bool isAlt = idx % 2 == 1;

          final PdfColor rowBg = isAlt ? _greyBg : _white;
          
          return pw.Container(
            padding:
                const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: pw.BoxDecoration(
              color: rowBg,
              border: const pw.Border(
                bottom: pw.BorderSide(color: _divider, width: 0.5),
                left: pw.BorderSide(color: _divider, width: 0.5),
                right: pw.BorderSide(color: _divider, width: 0.5),
              ),
            ),
            child: pw.Row(
              children: [
                pw.SizedBox(
                  width: 36,
                  child: pw.Text(
                    '${idx + 1}',
                    style: pw.TextStyle(fontSize: 9, color: _textLight,
                        fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.SizedBox(
                  width: 90,
                  child: pw.Text(
                    student['roll'] ?? 'N/A',
                    style: pw.TextStyle(fontSize: 9, color: _textMid,
                        fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.Expanded(
                  child: pw.Text(
                    student['name'] ?? 'Unknown',
                    style: pw.TextStyle(fontSize: 9, color: _textDark),
                  ),
                ),
                pw.SizedBox(
                  width: 75,
                  child: pw.Center(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: pw.BoxDecoration(
                        color: isPresent ? _primaryLight : _white,
                        border: pw.Border.all(
                          color: isPresent ? _primaryColor : _textLight,
                          width: 1,
                        ),
                        borderRadius: const pw.BorderRadius.all(
                            pw.Radius.circular(12)),
                      ),
                      child: pw.Text(
                        isPresent ? 'Present' : 'Absent',
                        style: pw.TextStyle(
                          fontSize: 8,
                          color: isPresent ? _primaryColor : _textLight,
                          fontWeight: pw.FontWeight.bold,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),

        // Bottom border
        pw.Container(
          height: 3,
          decoration: const pw.BoxDecoration(
            color: _primaryColor,
            borderRadius: pw.BorderRadius.only(
              bottomLeft: pw.Radius.circular(6),
              bottomRight: pw.Radius.circular(6),
            ),
          ),
        ),
      ],
    );
  }

  // ─── FOOTER ───────────────────────────────────────────────────────────────────

  static pw.Widget _buildFooter(pw.Context context, String facultyName,
      String subjectName, String dateStr, int total) {
    return pw.Container(
      padding: const pw.EdgeInsets.fromLTRB(32, 12, 32, 16),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: _divider, width: 1),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          // Left: branding
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'SmartAttend  •  Official Attendance Report',
                style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                  color: _primaryColor,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                '$subjectName  |  $dateStr  |  $total Students',
                style: pw.TextStyle(fontSize: 8, color: _textLight),
              ),
            ],
          ),
          // Center: signature
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Container(width: 130, height: 0.8, color: _textLight),
              pw.SizedBox(height: 3),
              pw.Text(
                facultyName.isNotEmpty ? facultyName : 'Faculty Signature',
                style: pw.TextStyle(fontSize: 9, color: _textMid,
                    fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(
                'Authorized Signature',
                style: pw.TextStyle(fontSize: 7, color: _textLight),
              ),
            ],
          ),
          // Right: page number
          pw.Container(
            padding:
                const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: pw.BoxDecoration(
              color: _primaryColor,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
            ),
            child: pw.Text(
              'Page ${context.pageNumber} / ${context.pagesCount}',
              style: pw.TextStyle(fontSize: 9, color: _white,
                  fontWeight: pw.FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
