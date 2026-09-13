// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../utils/gpa_calculator.dart';

// class StudentDashboard extends StatefulWidget {
//   const StudentDashboard({super.key});

//   @override
//   State<StudentDashboard> createState() => _StudentDashboardState();
// }

// class _StudentDashboardState extends State<StudentDashboard>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   String studentName = '';
//   String studentId = '';
//   String regNo = '';
//   String department = '';
//   String batch = '';
//   List<Map<String, dynamic>> allResults = [];
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 5, vsync: this);
//     _loadStudentData();
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   Future<void> _loadStudentData() async {
//     try {
//       final uid = FirebaseAuth.instance.currentUser!.uid;
//       final userDoc =
//           await FirebaseFirestore.instance.collection('users').doc(uid).get();
//       final email = userDoc.data()?['email'] ?? '';
//       studentName = userDoc.data()?['name'] ?? 'Student';

//       // Find student record by email
//       final studentSnap = await FirebaseFirestore.instance
//           .collection('students')
//           .where('email', isEqualTo: email)
//           .get();

//       if (studentSnap.docs.isNotEmpty) {
//         final sData = studentSnap.docs.first.data();
//         studentId = studentSnap.docs.first.id;
//         regNo = sData['regNo'] ?? '';
//         department = sData['department'] ?? '';
//         batch = sData['batch'] ?? '';

//         // Load results
//         final resultsSnap = await FirebaseFirestore.instance
//             .collection('results')
//             .where('studentId', isEqualTo: studentId)
//             .get();
//         allResults = resultsSnap.docs.map((d) => d.data()).toList();
//       }

//       if (mounted) setState(() => isLoading = false);
//     } catch (e) {
//       if (mounted) setState(() => isLoading = false);
//     }
//   }

//   List<Map<String, dynamic>> _getResultsForSemester(int sem) {
//     return allResults.where((r) => r['semester'] == sem).toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final cgpa = GpaCalculator.calculateCGPA(allResults);
//     final classification = GpaCalculator.getClassification(cgpa);
//     final totalCredits = GpaCalculator.totalCreditsEarned(allResults);

//     return Scaffold(
//       backgroundColor: const Color(0xFF0A0E27),
//       body: isLoading
//           ? const Center(
//               child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
//           : NestedScrollView(
//               headerSliverBuilder: (context, _) => [
//                 SliverAppBar(
//                   expandedHeight: 280,
//                   pinned: true,
//                   backgroundColor: const Color(0xFF1A1F4E),
//                   automaticallyImplyLeading: false,
//                   actions: [
//                     IconButton(
//                       icon: const Icon(Icons.logout_rounded,
//                           color: Color(0xFFE53935)),
//                       onPressed: () async {
//                         await FirebaseAuth.instance.signOut();
//                         if (mounted) {
//                           Navigator.pushReplacementNamed(context, '/login');
//                         }
//                       },
//                     ),
//                   ],
//                   flexibleSpace: FlexibleSpaceBar(
//                     background: Container(
//                       decoration: const BoxDecoration(
//                         gradient: LinearGradient(
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                           colors: [Color(0xFF1A1F4E), Color(0xFF0A0E27)],
//                         ),
//                       ),
//                       child: SafeArea(
//                         child: Padding(
//                           padding: const EdgeInsets.all(20),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               const SizedBox(height: 44),
//                               // Profile row
//                               Row(
//                                 children: [
//                                   Container(
//                                     width: 60,
//                                     height: 60,
//                                     decoration: BoxDecoration(
//                                       gradient: const LinearGradient(colors: [
//                                         Color(0xFF6C63FF),
//                                         Color(0xFF4ECDC4)
//                                       ]),
//                                       borderRadius: BorderRadius.circular(18),
//                                     ),
//                                     child: Center(
//                                       child: Text(
//                                         studentName.isNotEmpty
//                                             ? studentName[0].toUpperCase()
//                                             : '?',
//                                         style: const TextStyle(
//                                             color: Colors.white,
//                                             fontSize: 26,
//                                             fontWeight: FontWeight.bold),
//                                       ),
//                                     ),
//                                   ),
//                                   const SizedBox(width: 14),
//                                   Expanded(
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         const Text('Welcome back,',
//                                             style: TextStyle(
//                                                 color: Color(0xFF8B92B8),
//                                                 fontSize: 13)),
//                                         Text(studentName,
//                                             style: const TextStyle(
//                                                 color: Colors.white,
//                                                 fontSize: 20,
//                                                 fontWeight: FontWeight.bold)),
//                                         if (regNo.isNotEmpty)
//                                           Text(regNo,
//                                               style: const TextStyle(
//                                                   color: Color(0xFF6C63FF),
//                                                   fontSize: 13,
//                                                   fontWeight: FontWeight.w500)),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               const SizedBox(height: 20),
//                               // Stats
//                               Row(
//                                 children: [
//                                   _buildStat('CGPA', cgpa.toStringAsFixed(2),
//                                       const Color(0xFF6C63FF)),
//                                   const SizedBox(width: 10),
//                                   _buildStat(
//                                       'Credits',
//                                       totalCredits.toStringAsFixed(0),
//                                       const Color(0xFF4ECDC4)),
//                                   const SizedBox(width: 10),
//                                   _buildStat('Class', classification,
//                                       const Color(0xFFFFBE0B)),
//                                 ],
//                               ),
//                               if (department.isNotEmpty) ...[
//                                 const SizedBox(height: 10),
//                                 Text('$department • $batch',
//                                     style: const TextStyle(
//                                         color: Color(0xFF8B92B8),
//                                         fontSize: 12)),
//                               ],
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   bottom: TabBar(
//                     controller: _tabController,
//                     indicatorColor: const Color(0xFF6C63FF),
//                     labelColor: const Color(0xFF6C63FF),
//                     unselectedLabelColor: const Color(0xFF8B92B8),
//                     isScrollable: true,
//                     tabs: const [
//                       Tab(text: 'Overview'),
//                       Tab(text: 'Sem 1'),
//                       Tab(text: 'Sem 2'),
//                       Tab(text: 'Sem 3'),
//                       Tab(text: 'Sem 4'),
//                     ],
//                   ),
//                 ),
//               ],
//               body: TabBarView(
//                 controller: _tabController,
//                 children: [
//                   _buildOverviewTab(cgpa, classification, totalCredits),
//                   ...[1, 2, 3, 4].map((sem) => _buildSemesterTab(sem)).toList(),
//                   const SizedBox(height: 16),
//                   GestureDetector(
//                     onTap: () =>
//                         Navigator.pushNamed(context, '/student-result-home'),
//                     child: Container(
//                       width: double.infinity,
//                       padding: const EdgeInsets.all(18),
//                       decoration: BoxDecoration(
//                         gradient: const LinearGradient(
//                             colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)]),
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       child: const Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(Icons.analytics_rounded, color: Colors.white),
//                           SizedBox(width: 10),
//                           Text('View Full Result & Performance',
//                               style: TextStyle(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 15)),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//     );
//   }

//   Widget _buildStat(String label, String value, Color color) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
//         decoration: BoxDecoration(
//           color: color.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: color.withOpacity(0.3), width: 1),
//         ),
//         child: Column(
//           children: [
//             Text(value,
//                 style: TextStyle(
//                     color: color,
//                     fontSize: value.length > 7 ? 10 : 16,
//                     fontWeight: FontWeight.bold),
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis),
//             const SizedBox(height: 2),
//             Text(label,
//                 style: const TextStyle(color: Color(0xFF8B92B8), fontSize: 10)),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildOverviewTab(
//       double cgpa, String classification, double totalCredits) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         children: [
//           // CGPA big card
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(24),
//             decoration: BoxDecoration(
//               gradient: const LinearGradient(
//                   colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)]),
//               borderRadius: BorderRadius.circular(24),
//             ),
//             child: Column(
//               children: [
//                 const Text('Cumulative GPA',
//                     style: TextStyle(color: Colors.white70, fontSize: 14)),
//                 const SizedBox(height: 8),
//                 Text(cgpa.toStringAsFixed(2),
//                     style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 56,
//                         fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 4),
//                 Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Text(classification,
//                       style: const TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 14)),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 16),

//           // Semester GPAs
//           const Align(
//             alignment: Alignment.centerLeft,
//             child: Text('Semester-wise GPA',
//                 style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold)),
//           ),
//           const SizedBox(height: 12),

//           ...([1, 2, 3, 4].map((sem) {
//             final semResults = _getResultsForSemester(sem);
//             final gpa = GpaCalculator.calculateGPA(semResults);
//             final credits = semResults.fold<double>(
//                 0, (s, r) => s + (r['credits'] ?? 0).toDouble());
//             final hasData = semResults.isNotEmpty;

//             return Container(
//               margin: const EdgeInsets.only(bottom: 10),
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: const Color(0xFF1A1F4E),
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: Row(
//                 children: [
//                   Container(
//                     width: 44,
//                     height: 44,
//                     decoration: BoxDecoration(
//                       color: const Color(0xFF6C63FF).withOpacity(0.15),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Center(
//                       child: Text('S$sem',
//                           style: const TextStyle(
//                               color: Color(0xFF6C63FF),
//                               fontWeight: FontWeight.bold,
//                               fontSize: 14)),
//                     ),
//                   ),
//                   const SizedBox(width: 14),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text('Semester $sem',
//                             style: const TextStyle(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.w600,
//                                 fontSize: 15)),
//                         Text(
//                             hasData
//                                 ? '${semResults.length} subjects • ${credits.toStringAsFixed(0)} credits'
//                                 : 'No results yet',
//                             style: const TextStyle(
//                                 color: Color(0xFF8B92B8), fontSize: 12)),
//                       ],
//                     ),
//                   ),
//                   hasData
//                       ? Text(gpa.toStringAsFixed(2),
//                           style: const TextStyle(
//                               color: Color(0xFF4ECDC4),
//                               fontSize: 22,
//                               fontWeight: FontWeight.bold))
//                       : const Text('--',
//                           style: TextStyle(
//                               color: Color(0xFF8B92B8), fontSize: 18)),
//                 ],
//               ),
//             );
//           })),
//           const SizedBox(height: 20),
//         ],
//       ),
//     );
//   }

//   Widget _buildSemesterTab(int sem) {
//     final results = _getResultsForSemester(sem);
//     final gpa = GpaCalculator.calculateGPA(results);
//     final credits =
//         results.fold<double>(0, (s, r) => s + (r['credits'] ?? 0).toDouble());

//     if (results.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.assignment_outlined,
//                 color: Color(0xFF8B92B8), size: 60),
//             const SizedBox(height: 12),
//             Text('No results for Semester $sem',
//                 style: const TextStyle(color: Color(0xFF8B92B8), fontSize: 16)),
//           ],
//         ),
//       );
//     }

//     final passed =
//         results.where((r) => GpaCalculator.isPassed(r['grade'] ?? '')).length;
//     final failed = results.length - passed;

//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         children: [
//           // GPA Card
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               gradient: const LinearGradient(
//                   colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)]),
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 _buildGPAStat('GPA', gpa.toStringAsFixed(2)),
//                 _buildGPAStat('Credits', credits.toStringAsFixed(0)),
//                 _buildGPAStat('Passed', '$passed'),
//                 _buildGPAStat('Failed', '$failed'),
//               ],
//             ),
//           ),
//           const SizedBox(height: 16),

//           // Results Table
//           Container(
//             decoration: BoxDecoration(
//               color: const Color(0xFF1A1F4E),
//               borderRadius: BorderRadius.circular(18),
//             ),
//             child: Column(
//               children: [
//                 Padding(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                   child: Row(
//                     children: const [
//                       Expanded(
//                           flex: 2,
//                           child: Text('Subject',
//                               style: TextStyle(
//                                   color: Color(0xFF8B92B8),
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.w600))),
//                       SizedBox(
//                           width: 42,
//                           child: Text('Cr',
//                               style: TextStyle(
//                                   color: Color(0xFF8B92B8),
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.w600),
//                               textAlign: TextAlign.center)),
//                       SizedBox(
//                           width: 50,
//                           child: Text('Grade',
//                               style: TextStyle(
//                                   color: Color(0xFF8B92B8),
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.w600),
//                               textAlign: TextAlign.center)),
//                       SizedBox(
//                           width: 40,
//                           child: Text('GP',
//                               style: TextStyle(
//                                   color: Color(0xFF8B92B8),
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.w600),
//                               textAlign: TextAlign.center)),
//                       SizedBox(
//                           width: 44,
//                           child: Text('Status',
//                               style: TextStyle(
//                                   color: Color(0xFF8B92B8),
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.w600),
//                               textAlign: TextAlign.center)),
//                     ],
//                   ),
//                 ),
//                 const Divider(
//                     color: Color(0xFF2D3470), height: 1, thickness: 1),
//                 ...results.asMap().entries.map((entry) {
//                   final i = entry.key;
//                   final r = entry.value;
//                   final grade = r['grade'] ?? '';
//                   final gradeColor = Color(GpaCalculator.gradeColor(grade));
//                   final passed = GpaCalculator.isPassed(grade);

