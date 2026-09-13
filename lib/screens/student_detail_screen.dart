import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/gpa_calculator.dart';

class StudentDetailScreen extends StatefulWidget {
  final String studentId;
  final Map<String, dynamic> studentData;
  const StudentDetailScreen({
    super.key,
    required this.studentId,
    required this.studentData,
  });

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> allResults = [];
  bool isLoading = true;
  String studentId = '';
  Map<String, dynamic> studentData = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    studentId = widget.studentId;
    studentData = widget.studentData;
    _loadResults();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadResults() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('results')
          .where('studentId', isEqualTo: studentId)
          .get();
      setState(() {
        allResults = snap.docs.map((d) => d.data()).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  List<Map<String, dynamic>> _getResultsForSemester(int sem) {
    return allResults.where((r) => r['semester'] == sem).toList();
  }

  @override
  Widget build(BuildContext context) {
    final name = studentData['name'] ?? 'Student';
    final regNo = studentData['regNo'] ?? '';
    final dept = studentData['department'] ?? '';
    final batch = studentData['batch'] ?? '';

    final cgpa = GpaCalculator.calculateCGPA(allResults);
    final classification = GpaCalculator.getClassification(cgpa);
    final totalCredits = GpaCalculator.totalCreditsEarned(allResults);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
          : NestedScrollView(
              headerSliverBuilder: (context, innerBoxScrolled) => [
                SliverAppBar(
                  expandedHeight: 260,
                  pinned: true,
                  backgroundColor: const Color(0xFF1A1F4E),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_rounded,
                        color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.add_chart_rounded,
                          color: Color(0xFF4ECDC4)),
                      onPressed: () =>
                          Navigator.pushNamed(context, '/add-result')
                              .then((_) => _loadResults()),
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF1A1F4E), Color(0xFF0A0E27)],
                        ),
                      ),
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 44),
                              Row(
                                children: [
                                  Container(
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(colors: [
                                        Color(0xFF6C63FF),
                                        Color(0xFF4ECDC4)
                                      ]),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Center(
                                      child: Text(
                                        name.isNotEmpty
                                            ? name[0].toUpperCase()
                                            : '?',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(name,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 4),
                                        Text(regNo,
                                            style: const TextStyle(
                                                color: Color(0xFF6C63FF),
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500)),
                                        Text('$dept • $batch',
                                            style: const TextStyle(
                                                color: Color(0xFF8B92B8),
                                                fontSize: 13)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  _buildStat('CGPA', cgpa.toStringAsFixed(2),
                                      const Color(0xFF6C63FF)),
                                  const SizedBox(width: 12),
                                  _buildStat(
                                      'Credits',
                                      totalCredits.toStringAsFixed(0),
                                      const Color(0xFF4ECDC4)),
                                  const SizedBox(width: 12),
                                  _buildStat('Class', classification,
                                      const Color(0xFFFFBE0B)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  bottom: TabBar(
                    controller: _tabController,
                    indicatorColor: const Color(0xFF6C63FF),
                    labelColor: const Color(0xFF6C63FF),
                    unselectedLabelColor: const Color(0xFF8B92B8),
                    tabs: const [
                      Tab(text: 'Sem 1'),
                      Tab(text: 'Sem 2'),
                      Tab(text: 'Sem 3'),
                      Tab(text: 'Sem 4'),
                    ],
                  ),
                ),
              ],
              body: TabBarView(
                controller: _tabController,
                children:
                    [1, 2, 3, 4].map((sem) => _buildSemesterTab(sem)).toList(),
              ),
            ),
    );
  }

  Widget _buildStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    color: color,
                    fontSize: value.length > 6 ? 11 : 16,
                    fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(color: Color(0xFF8B92B8), fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildSemesterTab(int sem) {
    final results = _getResultsForSemester(sem);
    final gpa = GpaCalculator.calculateGPA(results);
    final credits = results.fold<double>(
        0, (sum, r) => sum + (r['credits'] ?? 0).toDouble());

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.assignment_outlined,
                color: Color(0xFF8B92B8), size: 60),
            const SizedBox(height: 12),
            Text('No results for Semester $sem',
                style: const TextStyle(color: Color(0xFF8B92B8), fontSize: 16)),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/add-result')
                  .then((_) => _loadResults()),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Add Result',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    // Count pass/fail
    final passed =
        results.where((r) => GpaCalculator.isPassed(r['grade'] ?? '')).length;
    final failed = results.length - passed;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // GPA Summary Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildGPAStat('GPA', gpa.toStringAsFixed(2)),
                _buildGPAStat('Credits', credits.toStringAsFixed(0)),
                _buildGPAStat('Passed', '$passed'),
                _buildGPAStat('Failed', '$failed'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Results Table
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A1F4E),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                // Table Header
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                          width: 48,
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
                          width: 40,
                          child: Text('GP',
                              style: TextStyle(
                                  color: Color(0xFF8B92B8),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600),
                              textAlign: TextAlign.center)),
                      SizedBox(
                          width: 44,
                          child: Text('Status',
                              style: TextStyle(
                                  color: Color(0xFF8B92B8),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600),
                              textAlign: TextAlign.center)),
                    ],
                  ),
                ),
                const Divider(
                    color: Color(0xFF2D3470), height: 1, thickness: 1),
                // Result rows
                ...results.asMap().entries.map((entry) {
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
                                          fontSize: 12,
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
                              width: 48,
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
                                    horizontal: 8, vertical: 4),
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
                              width: 40,
                              child: Text((r['gradePoint'] ?? 0).toString(),
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 13),
                                  textAlign: TextAlign.center),
                            ),
                            SizedBox(
                              width: 44,
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
                      if (i < results.length - 1)
                        const Divider(
                            color: Color(0xFF2D3470),
                            height: 1,
                            thickness: 0.5,
                            indent: 16,
                            endIndent: 16),
                    ],
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildGPAStat(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}
