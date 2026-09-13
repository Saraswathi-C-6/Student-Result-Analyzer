import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../utils/gpa_calculator.dart';

class PDFReportScreen extends StatefulWidget {
  final String studentName;
  final String regNo;
  final String department;
  final String batch;
  final List<Map<String, dynamic>> allResults;

  const PDFReportScreen({
    super.key,
    required this.studentName,
    required this.regNo,
    required this.department,
    required this.batch,
    required this.allResults,
  });

  @override
  State<PDFReportScreen> createState() => _PDFReportScreenState();
}

class _PDFReportScreenState extends State<PDFReportScreen> {
  bool isGenerating = false;

  List<Map<String, dynamic>> _getSemResults(int sem) =>
      widget.allResults.where((r) => r['semester'] == sem).toList();

  Future<void> _generateAndSharePDF() async {
    setState(() => isGenerating = true);
    try {
      final pdf = await _buildPDF();
      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: '${widget.regNo}_result_card.pdf',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating PDF: $e'),
            backgroundColor: const Color(0xFFE53935),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isGenerating = false);
    }
  }

  Future<pw.Document> _buildPDF() async {
    final pdf = pw.Document();
    final cgpa = GpaCalculator.calculateCGPA(widget.allResults);
    final classification = GpaCalculator.getClassification(cgpa);
    final totalCredits = GpaCalculator.totalCreditsEarned(widget.allResults);

    final primaryColor = PdfColor.fromHex('#6C63FF');
    final accentColor = PdfColor.fromHex('#4ECDC4');
    final darkBg = PdfColor.fromHex('#1A1F4E');
    final lightBg = PdfColor.fromHex('#F4F6FF');
    final textDark = PdfColor.fromHex('#2D3142');
    final textMuted = PdfColor.fromHex('#8B92B8');
    final textFaded = PdfColor.fromHex('#AAAACC'); // replaces white70

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(0),
        build: (context) => [
          // Header
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(32),
            decoration: pw.BoxDecoration(
              gradient: pw.LinearGradient(
                colors: [primaryColor, accentColor],
                begin: pw.Alignment.centerLeft,
                end: pw.Alignment.centerRight,
              ),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('STUDENT RESULT CARD',
                            style: pw.TextStyle(
                              color: PdfColors.white,
                              fontSize: 22,
                              fontWeight: pw.FontWeight.bold,
                              letterSpacing: 1.5,
                            )),
                        pw.SizedBox(height: 4),
                        pw.Text('Academic Performance Report',
                            style: pw.TextStyle(
                              color: PdfColors.white,
                              fontSize: 12,
                            )),
                      ],
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.white,
                        borderRadius: pw.BorderRadius.circular(12),
                      ),
                      child: pw.Text(
                        cgpa.toStringAsFixed(2),
                        style: pw.TextStyle(
                          color: primaryColor,
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Row(
                  children: [
                    _pdfInfoChip('Name', widget.studentName, PdfColors.white),
                    pw.SizedBox(width: 16),
                    _pdfInfoChip('Reg No', widget.regNo, PdfColors.white),
                    pw.SizedBox(width: 16),
                    _pdfInfoChip('Dept', widget.department, PdfColors.white),
                    pw.SizedBox(width: 16),
                    _pdfInfoChip('Batch', widget.batch, PdfColors.white),
                  ],
                ),
              ],
            ),
          ),

          // CGPA Summary
          pw.Container(
            color: lightBg,
            padding:
                const pw.EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                _pdfSummaryBox('CGPA', cgpa.toStringAsFixed(2), primaryColor),
                _pdfSummaryBox('Classification', classification, accentColor),
                _pdfSummaryBox(
                    'Credits Earned',
                    totalCredits.toStringAsFixed(0),
                    PdfColor.fromHex('#FFBE0B')),
                _pdfSummaryBox(
                    'Semesters',
                    widget.allResults.isEmpty ? '0' : '4',
                    PdfColor.fromHex('#FF6B6B')),
              ],
            ),
          ),

          pw.SizedBox(height: 16),

          // Semester results
          ...[1, 2, 3, 4].map((sem) {
            final results = _getSemResults(sem);
            if (results.isEmpty) return pw.SizedBox();
            final gpa = GpaCalculator.calculateGPA(results);
            final credits = results.fold<double>(
                0, (s, r) => s + (r['credits'] ?? 0).toDouble());

            return pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 32),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: pw.BoxDecoration(
                      color: darkBg,
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('SEMESTER $sem',
                            style: pw.TextStyle(
                              color: PdfColors.white,
                              fontSize: 13,
                              fontWeight: pw.FontWeight.bold,
                              letterSpacing: 1,
                            )),
                        pw.Row(
                          children: [
                            pw.Text('GPA: ',
                                style: pw.TextStyle(
                                    color: textFaded, fontSize: 12)),
                            pw.Text(gpa.toStringAsFixed(2),
                                style: pw.TextStyle(
                                    color: accentColor,
                                    fontSize: 14,
                                    fontWeight: pw.FontWeight.bold)),
                            pw.Text('   Credits: ',
                                style: pw.TextStyle(
                                    color: textFaded, fontSize: 12)),
                            pw.Text(credits.toStringAsFixed(0),
                                style: pw.TextStyle(
                                    color: PdfColors.white, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 8),

                  // Table Header
                  pw.Container(
                    color: PdfColor.fromHex('#EEF0F8'),
                    padding: const pw.EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    child: pw.Row(
                      children: [
                        pw.Expanded(
                            flex: 2,
                            child: pw.Text('Subject Code',
                                style: pw.TextStyle(
                                    color: textMuted,
                                    fontSize: 10,
                                    fontWeight: pw.FontWeight.bold))),
                        pw.Expanded(
                            flex: 3,
                            child: pw.Text('Subject Name',
                                style: pw.TextStyle(
                                    color: textMuted,
                                    fontSize: 10,
                                    fontWeight: pw.FontWeight.bold))),
                        pw.SizedBox(
                            width: 50,
                            child: pw.Text('Credits',
                                style: pw.TextStyle(
                                    color: textMuted,
                                    fontSize: 10,
                                    fontWeight: pw.FontWeight.bold),
                                textAlign: pw.TextAlign.center)),
                        pw.SizedBox(
                            width: 50,
                            child: pw.Text('Grade',
                                style: pw.TextStyle(
                                    color: textMuted,
                                    fontSize: 10,
                                    fontWeight: pw.FontWeight.bold),
                                textAlign: pw.TextAlign.center)),
                        pw.SizedBox(
                            width: 40,
                            child: pw.Text('GP',
                                style: pw.TextStyle(
                                    color: textMuted,
                                    fontSize: 10,
                                    fontWeight: pw.FontWeight.bold),
                                textAlign: pw.TextAlign.center)),
                        pw.SizedBox(
                            width: 50,
                            child: pw.Text('Status',
                                style: pw.TextStyle(
                                    color: textMuted,
                                    fontSize: 10,
                                    fontWeight: pw.FontWeight.bold),
                                textAlign: pw.TextAlign.center)),
                      ],
                    ),
                  ),

                  // Result rows
                  ...results.asMap().entries.map((entry) {
                    final r = entry.value;
                    final grade = r['grade'] ?? '';
                    final passed = GpaCalculator.isPassed(grade);
                    final isEven = entry.key % 2 == 0;

                    return pw.Container(
                      color: isEven ? PdfColors.white : lightBg,
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: pw.Row(
                        children: [
                          pw.Expanded(
                              flex: 2,
                              child: pw.Text(r['subjectCode'] ?? '',
                                  style: pw.TextStyle(
                                      color: primaryColor,
                                      fontSize: 11,
                                      fontWeight: pw.FontWeight.bold))),
                          pw.Expanded(
                              flex: 3,
                              child: pw.Text(r['subjectName'] ?? '',
                                  style: pw.TextStyle(
                                      color: textDark, fontSize: 11))),
                          pw.SizedBox(
                              width: 50,
                              child: pw.Text((r['credits'] ?? 0).toString(),
                                  style: pw.TextStyle(
                                      color: textDark, fontSize: 11),
                                  textAlign: pw.TextAlign.center)),
                          pw.SizedBox(
                              width: 50,
                              child: pw.Container(
                                margin: const pw.EdgeInsets.symmetric(
                                    horizontal: 6),
                                padding: const pw.EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: pw.BoxDecoration(
                                  color: _pdfGradeColor(grade),
                                  borderRadius: pw.BorderRadius.circular(4),
                                ),
                                child: pw.Text(grade,
                                    style: pw.TextStyle(
                                        color: PdfColors.white,
                                        fontSize: 11,
                                        fontWeight: pw.FontWeight.bold),
                                    textAlign: pw.TextAlign.center),
                              )),
                          pw.SizedBox(
                              width: 40,
                              child: pw.Text((r['gradePoint'] ?? 0).toString(),
                                  style: pw.TextStyle(
                                      color: textDark, fontSize: 11),
                                  textAlign: pw.TextAlign.center)),
                          pw.SizedBox(
                              width: 50,
                              child: pw.Text(
                                passed ? 'PASS' : 'FAIL',
                                style: pw.TextStyle(
                                    color: passed
                                        ? PdfColor.fromHex('#43A047')
                                        : PdfColor.fromHex('#E53935'),
                                    fontSize: 10,
                                    fontWeight: pw.FontWeight.bold),
                                textAlign: pw.TextAlign.center,
                              )),
                        ],
                      ),
                    );
                  }),
                  pw.SizedBox(height: 16),
                ],
              ),
            );
          }),

          // Grade Scale
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 32),
            child: pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: lightBg,
                borderRadius: pw.BorderRadius.circular(8),
                border:
                    pw.Border.all(color: PdfColor.fromHex('#E8EAF6'), width: 1),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Grade Scale',
                      style: pw.TextStyle(
                          color: textDark,
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 8),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                    children: [
                      _pdfGradeScaleItem('S', '10', primaryColor),
                      _pdfGradeScaleItem('A', '9', accentColor),
                      _pdfGradeScaleItem('B', '8', PdfColor.fromHex('#43A047')),
                      _pdfGradeScaleItem('C', '7', PdfColor.fromHex('#FFBE0B')),
                      _pdfGradeScaleItem('D', '6', PdfColor.fromHex('#FF9800')),
                      _pdfGradeScaleItem('E', '5', PdfColor.fromHex('#FF6B6B')),
                      _pdfGradeScaleItem('F', '0', PdfColor.fromHex('#E53935')),
                    ],
                  ),
                ],
              ),
            ),
          ),

          pw.SizedBox(height: 16),
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 32),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Generated by Student Result Analyzer',
                    style: pw.TextStyle(color: textMuted, fontSize: 10)),
                pw.Text(
                    'Date: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                    style: pw.TextStyle(color: textMuted, fontSize: 10)),
              ],
            ),
          ),
          pw.SizedBox(height: 24),
        ],
      ),
    );

    return pdf;
  }

  pw.Widget _pdfInfoChip(String label, String value, PdfColor textColor) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label,
            style: pw.TextStyle(
                color: PdfColor.fromHex('#CCCCDD'),
                fontSize: 9,
                fontWeight: pw.FontWeight.bold)),
        pw.Text(value,
            style: pw.TextStyle(
                color: textColor,
                fontSize: 11,
                fontWeight: pw.FontWeight.bold)),
      ],
    );
  }

  pw.Widget _pdfSummaryBox(String label, String value, PdfColor color) {
    return pw.Column(
      children: [
        pw.Text(value,
            style: pw.TextStyle(
                color: color, fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        pw.Text(label,
            style:
                pw.TextStyle(color: PdfColor.fromHex('#6B7280'), fontSize: 10)),
      ],
    );
  }

  pw.Widget _pdfGradeScaleItem(String grade, String point, PdfColor color) {
    return pw.Column(
      children: [
        pw.Container(
          width: 28,
          height: 28,
          decoration: pw.BoxDecoration(
            color: color,
            borderRadius: pw.BorderRadius.circular(6),
          ),
          child: pw.Center(
            child: pw.Text(grade,
                style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold)),
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(point,
            style:
                pw.TextStyle(color: PdfColor.fromHex('#2D3142'), fontSize: 10)),
      ],
    );
  }

  PdfColor _pdfGradeColor(String grade) {
    switch (grade.toUpperCase()) {
      case 'S':
        return PdfColor.fromHex('#6C63FF');
      case 'A':
        return PdfColor.fromHex('#4ECDC4');
      case 'B':
        return PdfColor.fromHex('#43A047');
      case 'C':
        return PdfColor.fromHex('#FFBE0B');
      case 'D':
        return PdfColor.fromHex('#FF9800');
      case 'E':
        return PdfColor.fromHex('#FF6B6B');
      default:
        return PdfColor.fromHex('#E53935');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cgpa = GpaCalculator.calculateCGPA(widget.allResults);
    final classification = GpaCalculator.getClassification(cgpa);
    final textColor = isDark ? Colors.white : const Color(0xFF2D3142);
    final cardBg = isDark ? const Color(0xFF1A1F4E) : Colors.white;
    final subColor = isDark ? const Color(0xFF8B92B8) : const Color(0xFF6B7280);

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0A0E27) : const Color(0xFFF4F6FF),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1A1F4E) : Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Result Card',
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          IconButton(
            icon: isGenerating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: Color(0xFF6C63FF), strokeWidth: 2))
                : const Icon(Icons.share_rounded, color: Color(0xFF6C63FF)),
            onPressed: isGenerating ? null : _generateAndSharePDF,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Icon(Icons.picture_as_pdf_rounded,
                      color: Colors.white, size: 48),
                  const SizedBox(height: 12),
                  Text(widget.studentName,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(widget.regNo,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _previewStat(
                          'CGPA', cgpa.toStringAsFixed(2), Colors.white),
                      _previewStat('Class', classification, Colors.white),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ...[1, 2, 3, 4].map((sem) {
              final results = _getSemResults(sem);
              if (results.isEmpty) return const SizedBox();
              final gpa = GpaCalculator.calculateGPA(results);
              final credits = results.fold<double>(
                  0, (s, r) => s + (r['credits'] ?? 0).toDouble());
              final passed = results
                  .where((r) => GpaCalculator.isPassed(r['grade'] ?? ''))
                  .length;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Semester $sem',
                            style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 15)),
                        Text('GPA: ${gpa.toStringAsFixed(2)}',
                            style: const TextStyle(
                                color: Color(0xFF4ECDC4),
                                fontWeight: FontWeight.bold,
                                fontSize: 15)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                        '${results.length} subjects • ${credits.toStringAsFixed(0)} credits • $passed passed',
                        style: TextStyle(color: subColor, fontSize: 12)),
                  ],
                ),
              );
            }),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: isGenerating ? null : _generateAndSharePDF,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                icon: isGenerating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.download_rounded, color: Colors.white),
                label: Text(
                    isGenerating ? 'Generating PDF...' : 'Download PDF Report',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton.icon(
                onPressed: isGenerating
                    ? null
                    : () async {
                        setState(() => isGenerating = true);
                        try {
                          final pdf = await _buildPDF();
                          await Printing.layoutPdf(
                              onLayout: (_) async => pdf.save());
                        } finally {
                          if (mounted) {
                            setState(() => isGenerating = false);
                          }
                        }
                      },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF6C63FF), width: 2),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.print_rounded, color: Color(0xFF6C63FF)),
                label: const Text('Print Result Card',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6C63FF))),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _previewStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                color: color, fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}
