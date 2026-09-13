// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'student_list_screen.dart';
// import 'add_student_screen.dart';
// import 'analytics_screen.dart';
// import 'notifications_screen.dart';
// import 'semester_subject_setup_screen.dart';
// import 'pdf_import_screen.dart';
// import 'semester_ranking_screen.dart';
// import '../utils/gpa_calculator.dart';

// class TeacherDashboard extends StatefulWidget {
//   const TeacherDashboard({super.key});

//   @override
//   State<TeacherDashboard> createState() => _TeacherDashboardState();
// }

// class _TeacherDashboardState extends State<TeacherDashboard> {
//   int _selectedIndex = 0;
//   int _notificationCount = 0;

//   // 0=Home  1=Students  2=Analytics  3=Alerts  4=Setup
//   late final List<Widget> _screens;

//   @override
//   void initState() {
//     super.initState();
//     _screens = const [
//       _DashboardHome(),
//       StudentListScreen(),
//       _AnalyticsPlaceholder(),
//       NotificationsScreen(),
//       _SetupTab(),
//     ];
//     _loadNotificationCount();
//   }

//   Future<void> _loadNotificationCount() async {
//     try {
//       final snapshot =
//           await FirebaseFirestore.instance.collection('students').get();
//       int count = 0;
//       for (final doc in snapshot.docs) {
//         final data = doc.data();
//         final results = data['results'] as Map<String, dynamic>? ?? {};
//         if (results.isEmpty) continue;
//         double total = 0;
//         int c = 0;
//         results.forEach((_, mark) {
//           total += GpaCalculator.getGradePoint((mark as num).toDouble());
//           c++;
//         });
//         if (c > 0 && total / c < 5.0) count++;
//       }
//       // Also check arrears from new results collection
//       final allResults =
//           await FirebaseFirestore.instance.collection('results').get();
//       final Map<String, int> arrearMap = {};
//       for (final doc in allResults.docs) {
//         final data = doc.data();
//         final sid = data['studentId'] as String? ?? '';
//         final grade = data['grade'] as String? ?? 'F';
//         if (!GpaCalculator.isPassed(grade)) {
//           arrearMap[sid] = (arrearMap[sid] ?? 0) + 1;
//         }
//       }
//       count += arrearMap.values.where((v) => v > 0).length;
//       if (mounted) setState(() => _notificationCount = count);
//     } catch (_) {}
//   }

//   Future<void> _signOut() async {
//     await FirebaseAuth.instance.signOut();
//     if (mounted) Navigator.pushReplacementNamed(context, '/login');
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final bgColor = isDark ? const Color(0xFF0A0E27) : const Color(0xFFF4F6FF);
//     final navBg = isDark ? const Color(0xFF1A1F4E) : Colors.white;
//     final textColor = isDark ? Colors.white : const Color(0xFF2D3142);

//     return Scaffold(
//       backgroundColor: bgColor,
//       appBar: AppBar(
//         backgroundColor: navBg,
//         elevation: 0,
//         title: Text('Teacher Dashboard',
//             style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
//         actions: [
//           if (_selectedIndex == 0)
//             IconButton(
//               icon: const Icon(Icons.person_add_rounded,
//                   color: Color(0xFF6C63FF)),
//               onPressed: () => Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (_) => const AddStudentScreen()),
//               ),
//               tooltip: 'Add Student',
//             ),
//           IconButton(
//             icon: Icon(Icons.logout_rounded, color: textColor),
//             onPressed: _signOut,
//             tooltip: 'Logout',
//           ),
//         ],
//       ),
//       body: _screens[_selectedIndex],
//       bottomNavigationBar: NavigationBar(
//         selectedIndex: _selectedIndex,
//         onDestinationSelected: (index) {
//           setState(() => _selectedIndex = index);
//           if (index == 3) _loadNotificationCount();
//         },
//         backgroundColor: navBg,
//         indicatorColor: const Color(0xFF6C63FF).withOpacity(0.15),
//         labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
//         destinations: [
//           const NavigationDestination(
//             icon: Icon(Icons.home_outlined),
//             selectedIcon: Icon(Icons.home_rounded, color: Color(0xFF6C63FF)),
//             label: 'Home',
//           ),
//           const NavigationDestination(
//             icon: Icon(Icons.people_outline),
//             selectedIcon: Icon(Icons.people_rounded, color: Color(0xFF6C63FF)),
//             label: 'Students',
//           ),
//           const NavigationDestination(
//             icon: Icon(Icons.bar_chart_outlined),
//             selectedIcon:
//                 Icon(Icons.bar_chart_rounded, color: Color(0xFF6C63FF)),
//             label: 'Analytics',
//           ),
//           NavigationDestination(
//             icon: Badge(
//               isLabelVisible: _notificationCount > 0,
//               label: Text('$_notificationCount'),
//               child: const Icon(Icons.notifications_outlined),
//             ),
//             selectedIcon: Badge(
//               isLabelVisible: _notificationCount > 0,
//               label: Text('$_notificationCount'),
//               child: const Icon(Icons.notifications_rounded,
//                   color: Color(0xFF6C63FF)),
//             ),
//             label: 'Alerts',
//           ),
//           // ── NEW: Setup Tab ──
//           const NavigationDestination(
//             icon: Icon(Icons.settings_outlined),
//             selectedIcon:
//                 Icon(Icons.settings_rounded, color: Color(0xFF6C63FF)),
//             label: 'Setup',
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ─── NEW: Setup Tab ────────────────────────────────────────────────────
// class _SetupTab extends StatelessWidget {
//   const _SetupTab();

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final textColor = isDark ? Colors.white : const Color(0xFF2D3142);
//     final cardBg = isDark ? const Color(0xFF1A1F4E) : Colors.white;
//     final subColor = isDark ? const Color(0xFF8B92B8) : const Color(0xFF6B7280);

//     return ListView(
//       padding: const EdgeInsets.all(16),
//       children: [
//         // Header
//         Container(
//           width: double.infinity,
//           padding: const EdgeInsets.all(20),
//           decoration: BoxDecoration(
//             gradient: const LinearGradient(
//               colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: const Row(
//             children: [
//               Icon(Icons.admin_panel_settings_rounded,
//                   color: Colors.white, size: 40),
//               SizedBox(width: 14),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text('Result Setup',
//                         style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold)),
//                     SizedBox(height: 2),
//                     Text('Configure subjects, import PDFs and view rankings',
//                         style: TextStyle(color: Colors.white70, fontSize: 12)),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 20),

//         Text('Workflow',
//             style: TextStyle(
//                 color: textColor, fontWeight: FontWeight.bold, fontSize: 15)),
//         const SizedBox(height: 10),
//         _workflowCard(cardBg, subColor),
//         const SizedBox(height: 20),

//         Text('Actions',
//             style: TextStyle(
//                 color: textColor, fontWeight: FontWeight.bold, fontSize: 15)),
//         const SizedBox(height: 12),

//         // Subject Setup card
//         _actionCard(
//           context,
//           title: 'Subject Setup',
//           subtitle: 'Add subjects with codes & credits per semester',
//           icon: Icons.book_rounded,
//           color: const Color(0xFF6C63FF),
//           onTap: () => Navigator.push(
//             context,
//             MaterialPageRoute(
//                 builder: (_) => const SemesterSubjectSetupScreen()),
//           ),
//         ),
//         const SizedBox(height: 12),

