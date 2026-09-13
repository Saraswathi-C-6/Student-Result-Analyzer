// import 'package:flutter/material.dart';
// import '../utils/gpa_calculator.dart';
// import '../services/student_result_service.dart';

// class RankDetailsScreen extends StatefulWidget {
//   final String studentId;
//   final String studentName;
//   final List<Map<String, dynamic>> allResults;

//   const RankDetailsScreen({
//     super.key,
//     required this.studentId,
//     required this.studentName,
//     required this.allResults,
//   });

//   @override
//   State<RankDetailsScreen> createState() => _RankDetailsScreenState();
// }

// class _RankDetailsScreenState extends State<RankDetailsScreen> {
//   final StudentResultService _service = StudentResultService();
//   Map<String, dynamic> overallRankData = {};
//   Map<String, dynamic> currentSemRankData = {};
//   Map<String, dynamic> prevSemRankData = {};
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadRankData();
//   }

//   Future<void> _loadRankData() async {
//     try {
//       final sems = _service.getCompletedSemesters(widget.allResults);
//       overallRankData = await _service.calculateOverallRank(widget.studentId);

//       if (sems.isNotEmpty) {
//         currentSemRankData =
//             await _service.calculateRank(widget.studentId, sems.last);
//       }
//       if (sems.length >= 2) {
//         prevSemRankData = await _service.calculateRank(
//             widget.studentId, sems[sems.length - 2]);
//       }

//       if (mounted) setState(() => isLoading = false);
//     } catch (_) {
//       if (mounted) setState(() => isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final cgpa = GpaCalculator.calculateCGPA(widget.allResults);
//     final sems = _service.getCompletedSemesters(widget.allResults);

