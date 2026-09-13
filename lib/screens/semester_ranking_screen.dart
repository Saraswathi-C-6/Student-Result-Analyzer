import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/gpa_calculator.dart';

/// Shows per-semester GPA ranking and overall CGPA ranking for all students.
class SemesterRankingScreen extends StatefulWidget {
  const SemesterRankingScreen({super.key});

  @override
  State<SemesterRankingScreen> createState() => _SemesterRankingScreenState();
}

class _SemesterRankingScreenState extends State<SemesterRankingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedSemester = 1;
  bool _isLoading = true;

  // semRankings[sem] = sorted list of {studentId, name, regNo, gpa, rank}
  final Map<int, List<Map<String, dynamic>>> _semRankings = {};
  List<Map<String, dynamic>> _cgpaRankings = [];
  List<int> _availableSemesters = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadRankings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRankings() async {
    setState(() => _isLoading = true);
    try {
      // Fetch all results
      final resultsSnap =
          await FirebaseFirestore.instance.collection('results').get();

      // Fetch all students for name lookup
      final studentsSnap =
          await FirebaseFirestore.instance.collection('students').get();
      final studentMap = <String, Map<String, dynamic>>{};
      for (final doc in studentsSnap.docs) {
        studentMap[doc.id] = doc.data();
      }

      // Group results by studentId and semester
      final Map<String, Map<int, List<Map<String, dynamic>>>> byStudentBySem =
          {};
      final Set<int> semesters = {};

      for (final doc in resultsSnap.docs) {
        final data = doc.data();
        final sid = data['studentId'] as String? ?? '';
        final sem = (data['semester'] as num?)?.toInt() ?? 1;
        if (sid.isEmpty) continue;
        semesters.add(sem);
        byStudentBySem.putIfAbsent(sid, () => {});
        byStudentBySem[sid]!.putIfAbsent(sem, () => []);
        byStudentBySem[sid]![sem]!.add(data);
      }

      final sortedSems = semesters.toList()..sort();

      // Build per-semester GPA rankings
      final semRankings = <int, List<Map<String, dynamic>>>{};
      for (final sem in sortedSems) {
        final list = <Map<String, dynamic>>[];
        byStudentBySem.forEach((sid, bySem) {
          if (!bySem.containsKey(sem)) return;
          final gpa = GpaCalculator.calculateGPA(bySem[sem]!);
          final student = studentMap[sid] ?? {};
          list.add({
            'studentId': sid,
            'name': student['name'] ?? 'Unknown',
            'regNo': student['regNo'] ?? sid,
            'gpa': gpa,
            'arrears': bySem[sem]!
                .where((r) => !GpaCalculator.isPassed(r['grade'] ?? 'F'))
                .length,
          });
        });
        list.sort((a, b) => (b['gpa'] as double).compareTo(a['gpa'] as double));
        for (int i = 0; i < list.length; i++) {
          list[i]['rank'] = i + 1;
        }
        semRankings[sem] = list;
      }

      // Build CGPA rankings
      final cgpaList = <Map<String, dynamic>>[];
      byStudentBySem.forEach((sid, bySem) {
        final allResults = bySem.values.expand((l) => l).toList();
        final cgpa = GpaCalculator.calculateCGPA(allResults);
        final student = studentMap[sid] ?? {};
        final totalArrears = allResults
            .where((r) => !GpaCalculator.isPassed(r['grade'] ?? 'F'))
            .length;
        cgpaList.add({
          'studentId': sid,
          'name': student['name'] ?? 'Unknown',
          'regNo': student['regNo'] ?? sid,
          'cgpa': cgpa,
          'classification': GpaCalculator.getClassification(cgpa),
          'totalSubjects': allResults.length,
          'arrears': totalArrears,
          'completedSemesters': bySem.keys.length,
        });
      });
      cgpaList
          .sort((a, b) => (b['cgpa'] as double).compareTo(a['cgpa'] as double));
      for (int i = 0; i < cgpaList.length; i++) {
        cgpaList[i]['rank'] = i + 1;
      }

      setState(() {
        _semRankings.clear();
        _semRankings.addAll(semRankings);
        _cgpaRankings = cgpaList;
        _availableSemesters = sortedSems;
        if (sortedSems.isNotEmpty) _selectedSemester = sortedSems.first;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1F4E),
        title: const Text('Rankings',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF4ECDC4)),
            onPressed: _loadRankings,
            tooltip: 'Refresh',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF6C63FF),
          labelColor: const Color(0xFF6C63FF),
          unselectedLabelColor: const Color(0xFF8B92B8),
          tabs: const [
            Tab(text: 'Semester GPA'),
            Tab(text: 'Overall CGPA'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildSemesterTab(),
                _buildCgpaTab(),
              ],
            ),
    );
  }

  // ── Semester GPA Tab ──────────────────────────────────────────────
  Widget _buildSemesterTab() {
    if (_availableSemesters.isEmpty) {
      return _emptyState('No results found.\nUpload student PDFs first.');
    }

    final rankings = _semRankings[_selectedSemester] ?? [];

    return Column(
      children: [
        // Semester selector chips
        Container(
          color: const Color(0xFF1A1F4E),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _availableSemesters.map((sem) {
                final isSelected = _selectedSemester == sem;
                return GestureDetector(
                  onTap: () => setState(() => _selectedSemester = sem),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF6C63FF)
                          : const Color(0xFF0A0E27),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF6C63FF)
                            : const Color(0xFF2D3470),
                      ),
                    ),
                    child: Text('Sem $sem',
                        style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF8B92B8),
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 13)),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        if (rankings.isEmpty)
          Expanded(
              child: _emptyState(
                  'No results for Semester $_selectedSemester yet.'))
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: rankings.length,
              itemBuilder: (ctx, i) =>
                  _SemRankTile(entry: rankings[i], index: i),
            ),
          ),
      ],
    );
  }

  // ── CGPA Tab ──────────────────────────────────────────────────────
  Widget _buildCgpaTab() {
    if (_cgpaRankings.isEmpty) {
      return _emptyState('No results found.\nUpload student PDFs first.');
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _cgpaRankings.length,
      itemBuilder: (ctx, i) => _CgpaRankTile(entry: _cgpaRankings[i], index: i),
    );
  }

  Widget _emptyState(String msg) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.leaderboard_rounded,
              color: Color(0xFF2D3470), size: 60),
          const SizedBox(height: 12),
          Text(msg,
              style: const TextStyle(color: Color(0xFF8B92B8)),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ── Semester Rank Tile ────────────────────────────────────────────────
class _SemRankTile extends StatelessWidget {
  final Map<String, dynamic> entry;
  final int index;
  const _SemRankTile({required this.entry, required this.index});

  @override
  Widget build(BuildContext context) {
    final rank = entry['rank'] as int;
    final gpa = (entry['gpa'] as double);
    final arrears = entry['arrears'] as int;

    Color rankColor;
    IconData rankIcon;
    if (rank == 1) {
      rankColor = const Color(0xFFFFD700);
      rankIcon = Icons.emoji_events_rounded;
    } else if (rank == 2) {
      rankColor = const Color(0xFFC0C0C0);
      rankIcon = Icons.emoji_events_rounded;
    } else if (rank == 3) {
      rankColor = const Color(0xFFCD7F32);
      rankIcon = Icons.emoji_events_rounded;
    } else {
      rankColor = const Color(0xFF4A5180);
      rankIcon = Icons.person_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:
            rank <= 3 ? rankColor.withOpacity(0.07) : const Color(0xFF1A1F4E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color:
              rank <= 3 ? rankColor.withOpacity(0.3) : const Color(0xFF2D3470),
          width: rank <= 3 ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          // Rank badge
          SizedBox(
            width: 36,
            child: rank <= 3
                ? Icon(rankIcon, color: rankColor, size: 28)
                : Center(
                    child: Text('#$rank',
                        style: const TextStyle(
                            color: Color(0xFF8B92B8),
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                  ),
          ),
          const SizedBox(width: 10),
          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFF6C63FF).withOpacity(0.15),
            child: Text(
              (entry['name'] as String).isNotEmpty
                  ? (entry['name'] as String)[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                  color: Color(0xFF6C63FF), fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          // Name + RegNo
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry['name'] as String,
                    style: TextStyle(
                        color: rank <= 3 ? rankColor : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                Text(entry['regNo'] as String,
                    style: const TextStyle(
                        color: Color(0xFF8B92B8), fontSize: 11)),
              ],
            ),
          ),
          // GPA + arrears
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(gpa.toStringAsFixed(2),
                  style: TextStyle(
                      color: rank <= 3 ? rankColor : const Color(0xFF6C63FF),
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
              Text('GPA',
                  style:
                      const TextStyle(color: Color(0xFF8B92B8), fontSize: 10)),
              if (arrears > 0)
                Text('$arrears arrear${arrears > 1 ? 's' : ''}',
                    style: const TextStyle(
                        color: Color(0xFFE53935), fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── CGPA Rank Tile ────────────────────────────────────────────────────
class _CgpaRankTile extends StatelessWidget {
  final Map<String, dynamic> entry;
  final int index;
  const _CgpaRankTile({required this.entry, required this.index});

  @override
  Widget build(BuildContext context) {
    final rank = entry['rank'] as int;
    final cgpa = (entry['cgpa'] as double);
    final classification = entry['classification'] as String;
    final arrears = entry['arrears'] as int;
    final sems = entry['completedSemesters'] as int;

    Color rankColor;
    if (rank == 1) {
      rankColor = const Color(0xFFFFD700);
    } else if (rank == 2) {
      rankColor = const Color(0xFFC0C0C0);
    } else if (rank == 3) {
      rankColor = const Color(0xFFCD7F32);
    } else {
      rankColor = const Color(0xFF6C63FF);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:
            rank <= 3 ? rankColor.withOpacity(0.07) : const Color(0xFF1A1F4E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color:
              rank <= 3 ? rankColor.withOpacity(0.3) : const Color(0xFF2D3470),
          width: rank <= 3 ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          // Rank badge
          SizedBox(
            width: 36,
            child: rank <= 3
                ? Icon(Icons.emoji_events_rounded, color: rankColor, size: 28)
                : Center(
                    child: Text('#$rank',
                        style: const TextStyle(
                            color: Color(0xFF8B92B8),
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                  ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 20,
            backgroundColor: rankColor.withOpacity(0.15),
            child: Text(
              (entry['name'] as String).isNotEmpty
                  ? (entry['name'] as String)[0].toUpperCase()
                  : '?',
              style: TextStyle(color: rankColor, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry['name'] as String,
                    style: TextStyle(
                        color: rank <= 3 ? rankColor : Colors.white,
                        fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Text(entry['regNo'] as String,
                        style: const TextStyle(
                            color: Color(0xFF8B92B8), fontSize: 11)),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C63FF).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(classification,
                          style: const TextStyle(
                              color: Color(0xFF6C63FF), fontSize: 10)),
                    ),
                  ],
                ),
                Text('$sems sem${sems != 1 ? 's' : ''} completed',
                    style: const TextStyle(
                        color: Color(0xFF4A5180), fontSize: 10)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(cgpa.toStringAsFixed(2),
                  style: TextStyle(
                      color: rank <= 3 ? rankColor : const Color(0xFF4ECDC4),
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
              const Text('CGPA',
                  style: TextStyle(color: Color(0xFF8B92B8), fontSize: 10)),
              if (arrears > 0)
                Text('$arrears arrear${arrears > 1 ? 's' : ''}',
                    style: const TextStyle(
                        color: Color(0xFFE53935), fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}