//         // PDF Import card
//         _actionCard(
//           context,
//           title: 'Import Result PDF',
//           subtitle: 'Upload student result PDF — auto-parsed & saved',
//           icon: Icons.picture_as_pdf_rounded,
//           color: const Color(0xFFFF6B6B),
//           onTap: () => Navigator.push(
//             context,
//             MaterialPageRoute(builder: (_) => const PdfImportScreen()),
//           ),
//         ),
//         const SizedBox(height: 12),

//         // Rankings card
//         _actionCard(
//           context,
//           title: 'Semester Rankings',
//           subtitle: 'View GPA & CGPA leaderboard for all students',
//           icon: Icons.leaderboard_rounded,
//           color: const Color(0xFFFFD700),
//           onTap: () => Navigator.push(
//             context,
//             MaterialPageRoute(builder: (_) => const SemesterRankingScreen()),
//           ),
//         ),
//         const SizedBox(height: 24),
//       ],
//     );
//   }

//   Widget _workflowCard(Color cardBg, Color subColor) {
//     final steps = [
//       ('1', 'Add Subjects', Icons.book_outlined, const Color(0xFF6C63FF)),
//       ('2', 'Upload PDF', Icons.upload_file_rounded, const Color(0xFFFF6B6B)),
//       (
//         '3',
//         'Auto Parsed',
//         Icons.auto_fix_high_rounded,
//         const Color(0xFF4ECDC4)
//       ),
//       ('4', 'GPA & CGPA', Icons.grade_rounded, const Color(0xFF43A047)),
//       ('5', 'Rankings', Icons.leaderboard_rounded, const Color(0xFFFFD700)),
//     ];

//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: cardBg,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           )
//         ],
//       ),
//       child: Row(
//         children: steps.asMap().entries.map((entry) {
//           final i = entry.key;
//           final s = entry.value;
//           return Expanded(
//             child: Row(
//               children: [
//                 Expanded(
//                   child: Column(
//                     children: [
//                       Container(
//                         width: 36,
//                         height: 36,
//                         decoration: BoxDecoration(
//                           color: s.$4.withOpacity(0.15),
//                           shape: BoxShape.circle,
//                         ),
//                         child: Icon(s.$3, color: s.$4, size: 18),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(s.$2,
//                           style: TextStyle(color: subColor, fontSize: 9),
//                           textAlign: TextAlign.center,
//                           maxLines: 2),
//                     ],
//                   ),
//                 ),
//                 if (i < steps.length - 1)
//                   Icon(Icons.arrow_forward_rounded, size: 14, color: subColor),
//               ],
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }

//   Widget _actionCard(
//     BuildContext context, {
//     required String title,
//     required String subtitle,
//     required IconData icon,
//     required Color color,
//     required VoidCallback onTap,
//   }) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final cardBg = isDark ? const Color(0xFF1A1F4E) : Colors.white;

//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: cardBg,
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(color: color.withOpacity(0.25)),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
//               blurRadius: 8,
//               offset: const Offset(0, 2),
//             )
//           ],
//         ),
//         child: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: color.withOpacity(0.12),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Icon(icon, color: color, size: 26),
//             ),
//             const SizedBox(width: 14),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(title,
//                       style: TextStyle(
//                           color:
//                               isDark ? Colors.white : const Color(0xFF2D3142),
//                           fontWeight: FontWeight.bold,
//                           fontSize: 15)),
//                   const SizedBox(height: 3),
//                   Text(subtitle,
//                       style: const TextStyle(
//                           color: Color(0xFF8B92B8), fontSize: 12)),
//                 ],
//               ),
//             ),
//             Icon(Icons.arrow_forward_ios_rounded, color: color, size: 16),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ─── Analytics Tab ────────────────────────────────────────────────────
// class _AnalyticsPlaceholder extends StatelessWidget {
//   const _AnalyticsPlaceholder();

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final textColor = isDark ? Colors.white : const Color(0xFF2D3142);
//     final subColor = isDark ? const Color(0xFF8B92B8) : const Color(0xFF6B7280);
//     final cardBg = isDark ? const Color(0xFF1A1F4E) : Colors.white;

//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance.collection('students').snapshots(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) {
//           return const Center(child: CircularProgressIndicator());
//         }
//         final docs = snapshot.data!.docs;
//         return ListView(
//           padding: const EdgeInsets.all(16),
//           children: [
//             Text('Class Analytics',
//                 style: TextStyle(
//                     color: textColor,
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold)),
//             const SizedBox(height: 4),
//             Text('Tap a student to view detailed analytics',
//                 style: TextStyle(color: subColor, fontSize: 13)),
//             const SizedBox(height: 16),
//             ...docs.map((doc) {
//               final data = doc.data() as Map<String, dynamic>;
//               final name = data['name'] ?? 'Unknown';
//               final regNo = data['regNo'] ?? '';

//               return FutureBuilder<QuerySnapshot>(
//                 future: FirebaseFirestore.instance
//                     .collection('results')
//                     .where('studentId', isEqualTo: doc.id)
//                     .get(),
//                 builder: (ctx, resSnap) {
//                   final allResults = <Map<String, dynamic>>[];
//                   if (resSnap.hasData) {
//                     for (final d in resSnap.data!.docs) {
//                       allResults.add(d.data() as Map<String, dynamic>);
//                     }
//                   }

//                   // Fallback to old results map
//                   final legacyResults =
//                       data['results'] as Map<String, dynamic>? ?? {};
//                   if (allResults.isEmpty && legacyResults.isNotEmpty) {
//                     legacyResults.forEach((key, val) {
//                       if (val is Map) {
//                         allResults.add({
//                           'subjectCode': key,
//                           'subjectName': val['subjectName'] ?? key,
//                           'credits': val['credits'] ?? 3,
//                           'grade': val['grade'] ?? 'F',
//                           'gradePoint': val['gradePoint'] ?? 0,
//                           'semester': val['semester'] ?? 1,
//                         });
//                       }
//                     });
//                   }

//                   final cgpa = GpaCalculator.calculateCGPA(allResults);

//                   return GestureDetector(
//                     onTap: () => Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => AnalyticsScreen(
//                           studentId: doc.id,
//                           studentName: name,
//                           allResults: allResults,
//                         ),
//                       ),
//                     ),
//                     child: Container(
//                       margin: const EdgeInsets.only(bottom: 12),
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: cardBg,
//                         borderRadius: BorderRadius.circular(14),
//                         boxShadow: [
//                           BoxShadow(
//                             color:
//                                 Colors.black.withOpacity(isDark ? 0.3 : 0.05),
//                             blurRadius: 8,
//                             offset: const Offset(0, 2),
//                           )
//                         ],
//                       ),
//                       child: Row(
//                         children: [
//                           CircleAvatar(
//                             backgroundColor:
//                                 const Color(0xFF6C63FF).withOpacity(0.15),
//                             child: Text(
//                               name.isNotEmpty ? name[0].toUpperCase() : '?',
//                               style: const TextStyle(
//                                   color: Color(0xFF6C63FF),
//                                   fontWeight: FontWeight.bold),
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(name,
//                                     style: TextStyle(
//                                         color: textColor,
//                                         fontWeight: FontWeight.bold)),
//                                 Text(regNo,
//                                     style: TextStyle(
//                                         color: subColor, fontSize: 12)),
//                               ],
//                             ),
//                           ),
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.end,
//                             children: [
//                               Text(
//                                 allResults.isEmpty
//                                     ? '—'
//                                     : cgpa.toStringAsFixed(2),
//                                 style: const TextStyle(
//                                     color: Color(0xFF6C63FF),
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 16),
//                               ),
//                               Text('CGPA',
//                                   style:
//                                       TextStyle(color: subColor, fontSize: 11)),
//                             ],
//                           ),
//                           const SizedBox(width: 8),
//                           const Icon(Icons.chevron_right_rounded,
//                               color: Color(0xFF6C63FF)),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               );
//             }),
//           ],
//         );
//       },
//     );
//   }
// }

