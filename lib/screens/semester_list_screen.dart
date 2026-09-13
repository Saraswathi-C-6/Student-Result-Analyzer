import 'package:flutter/material.dart';
import '../utils/gpa_calculator.dart';
import '../services/student_result_service.dart';
import 'semester_result_details_screen.dart';

class SemesterListScreen extends StatelessWidget {
  final String studentId;
  final String studentName;
  final List<Map<String, dynamic>> allResults;

  const SemesterListScreen({
    super.key,
    required this.studentId,
    required this.studentName,
    required this.allResults,
  });

  @override
  Widget build(BuildContext context) {
    final service = StudentResultService();
    final completedSemesters = service.getCompletedSemesters(allResults);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1F4E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Semester Results',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: completedSemesters.isEmpty
          ? _buildEmptyState()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header summary
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1F4E),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildHeaderStat(
                            'CGPA',
                            GpaCalculator.calculateCGPA(allResults)
                                .toStringAsFixed(2),
                            const Color(0xFF6C63FF)),
                        _buildHeaderStat('Semesters',
                            '${completedSemesters.length}', const Color(0xFF4ECDC4)),
                        _buildHeaderStat(
                            'Arrears',
                            '${service.countArrears(allResults)}',
                            service.countArrears(allResults) > 0
                                ? const Color(0xFFE53935)
                                : const Color(0xFF43A047)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text('All Semesters',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),

                  // Semester cards
                  ...completedSemesters.map((sem) {
                    final semResults = allResults
                        .where((r) => r['semester'] == sem)
                        .toList();
                    final gpa = GpaCalculator.calculateGPA(semResults);
                    final arrears = service.countSemesterArrears(semResults);
                    final credits = semResults.fold<double>(
                        0, (s, r) => s + (r['credits'] as num).toDouble());
                    final hasArrear = arrears > 0;

                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SemesterResultDetailsScreen(
                            studentId: studentId,
                            studentName: studentName,
                            semester: sem,
                            semesterResults: semResults,
                            allResults: allResults,
                          ),
                        ),
                      ),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1F4E),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: hasArrear
                                ? const Color(0xFFE53935).withOpacity(0.3)
                                : const Color(0xFF6C63FF).withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Semester badge
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: hasArrear
                                      ? [
                                          const Color(0xFFE53935),
                                          const Color(0xFFFF6B6B)
                                        ]
                                      : [
                                          const Color(0xFF6C63FF),
                                          const Color(0xFF4ECDC4)
                                        ],
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Center(
                                child: Text(
                                  'S$sem',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Semester $sem',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                  const SizedBox(height: 4),
                                  Text(
                                      '${semResults.length} subjects • ${credits.toStringAsFixed(0)} credits',
                                      style: const TextStyle(
                                          color: Color(0xFF8B92B8),
                                          fontSize: 12)),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: hasArrear
                                              ? const Color(0xFFE53935)
                                                  .withOpacity(0.12)
                                              : const Color(0xFF43A047)
                                                  .withOpacity(0.12),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          hasArrear
                                              ? '$arrears Arrear${arrears > 1 ? 's' : ''}'
                                              : 'All Passed',
                                          style: TextStyle(
                                              color: hasArrear
                                                  ? const Color(0xFFE53935)
                                                  : const Color(0xFF43A047),
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  gpa.toStringAsFixed(2),
                                  style: TextStyle(
                                      color: hasArrear
                                          ? const Color(0xFFE53935)
                                          : const Color(0xFF4ECDC4),
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold),
                                ),
                                const Text('GPA',
                                    style: TextStyle(
                                        color: Color(0xFF8B92B8), fontSize: 11)),
                              ],
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_ios_rounded,
                                color: Color(0xFF8B92B8), size: 16),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildHeaderStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                color: color, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(color: Color(0xFF8B92B8), fontSize: 12)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, color: Color(0xFF8B92B8), size: 72),
          SizedBox(height: 16),
          Text('No semester results yet',
              style: TextStyle(color: Colors.white, fontSize: 18)),
          SizedBox(height: 8),
          Text('Results will appear once your teacher adds them',
              style: TextStyle(color: Color(0xFF8B92B8), fontSize: 13),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}