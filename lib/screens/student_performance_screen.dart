import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../utils/gpa_calculator.dart';
import '../services/student_result_service.dart';
import '../services/performance_service.dart';

class StudentPerformanceScreen extends StatelessWidget {
  final String studentId;
  final String studentName;
  final List<Map<String, dynamic>> allResults;

  const StudentPerformanceScreen({
    super.key,
    required this.studentId,
    required this.studentName,
    required this.allResults,
  });

  @override
  Widget build(BuildContext context) {
    final service = StudentResultService();
    final completedSemesters = service.getCompletedSemesters(allResults);
    final gpaTrend = PerformanceService.gpatrend(allResults, completedSemesters);
    final cgpaGrowth =
        PerformanceService.cgpaGrowth(allResults, completedSemesters);
    final arrearHistory =
        PerformanceService.arrearHistory(allResults, completedSemesters);
    final best = PerformanceService.bestSemester(allResults, completedSemesters);
    final improvement =
        PerformanceService.improvementStatus(allResults, completedSemesters);
    final improvColor = Color(PerformanceService.improvementColor(improvement));
    final cgpa = GpaCalculator.calculateCGPA(allResults);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1F4E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Performance',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: completedSemesters.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart_rounded,
                      color: Color(0xFF8B92B8), size: 72),
                  SizedBox(height: 16),
                  Text('No performance data yet',
                      style: TextStyle(color: Colors.white, fontSize: 18)),
                  SizedBox(height: 8),
                  Text('Performance charts appear after results are added',
                      style: TextStyle(color: Color(0xFF8B92B8), fontSize: 13),
                      textAlign: TextAlign.center),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Highlights Row ─────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _buildHighlightCard(
                          'Best Semester',
                          best['semester'] > 0
                              ? 'Sem ${best['semester']}'
                              : '--',
                          '${(best['gpa'] as double).toStringAsFixed(2)} GPA',
                          Icons.star_rounded,
                          const Color(0xFFFFBE0B),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildHighlightCard(
                          'Current CGPA',
                          cgpa.toStringAsFixed(2),
                          GpaCalculator.getClassification(cgpa),
                          Icons.grade_rounded,
                          const Color(0xFF6C63FF),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Improvement indicator
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: improvColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: improvColor.withOpacity(0.3), width: 1),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.trending_up_rounded,
                            color: improvColor, size: 22),
                        const SizedBox(width: 12),
                        Text(improvement,
                            style: TextStyle(
                                color: improvColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── GPA Trend Line Chart ───────────────────────
                  _buildSectionTitle('GPA Trend (Semester-wise)'),
                  const SizedBox(height: 12),
                  _buildChartCard(
                    child: SizedBox(
                      height: 180,
                      child: LineChart(
                        LineChartData(
                          minY: 0,
                          maxY: 10,
                          lineTouchData: LineTouchData(
                            touchTooltipData: LineTouchTooltipData(
                              getTooltipItems: (spots) => spots
                                  .map((s) => LineTooltipItem(
                                        'Sem ${s.x.toInt()}: ${s.y.toStringAsFixed(2)}',
                                        const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12),
                                      ))
                                  .toList(),
                            ),
                          ),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 2,
                                reservedSize: 30,
                                getTitlesWidget: (v, _) => Text(
                                    v.toInt().toString(),
                                    style: const TextStyle(
                                        color: Color(0xFF8B92B8),
                                        fontSize: 10)),
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (v, _) => Text(
                                    'S${v.toInt()}',
                                    style: const TextStyle(
                                        color: Color(0xFF8B92B8),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600)),
                              ),
                            ),
                            topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                          ),
                          gridData: FlGridData(
                            show: true,
                            horizontalInterval: 2,
                            getDrawingHorizontalLine: (v) => FlLine(
                                color: const Color(0xFF2D3470), strokeWidth: 1),
                            drawVerticalLine: false,
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: gpaTrend
                                  .map((e) => FlSpot(
                                      (e['semester'] as int).toDouble(),
                                      (e['gpa'] as double)))
                                  .toList(),
                              isCurved: true,
                              color: const Color(0xFF6C63FF),
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, _, __, ___) =>
                                    FlDotCirclePainter(
                                  radius: 5,
                                  color: const Color(0xFF6C63FF),
                                  strokeWidth: 2,
                                  strokeColor: Colors.white,
                                ),
                              ),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    const Color(0xFF6C63FF).withOpacity(0.3),
                                    const Color(0xFF6C63FF).withOpacity(0.0),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── CGPA Growth Chart ──────────────────────────
                  _buildSectionTitle('CGPA Growth'),
                  const SizedBox(height: 12),
                  _buildChartCard(
                    child: SizedBox(
                      height: 160,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: 10,
                          minY: 0,
                          barTouchData: BarTouchData(
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipItem: (group, _, rod, __) =>
                                  BarTooltipItem(
                                'Sem ${group.x}: ${rod.toY.toStringAsFixed(2)}',
                                const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12),
                              ),
                            ),
                          ),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 2,
                                reservedSize: 30,
                                getTitlesWidget: (v, _) => Text(
                                    v.toInt().toString(),
                                    style: const TextStyle(
                                        color: Color(0xFF8B92B8),
                                        fontSize: 10)),
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (v, _) => Text(
                                    'S${v.toInt()}',
                                    style: const TextStyle(
                                        color: Color(0xFF8B92B8),
                                        fontSize: 11)),
                              ),
                            ),
                            topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                          ),
                          gridData: FlGridData(
                            show: true,
                            horizontalInterval: 2,
                            getDrawingHorizontalLine: (v) => FlLine(
                                color: const Color(0xFF2D3470), strokeWidth: 1),
                            drawVerticalLine: false,
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: cgpaGrowth
                              .map((e) => BarChartGroupData(
                                    x: e['semester'] as int,
                                    barRods: [
                                      BarChartRodData(
                                        toY: e['cgpa'] as double,
                                        width: 32,
                                        borderRadius:
                                            const BorderRadius.vertical(
                                                top: Radius.circular(6)),
                                        gradient: const LinearGradient(
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                          colors: [
                                            Color(0xFF4ECDC4),
                                            Color(0xFF6C63FF)
                                          ],
                                        ),
                                      ),
                                    ],
                                  ))
                              .toList(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Arrear History ─────────────────────────────
                  _buildSectionTitle('Arrear History'),
                  const SizedBox(height: 12),
                  _buildChartCard(
                    child: Column(
                      children: arrearHistory.map((e) {
                        final sem = e['semester'] as int;
                        final count = e['arrears'] as int;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 50,
                                child: Text('Sem $sem',
                                    style: const TextStyle(
                                        color: Color(0xFF8B92B8),
                                        fontSize: 12)),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: LinearProgressIndicator(
                                    value: count == 0 ? 1.0 : (count / 5).clamp(0.1, 1.0),
                                    backgroundColor: count == 0
                                        ? const Color(0xFF43A047).withOpacity(0.15)
                                        : const Color(0xFFE53935).withOpacity(0.15),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      count == 0
                                          ? const Color(0xFF43A047)
                                          : const Color(0xFFE53935),
                                    ),
                                    minHeight: 10,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                count == 0 ? 'Clear' : '$count',
                                style: TextStyle(
                                    color: count == 0
                                        ? const Color(0xFF43A047)
                                        : const Color(0xFFE53935),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title,
        style: const TextStyle(
            color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold));
  }

  Widget _buildChartCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F4E),
        borderRadius: BorderRadius.circular(18),
      ),
      child: child,
    );
  }

  Widget _buildHighlightCard(String title, String value, String subtitle,
      IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F4E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 22, fontWeight: FontWeight.bold)),
          Text(subtitle,
              style: const TextStyle(color: Color(0xFF8B92B8), fontSize: 11)),
          const SizedBox(height: 4),
          Text(title,
              style: const TextStyle(color: Colors.white, fontSize: 13)),
        ],
      ),
    );
  }
}