// // ─── Dashboard Home ───────────────────────────────────────────────────
// class _DashboardHome extends StatelessWidget {
//   const _DashboardHome();

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final textColor = isDark ? Colors.white : const Color(0xFF2D3142);

//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance.collection('students').snapshots(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         final students = snapshot.data!.docs;
//         final totalStudents = students.length;

//         return SingleChildScrollView(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // ── Welcome banner ──
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   gradient: const LinearGradient(
//                     colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Row(
//                   children: [
//                     const Icon(Icons.school_rounded,
//                         color: Colors.white, size: 40),
//                     const SizedBox(width: 14),
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text('Welcome, Teacher 👋',
//                             style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold)),
//                         const SizedBox(height: 2),
//                         Text('Here\'s a quick overview',
//                             style: TextStyle(
//                                 color: Colors.white.withOpacity(0.8),
//                                 fontSize: 13)),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 20),

//               // ── Stats from new results collection ──
//               FutureBuilder<QuerySnapshot>(
//                 future: FirebaseFirestore.instance.collection('results').get(),
//                 builder: (ctx, resSnap) {
//                   int passCount = 0;
//                   int failCount = 0;
//                   double totalGpa = 0;
//                   int gpaCount = 0;

//                   if (resSnap.hasData) {
//                     final Map<String, List<Map<String, dynamic>>> byStudent =
//                         {};
//                     for (final doc in resSnap.data!.docs) {
//                       final data = doc.data() as Map<String, dynamic>;
//                       final sid = data['studentId'] as String? ?? '';
//                       if (sid.isEmpty) continue;
//                       byStudent.putIfAbsent(sid, () => []);
//                       byStudent[sid]!.add(data);
//                     }
//                     byStudent.forEach((_, results) {
//                       final gpa = GpaCalculator.calculateCGPA(results);
//                       totalGpa += gpa;
//                       gpaCount++;
//                       if (gpa >= 5.0) {
//                         passCount++;
//                       } else {
//                         failCount++;
//                       }
//                     });
//                   }

//                   final avgGpa = gpaCount > 0 ? totalGpa / gpaCount : 0.0;

//                   return Column(
//                     children: [
//                       Row(
//                         children: [
//                           Expanded(
//                             child: _statCard(
//                                 'Total Students',
//                                 '$totalStudents',
//                                 Icons.school_rounded,
//                                 const Color(0xFF6C63FF),
//                                 isDark),
//                           ),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: _statCard(
//                                 'Avg CGPA',
//                                 avgGpa.toStringAsFixed(2),
//                                 Icons.grade_rounded,
//                                 const Color(0xFF4ECDC4),
//                                 isDark),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 12),
//                       Row(
//                         children: [
//                           Expanded(
//                             child: _statCard(
//                                 'Passed',
//                                 '$passCount',
//                                 Icons.check_circle_rounded,
//                                 const Color(0xFF43A047),
//                                 isDark),
//                           ),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: _statCard(
//                                 'At Risk',
//                                 '$failCount',
//                                 Icons.warning_rounded,
//                                 const Color(0xFFE53935),
//                                 isDark),
//                           ),
//                         ],
//                       ),
//                     ],
//                   );
//                 },
//               ),
//               const SizedBox(height: 24),

//               Text('Quick Actions',
//                   style: TextStyle(
//                       color: textColor,
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold)),
//               const SizedBox(height: 12),
//               Row(
//                 children: [
//                   Expanded(
//                     child: _actionButton(
//                       context,
//                       label: 'View Analytics',
//                       icon: Icons.bar_chart_rounded,
//                       color: const Color(0xFF6C63FF),
//                       onTap: () {
//                         final state = context
//                             .findAncestorStateOfType<_TeacherDashboardState>();
//                         state?.setState(() => state._selectedIndex = 2);
//                       },
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: _actionButton(
//                       context,
//                       label: 'Import PDF',
//                       icon: Icons.upload_file_rounded,
//                       color: const Color(0xFFFF6B6B),
//                       onTap: () => Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (_) => const PdfImportScreen()),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 12),
//               Row(
//                 children: [
//                   Expanded(
//                     child: _actionButton(
//                       context,
//                       label: 'Rankings',
//                       icon: Icons.leaderboard_rounded,
//                       color: const Color(0xFFFFD700),
//                       onTap: () => Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (_) => const SemesterRankingScreen()),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: _actionButton(
//                       context,
//                       label: 'View Alerts',
//                       icon: Icons.notifications_rounded,
//                       color: const Color(0xFFFF9800),
//                       onTap: () {
//                         final state = context
//                             .findAncestorStateOfType<_TeacherDashboardState>();
//                         state?.setState(() => state._selectedIndex = 3);
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _statCard(
//       String title, String value, IconData icon, Color color, bool isDark) {
//     final cardBg = isDark ? const Color(0xFF1A1F4E) : Colors.white;
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
//       decoration: BoxDecoration(
//         color: cardBg,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           )
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.12),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Icon(icon, color: color, size: 24),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(value,
//                     style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                         color: color)),
//                 const SizedBox(height: 2),
//                 Text(title,
//                     style:
//                         const TextStyle(fontSize: 11, color: Color(0xFF8B92B8)),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _actionButton(BuildContext context,
//       {required String label,
//       required IconData icon,
//       required Color color,
//       required VoidCallback onTap}) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 18),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [color, color.withOpacity(0.8)],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           borderRadius: BorderRadius.circular(14),
//         ),
//         child: Column(
//           children: [
//             Icon(icon, color: Colors.white, size: 26),
//             const SizedBox(height: 6),
//             Text(label,
//                 style: const TextStyle(
//                     color: Colors.white, fontWeight: FontWeight.w600)),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'student_list_screen.dart';
// import 'add_student_screen.dart';
// import 'analytics_screen.dart';
// import 'notifications_screen.dart';
// import 'semester_subject_setup_screen.dart';
// import 'pdf_import_screen.dart';
// import 'semester_ranking_screen.dart';
// import 'subject_management_page.dart'; // ← NEW
// import '../utils/gpa_calculator.dart';

// class TeacherDashboard extends StatefulWidget {
//   const TeacherDashboard({super.key});

//   @override
//   State<TeacherDashboard> createState() => _TeacherDashboardState();
// }

// class _TeacherDashboardState extends State<TeacherDashboard> {
//   int _selectedIndex = 0;
//   int _notificationCount = 0;

//   late final List<Widget> _screens;

//   @override
//   void initState() {
//     super.initState();
//     _screens = const [
//       _DashboardHome(),
//       StudentListScreen(),
//       _AnalyticsPlaceholder(),
//       NotificationsScreen(),
//       _SetupTab(),
//     ];
//     _loadNotificationCount();
//   }

//   Future<void> _loadNotificationCount() async {
//     try {
//       final snapshot =
//           await FirebaseFirestore.instance.collection('students').get();
//       int count = 0;
//       for (final doc in snapshot.docs) {
//         final data = doc.data();
//         final results = data['results'] as Map<String, dynamic>? ?? {};
//         if (results.isEmpty) continue;
//         double total = 0;
//         int c = 0;
//         results.forEach((_, mark) {
//           total += GpaCalculator.getGradePoint((mark as num).toDouble());
//           c++;
//         });
//         if (c > 0 && total / c < 5.0) count++;
//       }
//       final allResults =
//           await FirebaseFirestore.instance.collection('results').get();
//       final Map<String, int> arrearMap = {};
//       for (final doc in allResults.docs) {
//         final data = doc.data();
//         final sid = data['studentId'] as String? ?? '';
//         final grade = data['grade'] as String? ?? 'F';
//         if (!GpaCalculator.isPassed(grade)) {
//           arrearMap[sid] = (arrearMap[sid] ?? 0) + 1;
//         }
//       }
//       count += arrearMap.values.where((v) => v > 0).length;
//       if (mounted) setState(() => _notificationCount = count);
//     } catch (_) {}
//   }

//   Future<void> _signOut() async {
//     await FirebaseAuth.instance.signOut();
//     if (mounted) Navigator.pushReplacementNamed(context, '/login');
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final bgColor = isDark ? const Color(0xFF0A0E27) : const Color(0xFFF4F6FF);
//     final navBg = isDark ? const Color(0xFF1A1F4E) : Colors.white;
//     final textColor = isDark ? Colors.white : const Color(0xFF2D3142);

//     return Scaffold(
//       backgroundColor: bgColor,
//       appBar: AppBar(
//         backgroundColor: navBg,
//         elevation: 0,
//         title: Text('Teacher Dashboard',
//             style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
//         actions: [
//           if (_selectedIndex == 0)
//             IconButton(
//               icon: const Icon(Icons.person_add_rounded,
//                   color: Color(0xFF6C63FF)),
//               onPressed: () => Navigator.push(context,
//                   MaterialPageRoute(builder: (_) => const AddStudentScreen())),
//               tooltip: 'Add Student',
//             ),
//           IconButton(
//             icon: Icon(Icons.logout_rounded, color: textColor),
//             onPressed: _signOut,
//             tooltip: 'Logout',
//           ),
//         ],
//       ),
//       body: _screens[_selectedIndex],
//       bottomNavigationBar: NavigationBar(
//         selectedIndex: _selectedIndex,
//         onDestinationSelected: (index) {
//           setState(() => _selectedIndex = index);
//           if (index == 3) _loadNotificationCount();
//         },
//         backgroundColor: navBg,
//         indicatorColor: const Color(0xFF6C63FF).withOpacity(0.15),
//         labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
//         destinations: [
//           const NavigationDestination(
//             icon: Icon(Icons.home_outlined),
//             selectedIcon: Icon(Icons.home_rounded, color: Color(0xFF6C63FF)),
//             label: 'Home',
//           ),
//           const NavigationDestination(
//             icon: Icon(Icons.people_outline),
//             selectedIcon: Icon(Icons.people_rounded, color: Color(0xFF6C63FF)),
//             label: 'Students',
//           ),
//           const NavigationDestination(
//             icon: Icon(Icons.bar_chart_outlined),
//             selectedIcon:
//                 Icon(Icons.bar_chart_rounded, color: Color(0xFF6C63FF)),
//             label: 'Analytics',
//           ),
//           NavigationDestination(
//             icon: Badge(
//               isLabelVisible: _notificationCount > 0,
//               label: Text('$_notificationCount'),
//               child: const Icon(Icons.notifications_outlined),
//             ),
//             selectedIcon: Badge(
//               isLabelVisible: _notificationCount > 0,
//               label: Text('$_notificationCount'),
//               child: const Icon(Icons.notifications_rounded,
//                   color: Color(0xFF6C63FF)),
//             ),
//             label: 'Alerts',
//           ),
//           const NavigationDestination(
//             icon: Icon(Icons.settings_outlined),
//             selectedIcon:
//                 Icon(Icons.settings_rounded, color: Color(0xFF6C63FF)),
//             label: 'Setup',
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ─── Setup Tab ────────────────────────────────────────────────────────
// class _SetupTab extends StatelessWidget {
//   const _SetupTab();

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final textColor = isDark ? Colors.white : const Color(0xFF2D3142);
//     final cardBg = isDark ? const Color(0xFF1A1F4E) : Colors.white;
//     final subColor = isDark ? const Color(0xFF8B92B8) : const Color(0xFF6B7280);

//     return ListView(
//       padding: const EdgeInsets.all(16),
//       children: [
//         Container(
//           width: double.infinity,
//           padding: const EdgeInsets.all(20),
//           decoration: BoxDecoration(
//             gradient: const LinearGradient(
//               colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: const Row(children: [
//             Icon(Icons.admin_panel_settings_rounded,
//                 color: Colors.white, size: 40),
//             SizedBox(width: 14),
//             Expanded(
//               child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text('Result Setup',
//                         style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold)),
//                     SizedBox(height: 2),
//                     Text('Configure subjects, import PDFs and view rankings',
//                         style: TextStyle(color: Colors.white70, fontSize: 12)),
//                   ]),
//             ),
//           ]),
//         ),
//         const SizedBox(height: 20),

//         Text('Workflow',
//             style: TextStyle(
//                 color: textColor, fontWeight: FontWeight.bold, fontSize: 15)),
//         const SizedBox(height: 10),
//         _workflowCard(cardBg, subColor),
//         const SizedBox(height: 20),

//         Text('Actions',
//             style: TextStyle(
//                 color: textColor, fontWeight: FontWeight.bold, fontSize: 15)),
//         const SizedBox(height: 12),

//         // ── NEW: Subject Master ──────────────────────────────────
//         _actionCard(
//           context,
//           title: 'Subject Master',
//           subtitle: 'Add, edit & delete subjects centrally for all semesters',
//           icon: Icons.library_books_rounded,
//           color: const Color(0xFF4ECDC4),
//           onTap: () => Navigator.push(context,
//               MaterialPageRoute(builder: (_) => const SubjectManagementPage())),
//         ),
//         const SizedBox(height: 12),

//         // Subject Setup
//         _actionCard(
//           context,
//           title: 'Subject Setup',
//           subtitle: 'Add subjects with codes & credits per semester',
//           icon: Icons.book_rounded,
//           color: const Color(0xFF6C63FF),
//           onTap: () => Navigator.push(
//               context,
//               MaterialPageRoute(
//                   builder: (_) => const SemesterSubjectSetupScreen())),
//         ),
//         const SizedBox(height: 12),

//         // PDF Import
//         _actionCard(
//           context,
//           title: 'Import Result PDF',
//           subtitle: 'Upload student result PDF — auto-parsed & saved',
//           icon: Icons.picture_as_pdf_rounded,
//           color: const Color(0xFFFF6B6B),
//           onTap: () => Navigator.push(context,
//               MaterialPageRoute(builder: (_) => const PdfImportScreen())),
//         ),
//         const SizedBox(height: 12),

//         // Rankings
//         _actionCard(
//           context,
//           title: 'Semester Rankings',
//           subtitle: 'View GPA & CGPA leaderboard for all students',
//           icon: Icons.leaderboard_rounded,
//           color: const Color(0xFFFFD700),
//           onTap: () => Navigator.push(context,
//               MaterialPageRoute(builder: (_) => const SemesterRankingScreen())),
//         ),
//         const SizedBox(height: 24),
//       ],
//     );
//   }

//   Widget _workflowCard(Color cardBg, Color subColor) {
//     final steps = [
//       ('1', 'Add Subjects', Icons.book_outlined, const Color(0xFF6C63FF)),
//       ('2', 'Upload PDF', Icons.upload_file_rounded, const Color(0xFFFF6B6B)),
//       (
//         '3',
//         'Auto Parsed',
//         Icons.auto_fix_high_rounded,
//         const Color(0xFF4ECDC4)
//       ),
//       ('4', 'GPA & CGPA', Icons.grade_rounded, const Color(0xFF43A047)),
//       ('5', 'Rankings', Icons.leaderboard_rounded, const Color(0xFFFFD700)),
//     ];

//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: cardBg,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 8,
//               offset: const Offset(0, 2))
//         ],
//       ),
//       child: Row(
//         children: steps.asMap().entries.map((entry) {
//           final i = entry.key;
//           final s = entry.value;
//           return Expanded(
//             child: Row(children: [
//               Expanded(
//                 child: Column(children: [
//                   Container(
//                     width: 36,
//                     height: 36,
//                     decoration: BoxDecoration(
//                         color: s.$4.withOpacity(0.15), shape: BoxShape.circle),
//                     child: Icon(s.$3, color: s.$4, size: 18),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(s.$2,
//                       style: TextStyle(color: subColor, fontSize: 9),
//                       textAlign: TextAlign.center,
//                       maxLines: 2),
//                 ]),
//               ),
//               if (i < steps.length - 1)
//                 Icon(Icons.arrow_forward_rounded, size: 14, color: subColor),
//             ]),
//           );
//         }).toList(),
//       ),
//     );
//   }

//   Widget _actionCard(
//     BuildContext context, {
//     required String title,
//     required String subtitle,
//     required IconData icon,
//     required Color color,
//     required VoidCallback onTap,
//   }) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final cardBg = isDark ? const Color(0xFF1A1F4E) : Colors.white;

//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: cardBg,
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(color: color.withOpacity(0.25)),
//           boxShadow: [
//             BoxShadow(
//                 color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
//                 blurRadius: 8,
//                 offset: const Offset(0, 2))
//           ],
//         ),
//         child: Row(children: [
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//                 color: color.withOpacity(0.12),
//                 borderRadius: BorderRadius.circular(12)),
//             child: Icon(icon, color: color, size: 26),
//           ),
//           const SizedBox(width: 14),
//           Expanded(
//             child:
//                 Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//               Text(title,
//                   style: TextStyle(
//                       color: isDark ? Colors.white : const Color(0xFF2D3142),
//                       fontWeight: FontWeight.bold,
//                       fontSize: 15)),
//               const SizedBox(height: 3),
//               Text(subtitle,
//                   style:
//                       const TextStyle(color: Color(0xFF8B92B8), fontSize: 12)),
//             ]),
//           ),
//           Icon(Icons.arrow_forward_ios_rounded, color: color, size: 16),
//         ]),
//       ),
//     );
//   }
// }

// // ─── Analytics Tab (unchanged) ────────────────────────────────────────
// class _AnalyticsPlaceholder extends StatelessWidget {
//   const _AnalyticsPlaceholder();

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final textColor = isDark ? Colors.white : const Color(0xFF2D3142);
//     final subColor = isDark ? const Color(0xFF8B92B8) : const Color(0xFF6B7280);
//     final cardBg = isDark ? const Color(0xFF1A1F4E) : Colors.white;

//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance.collection('students').snapshots(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData)
//           return const Center(child: CircularProgressIndicator());
//         final docs = snapshot.data!.docs;
//         return ListView(
//           padding: const EdgeInsets.all(16),
//           children: [
//             Text('Class Analytics',
//                 style: TextStyle(
//                     color: textColor,
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold)),
//             const SizedBox(height: 4),
//             Text('Tap a student to view detailed analytics',
//                 style: TextStyle(color: subColor, fontSize: 13)),
//             const SizedBox(height: 16),
//             ...docs.map((doc) {
//               final data = doc.data() as Map<String, dynamic>;
//               final name = data['name'] ?? 'Unknown';
//               final regNo = data['regNo'] ?? '';

