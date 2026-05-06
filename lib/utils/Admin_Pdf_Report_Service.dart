import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class AdminPdfReportService {
  // Brand colors
  static const PdfColor _primaryColor = PdfColor.fromInt(0xFF0047AB);
  static const PdfColor _primaryLight = PdfColor.fromInt(0xFFE8EEF8);
  static const PdfColor _divider = PdfColor.fromInt(0xFFDDE1E9);
  static const PdfColor _textDark = PdfColor.fromInt(0xFF000000);
  static const PdfColor _textMid = PdfColor.fromInt(0xFF4A5568);
  static const PdfColor _textLight = PdfColor.fromInt(0xFF718096);
  static const PdfColor _white = PdfColors.white;
  static const PdfColor _greyBg = PdfColor.fromInt(0xFFF7F9FC);

  static Future<void> generateAndPrintAdminReport({
    required String reportTitle,
    required String dateRangeStr,
    required List<Map<String, dynamic>> students,
    String collegeName = '',
    String departmentName = '',
    String className = '',
    String divisionName = '',
    int totalSessions = 0,
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

    int totalAttendedAll = 0;
    int totalExpectedAll = 0;
    for (var s in students) {
      totalAttendedAll += (s['attendedClasses'] as int? ?? 0);
      totalExpectedAll += (s['totalClasses'] as int? ?? 0);
    }
    final double overallAttendancePct =
        totalExpectedAll > 0 ? (totalAttendedAll / totalExpectedAll) : 0.0;

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
                    reportTitle: reportTitle,
                    dateRangeStr: dateRangeStr,
                    collegeName: collegeName,
                    departmentName: departmentName,
                    className: className,
                    divisionName: divisionName,
                  ),
                  pw.SizedBox(height: 18),
                  _buildStatCards(
                      students.length, totalSessions, overallAttendancePct),
                  pw.SizedBox(height: 18),
                  _buildAttendanceBar(overallAttendancePct),
                  pw.SizedBox(height: 22),
                  _buildStudentTable(students),
                ],
              ),
            ),
            pw.SizedBox(height: 32),
          ];
        },
        footer: (pw.Context context) {
          return _buildFooter(context, reportTitle, dateRangeStr, students.length);
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name:
          'Admin_Report_${reportTitle.replaceAll(" ", "_")}.pdf',
    );
  }

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
                'ADMINISTRATIVE ATTENDANCE REPORT',
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

  static pw.Widget _buildSessionInfoBanner({
    required String reportTitle,
    required String dateRangeStr,
    required String collegeName,
    required String departmentName,
    required String className,
    required String divisionName,
  }) {
    final bool hasRow2 = collegeName.isNotEmpty || departmentName.isNotEmpty;
    final bool hasRow3 = className.isNotEmpty || divisionName.isNotEmpty;

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
              _infoCell('Report Target', reportTitle),
              _infoCell('Date Filter', dateRangeStr),
            ],
          ),
          if (hasRow2) ...[
            pw.SizedBox(height: 10),
            pw.Divider(color: _divider, thickness: 0.5),
            pw.SizedBox(height: 10),
            pw.Row(
              children: [
                if (collegeName.isNotEmpty) _infoCell('College', collegeName),
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
                if (className.isNotEmpty) _infoCell('Class', className),
                if (divisionName.isNotEmpty) _infoCell('Division', divisionName),
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

  static pw.Widget _buildStatCards(int totalStudents, int totalSessions, double pct) {
    final String pctStr = '${(pct * 100).toStringAsFixed(1)}%';

    return pw.Row(
      children: [
        _statCard('ENROLLED', totalStudents.toString(), 'Students', _primaryColor),
        pw.SizedBox(width: 10),
        _statCard('SESSIONS', totalSessions.toString(), 'Tracked', _primaryColor),
        pw.SizedBox(width: 10),
        _statCard('AVG ATTENDANCE', pctStr, 'Overall', _primaryColor),
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

  static pw.Widget _buildAttendanceBar(double pct) {
    final String pctStr = '${(pct * 100).toStringAsFixed(1)}%';
    
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Aggregate Attendance Rate',
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

  static pw.Widget _buildStudentTable(List<Map<String, dynamic>> students) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Student Aggregate Details',
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
                'Sorted by Roll No.',
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
                width: 30,
                child: pw.Text('#',
                    style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                        color: _white)),
              ),
              pw.SizedBox(
                width: 65,
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
                width: 60,
                child: pw.Center(
                  child: pw.Text('Sessions\nAttended',
                      style: pw.TextStyle(
                          fontSize: 8,
                          fontWeight: pw.FontWeight.bold,
                          color: _white),
                      textAlign: pw.TextAlign.center),
                ),
              ),
              pw.SizedBox(
                width: 60,
                child: pw.Center(
                  child: pw.Text('Percentage',
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
          final int attended = student['attendedClasses'] ?? 0;
          final int total = student['totalClasses'] ?? 0;
          final double pct = total > 0 ? (attended / total) : 0.0;
          final bool isAlt = idx % 2 == 1;

          final PdfColor rowBg = isAlt ? _greyBg : _white;
          
          final PdfColor pctColor = pct >= 0.75 
            ? PdfColor.fromInt(0xFF2E7D32) 
            : (pct >= 0.5 ? PdfColor.fromInt(0xFFED6C02) : PdfColor.fromInt(0xFFD32F2F));
          
          final PdfColor pctBgColor = pct >= 0.75 
            ? PdfColor.fromInt(0xFFE8F5E9) 
            : (pct >= 0.5 ? PdfColor.fromInt(0xFFFFF3E0) : PdfColor.fromInt(0xFFFFEBEE));

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
                  width: 30,
                  child: pw.Text(
                    '${idx + 1}',
                    style: pw.TextStyle(fontSize: 9, color: _textLight,
                        fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.SizedBox(
                  width: 65,
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
                  width: 60,
                  child: pw.Center(
                    child: pw.Text(
                      '$attended / $total',
                      style: pw.TextStyle(
                        fontSize: 9,
                        color: _textMid,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                pw.SizedBox(
                  width: 60,
                  child: pw.Center(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: pw.BoxDecoration(
                        color: pctBgColor,
                        borderRadius: const pw.BorderRadius.all(
                            pw.Radius.circular(12)),
                      ),
                      child: pw.Text(
                        '${(pct * 100).toStringAsFixed(0)}%',
                        style: pw.TextStyle(
                          fontSize: 8,
                          color: pctColor,
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

  static pw.Widget _buildFooter(pw.Context context, String reportTitle,
      String dateRangeStr, int total) {
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
                'SmartAttend  •  Admin Summary',
                style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                  color: _primaryColor,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                '$reportTitle  |  $dateRangeStr  |  $total Students',
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
                'Admin Signature',
                style: pw.TextStyle(fontSize: 9, color: _textMid,
                    fontWeight: pw.FontWeight.bold),
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