//     return Scaffold(
//       backgroundColor: const Color(0xFF0A0E27),
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF1A1F4E),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text('Rank Details',
//             style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//         elevation: 0,
//       ),
//       body: isLoading
//           ? const Center(
//               child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
//           : SingleChildScrollView(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // ── Overall Rank Card ────────────────────────
//                   Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.all(24),
//                     decoration: BoxDecoration(
//                       gradient: const LinearGradient(
//                         colors: [Color(0xFFFFBE0B), Color(0xFFFF9800)],
//                       ),
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Column(
//                       children: [
//                         const Icon(Icons.emoji_events_rounded,
//                             color: Colors.white, size: 40),
//                         const SizedBox(height: 8),
//                         const Text('Overall Rank (CGPA)',
//                             style:
//                                 TextStyle(color: Colors.white70, fontSize: 13)),
//                         const SizedBox(height: 4),
//                         Text(
//                           overallRankData.isNotEmpty
//                               ? '#${overallRankData['rank']}'
//                               : '--',
//                           style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 52,
//                               fontWeight: FontWeight.bold),
//                         ),
//                         Text(
//                           overallRankData.isNotEmpty
//                               ? 'out of ${overallRankData['totalStudents']} students'
//                               : '',
//                           style: const TextStyle(
//                               color: Colors.white70, fontSize: 13),
//                         ),
//                         const SizedBox(height: 16),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceAround,
//                           children: [
//                             _buildTopStat('Your CGPA', cgpa.toStringAsFixed(2)),
//                             _buildTopStat(
//                                 'Topper CGPA',
//                                 overallRankData.isNotEmpty
//                                     ? (overallRankData['topperCgpa'] as double)
//                                         .toStringAsFixed(2)
//                                     : '--'),
//                             _buildTopStat(
//                                 'Gap',
//                                 overallRankData.isNotEmpty
//                                     ? '-${(overallRankData['gapFromTopper'] as double).toStringAsFixed(2)}'
//                                     : '--'),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 16),

//                   // ── Semester Rank Comparison ─────────────────
//                   if (sems.isNotEmpty) ...[
//                     Row(
//                       children: [
//                         Expanded(
//                           child: _buildRankCard(
//                             label: 'Current Sem Rank',
//                             semester: sems.last,
//                             rankData: currentSemRankData,
//                             color: const Color(0xFF6C63FF),
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: _buildRankCard(
//                             label: 'Previous Sem Rank',
//                             semester:
//                                 sems.length >= 2 ? sems[sems.length - 2] : 0,
//                             rankData: prevSemRankData,
//                             color: const Color(0xFF4ECDC4),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 20),
//                   ],

//                   // ── Leaderboard ──────────────────────────────
//                   const Text('Top 5 Leaderboard',
//                       style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold)),
//                   const SizedBox(height: 12),

//                   if (overallRankData.isEmpty ||
//                       (overallRankData['top5'] as List).isEmpty)
//                     Container(
//                       padding: const EdgeInsets.all(24),
//                       decoration: BoxDecoration(
//                         color: const Color(0xFF1A1F4E),
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       child: const Center(
//                         child: Text('Leaderboard data not available',
//                             style: TextStyle(color: Color(0xFF8B92B8))),
//                       ),
//                     )
//                   else
//                     Container(
//                       decoration: BoxDecoration(
//                         color: const Color(0xFF1A1F4E),
//                         borderRadius: BorderRadius.circular(18),
//                       ),
//                       child: Column(
//                         children: [
//                           // Header
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 16, vertical: 12),
//                             decoration: const BoxDecoration(
//                               color: Color(0xFF2D3470),
//                               borderRadius: BorderRadius.vertical(
//                                   top: Radius.circular(18)),
//                             ),
//                             child: Row(
//                               children: const [
//                                 SizedBox(
//                                     width: 40,
//                                     child: Text('Rank',
//                                         style: TextStyle(
//                                             color: Color(0xFF8B92B8),
//                                             fontSize: 12,
//                                             fontWeight: FontWeight.w600),
//                                         textAlign: TextAlign.center)),
//                                 SizedBox(width: 8),
//                                 Expanded(
//                                     child: Text('Student',
//                                         style: TextStyle(
//                                             color: Color(0xFF8B92B8),
//                                             fontSize: 12,
//                                             fontWeight: FontWeight.w600))),
//                                 SizedBox(
//                                     width: 60,
//                                     child: Text('CGPA',
//                                         style: TextStyle(
//                                             color: Color(0xFF8B92B8),
//                                             fontSize: 12,
//                                             fontWeight: FontWeight.w600),
//                                         textAlign: TextAlign.center)),
//                               ],
//                             ),
//                           ),

//                           // Rows
//                           ...(overallRankData['top5'] as List)
//                               .asMap()
//                               .entries
//                               .map((entry) {
//                             final idx = entry.key;
//                             final s = entry.value as Map<String, dynamic>;
//                             final rank = s['rank'] as int;
//                             final isCurrentStudent =
//                                 s['studentId'] == widget.studentId;
//                             final rankColors = [
//                               const Color(0xFFFFBE0B),
//                               const Color(0xFF8B92B8),
//                               const Color(0xFFFF9800),
//                               Colors.white,
//                               Colors.white,
//                             ];
//                             final rankColor = rankColors[idx < 5 ? idx : 4];

//                             return Column(
//                               children: [
//                                 Container(
//                                   color: isCurrentStudent
//                                       ? const Color(0xFF6C63FF).withOpacity(0.1)
//                                       : Colors.transparent,
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 16, vertical: 12),
//                                   child: Row(
//                                     children: [
//                                       SizedBox(
//                                         width: 40,
//                                         child: rank <= 3
//                                             ? Icon(
//                                                 Icons.emoji_events_rounded,
//                                                 color: rankColor,
//                                                 size: 20,
//                                               )
//                                             : Text('$rank',
//                                                 style: TextStyle(
//                                                     color: rankColor,
//                                                     fontWeight: FontWeight.bold,
//                                                     fontSize: 14),
//                                                 textAlign: TextAlign.center),
//                                       ),
//                                       const SizedBox(width: 8),
//                                       Expanded(
//                                         child: Column(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           children: [
//                                             Row(
//                                               children: [
//                                                 Text(
//                                                   s['name'] ?? 'Unknown',
//                                                   style: TextStyle(
//                                                       color: isCurrentStudent
//                                                           ? const Color(
//                                                               0xFF6C63FF)
//                                                           : Colors.white,
//                                                       fontWeight:
//                                                           isCurrentStudent
//                                                               ? FontWeight.bold
//                                                               : FontWeight
//                                                                   .normal,
//                                                       fontSize: 14),
//                                                 ),
//                                                 if (isCurrentStudent) ...[
//                                                   const SizedBox(width: 6),
//                                                   Container(
//                                                     padding: const EdgeInsets
//                                                         .symmetric(
//                                                         horizontal: 6,
//                                                         vertical: 2),
//                                                     decoration: BoxDecoration(
//                                                       color: const Color(
//                                                               0xFF6C63FF)
//                                                           .withOpacity(0.2),
//                                                       borderRadius:
//                                                           BorderRadius.circular(
//                                                               6),
//                                                     ),
//                                                     child: const Text('You',
//                                                         style: TextStyle(
//                                                             color: Color(
//                                                                 0xFF6C63FF),
//                                                             fontSize: 10,
//                                                             fontWeight:
//                                                                 FontWeight
//                                                                     .bold)),
//                                                   ),
//                                                 ],
//                                               ],
//                                             ),
//                                             Text(s['regNo'] ?? '',
//                                                 style: const TextStyle(
//                                                     color: Color(0xFF8B92B8),
//                                                     fontSize: 11)),
//                                           ],
//                                         ),
//                                       ),
//                                       SizedBox(
//                                         width: 60,
//                                         child: Text(
//                                           (s['cgpa'] as double)
//                                               .toStringAsFixed(2),
//                                           style: TextStyle(
//                                               color: rankColor,
//                                               fontWeight: FontWeight.bold,
//                                               fontSize: 15),
//                                           textAlign: TextAlign.center,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 if (idx <
//                                     (overallRankData['top5'] as List).length -
//                                         1)
//                                   const Divider(
//                                       color: Color(0xFF2D3470),
//                                       height: 1,
//                                       indent: 16,
//                                       endIndent: 16),
//                               ],
//                             );
//                           }),
//                         ],
//                       ),
//                     ),
//                   const SizedBox(height: 24),
//                 ],
//               ),
//             ),
//     );
//   }

//   Widget _buildTopStat(String label, String value) {
//     return Column(
//       children: [
//         Text(value,
//             style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold)),
//         const SizedBox(height: 2),
//         Text(label,
//             style: const TextStyle(color: Colors.white70, fontSize: 11)),
//       ],
//     );
//   }

//   Widget _buildRankCard({
//     required String label,
//     required int semester,
//     required Map<String, dynamic> rankData,
//     required Color color,
//   }) {
//     final rank = rankData.isNotEmpty ? rankData['rank'] as int : 0;
//     final total = rankData.isNotEmpty ? rankData['totalStudents'] as int : 0;
//     final gpa = rankData.isNotEmpty
//         ? (rankData['studentGpa'] as double).toStringAsFixed(2)
//         : '--';

//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: const Color(0xFF1A1F4E),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: color.withOpacity(0.2), width: 1),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(label,
//               style: const TextStyle(color: Color(0xFF8B92B8), fontSize: 11)),
//           const SizedBox(height: 4),
//           Text(
//             semester > 0 ? 'Sem $semester' : '--',
//             style: const TextStyle(color: Colors.white, fontSize: 12),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             rank > 0 ? '#$rank' : '--',
//             style: TextStyle(
//                 color: color, fontSize: 28, fontWeight: FontWeight.bold),
//           ),
//           Text(
//             total > 0 ? 'of $total students' : '',
//             style: const TextStyle(color: Color(0xFF8B92B8), fontSize: 11),
//           ),
//           const SizedBox(height: 4),
//           Text('GPA: $gpa',
//               style: TextStyle(
//                   color: color, fontSize: 13, fontWeight: FontWeight.w600)),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import '../utils/gpa_calculator.dart';
import '../services/student_result_service.dart';

class RankDetailsScreen extends StatefulWidget {
  final String studentId;
  final String studentName;
  final List<Map<String, dynamic>> allResults;

  const RankDetailsScreen({
    super.key,
    required this.studentId,
    required this.studentName,
    required this.allResults,
  });

  @override
  State<RankDetailsScreen> createState() => _RankDetailsScreenState();
}

class _RankDetailsScreenState extends State<RankDetailsScreen> {
  final StudentResultService _service = StudentResultService();

  Map<String, dynamic> overallRankData = {};
  Map<String, dynamic> currentSemRankData = {};
  Map<String, dynamic> prevSemRankData = {};
  bool isLoading = true;
  String? errorMsg;

  @override
  void initState() {
    super.initState();
    _loadRankData();
  }

  Future<void> _loadRankData() async {
    try {
      final sems = _service.getCompletedSemesters(widget.allResults);

      // Overall rank
      overallRankData = await _service.calculateOverallRank(widget.studentId);

      // Current semester rank
      if (sems.isNotEmpty) {
        currentSemRankData =
            await _service.calculateRank(widget.studentId, sems.last);
      }

      // Previous semester rank
      if (sems.length >= 2) {
        prevSemRankData = await _service.calculateRank(
            widget.studentId, sems[sems.length - 2]);
      }

      if (mounted) setState(() => isLoading = false);
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMsg = e.toString();
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cgpa = GpaCalculator.calculateCGPA(widget.allResults);
    final sems = _service.getCompletedSemesters(widget.allResults);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1F4E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Rank Details',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
          : errorMsg != null
              ? _buildError()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Overall Rank Card ──────────────────────
                      _buildOverallRankCard(cgpa),
                      const SizedBox(height: 16),

                      // ── Semester Rank Comparison ───────────────
                      if (sems.isNotEmpty) ...[
                        Row(
                          children: [
                            Expanded(
                              child: _buildRankCard(
                                label: 'Current Sem Rank',
                                semester: sems.last,
                                rankData: currentSemRankData,
                                color: const Color(0xFF6C63FF),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildRankCard(
                                label: 'Previous Sem Rank',
                                semester: sems.length >= 2
                                    ? sems[sems.length - 2]
                                    : 0,
                                rankData: prevSemRankData,
                                color: const Color(0xFF4ECDC4),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],

                      // ── Leaderboard ────────────────────────────
                      const Text('Top 5 Leaderboard',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      _buildLeaderboard(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
    );
  }

  Widget _buildOverallRankCard(double cgpa) {
    final rank = overallRankData['rank'] as int? ?? 0;
    final total = overallRankData['totalStudents'] as int? ?? 0;
    final topperCgpa = (overallRankData['topperCgpa'] as double?) ?? 0.0;
    final gap = (overallRankData['gapFromTopper'] as double?) ?? 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFBE0B), Color(0xFFFF9800)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 40),
          const SizedBox(height: 8),
          const Text('Overall Rank (CGPA)',
              style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 4),
          Text(
            rank > 0 ? '#$rank' : '--',
            style: const TextStyle(
                color: Colors.white, fontSize: 52, fontWeight: FontWeight.bold),
          ),
          Text(
            total > 0 ? 'out of $total students' : 'No data yet',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTopStat('Your CGPA', cgpa.toStringAsFixed(2)),
              _buildTopStat('Topper CGPA', topperCgpa.toStringAsFixed(2)),
              _buildTopStat('Gap', '-${gap.toStringAsFixed(2)}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboard() {
    final top5 = overallRankData['top5'] as List? ?? [];

    if (top5.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1F4E),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Column(
            children: [
              Icon(Icons.leaderboard_rounded,
                  color: Color(0xFF8B92B8), size: 48),
              SizedBox(height: 12),
              Text('Leaderboard not available yet',
                  style: TextStyle(color: Color(0xFF8B92B8))),
              SizedBox(height: 4),
              Text('Results need to be added for all students',
                  style: TextStyle(color: Color(0xFF4A5180), fontSize: 12)),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F4E),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF2D3470),
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              children: const [
                SizedBox(
                    width: 44,
                    child: Text('Rank',
                        style: TextStyle(
                            color: Color(0xFF8B92B8),
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center)),
                SizedBox(width: 8),
                Expanded(
                    child: Text('Student',
                        style: TextStyle(
                            color: Color(0xFF8B92B8),
                            fontSize: 12,
                            fontWeight: FontWeight.w600))),
                SizedBox(
                    width: 60,
                    child: Text('CGPA',
                        style: TextStyle(
                            color: Color(0xFF8B92B8),
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center)),
              ],
            ),
          ),

          // Rows
          ...top5.asMap().entries.map((entry) {
            final idx = entry.key;
            final s = entry.value as Map<String, dynamic>;
            final rank = s['rank'] as int? ?? (idx + 1);
            final isCurrentStudent = s['studentId'] == widget.studentId;
            final cgpaVal = (s['cgpa'] as double?) ?? 0.0;

            // Medal colors for top 3
            final medalColors = [
              const Color(0xFFFFBE0B), // Gold
              const Color(0xFF8B92B8), // Silver
              const Color(0xFFFF9800), // Bronze
            ];
            final rankColor = idx < 3 ? medalColors[idx] : Colors.white;

            return Column(
              children: [
                Container(
                  color: isCurrentStudent
                      ? const Color(0xFF6C63FF).withOpacity(0.1)
                      : Colors.transparent,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                  child: Row(
                    children: [
                      // Rank badge
                      SizedBox(
                        width: 44,
                        child: idx < 3
                            ? Icon(Icons.emoji_events_rounded,
                                color: rankColor, size: 22)
                            : Text('$rank',
                                style: TextStyle(
                                    color: rankColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15),
                                textAlign: TextAlign.center),
                      ),
                      const SizedBox(width: 8),

                      // Name + reg
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    s['name'] ?? 'Unknown',
                                    style: TextStyle(
                                        color: isCurrentStudent
                                            ? const Color(0xFF6C63FF)
                                            : Colors.white,
                                        fontWeight: isCurrentStudent
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        fontSize: 14),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (isCurrentStudent) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF6C63FF)
                                          .withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text('You',
                                        style: TextStyle(
                                            color: Color(0xFF6C63FF),
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ],
                            ),
                            Text(
                              s['regNo'] ?? '',
                              style: const TextStyle(
                                  color: Color(0xFF8B92B8), fontSize: 11),
                            ),
                          ],
                        ),
                      ),

                      // CGPA
                      SizedBox(
                        width: 60,
                        child: Text(
                          cgpaVal.toStringAsFixed(2),
                          style: TextStyle(
                              color: rankColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                if (idx < top5.length - 1)
                  const Divider(
                      color: Color(0xFF2D3470),
                      height: 1,
                      indent: 16,
                      endIndent: 16),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTopStat(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }

  Widget _buildRankCard({
    required String label,
    required int semester,
    required Map<String, dynamic> rankData,
    required Color color,
  }) {
    final rank = rankData['rank'] as int? ?? 0;
    final total = rankData['totalStudents'] as int? ?? 0;
    final gpa = (rankData['studentGpa'] as double?) ?? 0.0;

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
          Text(label,
              style: const TextStyle(color: Color(0xFF8B92B8), fontSize: 11)),
          const SizedBox(height: 4),
          Text(
            semester > 0 ? 'Sem $semester' : '--',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(
            rank > 0 ? '#$rank' : '--',
            style: TextStyle(
                color: color, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          Text(
            total > 0 ? 'of $total students' : '',
            style: const TextStyle(color: Color(0xFF8B92B8), fontSize: 11),
          ),
          const SizedBox(height: 4),
          Text(
            gpa > 0 ? 'GPA: ${gpa.toStringAsFixed(2)}' : 'No data',
            style: TextStyle(
                color: color, fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded,
                color: Color(0xFFE53935), size: 60),
            const SizedBox(height: 16),
            const Text('Could not load rank data',
                style: TextStyle(color: Colors.white, fontSize: 16)),
            const SizedBox(height: 8),
            Text(errorMsg ?? '',
                style: const TextStyle(color: Color(0xFF8B92B8), fontSize: 12),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isLoading = true;
                  errorMsg = null;
                });
                _loadRankData();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