//               return FutureBuilder<QuerySnapshot>(
//                 future: FirebaseFirestore.instance
//                     .collection('results')
//                     .where('studentId', isEqualTo: doc.id)
//                     .get(),
//                 builder: (ctx, resSnap) {
//                   final allResults = <Map<String, dynamic>>[];
//                   if (resSnap.hasData) {
//                     for (final d in resSnap.data!.docs) {
//                       allResults.add(d.data() as Map<String, dynamic>);
//                     }
//                   }
//                   final legacyResults =
//                       data['results'] as Map<String, dynamic>? ?? {};
//                   if (allResults.isEmpty && legacyResults.isNotEmpty) {
//                     legacyResults.forEach((key, val) {
//                       if (val is Map) {
//                         allResults.add({
//                           'subjectCode': key,
//                           'subjectName': val['subjectName'] ?? key,
//                           'credits': val['credits'] ?? 3,
//                           'grade': val['grade'] ?? 'F',
//                           'gradePoint': val['gradePoint'] ?? 0,
//                           'semester': val['semester'] ?? 1,
//                         });
//                       }
//                     });
//                   }
//                   final cgpa = GpaCalculator.calculateCGPA(allResults);

//                   return GestureDetector(
//                     onTap: () => Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (_) => AnalyticsScreen(
//                                 studentId: doc.id,
//                                 studentName: name,
//                                 allResults: allResults))),
//                     child: Container(
//                       margin: const EdgeInsets.only(bottom: 12),
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: cardBg,
//                         borderRadius: BorderRadius.circular(14),
//                         boxShadow: [
//                           BoxShadow(
//                               color:
//                                   Colors.black.withOpacity(isDark ? 0.3 : 0.05),
//                               blurRadius: 8,
//                               offset: const Offset(0, 2))
//                         ],
//                       ),
//                       child: Row(children: [
//                         CircleAvatar(
//                           backgroundColor:
//                               const Color(0xFF6C63FF).withOpacity(0.15),
//                           child: Text(
//                               name.isNotEmpty ? name[0].toUpperCase() : '?',
//                               style: const TextStyle(
//                                   color: Color(0xFF6C63FF),
//                                   fontWeight: FontWeight.bold)),
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(name,
//                                     style: TextStyle(
//                                         color: textColor,
//                                         fontWeight: FontWeight.bold)),
//                                 Text(regNo,
//                                     style: TextStyle(
//                                         color: subColor, fontSize: 12)),
//                               ]),
//                         ),
//                         Column(
//                             crossAxisAlignment: CrossAxisAlignment.end,
//                             children: [
//                               Text(
//                                   allResults.isEmpty
//                                       ? '—'
//                                       : cgpa.toStringAsFixed(2),
//                                   style: const TextStyle(
//                                       color: Color(0xFF6C63FF),
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 16)),
//                               Text('CGPA',
//                                   style:
//                                       TextStyle(color: subColor, fontSize: 11)),
//                             ]),
//                         const SizedBox(width: 8),
//                         const Icon(Icons.chevron_right_rounded,
//                             color: Color(0xFF6C63FF)),
//                       ]),
//                     ),
//                   );
//                 },
//               );
//             }),
//           ],
//         );
//       },
//     );
//   }
// }

