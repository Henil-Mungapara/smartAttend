import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class PdfReportService {
  static Future<void> generateAndPrintAttendanceReport({
    required String subjectName,
    required String dateStr,
    required int totalStudents,
    required int presentCount,
    required int absentCount,
    required List<Map<String, dynamic>> students,
  }) async {
    final pdf = pw.Document();

    // Try to load the logo
    pw.MemoryImage? logoImage;
    try {
      final ByteData data = await rootBundle.load('assets/images/SmartAttendance.png');
      logoImage = pw.MemoryImage(data.buffer.asUint8List());
    } catch (e) {
      // If logo fails to load, it will just be null
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _buildHeader(logoImage),
            pw.SizedBox(height: 20),
            _buildSessionInfo(subjectName, dateStr),
            pw.SizedBox(height: 20),
            _buildSummaryStats(totalStudents, presentCount, absentCount),
            pw.SizedBox(height: 20),
            _buildStudentTable(students),
          ];
        },
        footer: (pw.Context context) {
          return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 10),
            child: pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
              style: const pw.TextStyle(color: PdfColors.grey),
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Attendance_Report_${subjectName.replaceAll(" ", "_")}_$dateStr.pdf',
    );
  }

  static pw.Widget _buildHeader(pw.MemoryImage? logoImage) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('SmartAttend', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#0047AB'))),
            pw.SizedBox(height: 4),
            pw.Text('Official Attendance Report', style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey700)),
            pw.SizedBox(height: 4),
            pw.Text('Generated on: ${DateFormat('MMM dd, yyyy - hh:mm a').format(DateTime.now())}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
          ],
        ),
        if (logoImage != null)
          pw.Container(
            height: 60,
            width: 60,
            child: pw.Image(logoImage),
          ),
      ],
    );
  }

  static pw.Widget _buildSessionInfo(String subjectName, String dateStr) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#F5F7FA'),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: PdfColor.fromHex('#E0E0E0')),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Subject', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
              pw.Text(subjectName, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text('Session Date', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
              pw.Text(dateStr, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSummaryStats(int total, int present, int absent) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
      children: [
        _statBox('Total Students', total.toString(), PdfColor.fromHex('#0047AB')),
        _statBox('Present', present.toString(), PdfColor.fromHex('#2E7D32')), // Green
        _statBox('Absent', absent.toString(), PdfColor.fromHex('#C62828')),   // Red
      ],
    );
  }

  static pw.Widget _statBox(String label, String value, PdfColor color) {
    return pw.Container(
      width: 100,
      padding: const pw.EdgeInsets.symmetric(vertical: 10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: color),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        children: [
          pw.Text(value, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: color)),
          pw.SizedBox(height: 4),
          pw.Text(label, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
        ],
      ),
    );
  }

  static pw.Widget _buildStudentTable(List<Map<String, dynamic>> students) {
    final headers = ['Roll No', 'Student Name', 'Status'];

    final data = students.map((s) {
      return [
        s['roll'] ?? 'N/A',
        s['name'] ?? 'Unknown',
        s['status'] ?? 'Unknown',
      ];
    }).toList();

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      border: pw.TableBorder.all(color: PdfColor.fromHex('#E0E0E0')),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: pw.BoxDecoration(color: PdfColor.fromHex('#0047AB')),
      cellHeight: 30,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.center,
      },
      cellStyle: const pw.TextStyle(fontSize: 10),
      oddRowDecoration: pw.BoxDecoration(color: PdfColor.fromHex('#F9F9F9')),
    );
  }
}
