import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../utils/gpa_calculator.dart';

class AnalyticsScreen extends StatefulWidget {
  final String studentId;
  final String studentName;
  final List<Map<String, dynamic>> allResults;

  const AnalyticsScreen({
    super.key,
    required this.studentId,
    required this.studentName,
    required this.allResults,
  });

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int touchedIndex = -1;

  List<Map<String, dynamic>> _getSemResults(int sem) =>
      widget.allResults.where((r) => r['semester'] == sem).toList();

  List<double> get _semGPAs => [1, 2, 3, 4]
      .map((s) => GpaCalculator.calculateGPA(_getSemResults(s)))
      .toList();

  double get _cgpa => GpaCalculator.calculateCGPA(widget.allResults);

  Map<String, int> get _gradeDistribution {
    final map = <String, int>{};
    for (var r in widget.allResults) {
      final g = r['grade'] ?? 'F';
      map[g] = (map[g] ?? 0) + 1;
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0A0E27) : const Color(0xFFF4F6FF);
    final cardBg = isDark ? const Color(0xFF1A1F4E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF2D3142);
    final subColor = isDark ? const Color(0xFF8B92B8) : const Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1A1F4E) : Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Analytics',
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Student header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        widget.studentName.isNotEmpty
                            ? widget.studentName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.studentName,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        Text(
                          'CGPA: ${_cgpa.toStringAsFixed(2)} — ${GpaCalculator.getClassification(_cgpa)}',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // GPA Bar Chart
            _buildSectionTitle('Semester-wise GPA', textColor),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 200,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: 10,
                        minY: 0,
                        barTouchData: BarTouchData(
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              return BarTooltipItem(
                                'Sem ${group.x + 1}\n${rod.toY.toStringAsFixed(2)}',
                                const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13),
                              );
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 2,
                              reservedSize: 32,
                              getTitlesWidget: (v, meta) => Text(
                                v.toInt().toString(),
                                style: TextStyle(color: subColor, fontSize: 11),
                              ),
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (v, meta) => Text(
                                'S${v.toInt() + 1}',
                                style: TextStyle(
                                    color: subColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600),
                              ),
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
                            color: subColor.withOpacity(0.15),
                            strokeWidth: 1,
                          ),
                          drawVerticalLine: false,
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: _semGPAs.asMap().entries.map((e) {
                          final gpa = e.value;
                          final color = _gpaColor(gpa);
                          return BarChartGroupData(
                            x: e.key,
                            barRods: [
                              BarChartRodData(
                                toY: gpa,
                                width: 36,
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(8)),
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    color.withOpacity(0.6),
                                    color,
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: _semGPAs.asMap().entries.map((e) {
                      final hasData = _getSemResults(e.key + 1).isNotEmpty;
                      return Column(
                        children: [
                          Text(
                            hasData ? e.value.toStringAsFixed(2) : '--',
                            style: TextStyle(
                                color: hasData ? _gpaColor(e.value) : subColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 15),
                          ),
                          Text('Sem ${e.key + 1}',
                              style: TextStyle(color: subColor, fontSize: 11)),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Grade Distribution Pie Chart
            _buildSectionTitle('Grade Distribution', textColor),
            const SizedBox(height: 12),
            if (widget.allResults.isEmpty)
              _buildNoData(cardBg, subColor)
            else
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: SizedBox(
                  height: 220,
                  child: Row(
                    children: [
                      Expanded(
                        child: PieChart(
                          PieChartData(
                            pieTouchData: PieTouchData(
                              touchCallback: (event, response) {
                                setState(() {
                                  if (!event.isInterestedForInteractions ||
                                      response == null ||
                                      response.touchedSection == null) {
                                    touchedIndex = -1;
                                    return;
                                  }
                                  touchedIndex = response
                                      .touchedSection!.touchedSectionIndex;
                                });
                              },
                            ),
                            sectionsSpace: 3,
                            centerSpaceRadius: 40,
                            sections: _buildPieSections(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _gradeDistribution.entries.map((e) {
                          final color = Color(GpaCalculator.gradeColor(e.key));
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Grade ${e.key}: ${e.value}',
                                  style:
                                      TextStyle(color: textColor, fontSize: 13),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),

            // GPA Trend Line Chart
            _buildSectionTitle('GPA Trend', textColor),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
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
                                  'Sem ${s.x.toInt()}\nGPA: ${s.y.toStringAsFixed(2)}',
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
                          reservedSize: 32,
                          getTitlesWidget: (v, meta) => Text(
                            v.toInt().toString(),
                            style: TextStyle(color: subColor, fontSize: 11),
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, meta) => Text(
                            'S${v.toInt()}',
                            style: TextStyle(
                                color: subColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                          ),
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
                        color: subColor.withOpacity(0.15),
                        strokeWidth: 1,
                      ),
                      drawVerticalLine: false,
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: _semGPAs.asMap().entries.map((e) {
                          return FlSpot((e.key + 1).toDouble(), e.value);
                        }).toList(),
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
                      LineChartBarData(
                        spots: [
                          FlSpot(1, _cgpa),
                          FlSpot(4, _cgpa),
                        ],
                        isCurved: false,
                        color: const Color(0xFF4ECDC4).withOpacity(0.6),
                        barWidth: 1.5,
                        dashArray: [6, 4],
                        dotData: const FlDotData(show: false),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildLegend(
                    'GPA per Semester', const Color(0xFF6C63FF), textColor),
                const SizedBox(width: 20),
                _buildLegend('CGPA (${_cgpa.toStringAsFixed(2)})',
                    const Color(0xFF4ECDC4), textColor,
                    dashed: true),
              ],
            ),
            const SizedBox(height: 20),

            // Subject Performance
            _buildSectionTitle('Subject Performance', textColor),
            const SizedBox(height: 12),
            if (widget.allResults.isEmpty)
              _buildNoData(cardBg, subColor)
            else
              Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  children: widget.allResults.asMap().entries.map((entry) {
                    final r = entry.value;
                    final grade = r['grade'] ?? 'F';
                    final gp = (r['gradePoint'] ?? 0) as num;
                    final color = Color(GpaCalculator.gradeColor(grade));
                    final sem = r['semester'] ?? 0;
                    final isLast = entry.key == widget.allResults.length - 1;
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(r['subjectName'] ?? '',
                                        style: TextStyle(
                                            color: textColor,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                    Text('${r['subjectCode'] ?? ''} • Sem $sem',
                                        style: TextStyle(
                                            color: subColor, fontSize: 11)),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              SizedBox(
                                width: 80,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('$gp/10',
                                        style: TextStyle(
                                            color: color,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: gp.toDouble() / 10,
                                        backgroundColor:
                                            color.withOpacity(0.15),
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                color),
                                        minHeight: 6,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(grade,
                                    style: TextStyle(
                                        color: color,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14)),
                              ),
                            ],
                          ),
                        ),
                        if (!isLast)
                          Divider(
                              color: subColor.withOpacity(0.15),
                              height: 1,
                              indent: 16,
                              endIndent: 16),
                      ],
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

  List<PieChartSectionData> _buildPieSections() {
    final entries = _gradeDistribution.entries.toList();
    return entries.asMap().entries.map((e) {
      final isTouched = e.key == touchedIndex;
      final grade = e.value.key;
      final count = e.value.value;
      final color = Color(GpaCalculator.gradeColor(grade));
      return PieChartSectionData(
        color: color,
        value: count.toDouble(),
        title: '$grade\n$count',
        radius: isTouched ? 70 : 58,
        titleStyle: TextStyle(
          fontSize: isTouched ? 14 : 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Color _gpaColor(double gpa) {
    if (gpa >= 9.0) return const Color(0xFF6C63FF);
    if (gpa >= 8.0) return const Color(0xFF4ECDC4);
    if (gpa >= 7.0) return const Color(0xFF43A047);
    if (gpa >= 6.0) return const Color(0xFFFFBE0B);
    if (gpa >= 5.0) return const Color(0xFFFF9800);
    return const Color(0xFFE53935);
  }

  Widget _buildSectionTitle(String title, Color textColor) {
    return Text(title,
        style: TextStyle(
            color: textColor, fontSize: 16, fontWeight: FontWeight.bold));
  }

  Widget _buildNoData(Color cardBg, Color subColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text('No results yet to analyze',
            style: TextStyle(color: subColor, fontSize: 14)),
      ),
    );
  }

  Widget _buildLegend(String label, Color color, Color textColor,
      {bool dashed = false}) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(color: textColor, fontSize: 12)),
      ],
    );
  }
}