//                   return Column(
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 16, vertical: 12),
//                         child: Row(
//                           children: [
//                             Expanded(
//                               flex: 2,
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(r['subjectCode'] ?? '',
//                                       style: const TextStyle(
//                                           color: Color(0xFF6C63FF),
//                                           fontSize: 12,
//                                           fontWeight: FontWeight.w600)),
//                                   Text(r['subjectName'] ?? '',
//                                       style: const TextStyle(
//                                           color: Colors.white, fontSize: 13),
//                                       maxLines: 1,
//                                       overflow: TextOverflow.ellipsis),
//                                 ],
//                               ),
//                             ),
//                             SizedBox(
//                               width: 42,
//                               child: Text((r['credits'] ?? 0).toString(),
//                                   style: const TextStyle(
//                                       color: Colors.white, fontSize: 13),
//                                   textAlign: TextAlign.center),
//                             ),
//                             SizedBox(
//                               width: 50,
//                               child: Container(
//                                 margin:
//                                     const EdgeInsets.symmetric(horizontal: 4),
//                                 padding: const EdgeInsets.symmetric(
//                                     horizontal: 6, vertical: 4),
//                                 decoration: BoxDecoration(
//                                   color: gradeColor.withOpacity(0.15),
//                                   borderRadius: BorderRadius.circular(8),
//                                 ),
//                                 child: Text(grade,
//                                     style: TextStyle(
//                                         color: gradeColor,
//                                         fontSize: 13,
//                                         fontWeight: FontWeight.bold),
//                                     textAlign: TextAlign.center),
//                               ),
//                             ),
//                             SizedBox(
//                               width: 40,
//                               child: Text((r['gradePoint'] ?? 0).toString(),
//                                   style: const TextStyle(
//                                       color: Colors.white, fontSize: 13),
//                                   textAlign: TextAlign.center),
//                             ),
//                             SizedBox(
//                               width: 44,
//                               child: Icon(
//                                 passed
//                                     ? Icons.check_circle_rounded
//                                     : Icons.cancel_rounded,
//                                 color: passed
//                                     ? const Color(0xFF43A047)
//                                     : const Color(0xFFE53935),
//                                 size: 20,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       if (i < results.length - 1)
//                         const Divider(
//                             color: Color(0xFF2D3470),
//                             height: 1,
//                             thickness: 0.5,
//                             indent: 16,
//                             endIndent: 16),
//                     ],
//                   );
//                 }),
//               ],
//             ),
//           ),
//           const SizedBox(height: 20),
//         ],
//       ),
//     );
//   }

//   Widget _buildGPAStat(String label, String value) {
//     return Column(
//       children: [
//         Text(value,
//             style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold)),
//         const SizedBox(height: 4),
//         Text(label,
//             style: const TextStyle(color: Colors.white70, fontSize: 12)),
//       ],
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../utils/gpa_calculator.dart';
// import 'student_result_home_screen.dart';

// class StudentDashboard extends StatefulWidget {
//   const StudentDashboard({super.key});

//   @override
//   State<StudentDashboard> createState() => _StudentDashboardState();
// }

// class _StudentDashboardState extends State<StudentDashboard>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   String studentName = '';
//   String studentId = '';
//   String regNo = '';
//   String department = '';
//   String batch = '';
//   List<Map<String, dynamic>> allResults = [];
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     // ✅ FIXED: exactly 5 tabs matching the 5 Tab() widgets below
//     _tabController = TabController(length: 5, vsync: this);
//     _loadStudentData();
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   Future<void> _loadStudentData() async {
//     try {
//       final uid = FirebaseAuth.instance.currentUser!.uid;
//       final userDoc =
//           await FirebaseFirestore.instance.collection('users').doc(uid).get();
//       final email = userDoc.data()?['email'] ?? '';
//       studentName = userDoc.data()?['name'] ?? 'Student';

//       final studentSnap = await FirebaseFirestore.instance
//           .collection('students')
//           .where('email', isEqualTo: email)
//           .get();

//       if (studentSnap.docs.isNotEmpty) {
//         final sData = studentSnap.docs.first.data();
//         studentId = studentSnap.docs.first.id;
//         regNo = sData['regNo'] ?? '';
//         department = sData['department'] ?? '';
//         batch = sData['batch'] ?? '';

//         final resultsSnap = await FirebaseFirestore.instance
//             .collection('results')
//             .where('studentId', isEqualTo: studentId)
//             .get();
//         allResults = resultsSnap.docs.map((d) => d.data()).toList();
//       }

//       if (mounted) setState(() => isLoading = false);
//     } catch (e) {
//       if (mounted) setState(() => isLoading = false);
//     }
//   }

//   List<Map<String, dynamic>> _getResultsForSemester(int sem) {
//     return allResults.where((r) => r['semester'] == sem).toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final cgpa = GpaCalculator.calculateCGPA(allResults);
//     final classification = GpaCalculator.getClassification(cgpa);
//     final totalCredits = GpaCalculator.totalCreditsEarned(allResults);

//     return Scaffold(
//       backgroundColor: const Color(0xFF0A0E27),
//       body: isLoading
//           ? const Center(
//               child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
//           : NestedScrollView(
//               headerSliverBuilder: (context, _) => [
//                 SliverAppBar(
//                   expandedHeight: 280,
//                   pinned: true,
//                   backgroundColor: const Color(0xFF1A1F4E),
//                   automaticallyImplyLeading: false,
//                   actions: [
//                     IconButton(
//                       icon: const Icon(Icons.settings_outlined,
//                           color: Color(0xFF8B92B8)),
//                       onPressed: () =>
//                           Navigator.pushNamed(context, '/settings'),
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.logout_rounded,
//                           color: Color(0xFFE53935)),
//                       onPressed: () async {
//                         await FirebaseAuth.instance.signOut();
//                         if (mounted) {
//                           Navigator.pushReplacementNamed(context, '/login');
//                         }
//                       },
//                     ),
//                   ],
//                   flexibleSpace: FlexibleSpaceBar(
//                     background: Container(
//                       decoration: const BoxDecoration(
//                         gradient: LinearGradient(
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                           colors: [Color(0xFF1A1F4E), Color(0xFF0A0E27)],
//                         ),
//                       ),
//                       child: SafeArea(
//                         child: Padding(
//                           padding: const EdgeInsets.all(20),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               const SizedBox(height: 44),
//                               Row(
//                                 children: [
//                                   Container(
//                                     width: 60,
//                                     height: 60,
//                                     decoration: BoxDecoration(
//                                       gradient: const LinearGradient(colors: [
//                                         Color(0xFF6C63FF),
//                                         Color(0xFF4ECDC4)
//                                       ]),
//                                       borderRadius: BorderRadius.circular(18),
//                                     ),
//                                     child: Center(
//                                       child: Text(
//                                         studentName.isNotEmpty
//                                             ? studentName[0].toUpperCase()
//                                             : '?',
//                                         style: const TextStyle(
//                                             color: Colors.white,
//                                             fontSize: 26,
//                                             fontWeight: FontWeight.bold),
//                                       ),
//                                     ),
//                                   ),
//                                   const SizedBox(width: 14),
//                                   Expanded(
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         const Text('Welcome back,',
//                                             style: TextStyle(
//                                                 color: Color(0xFF8B92B8),
//                                                 fontSize: 13)),
//                                         Text(studentName,
//                                             style: const TextStyle(
//                                                 color: Colors.white,
//                                                 fontSize: 20,
//                                                 fontWeight: FontWeight.bold)),
//                                         if (regNo.isNotEmpty)
//                                           Text(regNo,
//                                               style: const TextStyle(
//                                                   color: Color(0xFF6C63FF),
//                                                   fontSize: 13,
//                                                   fontWeight: FontWeight.w500)),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               const SizedBox(height: 20),
//                               Row(
//                                 children: [
//                                   _buildStat('CGPA', cgpa.toStringAsFixed(2),
//                                       const Color(0xFF6C63FF)),
//                                   const SizedBox(width: 10),
//                                   _buildStat(
//                                       'Credits',
//                                       totalCredits.toStringAsFixed(0),
//                                       const Color(0xFF4ECDC4)),
//                                   const SizedBox(width: 10),
//                                   _buildStat('Class', classification,
//                                       const Color(0xFFFFBE0B)),
//                                 ],
//                               ),
//                               if (department.isNotEmpty) ...[
//                                 const SizedBox(height: 10),
//                                 Text('$department • $batch',
//                                     style: const TextStyle(
//                                         color: Color(0xFF8B92B8),
//                                         fontSize: 12)),
//                               ],
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   bottom: TabBar(
//                     controller: _tabController,
//                     indicatorColor: const Color(0xFF6C63FF),
//                     labelColor: const Color(0xFF6C63FF),
//                     unselectedLabelColor: const Color(0xFF8B92B8),
//                     isScrollable: true,
//                     // ✅ 5 tabs — must match TabController(length: 5)
//                     tabs: const [
//                       Tab(text: 'Overview'),
//                       Tab(text: 'Sem 1'),
//                       Tab(text: 'Sem 2'),
//                       Tab(text: 'Sem 3'),
//                       Tab(text: 'Sem 4'),
//                     ],
//                   ),
//                 ),
//               ],
//               body: TabBarView(
//                 controller: _tabController,
//                 // ✅ 5 children — must match TabController(length: 5)
//                 children: [
//                   _buildOverviewTab(cgpa, classification, totalCredits),
//                   _buildSemesterTab(1),
//                   _buildSemesterTab(2),
//                   _buildSemesterTab(3),
//                   _buildSemesterTab(4),
//                 ],
//               ),
//             ),
//     );
//   }

//   Widget _buildStat(String label, String value, Color color) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
//         decoration: BoxDecoration(
//           color: color.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: color.withOpacity(0.3), width: 1),
//         ),
//         child: Column(
//           children: [
//             Text(value,
//                 style: TextStyle(
//                     color: color,
//                     fontSize: value.length > 7 ? 10 : 16,
//                     fontWeight: FontWeight.bold),
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis),
//             const SizedBox(height: 2),
//             Text(label,
//                 style: const TextStyle(color: Color(0xFF8B92B8), fontSize: 10)),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildOverviewTab(
//       double cgpa, String classification, double totalCredits) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         children: [
//           // CGPA Big Card
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(24),
//             decoration: BoxDecoration(
//               gradient: const LinearGradient(
//                   colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)]),
//               borderRadius: BorderRadius.circular(24),
//             ),
//             child: Column(
//               children: [
//                 const Text('Cumulative GPA',
//                     style: TextStyle(color: Colors.white70, fontSize: 14)),
//                 const SizedBox(height: 8),
//                 Text(cgpa.toStringAsFixed(2),
//                     style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 56,
//                         fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 4),
//                 Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Text(classification,
//                       style: const TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 14)),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 16),

//           // ✅ NEW BUTTON — Full Result & Performance Module
//           GestureDetector(
//             onTap: () => Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (_) => const StudentResultHomeScreen(),
//               ),
//             ),
//             child: Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(18),
//               decoration: BoxDecoration(
//                 gradient: const LinearGradient(
//                   colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)],
//                   begin: Alignment.centerLeft,
//                   end: Alignment.centerRight,
//                 ),
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: [
//                   BoxShadow(
//                     color: const Color(0xFF6C63FF).withOpacity(0.3),
//                     blurRadius: 12,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: const Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.analytics_rounded, color: Colors.white, size: 22),
//                   SizedBox(width: 10),
//                   Text('Full Result & Performance',
//                       style: TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 15)),
//                   SizedBox(width: 8),
//                   Icon(Icons.arrow_forward_ios_rounded,
//                       color: Colors.white70, size: 14),
//                 ],
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),

//           // Semester GPA list
//           const Align(
//             alignment: Alignment.centerLeft,
//             child: Text('Semester-wise GPA',
//                 style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold)),
//           ),
//           const SizedBox(height: 12),

//           ...([1, 2, 3, 4].map((sem) {
//             final semResults = _getResultsForSemester(sem);
//             final gpa = GpaCalculator.calculateGPA(semResults);
//             final credits = semResults.fold<double>(
//                 0, (s, r) => s + (r['credits'] ?? 0).toDouble());
//             final hasData = semResults.isNotEmpty;

//             return Container(
//               margin: const EdgeInsets.only(bottom: 10),
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: const Color(0xFF1A1F4E),
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: Row(
//                 children: [
//                   Container(
//                     width: 44,
//                     height: 44,
//                     decoration: BoxDecoration(
//                       color: const Color(0xFF6C63FF).withOpacity(0.15),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Center(
//                       child: Text('S$sem',
//                           style: const TextStyle(
//                               color: Color(0xFF6C63FF),
//                               fontWeight: FontWeight.bold,
//                               fontSize: 14)),
//                     ),
//                   ),
//                   const SizedBox(width: 14),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text('Semester $sem',
//                             style: const TextStyle(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.w600,
//                                 fontSize: 15)),
//                         Text(
//                             hasData
//                                 ? '${semResults.length} subjects • ${credits.toStringAsFixed(0)} credits'
//                                 : 'No results yet',
//                             style: const TextStyle(
//                                 color: Color(0xFF8B92B8), fontSize: 12)),
//                       ],
//                     ),
//                   ),
//                   hasData
//                       ? Text(gpa.toStringAsFixed(2),
//                           style: const TextStyle(
//                               color: Color(0xFF4ECDC4),
//                               fontSize: 22,
//                               fontWeight: FontWeight.bold))
//                       : const Text('--',
//                           style: TextStyle(
//                               color: Color(0xFF8B92B8), fontSize: 18)),
//                 ],
//               ),
//             );
//           })),
//           const SizedBox(height: 20),
//         ],
//       ),
//     );
//   }

//   Widget _buildSemesterTab(int sem) {
//     final results = _getResultsForSemester(sem);
//     final gpa = GpaCalculator.calculateGPA(results);
//     final credits =
//         results.fold<double>(0, (s, r) => s + (r['credits'] ?? 0).toDouble());

//     if (results.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.assignment_outlined,
//                 color: Color(0xFF8B92B8), size: 60),
//             const SizedBox(height: 12),
//             Text('No results for Semester $sem',
//                 style: const TextStyle(color: Color(0xFF8B92B8), fontSize: 16)),
//           ],
//         ),
//       );
//     }

//     final passed =
//         results.where((r) => GpaCalculator.isPassed(r['grade'] ?? '')).length;
//     final failed = results.length - passed;

//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         children: [
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               gradient: const LinearGradient(
//                   colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)]),
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 _buildGPAStat('GPA', gpa.toStringAsFixed(2)),
//                 _buildGPAStat('Credits', credits.toStringAsFixed(0)),
//                 _buildGPAStat('Passed', '$passed'),
//                 _buildGPAStat('Failed', '$failed'),
//               ],
//             ),
//           ),
//           const SizedBox(height: 16),
//           Container(
//             decoration: BoxDecoration(
//               color: const Color(0xFF1A1F4E),
//               borderRadius: BorderRadius.circular(18),
//             ),
//             child: Column(
//               children: [
//                 Padding(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                   child: Row(
//                     children: const [
//                       Expanded(
//                           flex: 2,
//                           child: Text('Subject',
//                               style: TextStyle(
//                                   color: Color(0xFF8B92B8),
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.w600))),
//                       SizedBox(
//                           width: 42,
//                           child: Text('Cr',
//                               style: TextStyle(
//                                   color: Color(0xFF8B92B8),
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.w600),
//                               textAlign: TextAlign.center)),
//                       SizedBox(
//                           width: 50,
//                           child: Text('Grade',
//                               style: TextStyle(
//                                   color: Color(0xFF8B92B8),
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.w600),
//                               textAlign: TextAlign.center)),
//                       SizedBox(
//                           width: 40,
//                           child: Text('GP',
//                               style: TextStyle(
//                                   color: Color(0xFF8B92B8),
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.w600),
//                               textAlign: TextAlign.center)),
//                       SizedBox(
//                           width: 44,
//                           child: Text('Status',
//                               style: TextStyle(
//                                   color: Color(0xFF8B92B8),
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.w600),
//                               textAlign: TextAlign.center)),
//                     ],
//                   ),
//                 ),
//                 const Divider(
//                     color: Color(0xFF2D3470), height: 1, thickness: 1),
//                 ...results.asMap().entries.map((entry) {
//                   final i = entry.key;
//                   final r = entry.value;
//                   final grade = r['grade'] ?? '';
//                   final gradeColor = Color(GpaCalculator.gradeColor(grade));
//                   final passed = GpaCalculator.isPassed(grade);
//                   return Column(
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 16, vertical: 12),
//                         child: Row(
//                           children: [
//                             Expanded(
//                               flex: 2,
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(r['subjectCode'] ?? '',
//                                       style: const TextStyle(
//                                           color: Color(0xFF6C63FF),
//                                           fontSize: 12,
//                                           fontWeight: FontWeight.w600)),
//                                   Text(r['subjectName'] ?? '',
//                                       style: const TextStyle(
//                                           color: Colors.white, fontSize: 13),
//                                       maxLines: 1,
//                                       overflow: TextOverflow.ellipsis),
//                                 ],
//                               ),
//                             ),
//                             SizedBox(
//                               width: 42,
//                               child: Text((r['credits'] ?? 0).toString(),
//                                   style: const TextStyle(
//                                       color: Colors.white, fontSize: 13),
//                                   textAlign: TextAlign.center),
//                             ),
//                             SizedBox(
//                               width: 50,
//                               child: Container(
//                                 margin:
//                                     const EdgeInsets.symmetric(horizontal: 4),
//                                 padding: const EdgeInsets.symmetric(
//                                     horizontal: 6, vertical: 4),
//                                 decoration: BoxDecoration(
//                                   color: gradeColor.withOpacity(0.15),
//                                   borderRadius: BorderRadius.circular(8),
//                                 ),
//                                 child: Text(grade,
//                                     style: TextStyle(
//                                         color: gradeColor,
//                                         fontSize: 13,
//                                         fontWeight: FontWeight.bold),
//                                     textAlign: TextAlign.center),
//                               ),
//                             ),
//                             SizedBox(
//                               width: 40,
//                               child: Text((r['gradePoint'] ?? 0).toString(),
//                                   style: const TextStyle(
//                                       color: Colors.white, fontSize: 13),
//                                   textAlign: TextAlign.center),
//                             ),
//                             SizedBox(
//                               width: 44,
//                               child: Icon(
//                                 passed
//                                     ? Icons.check_circle_rounded
//                                     : Icons.cancel_rounded,
//                                 color: passed
//                                     ? const Color(0xFF43A047)
//                                     : const Color(0xFFE53935),
//                                 size: 20,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       if (i < results.length - 1)
//                         const Divider(
//                             color: Color(0xFF2D3470),
//                             height: 1,
//                             thickness: 0.5,
//                             indent: 16,
//                             endIndent: 16),
//                     ],
//                   );
//                 }),
//               ],
//             ),
//           ),
//           const SizedBox(height: 20),
//         ],
//       ),
//     );
//   }

//   Widget _buildGPAStat(String label, String value) {
//     return Column(
//       children: [
//         Text(value,
//             style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold)),
//         const SizedBox(height: 4),
//         Text(label,
//             style: const TextStyle(color: Colors.white70, fontSize: 12)),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/gpa_calculator.dart';
import '../services/student_result_service.dart';
import 'semester_result_details_screen.dart';
import 'student_performance_screen.dart';
import 'student_result_home_screen.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final StudentResultService _resultService = StudentResultService();

  // Student identity
  String studentName = '';
  String registerNumber = '';
  String department = '';
  String batch = '';

  // Results
  List<Map<String, dynamic>> allResults = [];
  Set<int> availableSemesters = {};
  bool isLoading = true;

  // Sem 1–8
  static const int _totalSemesters = 8;

  @override
  void initState() {
    super.initState();
    // 2 tabs: Overview + Performance
    _tabController = TabController(length: 2, vsync: this);
    _loadStudentData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── STEP 1–4: Login → UID → registerNumber → results ────────────
  Future<void> _loadStudentData() async {
    try {
      // Step 1: Get current logged-in user
      final uid = FirebaseAuth.instance.currentUser!.uid;

      // Step 2: Fetch user document from users/{uid}
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      studentName = userDoc.data()?['name'] ?? 'Student';

      // Step 3: Read registerNumber directly from users collection
      registerNumber =
          (userDoc.data()?['registerNumber'] ?? userDoc.data()?['regNo'] ?? '')
              .toString();

      // Also read department/batch from users doc first
      department = (userDoc.data()?['department'] ?? '').toString();
      batch = (userDoc.data()?['batch'] ?? '').toString();

      if (registerNumber.isNotEmpty) {
        // Step 4: Fetch student profile from students collection
        final studentDoc = await FirebaseFirestore.instance
            .collection('students')
            .doc(registerNumber)
            .get();

        if (studentDoc.exists) {
          department = studentDoc.data()?['department'] ?? department;
          batch = studentDoc.data()?['batch'] ?? batch;
        }

        // Fetch all semester results
        allResults = await _resultService.fetchResults(registerNumber);
        availableSemesters =
            await _resultService.fetchAvailableSemesters(registerNumber);
      }

      if (mounted) setState(() => isLoading = false);
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  List<Map<String, dynamic>> _getResultsForSemester(int sem) {
    return allResults.where((r) => r['semester'] == sem).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cgpa = GpaCalculator.calculateCGPA(allResults);
    final classification = GpaCalculator.getClassification(cgpa);
    final totalCredits = GpaCalculator.totalCreditsEarned(allResults);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
          : NestedScrollView(
              headerSliverBuilder: (context, _) => [
                SliverAppBar(
                  expandedHeight: 280,
                  pinned: true,
                  backgroundColor: const Color(0xFF1A1F4E),
                  automaticallyImplyLeading: false,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.settings_outlined,
                          color: Color(0xFF8B92B8)),
                      onPressed: () =>
                          Navigator.pushNamed(context, '/settings'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout_rounded,
                          color: Color(0xFFE53935)),
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        if (mounted) {
                          Navigator.pushReplacementNamed(context, '/login');
                        }
                      },
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
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(colors: [
                                        Color(0xFF6C63FF),
                                        Color(0xFF4ECDC4)
                                      ]),
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: Center(
                                      child: Text(
                                        studentName.isNotEmpty
                                            ? studentName[0].toUpperCase()
                                            : '?',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 26,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text('Welcome back,',
                                            style: TextStyle(
                                                color: Color(0xFF8B92B8),
                                                fontSize: 13)),
                                        Text(studentName,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold)),
                                        if (registerNumber.isNotEmpty)
                                          Text(registerNumber,
                                              style: const TextStyle(
                                                  color: Color(0xFF6C63FF),
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500)),
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
                                  const SizedBox(width: 10),
                                  _buildStat(
                                      'Credits',
                                      totalCredits.toStringAsFixed(0),
                                      const Color(0xFF4ECDC4)),
                                  const SizedBox(width: 10),
                                  _buildStat('Class', classification,
                                      const Color(0xFFFFBE0B)),
                                ],
                              ),
                              if (department.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Text('$department • $batch',
                                    style: const TextStyle(
                                        color: Color(0xFF8B92B8),
                                        fontSize: 12)),
                              ],
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
                    isScrollable: true,
                    tabs: const [
                      Tab(text: 'Overview'),
                      Tab(text: 'Performance'),
                    ],
                  ),
                ),
              ],
              body: TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(cgpa, classification, totalCredits),
                  // Pass data directly to existing performance screen
                  StudentPerformanceScreen(
                    studentId: registerNumber,
                    studentName: studentName,
                    allResults: allResults,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
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
                    fontSize: value.length > 7 ? 10 : 16,
                    fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(color: Color(0xFF8B92B8), fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab(
      double cgpa, String classification, double totalCredits) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // ── CGPA Big Card ──────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)]),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                const Text('Cumulative GPA',
                    style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 8),
                Text(cgpa.toStringAsFixed(2),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 56,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(classification,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Full Result & Performance button ───────────────────
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StudentResultHomeScreen(
                  autoRegisterNumber: registerNumber,
                ),
              ),
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6C63FF).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.analytics_rounded, color: Colors.white, size: 22),
                  SizedBox(width: 10),
                  Text('Full Result & Performance',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_ios_rounded,
                      color: Colors.white70, size: 14),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Semester-wise GPA list: Sem 1–8 ───────────────────
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Semester-wise GPA',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 12),

          ...List.generate(_totalSemesters, (i) => i + 1).map((sem) {
            final semResults = _getResultsForSemester(sem);
            final hasData = availableSemesters.contains(sem);
            final gpa = GpaCalculator.calculateGPA(semResults);
            final credits = semResults.fold<double>(
                0, (s, r) => s + (r['credits'] ?? 0).toDouble());

            return GestureDetector(
              onTap: hasData && semResults.isNotEmpty
                  ? () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SemesterResultDetailsScreen(
                            studentId: registerNumber,
                            studentName: studentName,
                            semester: sem,
                            semesterResults: semResults,
                            allResults: allResults,
                          ),
                        ),
                      )
                  : null,
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1F4E),
                  borderRadius: BorderRadius.circular(16),
                  border: hasData && semResults.isNotEmpty
                      ? Border.all(
                          color: const Color(0xFF6C63FF).withOpacity(0.2),
                          width: 1)
                      : null,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: hasData
                            ? const Color(0xFF6C63FF).withOpacity(0.15)
                            : const Color(0xFF8B92B8).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text('S$sem',
                            style: TextStyle(
                                color: hasData
                                    ? const Color(0xFF6C63FF)
                                    : const Color(0xFF8B92B8),
                                fontWeight: FontWeight.bold,
                                fontSize: 14)),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Semester $sem',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15)),
                          Text(
                            !hasData
                                ? 'Result Not Available'
                                : semResults.isEmpty
                                    ? 'No Result'
                                    : '${semResults.length} subjects • ${credits.toStringAsFixed(0)} credits',
                            style: TextStyle(
                                color: hasData && semResults.isNotEmpty
                                    ? const Color(0xFF8B92B8)
                                    : const Color(0xFF8B92B8).withOpacity(0.6),
                                fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    // GPA or status
                    hasData && semResults.isNotEmpty
                        ? Row(
                            children: [
                              Text(gpa.toStringAsFixed(2),
                                  style: const TextStyle(
                                      color: Color(0xFF4ECDC4),
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(width: 6),
                              const Icon(Icons.arrow_forward_ios_rounded,
                                  color: Color(0xFF6C63FF), size: 14),
                            ],
                          )
                        : const Text('--',
                            style: TextStyle(
                                color: Color(0xFF8B92B8), fontSize: 18)),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
