import 'package:flutter/material.dart';
import '../utils/gpa_calculator.dart';
import '../services/student_result_service.dart';
import '../services/performance_service.dart';

class SemesterResultDetailsScreen extends StatefulWidget {
  final String studentId;
  final String studentName;
  final int semester;
  final List<Map<String, dynamic>> semesterResults;
  final List<Map<String, dynamic>> allResults;

  const SemesterResultDetailsScreen({
    super.key,
    required this.studentId,
    required this.studentName,
    required this.semester,
    required this.semesterResults,
    required this.allResults,
  });

  @override
  State<SemesterResultDetailsScreen> createState() =>
      _SemesterResultDetailsScreenState();
}

class _SemesterResultDetailsScreenState
    extends State<SemesterResultDetailsScreen> {
  final StudentResultService _service = StudentResultService();
  Map<String, dynamic> rankData = {};
  bool isLoadingRank = true;

  @override
  void initState() {
    super.initState();
    _loadRank();
  }

  Future<void> _loadRank() async {
    try {
      final data =
          await _service.calculateRank(widget.studentId, widget.semester);
      if (mounted)
        setState(() {
          rankData = data;
          isLoadingRank = false;
        });
    } catch (_) {
      if (mounted) setState(() => isLoadingRank = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gpa = GpaCalculator.calculateGPA(widget.semesterResults);
    final totalCredits = widget.semesterResults
        .fold<double>(0, (s, r) => s + (r['credits'] as num).toDouble());
    final arrears = _service.countSemesterArrears(widget.semesterResults);
    final passPercent =
        PerformanceService.passPercentage(widget.semesterResults);
    final passed = widget.semesterResults
        .where((r) => GpaCalculator.isPassed(r['grade'] ?? 'F'))
        .length;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1F4E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Semester ${widget.semester} Result',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── GPA Summary Card ─────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: arrears > 0
                      ? [const Color(0xFFE53935), const Color(0xFFFF6B6B)]
                      : [const Color(0xFF6C63FF), const Color(0xFF4ECDC4)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text('Semester ${widget.semester} GPA',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 8),
                  Text(gpa.toStringAsFixed(2),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 52,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildTopStat('Credits', totalCredits.toStringAsFixed(0)),
                      _buildTopStat('Passed', '$passed'),
                      _buildTopStat('Arrears', '$arrears'),
                      _buildTopStat(
                          'Pass %', '${passPercent.toStringAsFixed(0)}%'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Rank + Extra Info ────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    icon: Icons.emoji_events_rounded,
                    label: 'Semester Rank',
                    value: isLoadingRank
                        ? '...'
                        : rankData.isNotEmpty
                            ? '${rankData['rank']}/${rankData['totalStudents']}'
                            : '--',
                    color: const Color(0xFFFFBE0B),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoCard(
                    icon: Icons.trending_up_rounded,
                    label: 'vs Topper',
                    value: isLoadingRank
                        ? '...'
                        : rankData.isNotEmpty
                            ? '-${(rankData['gapFromTopper'] as double).toStringAsFixed(2)}'
                            : '--',
                    color: const Color(0xFF4ECDC4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Subject Table ────────────────────────────────────
            const Text('Subject-wise Result',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1A1F4E),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  // Table Header
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: const BoxDecoration(
                      color: Color(0xFF2D3470),
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(18)),
                    ),
                    child: Row(
                      children: const [
                        Expanded(
                            flex: 2,
                            child: Text('Subject',
                                style: TextStyle(
                                    color: Color(0xFF8B92B8),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600))),
                        SizedBox(
                            width: 36,
                            child: Text('Cr',
                                style: TextStyle(
                                    color: Color(0xFF8B92B8),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600),
                                textAlign: TextAlign.center)),
                        SizedBox(
                            width: 48,
                            child: Text('Grade',
                                style: TextStyle(
                                    color: Color(0xFF8B92B8),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600),
                                textAlign: TextAlign.center)),
                        SizedBox(
                            width: 36,
                            child: Text('GP',
                                style: TextStyle(
                                    color: Color(0xFF8B92B8),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600),
                                textAlign: TextAlign.center)),
                        SizedBox(
                            width: 40,
                            child: Text('Status',
                                style: TextStyle(
                                    color: Color(0xFF8B92B8),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600),
                                textAlign: TextAlign.center)),
                      ],
                    ),
                  ),

                  // Table rows
                  ...widget.semesterResults.asMap().entries.map((entry) {
                    final i = entry.key;
                    final r = entry.value;
                    final grade = r['grade'] ?? '';
                    final gradeColor = Color(GpaCalculator.gradeColor(grade));
                    final passed = GpaCalculator.isPassed(grade);

                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(r['subjectCode'] ?? '',
                                        style: const TextStyle(
                                            color: Color(0xFF6C63FF),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600)),
                                    Text(r['subjectName'] ?? '',
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 13),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 36,
                                child: Text((r['credits'] ?? 0).toString(),
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 13),
                                    textAlign: TextAlign.center),
                              ),
                              SizedBox(
                                width: 48,
                                child: Container(
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: gradeColor.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(grade,
                                      style: TextStyle(
                                          color: gradeColor,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center),
                                ),
                              ),
                              SizedBox(
                                width: 36,
                                child: Text((r['gradePoint'] ?? 0).toString(),
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 13),
                                    textAlign: TextAlign.center),
                              ),
                              SizedBox(
                                width: 40,
                                child: Icon(
                                  passed
                                      ? Icons.check_circle_rounded
                                      : Icons.cancel_rounded,
                                  color: passed
                                      ? const Color(0xFF43A047)
                                      : const Color(0xFFE53935),
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (i < widget.semesterResults.length - 1)
                          const Divider(
                              color: Color(0xFF2D3470),
                              height: 1,
                              thickness: 0.5,
                              indent: 16,
                              endIndent: 16),
                      ],
                    );
                  }),

                  // Table Footer — Totals
                  Container(
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C63FF).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: const Color(0xFF6C63FF).withOpacity(0.3),
                          width: 1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildFooterStat(
                            'Total Credits', totalCredits.toStringAsFixed(0)),
                        _buildFooterStat(
                            'Semester GPA', gpa.toStringAsFixed(2)),
                        _buildFooterStat(
                            'Pass %', '${passPercent.toStringAsFixed(0)}%'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTopStat(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F4E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(label,
                    style: const TextStyle(
                        color: Color(0xFF8B92B8), fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterStat(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: Color(0xFF6C63FF),
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(color: Color(0xFF8B92B8), fontSize: 11)),
      ],
    );
  }
}