// // ─── Dashboard Home (unchanged) ───────────────────────────────────────
// class _DashboardHome extends StatelessWidget {
//   const _DashboardHome();

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final textColor = isDark ? Colors.white : const Color(0xFF2D3142);

//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance.collection('students').snapshots(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData)
//           return const Center(child: CircularProgressIndicator());
//         final students = snapshot.data!.docs;
//         final totalStudents = students.length;

//         return SingleChildScrollView(
//           padding: const EdgeInsets.all(16),
//           child:
//               Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 gradient: const LinearGradient(
//                     colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight),
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: Row(children: [
//                 const Icon(Icons.school_rounded, color: Colors.white, size: 40),
//                 const SizedBox(width: 14),
//                 Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                   const Text('Welcome, Teacher 👋',
//                       style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold)),
//                   const SizedBox(height: 2),
//                   Text('Here\'s a quick overview',
//                       style: TextStyle(
//                           color: Colors.white.withOpacity(0.8), fontSize: 13)),
//                 ]),
//               ]),
//             ),
//             const SizedBox(height: 20),
//             FutureBuilder<QuerySnapshot>(
//               future: FirebaseFirestore.instance.collection('results').get(),
//               builder: (ctx, resSnap) {
//                 int passCount = 0, failCount = 0;
//                 double totalGpa = 0;
//                 int gpaCount = 0;
//                 if (resSnap.hasData) {
//                   final Map<String, List<Map<String, dynamic>>> byStudent = {};
//                   for (final doc in resSnap.data!.docs) {
//                     final data = doc.data() as Map<String, dynamic>;
//                     final sid = data['studentId'] as String? ?? '';
//                     if (sid.isEmpty) continue;
//                     byStudent.putIfAbsent(sid, () => []);
//                     byStudent[sid]!.add(data);
//                   }
//                   byStudent.forEach((_, results) {
//                     final gpa = GpaCalculator.calculateCGPA(results);
//                     totalGpa += gpa;
//                     gpaCount++;
//                     gpa >= 5.0 ? passCount++ : failCount++;
//                   });
//                 }
//                 final avgGpa = gpaCount > 0 ? totalGpa / gpaCount : 0.0;

//                 return Column(children: [
//                   Row(children: [
//                     Expanded(
//                         child: _statCard(
//                             'Total Students',
//                             '$totalStudents',
//                             Icons.school_rounded,
//                             const Color(0xFF6C63FF),
//                             isDark)),
//                     const SizedBox(width: 12),
//                     Expanded(
//                         child: _statCard(
//                             'Avg CGPA',
//                             avgGpa.toStringAsFixed(2),
//                             Icons.grade_rounded,
//                             const Color(0xFF4ECDC4),
//                             isDark)),
//                   ]),
//                   const SizedBox(height: 12),
//                   Row(children: [
//                     Expanded(
//                         child: _statCard(
//                             'Passed',
//                             '$passCount',
//                             Icons.check_circle_rounded,
//                             const Color(0xFF43A047),
//                             isDark)),
//                     const SizedBox(width: 12),
//                     Expanded(
//                         child: _statCard(
//                             'At Risk',
//                             '$failCount',
//                             Icons.warning_rounded,
//                             const Color(0xFFE53935),
//                             isDark)),
//                   ]),
//                 ]);
//               },
//             ),
//             const SizedBox(height: 24),
//             Text('Quick Actions',
//                 style: TextStyle(
//                     color: textColor,
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold)),
//             const SizedBox(height: 12),
//             Row(children: [
//               Expanded(
//                   child: _actionButton(context,
//                       label: 'View Analytics',
//                       icon: Icons.bar_chart_rounded,
//                       color: const Color(0xFF6C63FF), onTap: () {
//                 final state =
//                     context.findAncestorStateOfType<_TeacherDashboardState>();
//                 state?.setState(() => state._selectedIndex = 2);
//               })),
//               const SizedBox(width: 12),
//               Expanded(
//                   child: _actionButton(context,
//                       label: 'Import PDF',
//                       icon: Icons.upload_file_rounded,
//                       color: const Color(0xFFFF6B6B),
//                       onTap: () => Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                               builder: (_) => const PdfImportScreen())))),
//             ]),
//             const SizedBox(height: 12),
//             Row(children: [
//               Expanded(
//                   child: _actionButton(context,
//                       label: 'Rankings',
//                       icon: Icons.leaderboard_rounded,
//                       color: const Color(0xFFFFD700),
//                       onTap: () => Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                               builder: (_) => const SemesterRankingScreen())))),
//               const SizedBox(width: 12),
//               Expanded(
//                   child: _actionButton(context,
//                       label: 'View Alerts',
//                       icon: Icons.notifications_rounded,
//                       color: const Color(0xFFFF9800), onTap: () {
//                 final state =
//                     context.findAncestorStateOfType<_TeacherDashboardState>();
//                 state?.setState(() => state._selectedIndex = 3);
//               })),
//             ]),
//             const SizedBox(height: 16),
//           ]),
//         );
//       },
//     );
//   }

//   Widget _statCard(
//       String title, String value, IconData icon, Color color, bool isDark) {
//     final cardBg = isDark ? const Color(0xFF1A1F4E) : Colors.white;
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
//       decoration: BoxDecoration(
//         color: cardBg,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//               color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
//               blurRadius: 10,
//               offset: const Offset(0, 4))
//         ],
//       ),
//       child: Row(children: [
//         Container(
//           padding: const EdgeInsets.all(10),
//           decoration: BoxDecoration(
//               color: color.withOpacity(0.12),
//               borderRadius: BorderRadius.circular(12)),
//           child: Icon(icon, color: color, size: 24),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//             child:
//                 Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           Text(value,
//               style: TextStyle(
//                   fontSize: 20, fontWeight: FontWeight.bold, color: color)),
//           const SizedBox(height: 2),
//           Text(title,
//               style: const TextStyle(fontSize: 11, color: Color(0xFF8B92B8)),
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis),
//         ])),
//       ]),
//     );
//   }

//   Widget _actionButton(
//     BuildContext context, {
//     required String label,
//     required IconData icon,
//     required Color color,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 18),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//               colors: [color, color.withOpacity(0.8)],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight),
//           borderRadius: BorderRadius.circular(14),
//         ),
//         child: Column(children: [
//           Icon(icon, color: Colors.white, size: 26),
//           const SizedBox(height: 6),
//           Text(label,
//               style: const TextStyle(
//                   color: Colors.white, fontWeight: FontWeight.w600)),
//         ]),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'student_list_screen.dart';
import 'add_student_screen.dart';
import 'analytics_screen.dart';
import 'notifications_screen.dart';
// ❌ REMOVED: import 'semester_subject_setup_screen.dart';
import 'pdf_import_screen.dart';
import 'semester_ranking_screen.dart';
import 'subject_management_page.dart';
import '../utils/gpa_calculator.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  int _selectedIndex = 0;
  int _notificationCount = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = const [
      _DashboardHome(),
      StudentListScreen(),
      _AnalyticsPlaceholder(),
      NotificationsScreen(),
      _SetupTab(),
    ];
    _loadNotificationCount();
  }

  Future<void> _loadNotificationCount() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('students').get();
      int count = 0;
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final results = data['results'] as Map<String, dynamic>? ?? {};
        if (results.isEmpty) continue;
        double total = 0;
        int c = 0;
        results.forEach((_, mark) {
          total += GpaCalculator.getGradePoint((mark as num).toDouble());
          c++;
        });
        if (c > 0 && total / c < 5.0) count++;
      }
      final allResults =
          await FirebaseFirestore.instance.collection('results').get();
      final Map<String, int> arrearMap = {};
      for (final doc in allResults.docs) {
        final data = doc.data();
        final sid = data['studentId'] as String? ?? '';
        final grade = data['grade'] as String? ?? 'F';
        if (!GpaCalculator.isPassed(grade)) {
          arrearMap[sid] = (arrearMap[sid] ?? 0) + 1;
        }
      }
      count += arrearMap.values.where((v) => v > 0).length;
      if (mounted) setState(() => _notificationCount = count);
    } catch (_) {}
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0A0E27) : const Color(0xFFF4F6FF);
    final navBg = isDark ? const Color(0xFF1A1F4E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF2D3142);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: navBg,
        elevation: 0,
        title: Text('Teacher Dashboard',
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        actions: [
          if (_selectedIndex == 0)
            IconButton(
              icon: const Icon(Icons.person_add_rounded,
                  color: Color(0xFF6C63FF)),
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AddStudentScreen())),
              tooltip: 'Add Student',
            ),
          IconButton(
            icon: Icon(Icons.logout_rounded, color: textColor),
            onPressed: _signOut,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
          if (index == 3) _loadNotificationCount();
        },
        backgroundColor: navBg,
        indicatorColor: const Color(0xFF6C63FF).withOpacity(0.15),
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded, color: Color(0xFF6C63FF)),
            label: 'Home',
          ),
          const NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people_rounded, color: Color(0xFF6C63FF)),
            label: 'Students',
          ),
          const NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon:
                Icon(Icons.bar_chart_rounded, color: Color(0xFF6C63FF)),
            label: 'Analytics',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: _notificationCount > 0,
              label: Text('$_notificationCount'),
              child: const Icon(Icons.notifications_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: _notificationCount > 0,
              label: Text('$_notificationCount'),
              child: const Icon(Icons.notifications_rounded,
                  color: Color(0xFF6C63FF)),
            ),
            label: 'Alerts',
          ),
          const NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon:
                Icon(Icons.settings_rounded, color: Color(0xFF6C63FF)),
            label: 'Setup',
          ),
        ],
      ),
    );
  }
}

// ─── Setup Tab ────────────────────────────────────────────────────────
class _SetupTab extends StatelessWidget {
  const _SetupTab();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF2D3142);
    final cardBg = isDark ? const Color(0xFF1A1F4E) : Colors.white;
    final subColor = isDark ? const Color(0xFF8B92B8) : const Color(0xFF6B7280);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── Header banner ──────────────────────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(children: [
            Icon(Icons.admin_panel_settings_rounded,
                color: Colors.white, size: 40),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Result Setup',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 2),
                    Text('Configure subjects, import PDFs and view rankings',
                        style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ]),
            ),
          ]),
        ),
        const SizedBox(height: 20),

        // ── Workflow steps ─────────────────────────────────────────
        Text('Workflow',
            style: TextStyle(
                color: textColor, fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 10),
        _workflowCard(cardBg, subColor),
        const SizedBox(height: 20),

        // ── Action cards ───────────────────────────────────────────
        Text('Actions',
            style: TextStyle(
                color: textColor, fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 12),

        // ✅ Subject Master (replaces old Subject Setup)
        _actionCard(
          context,
          title: 'Subject Master',
          subtitle: 'Add, edit & delete subjects centrally for all semesters',
          icon: Icons.library_books_rounded,
          color: const Color(0xFF4ECDC4),
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const SubjectManagementPage())),
        ),
        const SizedBox(height: 12),

        // ❌ REMOVED: Subject Setup card (semester_subject_setup_screen.dart)

        // ✅ Import Result PDF
        _actionCard(
          context,
          title: 'Import Result PDF',
          subtitle: 'Upload student result PDF — auto-parsed & saved',
          icon: Icons.picture_as_pdf_rounded,
          color: const Color(0xFFFF6B6B),
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const PdfImportScreen())),
        ),
        const SizedBox(height: 12),

        // ✅ Semester Rankings
        _actionCard(
          context,
          title: 'Semester Rankings',
          subtitle: 'View GPA & CGPA leaderboard for all students',
          icon: Icons.leaderboard_rounded,
          color: const Color(0xFFFFD700),
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const SemesterRankingScreen())),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _workflowCard(Color cardBg, Color subColor) {
    final steps = [
      ('1', 'Add Subjects', Icons.book_outlined, const Color(0xFF6C63FF)),
      ('2', 'Upload PDF', Icons.upload_file_rounded, const Color(0xFFFF6B6B)),
      (
        '3',
        'Auto Parsed',
        Icons.auto_fix_high_rounded,
        const Color(0xFF4ECDC4)
      ),
      ('4', 'GPA & CGPA', Icons.grade_rounded, const Color(0xFF43A047)),
      ('5', 'Rankings', Icons.leaderboard_rounded, const Color(0xFFFFD700)),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: steps.asMap().entries.map((entry) {
          final i = entry.key;
          final s = entry.value;
          return Expanded(
            child: Row(children: [
              Expanded(
                child: Column(children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                        color: s.$4.withOpacity(0.15), shape: BoxShape.circle),
                    child: Icon(s.$3, color: s.$4, size: 18),
                  ),
                  const SizedBox(height: 4),
                  Text(s.$2,
                      style: TextStyle(color: subColor, fontSize: 9),
                      textAlign: TextAlign.center,
                      maxLines: 2),
                ]),
              ),
              if (i < steps.length - 1)
                Icon(Icons.arrow_forward_rounded, size: 14, color: subColor),
            ]),
          );
        }).toList(),
      ),
    );
  }

  Widget _actionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1A1F4E) : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.25)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF2D3142),
                      fontWeight: FontWeight.bold,
                      fontSize: 15)),
              const SizedBox(height: 3),
              Text(subtitle,
                  style:
                      const TextStyle(color: Color(0xFF8B92B8), fontSize: 12)),
            ]),
          ),
          Icon(Icons.arrow_forward_ios_rounded, color: color, size: 16),
        ]),
      ),
    );
  }
}

// ─── Analytics Tab (unchanged) ────────────────────────────────────────
class _AnalyticsPlaceholder extends StatelessWidget {
  const _AnalyticsPlaceholder();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF2D3142);
    final subColor = isDark ? const Color(0xFF8B92B8) : const Color(0xFF6B7280);
    final cardBg = isDark ? const Color(0xFF1A1F4E) : Colors.white;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('students').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Class Analytics',
                style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Tap a student to view detailed analytics',
                style: TextStyle(color: subColor, fontSize: 13)),
            const SizedBox(height: 16),
            ...docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final name = data['name'] ?? 'Unknown';
              final regNo = data['regNo'] ?? '';

              return FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection('results')
                    .where('studentId', isEqualTo: doc.id)
                    .get(),
                builder: (ctx, resSnap) {
                  final allResults = <Map<String, dynamic>>[];
                  if (resSnap.hasData) {
                    for (final d in resSnap.data!.docs) {
                      allResults.add(d.data() as Map<String, dynamic>);
                    }
                  }
                  final legacyResults =
                      data['results'] as Map<String, dynamic>? ?? {};
                  if (allResults.isEmpty && legacyResults.isNotEmpty) {
                    legacyResults.forEach((key, val) {
                      if (val is Map) {
                        allResults.add({
                          'subjectCode': key,
                          'subjectName': val['subjectName'] ?? key,
                          'credits': val['credits'] ?? 3,
                          'grade': val['grade'] ?? 'F',
                          'gradePoint': val['gradePoint'] ?? 0,
                          'semester': val['semester'] ?? 1,
                        });
                      }
                    });
                  }
                  final cgpa = GpaCalculator.calculateCGPA(allResults);

                  return GestureDetector(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => AnalyticsScreen(
                                studentId: doc.id,
                                studentName: name,
                                allResults: allResults))),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                              color:
                                  Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2))
                        ],
                      ),
                      child: Row(children: [
                        CircleAvatar(
                          backgroundColor:
                              const Color(0xFF6C63FF).withOpacity(0.15),
                          child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : '?',
                              style: const TextStyle(
                                  color: Color(0xFF6C63FF),
                                  fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name,
                                    style: TextStyle(
                                        color: textColor,
                                        fontWeight: FontWeight.bold)),
                                Text(regNo,
                                    style: TextStyle(
                                        color: subColor, fontSize: 12)),
                              ]),
                        ),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                  allResults.isEmpty
                                      ? '—'
                                      : cgpa.toStringAsFixed(2),
                                  style: const TextStyle(
                                      color: Color(0xFF6C63FF),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              Text('CGPA',
                                  style:
                                      TextStyle(color: subColor, fontSize: 11)),
                            ]),
                        const SizedBox(width: 8),
                        const Icon(Icons.chevron_right_rounded,
                            color: Color(0xFF6C63FF)),
                      ]),
                    ),
                  );
                },
              );
            }),
          ],
        );
      },
    );
  }
}

// ─── Dashboard Home (unchanged) ───────────────────────────────────────
class _DashboardHome extends StatelessWidget {
  const _DashboardHome();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF2D3142);

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('students').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        final students = snapshot.data!.docs;
        final totalStudents = students.length;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(children: [
                const Icon(Icons.school_rounded, color: Colors.white, size: 40),
                const SizedBox(width: 14),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Welcome, Teacher 👋',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text('Here\'s a quick overview',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.8), fontSize: 13)),
                ]),
              ]),
            ),
            const SizedBox(height: 20),
            FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance.collection('results').get(),
              builder: (ctx, resSnap) {
                int passCount = 0, failCount = 0;
                double totalGpa = 0;
                int gpaCount = 0;
                if (resSnap.hasData) {
                  final Map<String, List<Map<String, dynamic>>> byStudent = {};
                  for (final doc in resSnap.data!.docs) {
                    final data = doc.data() as Map<String, dynamic>;
                    final sid = data['studentId'] as String? ?? '';
                    if (sid.isEmpty) continue;
                    byStudent.putIfAbsent(sid, () => []);
                    byStudent[sid]!.add(data);
                  }
                  byStudent.forEach((_, results) {
                    final gpa = GpaCalculator.calculateCGPA(results);
                    totalGpa += gpa;
                    gpaCount++;
                    gpa >= 5.0 ? passCount++ : failCount++;
                  });
                }
                final avgGpa = gpaCount > 0 ? totalGpa / gpaCount : 0.0;

                return Column(children: [
                  Row(children: [
                    Expanded(
                        child: _statCard(
                            'Total Students',
                            '$totalStudents',
                            Icons.school_rounded,
                            const Color(0xFF6C63FF),
                            isDark)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _statCard(
                            'Avg CGPA',
                            avgGpa.toStringAsFixed(2),
                            Icons.grade_rounded,
                            const Color(0xFF4ECDC4),
                            isDark)),
                  ]),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                        child: _statCard(
                            'Passed',
                            '$passCount',
                            Icons.check_circle_rounded,
                            const Color(0xFF43A047),
                            isDark)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _statCard(
                            'At Risk',
                            '$failCount',
                            Icons.warning_rounded,
                            const Color(0xFFE53935),
                            isDark)),
                  ]),
                ]);
              },
            ),
            const SizedBox(height: 24),
            Text('Quick Actions',
                style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                  child: _actionButton(context,
                      label: 'View Analytics',
                      icon: Icons.bar_chart_rounded,
                      color: const Color(0xFF6C63FF), onTap: () {
                final state =
                    context.findAncestorStateOfType<_TeacherDashboardState>();
                state?.setState(() => state._selectedIndex = 2);
              })),
              const SizedBox(width: 12),
              Expanded(
                  child: _actionButton(context,
                      label: 'Import PDF',
                      icon: Icons.upload_file_rounded,
                      color: const Color(0xFFFF6B6B),
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const PdfImportScreen())))),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                  child: _actionButton(context,
                      label: 'Rankings',
                      icon: Icons.leaderboard_rounded,
                      color: const Color(0xFFFFD700),
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SemesterRankingScreen())))),
              const SizedBox(width: 12),
              Expanded(
                  child: _actionButton(context,
                      label: 'View Alerts',
                      icon: Icons.notifications_rounded,
                      color: const Color(0xFFFF9800), onTap: () {
                final state =
                    context.findAncestorStateOfType<_TeacherDashboardState>();
                state?.setState(() => state._selectedIndex = 3);
              })),
            ]),
            const SizedBox(height: 16),
          ]),
        );
      },
    );
  }

  Widget _statCard(
      String title, String value, IconData icon, Color color, bool isDark) {
    final cardBg = isDark ? const Color(0xFF1A1F4E) : Colors.white;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value,
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(title,
              style: const TextStyle(fontSize: 11, color: Color(0xFF8B92B8)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ])),
      ]),
    );
  }

  Widget _actionButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [color, color.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(children: [
          Icon(icon, color: Colors.white, size: 26),
          const SizedBox(height: 6),
          Text(label,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}
