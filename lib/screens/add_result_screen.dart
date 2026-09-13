// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../utils/gpa_calculator.dart';

// class AddResultScreen extends StatefulWidget {
//   const AddResultScreen({super.key});

//   @override
//   State<AddResultScreen> createState() => _AddResultScreenState();
// }

// class _AddResultScreenState extends State<AddResultScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _subjectCodeController = TextEditingController();
//   final _subjectNameController = TextEditingController();
//   final _creditsController = TextEditingController();

//   String? selectedStudentId;
//   String? selectedStudentName;
//   String selectedGrade = 'S';
//   int selectedSemester = 1;
//   bool isLoading = false;
//   bool isFetchingStudents = true;
//   List<Map<String, dynamic>> students = [];

//   final grades = ['S', 'A', 'B', 'C', 'D', 'E', 'F'];
//   final semesters = [1, 2, 3, 4];

//   @override
//   void initState() {
//     super.initState();
//     _fetchStudents();
//   }

//   @override
//   void dispose() {
//     _subjectCodeController.dispose();
//     _subjectNameController.dispose();
//     _creditsController.dispose();
//     super.dispose();
//   }

//   Future<void> _fetchStudents() async {
//     try {
//       final snap = await FirebaseFirestore.instance
//           .collection('students')
//           .orderBy('name')
//           .get();
//       setState(() {
//         students = snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
//         isFetchingStudents = false;
//       });
//     } catch (e) {
//       setState(() => isFetchingStudents = false);
//     }
//   }

//   Future<void> _saveResult() async {
//     if (!_formKey.currentState!.validate()) return;
//     if (selectedStudentId == null) {
//       _showError('Please select a student');
//       return;
//     }

//     setState(() => isLoading = true);
//     try {
//       // Check for duplicate subject in same semester
//       final existing = await FirebaseFirestore.instance
//           .collection('results')
//           .where('studentId', isEqualTo: selectedStudentId)
//           .where('semester', isEqualTo: selectedSemester)
//           .where('subjectCode',
//               isEqualTo: _subjectCodeController.text.trim().toUpperCase())
//           .get();

//       if (existing.docs.isNotEmpty) {
//         _showError(
//             'Result for this subject already exists in Semester $selectedSemester!');
//         setState(() => isLoading = false);
//         return;
//       }

//       final gradePoint = GpaCalculator.gradeToPoint(selectedGrade);
//       final credits = double.parse(_creditsController.text.trim());

//       await FirebaseFirestore.instance.collection('results').add({
//         'studentId': selectedStudentId,
//         'studentName': selectedStudentName,
//         'subjectCode': _subjectCodeController.text.trim().toUpperCase(),
//         'subjectName': _subjectNameController.text.trim(),
//         'credits': credits,
//         'grade': selectedGrade,
//         'gradePoint': gradePoint,
//         'semester': selectedSemester,
//         'createdAt': FieldValue.serverTimestamp(),
//       });

//       if (!mounted) return;
//       _showSuccess('Result added successfully!');
//       // Clear form for next entry
//       _subjectCodeController.clear();
//       _subjectNameController.clear();
//       _creditsController.clear();
//       setState(() => selectedGrade = 'S');
//     } catch (e) {
//       _showError('Failed to save result. Please try again.');
//     } finally {
//       if (mounted) setState(() => isLoading = false);
//     }
//   }

//   void _showError(String msg) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//       content: Row(children: [
//         const Icon(Icons.error_outline, color: Colors.white, size: 18),
//         const SizedBox(width: 8),
//         Expanded(child: Text(msg)),
//       ]),
//       backgroundColor: const Color(0xFFE53935),
//       behavior: SnackBarBehavior.floating,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       margin: const EdgeInsets.all(16),
//     ));
//   }

//   void _showSuccess(String msg) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//       content: Row(children: [
//         const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
//         const SizedBox(width: 8),
//         Text(msg),
//       ]),
//       backgroundColor: const Color(0xFF43A047),
//       behavior: SnackBarBehavior.floating,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       margin: const EdgeInsets.all(16),
//     ));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF0A0E27),
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF1A1F4E),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text('Add Result',
//             style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//         elevation: 0,
//       ),
//       body: isFetchingStudents
//           ? const Center(
//               child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
//           : SafeArea(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.all(20),
//                 child: Form(
//                   key: _formKey,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Header
//                       Container(
//                         width: double.infinity,
//                         padding: const EdgeInsets.all(20),
//                         decoration: BoxDecoration(
//                           gradient: const LinearGradient(
//                               colors: [Color(0xFF4ECDC4), Color(0xFF6C63FF)]),
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: const Row(
//                           children: [
//                             Icon(Icons.add_chart_rounded,
//                                 color: Colors.white, size: 40),
//                             SizedBox(width: 16),
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text('Enter Result',
//                                     style: TextStyle(
//                                         color: Colors.white,
//                                         fontSize: 18,
//                                         fontWeight: FontWeight.bold)),
//                                 Text('Fill in the subject result details',
//                                     style: TextStyle(
//                                         color: Colors.white70, fontSize: 13)),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(height: 28),

//                       // Select Student
//                       _buildSectionLabel('Select Student'),
//                       const SizedBox(height: 8),
//                       Container(
//                         decoration: BoxDecoration(
//                           color: const Color(0xFF1A1F4E),
//                           borderRadius: BorderRadius.circular(14),
//                           border: Border.all(
//                               color: const Color(0xFF2D3470), width: 1.5),
//                         ),
//                         child: DropdownButtonFormField<String>(
//                           value: selectedStudentId,
//                           dropdownColor: const Color(0xFF1A1F4E),
//                           style: const TextStyle(
//                               color: Colors.white, fontSize: 15),
//                           icon: const Icon(Icons.keyboard_arrow_down_rounded,
//                               color: Color(0xFF6C63FF)),
//                           decoration: const InputDecoration(
//                             contentPadding: EdgeInsets.symmetric(
//                                 horizontal: 16, vertical: 14),
//                             border: InputBorder.none,
//                             prefixIcon: Icon(Icons.person_search_rounded,
//                                 color: Color(0xFF6C63FF), size: 20),
//                           ),
//                           hint: const Text('Select a student',
//                               style: TextStyle(color: Color(0xFF4A5180))),
//                           items: students.map((s) {
//                             return DropdownMenuItem<String>(
//                               value: s['id'],
//                               child: Text('${s['name']} (${s['regNo'] ?? ''})'),
//                             );
//                           }).toList(),
//                           onChanged: (val) {
//                             setState(() {
//                               selectedStudentId = val;
//                               selectedStudentName = students
//                                   .firstWhere((s) => s['id'] == val)['name'];
//                             });
//                           },
//                           validator: (v) =>
//                               v == null ? 'Please select a student' : null,
//                         ),
//                       ),
//                       const SizedBox(height: 20),

//                       // Semester Selector
//                       _buildSectionLabel('Semester'),
//                       const SizedBox(height: 8),
//                       Row(
//                         children: semesters.map((sem) {
//                           final isSelected = selectedSemester == sem;
//                           return Expanded(
//                             child: GestureDetector(
//                               onTap: () =>
//                                   setState(() => selectedSemester = sem),
//                               child: AnimatedContainer(
//                                 duration: const Duration(milliseconds: 200),
//                                 margin:
//                                     EdgeInsets.only(right: sem < 4 ? 10 : 0),
//                                 padding:
//                                     const EdgeInsets.symmetric(vertical: 14),
//                                 decoration: BoxDecoration(
//                                   color: isSelected
//                                       ? const Color(0xFF6C63FF)
//                                       : const Color(0xFF1A1F4E),
//                                   borderRadius: BorderRadius.circular(12),
//                                   border: Border.all(
//                                     color: isSelected
//                                         ? const Color(0xFF6C63FF)
//                                         : const Color(0xFF2D3470),
//                                     width: 1.5,
//                                   ),
//                                 ),
//                                 child: Column(
//                                   children: [
//                                     Text('Sem',
//                                         style: TextStyle(
//                                             color: isSelected
//                                                 ? Colors.white70
//                                                 : const Color(0xFF8B92B8),
//                                             fontSize: 11)),
//                                     Text('$sem',
//                                         style: TextStyle(
//                                             color: Colors.white,
//                                             fontSize: 18,
//                                             fontWeight: isSelected
//                                                 ? FontWeight.bold
//                                                 : FontWeight.normal)),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           );
//                         }).toList(),
//                       ),
//                       const SizedBox(height: 20),

//                       // Subject Code
//                       _buildTextField('Subject Code', 'e.g. CS101',
//                           Icons.code_rounded, _subjectCodeController,
//                           validator: (v) =>
//                               v!.isEmpty ? 'Please enter subject code' : null),

//                       // Subject Name
//                       _buildTextField('Subject Name', 'e.g. Data Structures',
//                           Icons.book_outlined, _subjectNameController,
//                           validator: (v) =>
//                               v!.isEmpty ? 'Please enter subject name' : null),

//                       // Credits
//                       _buildTextField('Credits', 'e.g. 4',
//                           Icons.star_outline_rounded, _creditsController,
//                           keyboardType: const TextInputType.numberWithOptions(
//                               decimal: true), validator: (v) {
//                         if (v!.isEmpty) return 'Please enter credits';
//                         if (double.tryParse(v) == null) {
//                           return 'Enter valid number';
//                         }
//                         if (double.parse(v) <= 0) {
//                           return 'Credits must be greater than 0';
//                         }
//                         return null;
//                       }),

//                       // Grade Selector
//                       _buildSectionLabel('Grade'),
//                       const SizedBox(height: 8),
//                       Wrap(
//                         spacing: 10,
//                         runSpacing: 10,
//                         children: grades.map((g) {
//                           final isSelected = selectedGrade == g;
//                           final color = Color(GpaCalculator.gradeColor(g));
//                           return GestureDetector(
//                             onTap: () => setState(() => selectedGrade = g),
//                             child: AnimatedContainer(
//                               duration: const Duration(milliseconds: 200),
//                               width: 58,
//                               height: 58,
//                               decoration: BoxDecoration(
//                                 color: isSelected
//                                     ? color.withOpacity(0.2)
//                                     : const Color(0xFF1A1F4E),
//                                 borderRadius: BorderRadius.circular(14),
//                                 border: Border.all(
//                                   color: isSelected
//                                       ? color
//                                       : const Color(0xFF2D3470),
//                                   width: isSelected ? 2 : 1.5,
//                                 ),
//                               ),
//                               child: Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Text(g,
//                                       style: TextStyle(
//                                           color:
//                                               isSelected ? color : Colors.white,
//                                           fontSize: 20,
//                                           fontWeight: FontWeight.bold)),
//                                   Text('${GpaCalculator.gradeToPoint(g)}',
//                                       style: TextStyle(
//                                           color: isSelected
//                                               ? color
//                                               : const Color(0xFF8B92B8),
//                                           fontSize: 11)),
//                                 ],
//                               ),
//                             ),
//                           );
//                         }).toList(),
//                       ),
//                       const SizedBox(height: 32),

//                       SizedBox(
//                         width: double.infinity,
//                         height: 56,
//                         child: ElevatedButton(
//                           onPressed: isLoading ? null : _saveResult,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: const Color(0xFF4ECDC4),
//                             foregroundColor: Colors.white,
//                             elevation: 0,
//                             shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(16)),
//                             disabledBackgroundColor:
//                                 const Color(0xFF4ECDC4).withOpacity(0.5),
//                           ),
//                           child: isLoading
//                               ? const SizedBox(
//                                   width: 24,
//                                   height: 24,
//                                   child: CircularProgressIndicator(
//                                       color: Colors.white, strokeWidth: 2.5))
//                               : const Text('Save Result',
//                                   style: TextStyle(
//                                       fontSize: 17,
//                                       fontWeight: FontWeight.bold,
//                                       color: Color(0xFF0A0E27))),
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//     );
//   }

//   Widget _buildSectionLabel(String text) {
//     return Text(text,
//         style: const TextStyle(
//             color: Color(0xFF8B92B8),
//             fontSize: 13,
//             fontWeight: FontWeight.w600));
//   }

//   Widget _buildTextField(String label, String hint, IconData icon,
//       TextEditingController controller,
//       {TextInputType? keyboardType, String? Function(String?)? validator}) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildSectionLabel(label),
//           const SizedBox(height: 8),
//           TextFormField(
//             controller: controller,
//             keyboardType: keyboardType,
//             validator: validator,
//             style: const TextStyle(color: Colors.white, fontSize: 15),
//             decoration: InputDecoration(
//               hintText: hint,
//               hintStyle:
//                   const TextStyle(color: Color(0xFF4A5180), fontSize: 14),
//               prefixIcon: Icon(icon, color: const Color(0xFF4ECDC4), size: 20),
//               filled: true,
//               fillColor: const Color(0xFF1A1F4E),
//               contentPadding:
//                   const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(14),
//                 borderSide:
//                     const BorderSide(color: Color(0xFF2D3470), width: 1.5),
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(14),
//                 borderSide:
//                     const BorderSide(color: Color(0xFF2D3470), width: 1.5),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(14),
//                 borderSide:
//                     const BorderSide(color: Color(0xFF4ECDC4), width: 2),
//               ),
//               errorBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(14),
//                 borderSide:
//                     const BorderSide(color: Color(0xFFE53935), width: 1.5),
//               ),
//               focusedErrorBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(14),
//                 borderSide:
//                     const BorderSide(color: Color(0xFFE53935), width: 2),
//               ),
//               errorStyle: const TextStyle(color: Color(0xFFFF6B6B)),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:file_picker/file_picker.dart';
// import 'dart:io';
// import '../utils/gpa_calculator.dart';

// // ─────────────────────────────────────────────────────────────────────────────
// // Subject credits master — update this map with your university's credits
// // ─────────────────────────────────────────────────────────────────────────────
// const Map<String, double> _subjectCredits = {
//   'MAA101': 4,
//   'PHA101': 4,
//   'CYA101': 4,
//   'HSA101': 3,
//   'MEA101': 3,
//   'PHA102': 2,
//   'CYA102': 2,
//   'FYA101': 1,
//   'EEA101': 4,
//   'CSA101': 4,
//   'MEA102': 3,
//   'CEA101': 2,
//   'EEA102': 2,
//   'CSA102': 2,
// };

// // Subject name master
// const Map<String, String> _subjectNames = {
//   'MAA101': 'Engineering Mathematics I',
//   'PHA101': 'Engineering Physics',
//   'CYA101': 'Engineering Chemistry',
//   'HSA101': 'Technical English',
//   'MEA101': 'Engineering Mechanics',
//   'PHA102': 'Physics Lab',
//   'CYA102': 'Chemistry Lab',
//   'FYA101': 'Physical Education',
//   'EEA101': 'Basic Electrical Engineering',
//   'CSA101': 'Problem Solving & C Programming',
//   'MEA102': 'Engineering Drawing',
//   'CEA101': 'Civil Engineering Lab',
//   'EEA102': 'Electrical Engineering Lab',
//   'CSA102': 'C Programming Lab',
// };

// class AddResultScreen extends StatefulWidget {
//   const AddResultScreen({super.key});

//   @override
//   State<AddResultScreen> createState() => _AddResultScreenState();
// }

// class _AddResultScreenState extends State<AddResultScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF0A0E27),
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF1A1F4E),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text('Add Result',
//             style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//         elevation: 0,
//         bottom: TabBar(
//           controller: _tabController,
//           indicatorColor: const Color(0xFF4ECDC4),
//           labelColor: const Color(0xFF4ECDC4),
//           unselectedLabelColor: const Color(0xFF8B92B8),
//           tabs: const [
//             Tab(icon: Icon(Icons.edit_rounded), text: 'Manual Entry'),
//             Tab(icon: Icon(Icons.picture_as_pdf_rounded), text: 'Import PDF'),
//           ],
//         ),
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: const [
//           _ManualEntryTab(),
//           _PdfImportTab(),
//         ],
//       ),
//     );
//   }
// }

// // ═════════════════════════════════════════════════════════════════════════════
// // MANUAL ENTRY TAB (existing logic, unchanged)
// // ═════════════════════════════════════════════════════════════════════════════
// class _ManualEntryTab extends StatefulWidget {
//   const _ManualEntryTab();

//   @override
//   State<_ManualEntryTab> createState() => _ManualEntryTabState();
// }

// class _ManualEntryTabState extends State<_ManualEntryTab> {
//   final _formKey = GlobalKey<FormState>();
//   final _subjectCodeController = TextEditingController();
//   final _subjectNameController = TextEditingController();
//   final _creditsController = TextEditingController();

//   String? selectedStudentId;
//   String? selectedStudentName;
//   String selectedGrade = 'S';
//   int selectedSemester = 1;
//   bool isLoading = false;
//   bool isFetchingStudents = true;
//   List<Map<String, dynamic>> students = [];

//   final grades = ['S', 'A', 'B', 'C', 'D', 'E', 'F'];
//   final semesters = [1, 2, 3, 4];

//   @override
//   void initState() {
//     super.initState();
//     _fetchStudents();
//   }

//   @override
//   void dispose() {
//     _subjectCodeController.dispose();
//     _subjectNameController.dispose();
//     _creditsController.dispose();
//     super.dispose();
//   }

//   Future<void> _fetchStudents() async {
//     try {
//       final snap = await FirebaseFirestore.instance
//           .collection('students')
//           .orderBy('name')
//           .get();
//       setState(() {
//         students = snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
//         isFetchingStudents = false;
//       });
//     } catch (e) {
//       setState(() => isFetchingStudents = false);
//     }
//   }

//   Future<void> _saveResult() async {
//     if (!_formKey.currentState!.validate()) return;
//     if (selectedStudentId == null) {
//       _showSnack('Please select a student', isError: true);
//       return;
//     }
//     setState(() => isLoading = true);
//     try {
//       final existing = await FirebaseFirestore.instance
//           .collection('results')
//           .where('studentId', isEqualTo: selectedStudentId)
//           .where('semester', isEqualTo: selectedSemester)
//           .where('subjectCode',
//               isEqualTo: _subjectCodeController.text.trim().toUpperCase())
//           .get();

//       if (existing.docs.isNotEmpty) {
//         _showSnack(
//             'Result for this subject already exists in Semester $selectedSemester!',
//             isError: true);
//         setState(() => isLoading = false);
//         return;
//       }

//       final gradePoint = GpaCalculator.gradeToPoint(selectedGrade);
//       final credits = double.parse(_creditsController.text.trim());

//       await FirebaseFirestore.instance.collection('results').add({
//         'studentId': selectedStudentId,
//         'studentName': selectedStudentName,
//         'subjectCode': _subjectCodeController.text.trim().toUpperCase(),
//         'subjectName': _subjectNameController.text.trim(),
//         'credits': credits,
//         'grade': selectedGrade,
//         'gradePoint': gradePoint,
//         'semester': selectedSemester,
//         'createdAt': FieldValue.serverTimestamp(),
//       });

//       if (!mounted) return;
//       _showSnack('Result added successfully!');
//       _subjectCodeController.clear();
//       _subjectNameController.clear();
//       _creditsController.clear();
//       setState(() => selectedGrade = 'S');
//     } catch (e) {
//       _showSnack('Failed to save result. Please try again.', isError: true);
//     } finally {
//       if (mounted) setState(() => isLoading = false);
//     }
//   }

//   void _showSnack(String msg, {bool isError = false}) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//       content: Row(children: [
//         Icon(isError ? Icons.error_outline : Icons.check_circle_outline,
//             color: Colors.white, size: 18),
//         const SizedBox(width: 8),
//         Expanded(child: Text(msg)),
//       ]),
//       backgroundColor:
//           isError ? const Color(0xFFE53935) : const Color(0xFF43A047),
//       behavior: SnackBarBehavior.floating,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       margin: const EdgeInsets.all(16),
//     ));
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (isFetchingStudents) {
//       return const Center(
//           child: CircularProgressIndicator(color: Color(0xFF6C63FF)));
//     }
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(20),
//       child: Form(
//         key: _formKey,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Select Student
//             _label('Select Student'),
//             const SizedBox(height: 8),
//             Container(
//               decoration: BoxDecoration(
//                 color: const Color(0xFF1A1F4E),
//                 borderRadius: BorderRadius.circular(14),
//                 border: Border.all(color: const Color(0xFF2D3470), width: 1.5),
//               ),
//               child: DropdownButtonFormField<String>(
//                 value: selectedStudentId,
//                 dropdownColor: const Color(0xFF1A1F4E),
//                 style: const TextStyle(color: Colors.white, fontSize: 15),
//                 icon: const Icon(Icons.keyboard_arrow_down_rounded,
//                     color: Color(0xFF6C63FF)),
//                 decoration: const InputDecoration(
//                   contentPadding:
//                       EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//                   border: InputBorder.none,
//                   prefixIcon: Icon(Icons.person_search_rounded,
//                       color: Color(0xFF6C63FF), size: 20),
//                 ),
//                 hint: const Text('Select a student',
//                     style: TextStyle(color: Color(0xFF4A5180))),
//                 items: students.map((s) {
//                   return DropdownMenuItem<String>(
//                     value: s['id'],
//                     child: Text('${s['name']} (${s['regNo'] ?? ''})'),
//                   );
//                 }).toList(),
//                 onChanged: (val) {
//                   setState(() {
//                     selectedStudentId = val;
//                     selectedStudentName =
//                         students.firstWhere((s) => s['id'] == val)['name'];
//                   });
//                 },
//                 validator: (v) => v == null ? 'Please select a student' : null,
//               ),
//             ),
//             const SizedBox(height: 20),

//             // Semester
//             _label('Semester'),
//             const SizedBox(height: 8),
//             Row(
//               children: semesters.map((sem) {
//                 final isSelected = selectedSemester == sem;
//                 return Expanded(
//                   child: GestureDetector(
//                     onTap: () => setState(() => selectedSemester = sem),
//                     child: AnimatedContainer(
//                       duration: const Duration(milliseconds: 200),
//                       margin: EdgeInsets.only(right: sem < 4 ? 10 : 0),
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       decoration: BoxDecoration(
//                         color: isSelected
//                             ? const Color(0xFF6C63FF)
//                             : const Color(0xFF1A1F4E),
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(
//                           color: isSelected
//                               ? const Color(0xFF6C63FF)
//                               : const Color(0xFF2D3470),
//                           width: 1.5,
//                         ),
//                       ),
//                       child: Column(
//                         children: [
//                           Text('Sem',
//                               style: TextStyle(
//                                   color: isSelected
//                                       ? Colors.white70
//                                       : const Color(0xFF8B92B8),
//                                   fontSize: 11)),
//                           Text('$sem',
//                               style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 18,
//                                   fontWeight: isSelected
//                                       ? FontWeight.bold
//                                       : FontWeight.normal)),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               }).toList(),
//             ),
//             const SizedBox(height: 20),

//             _buildTextField('Subject Code', 'e.g. CS101', Icons.code_rounded,
//                 _subjectCodeController,
//                 validator: (v) =>
//                     v!.isEmpty ? 'Please enter subject code' : null),
//             _buildTextField('Subject Name', 'e.g. Data Structures',
//                 Icons.book_outlined, _subjectNameController,
//                 validator: (v) =>
//                     v!.isEmpty ? 'Please enter subject name' : null),
//             _buildTextField('Credits', 'e.g. 4', Icons.star_outline_rounded,
//                 _creditsController,
//                 keyboardType:
//                     const TextInputType.numberWithOptions(decimal: true),
//                 validator: (v) {
//               if (v!.isEmpty) return 'Please enter credits';
//               if (double.tryParse(v) == null) return 'Enter valid number';
//               if (double.parse(v) <= 0) return 'Credits must be > 0';
//               return null;
//             }),

//             // Grade
//             _label('Grade'),
//             const SizedBox(height: 8),
//             Wrap(
//               spacing: 10,
//               runSpacing: 10,
//               children: grades.map((g) {
//                 final isSelected = selectedGrade == g;
//                 final color = Color(GpaCalculator.gradeColor(g));
//                 return GestureDetector(
//                   onTap: () => setState(() => selectedGrade = g),
//                   child: AnimatedContainer(
//                     duration: const Duration(milliseconds: 200),
//                     width: 58,
//                     height: 58,
//                     decoration: BoxDecoration(
//                       color: isSelected
//                           ? color.withOpacity(0.2)
//                           : const Color(0xFF1A1F4E),
//                       borderRadius: BorderRadius.circular(14),
//                       border: Border.all(
//                         color: isSelected ? color : const Color(0xFF2D3470),
//                         width: isSelected ? 2 : 1.5,
//                       ),
//                     ),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(g,
//                             style: TextStyle(
//                                 color: isSelected ? color : Colors.white,
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.bold)),
//                         Text('${GpaCalculator.gradeToPoint(g)}',
//                             style: TextStyle(
//                                 color: isSelected
//                                     ? color
//                                     : const Color(0xFF8B92B8),
//                                 fontSize: 11)),
//                       ],
//                     ),
//                   ),
//                 );
//               }).toList(),
//             ),
//             const SizedBox(height: 32),

//             SizedBox(
//               width: double.infinity,
//               height: 56,
//               child: ElevatedButton(
//                 onPressed: isLoading ? null : _saveResult,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF4ECDC4),
//                   foregroundColor: Colors.white,
//                   elevation: 0,
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(16)),
//                   disabledBackgroundColor:
//                       const Color(0xFF4ECDC4).withOpacity(0.5),
//                 ),
//                 child: isLoading
//                     ? const SizedBox(
//                         width: 24,
//                         height: 24,
//                         child: CircularProgressIndicator(
//                             color: Colors.white, strokeWidth: 2.5))
//                     : const Text('Save Result',
//                         style: TextStyle(
//                             fontSize: 17,
//                             fontWeight: FontWeight.bold,
//                             color: Color(0xFF0A0E27))),
//               ),
//             ),
//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _label(String text) => Text(text,
//       style: const TextStyle(
//           color: Color(0xFF8B92B8), fontSize: 13, fontWeight: FontWeight.w600));

//   Widget _buildTextField(
//     String label,
//     String hint,
//     IconData icon,
//     TextEditingController controller, {
//     TextInputType? keyboardType,
//     String? Function(String?)? validator,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _label(label),
//           const SizedBox(height: 8),
//           TextFormField(
//             controller: controller,
//             keyboardType: keyboardType,
//             validator: validator,
//             style: const TextStyle(color: Colors.white, fontSize: 15),
//             decoration: InputDecoration(
//               hintText: hint,
//               hintStyle:
//                   const TextStyle(color: Color(0xFF4A5180), fontSize: 14),
//               prefixIcon: Icon(icon, color: const Color(0xFF4ECDC4), size: 20),
//               filled: true,
//               fillColor: const Color(0xFF1A1F4E),
//               contentPadding:
//                   const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(14),
//                 borderSide:
//                     const BorderSide(color: Color(0xFF2D3470), width: 1.5),
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(14),
//                 borderSide:
//                     const BorderSide(color: Color(0xFF2D3470), width: 1.5),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(14),
//                 borderSide:
//                     const BorderSide(color: Color(0xFF4ECDC4), width: 2),
//               ),
//               errorBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(14),
//                 borderSide:
//                     const BorderSide(color: Color(0xFFE53935), width: 1.5),
//               ),
//               focusedErrorBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(14),
//                 borderSide:
//                     const BorderSide(color: Color(0xFFE53935), width: 2),
//               ),
//               errorStyle: const TextStyle(color: Color(0xFFFF6B6B)),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ═════════════════════════════════════════════════════════════════════════════
// // PDF IMPORT TAB — parses PTU result PDF format
// // ═════════════════════════════════════════════════════════════════════════════
// class _PdfImportTab extends StatefulWidget {
//   const _PdfImportTab();

//   @override
//   State<_PdfImportTab> createState() => _PdfImportTabState();
// }

// class _PdfImportTabState extends State<_PdfImportTab> {
//   // Parsed records ready to preview before saving
//   List<_ParsedStudentResult> _parsedResults = [];
//   String _fileName = '';
//   bool _isParsing = false;
//   bool _isSaving = false;
//   int _selectedSemester = 1;
//   String _statusMessage = '';
//   int _savedCount = 0;
//   int _skippedCount = 0;

//   // ── Pick & parse PDF ────────────────────────────────────────────
//   Future<void> _pickAndParsePdf() async {
//     setState(() {
//       _isParsing = true;
//       _parsedResults = [];
//       _statusMessage = '';
//       _savedCount = 0;
//       _skippedCount = 0;
//     });

//     try {
//       final result = await FilePicker.platform.pickFiles(
//         type: FileType.custom,
//         allowedExtensions: ['pdf'],
//         allowMultiple: false,
//       );

//       if (result == null || result.files.isEmpty) {
//         setState(() => _isParsing = false);
//         return;
//       }

//       final file = result.files.first;
//       setState(() => _fileName = file.name);

//       // Read file bytes
//       final bytes = file.bytes ?? await File(file.path!).readAsBytes();

//       // Extract text from PDF using basic byte parsing
//       // We use the syncfusion-free approach: read raw text from PDF
//       final text = await _extractTextFromPdfBytes(bytes);
//       final parsed = _parsePtuResultText(text);

//       setState(() {
//         _parsedResults = parsed;
//         _isParsing = false;
//         if (parsed.isEmpty) {
//           _statusMessage =
//               'No results found. Make sure this is a PTU result PDF.';
//         }
//       });
//     } catch (e) {
//       setState(() {
//         _isParsing = false;
//         _statusMessage = 'Error reading PDF: $e';
//       });
//     }
//   }

//   // ── Extract raw text from PDF bytes (stream-based, no package needed) ──
//   Future<String> _extractTextFromPdfBytes(List<int> bytes) async {
//     // Convert bytes to string, extract text between BT/ET markers
//     final raw =
//         String.fromCharCodes(bytes.where((b) => b >= 32 && b < 127).toList());

//     // Also try reading as latin1
//     final buffer = StringBuffer();
//     bool inText = false;
//     for (int i = 0; i < raw.length - 2; i++) {
//       if (raw[i] == 'B' && raw[i + 1] == 'T') {
//         inText = true;
//       } else if (raw[i] == 'E' && raw[i + 1] == 'T') {
//         inText = false;
//         buffer.write(' ');
//       } else if (inText) {
//         buffer.write(raw[i]);
//       }
//     }

//     // Fallback: just use the raw printable string
//     final extracted = buffer.toString();
//     return extracted.isNotEmpty ? extracted : raw;
//   }

//   // ── Parse PTU format: RegNo Name SubCode - Grade SubCode - Grade ... ──
//   List<_ParsedStudentResult> _parsePtuResultText(String text) {
//     final results = <_ParsedStudentResult>[];

//     // Clean text: normalize spaces
//     text = text.replaceAll(RegExp(r'\s+'), ' ');

//     // Pattern to match a student entry:
//     // Reg number (10 digits) followed by name then subject results
//     // e.g: 2303107001 ANUSUYA K MAA101 - B PHA101 - B ...
//     final studentPattern = RegExp(
//       r'(\d{10})\s+([A-Z][A-Z\s@]+?)\s+(?=[A-Z]{2,3}\d{3})',
//     );

//     // Subject-grade pattern: SUBCODE - GRADE
//     final subjectPattern = RegExp(r'([A-Z]{2,3}\d{3})\s*-\s*([A-ZFPZ])');

//     // Find all student blocks
//     final matches = studentPattern.allMatches(text).toList();

//     for (int i = 0; i < matches.length; i++) {
//       final match = matches[i];
//       final regNo = match.group(1)!.trim();
//       final name = match.group(2)!.trim();

//       // Get text block for this student (until next student or end)
//       final start = match.start;
//       final end = i + 1 < matches.length ? matches[i + 1].start : text.length;
//       final block = text.substring(start, end);

//       // Extract all subject-grade pairs from this block
//       final subjects = <_SubjectGrade>[];
//       for (final sm in subjectPattern.allMatches(block)) {
//         final code = sm.group(1)!.trim();
//         final grade = sm.group(2)!.trim();

//         // Skip 'P' grade (Physical Education pass — no grade point impact)
//         // and 'Z' (withheld/absent)
//         if (grade == 'P' || grade == 'Z') continue;

//         final credits = _subjectCredits[code] ?? 3.0;
//         final subjectName = _subjectNames[code] ?? code;
//         final gradePoint = GpaCalculator.gradeToPoint(grade).toDouble();

//         subjects.add(_SubjectGrade(
//           subjectCode: code,
//           subjectName: subjectName,
//           grade: grade,
//           gradePoint: gradePoint,
//           credits: credits,
//         ));
//       }

//       if (subjects.isNotEmpty) {
//         results.add(_ParsedStudentResult(
//           regNo: regNo,
//           name: name,
//           subjects: subjects,
//         ));
//       }
//     }

//     return results;
//   }

//   // ── Save all parsed results to Firestore ────────────────────────
//   Future<void> _saveAllToFirestore() async {
//     if (_parsedResults.isEmpty) return;
//     setState(() {
//       _isSaving = true;
//       _savedCount = 0;
//       _skippedCount = 0;
//       _statusMessage = 'Saving...';
//     });

//     final db = FirebaseFirestore.instance;
//     int saved = 0;
//     int skipped = 0;

//     for (final studentResult in _parsedResults) {
//       // Find student document by regNo
//       final studentSnap = await db
//           .collection('students')
//           .where('regNo', isEqualTo: studentResult.regNo)
//           .limit(1)
//           .get();

//       String? studentId;
//       String? studentName;

//       if (studentSnap.docs.isNotEmpty) {
//         studentId = studentSnap.docs.first.id;
//         studentName =
//             studentSnap.docs.first.data()['name'] ?? studentResult.name;
//       } else {
//         // Student not found — skip or auto-create
//         skipped += studentResult.subjects.length;
//         continue;
//       }

//       // Save each subject result
//       for (final sub in studentResult.subjects) {
//         // Check for duplicate
//         final existing = await db
//             .collection('results')
//             .where('studentId', isEqualTo: studentId)
//             .where('semester', isEqualTo: _selectedSemester)
//             .where('subjectCode', isEqualTo: sub.subjectCode)
//             .get();

//         if (existing.docs.isNotEmpty) {
//           skipped++;
//           continue;
//         }

//         await db.collection('results').add({
//           'studentId': studentId,
//           'studentName': studentName,
//           'subjectCode': sub.subjectCode,
//           'subjectName': sub.subjectName,
//           'credits': sub.credits,
//           'grade': sub.grade,
//           'gradePoint': sub.gradePoint,
//           'semester': _selectedSemester,
//           'createdAt': FieldValue.serverTimestamp(),
//         });
//         saved++;
//       }
//     }

//     setState(() {
//       _isSaving = false;
//       _savedCount = saved;
//       _skippedCount = skipped;
//       _statusMessage =
//           '✅ Done! $saved records saved. $skipped skipped (duplicates or student not found).';
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Info banner
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               gradient: const LinearGradient(
//                   colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)]),
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: const Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Icon(Icons.picture_as_pdf_rounded,
//                         color: Colors.white, size: 28),
//                     SizedBox(width: 10),
//                     Text('PTU Result PDF Import',
//                         style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold)),
//                   ],
//                 ),
//                 SizedBox(height: 8),
//                 Text(
//                   'Import official PTU result PDFs.\n'
//                   'Format: RegNo  Name  SubCode - Grade  SubCode - Grade...\n'
//                   'Students must already be added in the app.',
//                   style: TextStyle(color: Colors.white70, fontSize: 12),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 20),

//           // Semester selector
//           const Text('Select Semester for this PDF',
//               style: TextStyle(
//                   color: Color(0xFF8B92B8),
//                   fontSize: 13,
//                   fontWeight: FontWeight.w600)),
//           const SizedBox(height: 8),
//           Row(
//             children: [1, 2, 3, 4].map((sem) {
//               final isSelected = _selectedSemester == sem;
//               return Expanded(
//                 child: GestureDetector(
//                   onTap: () => setState(() => _selectedSemester = sem),
//                   child: AnimatedContainer(
//                     duration: const Duration(milliseconds: 200),
//                     margin: EdgeInsets.only(right: sem < 4 ? 10 : 0),
//                     padding: const EdgeInsets.symmetric(vertical: 14),
//                     decoration: BoxDecoration(
//                       color: isSelected
//                           ? const Color(0xFF6C63FF)
//                           : const Color(0xFF1A1F4E),
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(
//                         color: isSelected
//                             ? const Color(0xFF6C63FF)
//                             : const Color(0xFF2D3470),
//                         width: 1.5,
//                       ),
//                     ),
//                     child: Column(
//                       children: [
//                         Text('Sem',
//                             style: TextStyle(
//                                 color: isSelected
//                                     ? Colors.white70
//                                     : const Color(0xFF8B92B8),
//                                 fontSize: 11)),
//                         Text('$sem',
//                             style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 18,
//                                 fontWeight: isSelected
//                                     ? FontWeight.bold
//                                     : FontWeight.normal)),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             }).toList(),
//           ),
//           const SizedBox(height: 24),

//           // Pick PDF button
//           SizedBox(
//             width: double.infinity,
//             height: 56,
//             child: ElevatedButton.icon(
//               onPressed: _isParsing || _isSaving ? null : _pickAndParsePdf,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF1A1F4E),
//                 foregroundColor: Colors.white,
//                 elevation: 0,
//                 side: const BorderSide(color: Color(0xFF4ECDC4), width: 2),
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16)),
//               ),
//               icon: _isParsing
//                   ? const SizedBox(
//                       width: 20,
//                       height: 20,
//                       child: CircularProgressIndicator(
//                           color: Color(0xFF4ECDC4), strokeWidth: 2))
//                   : const Icon(Icons.upload_file_rounded,
//                       color: Color(0xFF4ECDC4)),
//               label: Text(
//                 _isParsing
//                     ? 'Reading PDF...'
//                     : _fileName.isEmpty
//                         ? 'Choose PDF File'
//                         : _fileName,
//                 style:
//                     const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ),
//           ),
//           const SizedBox(height: 20),

//           // Preview
//           if (_parsedResults.isNotEmpty) ...[
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Preview — ${_parsedResults.length} students found',
//                   style: const TextStyle(
//                       color: Color(0xFF4ECDC4),
//                       fontSize: 14,
//                       fontWeight: FontWeight.bold),
//                 ),
//                 Text(
//                   '${_parsedResults.fold(0, (s, r) => s + r.subjects.length)} subjects',
//                   style:
//                       const TextStyle(color: Color(0xFF8B92B8), fontSize: 13),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),

//             // Student cards preview
//             ..._parsedResults.map((sr) => _buildPreviewCard(sr)),
//             const SizedBox(height: 20),

//             // Save button
//             SizedBox(
//               width: double.infinity,
//               height: 56,
//               child: ElevatedButton.icon(
//                 onPressed: _isSaving ? null : _saveAllToFirestore,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF4ECDC4),
//                   foregroundColor: const Color(0xFF0A0E27),
//                   elevation: 0,
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(16)),
//                   disabledBackgroundColor:
//                       const Color(0xFF4ECDC4).withOpacity(0.5),
//                 ),
//                 icon: _isSaving
//                     ? const SizedBox(
//                         width: 20,
//                         height: 20,
//                         child: CircularProgressIndicator(
//                             color: Color(0xFF0A0E27), strokeWidth: 2))
//                     : const Icon(Icons.cloud_upload_rounded),
//                 label: Text(
//                   _isSaving
//                       ? 'Saving to Firestore...'
//                       : 'Save All to Firestore',
//                   style: const TextStyle(
//                       fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//               ),
//             ),
//           ],

//           // Status message
//           if (_statusMessage.isNotEmpty) ...[
//             const SizedBox(height: 16),
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: _statusMessage.startsWith('✅')
//                     ? const Color(0xFF43A047).withOpacity(0.15)
//                     : const Color(0xFFE53935).withOpacity(0.15),
//                 borderRadius: BorderRadius.circular(14),
//                 border: Border.all(
//                   color: _statusMessage.startsWith('✅')
//                       ? const Color(0xFF43A047)
//                       : const Color(0xFFE53935),
//                   width: 1,
//                 ),
//               ),
//               child: Text(
//                 _statusMessage,
//                 style: TextStyle(
//                   color: _statusMessage.startsWith('✅')
//                       ? const Color(0xFF43A047)
//                       : const Color(0xFFFF6B6B),
//                   fontSize: 14,
//                 ),
//               ),
//             ),
//           ],
//           const SizedBox(height: 20),
//         ],
//       ),
//     );
//   }

//   Widget _buildPreviewCard(_ParsedStudentResult sr) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       decoration: BoxDecoration(
//         color: const Color(0xFF1A1F4E),
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: const Color(0xFF2D3470), width: 1),
//       ),
//       child: Theme(
//         data: Theme.of(context).copyWith(
//           dividerColor: Colors.transparent,
//           colorScheme: const ColorScheme.dark(),
//         ),
//         child: ExpansionTile(
//           tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//           title: Text(sr.name,
//               style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 14,
//                   fontWeight: FontWeight.bold)),
//           subtitle: Text(
//             '${sr.regNo}  •  ${sr.subjects.length} subjects',
//             style: const TextStyle(color: Color(0xFF8B92B8), fontSize: 12),
//           ),
//           iconColor: const Color(0xFF4ECDC4),
//           collapsedIconColor: const Color(0xFF8B92B8),
//           children: sr.subjects.map((sub) {
//             final color = Color(GpaCalculator.gradeColor(sub.grade));
//             return Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(sub.subjectCode,
//                             style: const TextStyle(
//                                 color: Color(0xFF6C63FF),
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w600)),
//                         Text(sub.subjectName,
//                             style: const TextStyle(
//                                 color: Colors.white70, fontSize: 12),
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis),
//                       ],
//                     ),
//                   ),
//                   Text('${sub.credits} cr',
//                       style: const TextStyle(
//                           color: Color(0xFF8B92B8), fontSize: 12)),
//                   const SizedBox(width: 12),
//                   Container(
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                     decoration: BoxDecoration(
//                       color: color.withOpacity(0.15),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Text(sub.grade,
//                         style: TextStyle(
//                             color: color,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 14)),
//                   ),
//                 ],
//               ),
//             );
//           }).toList(),
//         ),
//       ),
//     );
//   }
// }

// // ─── Data models ──────────────────────────────────────────────────────────────
// class _ParsedStudentResult {
//   final String regNo;
//   final String name;
//   final List<_SubjectGrade> subjects;
//   _ParsedStudentResult(
//       {required this.regNo, required this.name, required this.subjects});
// }

// class _SubjectGrade {
//   final String subjectCode;
//   final String subjectName;
//   final String grade;
//   final double gradePoint;
//   final double credits;
//   _SubjectGrade({
//     required this.subjectCode,
//     required this.subjectName,
//     required this.grade,
//     required this.gradePoint,
//     required this.credits,
//   });
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:io';
import '../utils/gpa_calculator.dart';

const Map<String, Map<String, dynamic>> _subjectMaster = {
  'MAA101': {'name': 'Engineering Mathematics I', 'credits': 4.0},
  'PHA101': {'name': 'Engineering Physics', 'credits': 4.0},
  'CYA101': {'name': 'Engineering Chemistry', 'credits': 4.0},
  'HSA101': {'name': 'Technical English', 'credits': 3.0},
  'MEA101': {'name': 'Engineering Mechanics', 'credits': 3.0},
  'PHA102': {'name': 'Physics Lab', 'credits': 2.0},
  'CYA102': {'name': 'Chemistry Lab', 'credits': 2.0},
  'FYA101': {'name': 'Physical Education I', 'credits': 1.0},
  'EEA101': {'name': 'Basic Electrical Engineering', 'credits': 4.0},
  'CSA101': {'name': 'Problem Solving & C Programming', 'credits': 4.0},
  'MEA102': {'name': 'Engineering Drawing', 'credits': 3.0},
  'CEA101': {'name': 'Civil & Mechanical Workshop', 'credits': 2.0},
  'EEA102': {'name': 'Electrical Engineering Lab', 'credits': 2.0},
  'CSA102': {'name': 'C Programming Lab', 'credits': 2.0},
  'MAA201': {'name': 'Engineering Mathematics II', 'credits': 4.0},
  'CSA201': {'name': 'Problem Solving & Python', 'credits': 4.0},
  'CSA202': {'name': 'Digital Principles & System Design', 'credits': 4.0},
  'ECA201': {'name': 'Basic Electronics Engineering', 'credits': 3.0},
  'MEA201': {'name': 'Engineering Graphics', 'credits': 3.0},
  'CSA203': {'name': 'Python Programming Lab', 'credits': 2.0},
  'ECA202': {'name': 'Electronics Lab', 'credits': 2.0},
  'FYA201': {'name': 'Physical Education II', 'credits': 1.0},
  'ECA203': {'name': 'Electronic Devices & Circuits', 'credits': 4.0},
  'ECA204': {'name': 'Signals & Systems', 'credits': 4.0},
  'ECA205': {'name': 'Digital Electronics', 'credits': 4.0},
  'ECA206': {'name': 'Electronic Circuits Lab', 'credits': 2.0},
  'ECA207': {'name': 'Digital Electronics Lab', 'credits': 2.0},
  'EEA201': {'name': 'Circuit Theory', 'credits': 4.0},
  'EEA202': {'name': 'Electronic Devices & Circuits', 'credits': 4.0},
  'EEA203': {'name': 'Digital Electronics', 'credits': 3.0},
  'EEA204': {'name': 'Circuit Theory Lab', 'credits': 2.0},
  'EEA205': {'name': 'Electronics Lab', 'credits': 2.0},
  'MAA301': {'name': 'Discrete Mathematics', 'credits': 4.0},
  'CSA301': {'name': 'Data Structures', 'credits': 4.0},
  'CSA302': {'name': 'Computer Organization & Architecture', 'credits': 4.0},
  'CSA303': {'name': 'Object Oriented Programming', 'credits': 4.0},
  'CSA304': {'name': 'Database Management Systems', 'credits': 3.0},
  'CSA305': {'name': 'Data Structures Lab', 'credits': 2.0},
  'CSA306': {'name': 'OOP Lab', 'credits': 2.0},
  'FYA301': {'name': 'Physical Education III', 'credits': 1.0},
  'ECA301': {'name': 'Analog Communications', 'credits': 4.0},
  'ECA302': {'name': 'Linear Integrated Circuits', 'credits': 4.0},
  'ECA303': {'name': 'Electromagnetic Theory', 'credits': 4.0},
  'ECA304': {'name': 'Microprocessors & Microcontrollers', 'credits': 3.0},
  'ECA305': {'name': 'Analog Communications Lab', 'credits': 2.0},
  'ECA306': {'name': 'LIC Lab', 'credits': 2.0},
  'EEA301': {'name': 'Electrical Machines I', 'credits': 4.0},
  'EEA302': {'name': 'Power Systems I', 'credits': 4.0},
  'EEA303': {'name': 'Control Systems', 'credits': 4.0},
  'EEA304': {'name': 'Measurements & Instrumentation', 'credits': 3.0},
  'EEA305': {'name': 'Electrical Machines Lab', 'credits': 2.0},
  'EEA306': {'name': 'Control Systems Lab', 'credits': 2.0},
  'ISA301': {'name': 'Data Structures', 'credits': 4.0},
  'ISA302': {'name': 'Computer Organization & Architecture', 'credits': 4.0},
  'ISA303': {'name': 'OOP with Java', 'credits': 4.0},
  'ISA304': {'name': 'Database Management Systems', 'credits': 3.0},
  'ISA305': {'name': 'Data Structures Lab', 'credits': 2.0},
  'ISA306': {'name': 'Java Programming Lab', 'credits': 2.0},
  'MAA401': {'name': 'Probability & Statistics', 'credits': 4.0},
  'CSA401': {'name': 'Design & Analysis of Algorithms', 'credits': 4.0},
  'CSA402': {'name': 'Operating Systems', 'credits': 4.0},
  'CSA403': {'name': 'Computer Networks', 'credits': 4.0},
  'CSA404': {'name': 'Software Engineering', 'credits': 3.0},
  'CSA405': {'name': 'Algorithms Lab', 'credits': 2.0},
  'CSA406': {'name': 'Networks Lab', 'credits': 2.0},
  'FYA401': {'name': 'Physical Education IV', 'credits': 1.0},
  'ECA401': {'name': 'Digital Communications', 'credits': 4.0},
  'ECA402': {'name': 'VLSI Design', 'credits': 4.0},
  'ECA403': {'name': 'Control Systems', 'credits': 4.0},
  'ECA404': {'name': 'Digital Signal Processing', 'credits': 3.0},
  'ECA405': {'name': 'Digital Communications Lab', 'credits': 2.0},
  'ECA406': {'name': 'DSP Lab', 'credits': 2.0},
  'EEA401': {'name': 'Electrical Machines II', 'credits': 4.0},
  'EEA402': {'name': 'Power Systems II', 'credits': 4.0},
  'EEA403': {'name': 'Power Electronics', 'credits': 4.0},
  'EEA404': {'name': 'Microprocessors & Applications', 'credits': 3.0},
  'EEA405': {'name': 'Power Electronics Lab', 'credits': 2.0},
  'EEA406': {'name': 'Simulation Lab', 'credits': 2.0},
  'ISA401': {'name': 'Design & Analysis of Algorithms', 'credits': 4.0},
  'ISA402': {'name': 'Operating Systems', 'credits': 4.0},
  'ISA403': {'name': 'Computer Networks', 'credits': 4.0},
  'ISA404': {'name': 'Software Engineering', 'credits': 3.0},
  'ISA405': {'name': 'Algorithms Lab', 'credits': 2.0},
  'ISA406': {'name': 'Networks Lab', 'credits': 2.0},
};

String _subjectName(String code) =>
    _subjectMaster[code]?['name'] as String? ?? code;
double _subjectCredits(String code) =>
    _subjectMaster[code]?['credits'] as double? ?? 3.0;

class AddResultScreen extends StatefulWidget {
  const AddResultScreen({super.key});
  @override
  State<AddResultScreen> createState() => _AddResultScreenState();
}

class _AddResultScreenState extends State<AddResultScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1F4E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Add Result',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF4ECDC4),
          labelColor: const Color(0xFF4ECDC4),
          unselectedLabelColor: const Color(0xFF8B92B8),
          tabs: const [
            Tab(icon: Icon(Icons.edit_rounded), text: 'Manual Entry'),
            Tab(icon: Icon(Icons.picture_as_pdf_rounded), text: 'Import PDF'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [_ManualEntryTab(), _PdfImportTab()],
      ),
    );
  }
}

// ── Manual Entry ─────────────────────────────────────────────────────────────
class _ManualEntryTab extends StatefulWidget {
  const _ManualEntryTab();
  @override
  State<_ManualEntryTab> createState() => _ManualEntryTabState();
}

class _ManualEntryTabState extends State<_ManualEntryTab> {
  final _formKey = GlobalKey<FormState>();
  final _codeCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _credCtrl = TextEditingController();
  String? selStudentId, selStudentName;
  String selGrade = 'S';
  int selSem = 1;
  bool isLoading = false, isFetching = true;
  List<Map<String, dynamic>> students = [];
  final grades = ['S', 'A', 'B', 'C', 'D', 'E', 'F'];

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection('students')
        .orderBy('name')
        .get()
        .then((s) {
      setState(() {
        students = s.docs.map((d) => {'id': d.id, ...d.data()}).toList();
        isFetching = false;
      });
    }).catchError((_) => setState(() => isFetching = false));
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _nameCtrl.dispose();
    _credCtrl.dispose();
    super.dispose();
  }

  void _snack(String msg, {bool err = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(err ? Icons.error_outline : Icons.check_circle_outline,
            color: Colors.white, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(msg)),
      ]),
      backgroundColor: err ? const Color(0xFFE53935) : const Color(0xFF43A047),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (selStudentId == null) {
      _snack('Select a student', err: true);
      return;
    }
    setState(() => isLoading = true);
    try {
      final code = _codeCtrl.text.trim().toUpperCase();
      final dup = await FirebaseFirestore.instance
          .collection('results')
          .where('studentId', isEqualTo: selStudentId)
          .where('semester', isEqualTo: selSem)
          .where('subjectCode', isEqualTo: code)
          .get();
      if (dup.docs.isNotEmpty) {
        _snack('Already exists in Semester $selSem!', err: true);
        setState(() => isLoading = false);
        return;
      }
      await FirebaseFirestore.instance.collection('results').add({
        'studentId': selStudentId,
        'studentName': selStudentName,
        'subjectCode': code,
        'subjectName': _nameCtrl.text.trim(),
        'credits': double.parse(_credCtrl.text.trim()),
        'grade': selGrade,
        'gradePoint': GpaCalculator.gradeToPoint(selGrade),
        'semester': selSem,
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      _snack('Result added!');
      _codeCtrl.clear();
      _nameCtrl.clear();
      _credCtrl.clear();
      setState(() => selGrade = 'S');
    } catch (_) {
      _snack('Failed to save', err: true);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isFetching)
      return const Center(
          child: CircularProgressIndicator(color: Color(0xFF6C63FF)));
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
          key: _formKey,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _lbl('Select Student'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                  color: const Color(0xFF1A1F4E),
                  borderRadius: BorderRadius.circular(14),
                  border:
                      Border.all(color: const Color(0xFF2D3470), width: 1.5)),
              child: DropdownButtonFormField<String>(
                value: selStudentId,
                dropdownColor: const Color(0xFF1A1F4E),
                style: const TextStyle(color: Colors.white, fontSize: 15),
                icon: const Icon(Icons.keyboard_arrow_down_rounded,
                    color: Color(0xFF6C63FF)),
                decoration: const InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.person_search_rounded,
                        color: Color(0xFF6C63FF), size: 20)),
                hint: const Text('Select a student',
                    style: TextStyle(color: Color(0xFF4A5180))),
                items: students
                    .map((s) => DropdownMenuItem<String>(
                        value: s['id'],
                        child: Text('${s['name']} (${s['regNo'] ?? ''})')))
                    .toList(),
                onChanged: (v) => setState(() {
                  selStudentId = v;
                  selStudentName =
                      students.firstWhere((s) => s['id'] == v)['name'];
                }),
                validator: (v) => v == null ? 'Select a student' : null,
              ),
            ),
            const SizedBox(height: 20),
            _lbl('Semester'),
            const SizedBox(height: 8),
            Row(
                children: [1, 2, 3, 4].map((s) {
              final sel = selSem == s;
              return Expanded(
                  child: GestureDetector(
                onTap: () => setState(() => selSem = s),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.only(right: s < 4 ? 10 : 0),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                      color: sel
                          ? const Color(0xFF6C63FF)
                          : const Color(0xFF1A1F4E),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: sel
                              ? const Color(0xFF6C63FF)
                              : const Color(0xFF2D3470),
                          width: 1.5)),
                  child: Column(children: [
                    Text('Sem',
                        style: TextStyle(
                            color:
                                sel ? Colors.white70 : const Color(0xFF8B92B8),
                            fontSize: 11)),
                    Text('$s',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight:
                                sel ? FontWeight.bold : FontWeight.normal)),
                  ]),
                ),
              ));
            }).toList()),
            const SizedBox(height: 20),
            _field('Subject Code', 'e.g. CSA301', Icons.code_rounded, _codeCtrl,
                v: (v) => v!.isEmpty ? 'Required' : null),
            _field('Subject Name', 'e.g. Data Structures', Icons.book_outlined,
                _nameCtrl,
                v: (v) => v!.isEmpty ? 'Required' : null),
            _field('Credits', 'e.g. 4', Icons.star_outline_rounded, _credCtrl,
                kb: const TextInputType.numberWithOptions(decimal: true),
                v: (v) {
              if (v!.isEmpty) return 'Required';
              if (double.tryParse(v) == null) return 'Invalid';
              if (double.parse(v) <= 0) return '>0';
              return null;
            }),
            _lbl('Grade'),
            const SizedBox(height: 8),
            Wrap(
                spacing: 10,
                runSpacing: 10,
                children: grades.map((g) {
                  final sel = selGrade == g;
                  final c = Color(GpaCalculator.gradeColor(g));
                  return GestureDetector(
                    onTap: () => setState(() => selGrade = g),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                          color: sel
                              ? c.withOpacity(0.2)
                              : const Color(0xFF1A1F4E),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: sel ? c : const Color(0xFF2D3470),
                              width: sel ? 2 : 1.5)),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(g,
                                style: TextStyle(
                                    color: sel ? c : Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                            Text('${GpaCalculator.gradeToPoint(g)}',
                                style: TextStyle(
                                    color: sel ? c : const Color(0xFF8B92B8),
                                    fontSize: 11)),
                          ]),
                    ),
                  );
                }).toList()),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: isLoading ? null : _save,
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4ECDC4),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    disabledBackgroundColor:
                        const Color(0xFF4ECDC4).withOpacity(0.5)),
                child: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5))
                    : const Text('Save Result',
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0A0E27))),
              ),
            ),
            const SizedBox(height: 20),
          ])),
    );
  }

  Widget _lbl(String t) => Text(t,
      style: const TextStyle(
          color: Color(0xFF8B92B8), fontSize: 13, fontWeight: FontWeight.w600));

  Widget _field(
      String label, String hint, IconData icon, TextEditingController ctrl,
      {TextInputType? kb, String? Function(String?)? v}) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _lbl(label),
          const SizedBox(height: 8),
          TextFormField(
            controller: ctrl,
            keyboardType: kb,
            validator: v,
            style: const TextStyle(color: Colors.white, fontSize: 15),
            decoration: InputDecoration(
                hintText: hint,
                hintStyle:
                    const TextStyle(color: Color(0xFF4A5180), fontSize: 14),
                prefixIcon:
                    Icon(icon, color: const Color(0xFF4ECDC4), size: 20),
                filled: true,
                fillColor: const Color(0xFF1A1F4E),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        const BorderSide(color: Color(0xFF2D3470), width: 1.5)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        const BorderSide(color: Color(0xFF2D3470), width: 1.5)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        const BorderSide(color: Color(0xFF4ECDC4), width: 2)),
                errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        const BorderSide(color: Color(0xFFE53935), width: 1.5)),
                focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        const BorderSide(color: Color(0xFFE53935), width: 2)),
                errorStyle: const TextStyle(color: Color(0xFFFF6B6B))),
          ),
        ]));
  }
}

// ── PDF Import ────────────────────────────────────────────────────────────────
class _PdfImportTab extends StatefulWidget {
  const _PdfImportTab();
  @override
  State<_PdfImportTab> createState() => _PdfImportTabState();
}

class _PdfImportTabState extends State<_PdfImportTab> {
  List<_ParsedStudent> _parsed = [];
  List<_ParsedStudent> _notFound = [];
  String _fileName = '', _status = '';
  bool _parsing = false, _saving = false;
  int _sem = 1;

  Future<void> _pickPdf() async {
    setState(() {
      _parsing = true;
      _parsed = [];
      _notFound = [];
      _status = '';
    });
    try {
      final res = await FilePicker.platform.pickFiles(
          type: FileType.custom, allowedExtensions: ['pdf'], withData: true);
      if (res == null || res.files.isEmpty) {
        setState(() => _parsing = false);
        return;
      }
      final f = res.files.first;
      setState(() => _fileName = f.name);
      final bytes = f.bytes ?? await File(f.path!).readAsBytes();

      // ── Syncfusion PDF text extraction ──────────────────────────
      final doc = PdfDocument(inputBytes: bytes);
      final extractor = PdfTextExtractor(doc);
      final sb = StringBuffer();
      for (int i = 0; i < doc.pages.count; i++) {
        sb.writeln(extractor.extractText(startPageIndex: i));
      }
      doc.dispose();

      final parsed = _parse(sb.toString());
      setState(() {
        _parsed = parsed;
        _parsing = false;
        if (parsed.isEmpty)
          _status = 'No results found. Check if this is a PTU result PDF.';
      });
    } catch (e) {
      setState(() {
        _parsing = false;
        _status = 'Error: $e';
      });
    }
  }

  // ── PTU format parser ─────────────────────────────────────────────────────
  // Each line: {SlNo} {10-digit RegNo} {NAME} {CODE} - {GRADE} {CODE} - {GRADE}...
  List<_ParsedStudent> _parse(String text) {
    final results = <_ParsedStudent>[];
    final regNoRx = RegExp(r'\b(2\d{9})\b');
    final subRx = RegExp(r'\b([A-Z]{2,3}\d{3})\s*-\s*([A-ZFPZ])\b');

    for (final line in text.split('\n')) {
      final clean = line.replaceAll(RegExp(r'\s+'), ' ').trim();
      final regMatch = regNoRx.firstMatch(clean);
      if (regMatch == null) continue;

      final regNo = regMatch.group(1)!;
      final after = clean.substring(regMatch.end).trim();
      final firstSub = subRx.firstMatch(after);
      if (firstSub == null) continue;

      // Name = text before first subject code, cleaned
      String name = after
          .substring(0, firstSub.start)
          .replaceAll(RegExp(r'^\d+\s*'), '')
          .replaceAll(RegExp(r'[^A-Z\s@]'), '')
          .trim();
      if (name.isEmpty) continue;

      final subjects = <_SubjectGrade>[];
      for (final m in subRx.allMatches(after)) {
        final code = m.group(1)!;
        final grade = m.group(2)!;
        if (grade == 'P' || grade == 'Z') continue; // skip PE pass & absent
        subjects.add(_SubjectGrade(
          code: code,
          name: _subjectName(code),
          grade: grade,
          gp: GpaCalculator.gradeToPoint(grade).toDouble(),
          credits: _subjectCredits(code),
        ));
      }
      if (subjects.isNotEmpty)
        results
            .add(_ParsedStudent(regNo: regNo, name: name, subjects: subjects));
    }
    return results;
  }

  Future<void> _saveAll() async {
    if (_parsed.isEmpty) return;
    setState(() {
      _saving = true;
      _status = 'Saving...';
      _notFound = [];
    });
    final db = FirebaseFirestore.instance;
    int saved = 0, skipped = 0;
    final notFound = <_ParsedStudent>[];

    for (final sr in _parsed) {
      final snap = await db
          .collection('students')
          .where('regNo', isEqualTo: sr.regNo)
          .limit(1)
          .get();
      if (snap.docs.isEmpty) {
        notFound.add(sr);
        continue;
      }
      final sid = snap.docs.first.id;
      final sname = snap.docs.first.data()['name'] ?? sr.name;

      for (final sub in sr.subjects) {
        final dup = await db
            .collection('results')
            .where('studentId', isEqualTo: sid)
            .where('semester', isEqualTo: _sem)
            .where('subjectCode', isEqualTo: sub.code)
            .get();
        if (dup.docs.isNotEmpty) {
          skipped++;
          continue;
        }
        await db.collection('results').add({
          'studentId': sid,
          'studentName': sname,
          'regNo': sr.regNo,
          'subjectCode': sub.code,
          'subjectName': sub.name,
          'credits': sub.credits,
          'grade': sub.grade,
          'gradePoint': sub.gp,
          'semester': _sem,
          'createdAt': FieldValue.serverTimestamp(),
        });
        saved++;
      }
    }
    setState(() {
      _saving = false;
      _notFound = notFound;
      _status =
          '✅ Done!\n• $saved results saved\n• $skipped skipped (duplicate)\n'
          '• ${notFound.fold(0, (s, r) => s + r.subjects.length)} skipped (student not in app)';
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)]),
                borderRadius: BorderRadius.circular(16)),
            child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Icon(Icons.picture_as_pdf_rounded,
                        color: Colors.white, size: 26),
                    SizedBox(width: 10),
                    Text('PTU Result PDF Import',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold))
                  ]),
                  SizedBox(height: 8),
                  Text(
                      '• Upload official PTU result PDF\n• Auto-reads RegNo, Name, Subject & Grade\n'
                      '• Students must be added first\n• Duplicate results are skipped',
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                ]),
          ),
          const SizedBox(height: 20),

          // Semester
          const Text('Select Semester',
              style: TextStyle(
                  color: Color(0xFF8B92B8),
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
              children: [1, 2, 3, 4].map((s) {
            final sel = _sem == s;
            return Expanded(
                child: GestureDetector(
              onTap: () => setState(() => _sem = s),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.only(right: s < 4 ? 10 : 0),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                    color:
                        sel ? const Color(0xFF6C63FF) : const Color(0xFF1A1F4E),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: sel
                            ? const Color(0xFF6C63FF)
                            : const Color(0xFF2D3470),
                        width: 1.5)),
                child: Column(children: [
                  Text('Sem',
                      style: TextStyle(
                          color: sel ? Colors.white70 : const Color(0xFF8B92B8),
                          fontSize: 11)),
                  Text('$s',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight:
                              sel ? FontWeight.bold : FontWeight.normal)),
                ]),
              ),
            ));
          }).toList()),
          const SizedBox(height: 20),

          // Pick button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _parsing || _saving ? null : _pickPdf,
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A1F4E),
                  elevation: 0,
                  side: const BorderSide(color: Color(0xFF4ECDC4), width: 2),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16))),
              icon: _parsing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Color(0xFF4ECDC4), strokeWidth: 2))
                  : const Icon(Icons.upload_file_rounded,
                      color: Color(0xFF4ECDC4)),
              label: Text(
                  _parsing
                      ? 'Reading PDF...'
                      : _fileName.isEmpty
                          ? 'Choose PDF File'
                          : _fileName,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis),
            ),
          ),
          const SizedBox(height: 20),

          // Preview
          if (_parsed.isNotEmpty) ...[
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('${_parsed.length} students found',
                  style: const TextStyle(
                      color: Color(0xFF4ECDC4),
                      fontSize: 14,
                      fontWeight: FontWeight.bold)),
              Text(
                  '${_parsed.fold(0, (s, r) => s + r.subjects.length)} subjects',
                  style:
                      const TextStyle(color: Color(0xFF8B92B8), fontSize: 13)),
            ]),
            const SizedBox(height: 12),
            ..._parsed.map(_card),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _saveAll,
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4ECDC4),
                    foregroundColor: const Color(0xFF0A0E27),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    disabledBackgroundColor:
                        const Color(0xFF4ECDC4).withOpacity(0.5)),
                icon: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Color(0xFF0A0E27), strokeWidth: 2))
                    : const Icon(Icons.cloud_upload_rounded),
                label: Text(_saving ? 'Saving...' : 'Save All to Firestore',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],

          // Not found warning
          if (_notFound.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: const Color(0xFFFF9800).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFF9800), width: 1)),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(children: [
                      Icon(Icons.warning_amber_rounded,
                          color: Color(0xFFFF9800), size: 18),
                      SizedBox(width: 6),
                      Text('Students not in app (add them first):',
                          style: TextStyle(
                              color: Color(0xFFFF9800),
                              fontWeight: FontWeight.bold,
                              fontSize: 13))
                    ]),
                    const SizedBox(height: 8),
                    ..._notFound.map((s) => Text('• ${s.regNo}  ${s.name}',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12))),
                  ]),
            ),
          ],

          // Status
          if (_status.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: _status.startsWith('✅')
                      ? const Color(0xFF43A047).withOpacity(0.12)
                      : const Color(0xFFE53935).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: _status.startsWith('✅')
                          ? const Color(0xFF43A047)
                          : const Color(0xFFE53935),
                      width: 1)),
              child: Text(_status,
                  style: TextStyle(
                      color: _status.startsWith('✅')
                          ? const Color(0xFF43A047)
                          : const Color(0xFFFF6B6B),
                      fontSize: 13,
                      height: 1.6)),
            ),
          ],
          const SizedBox(height: 24),
        ]));
  }

  Widget _card(_ParsedStudent sr) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
          color: const Color(0xFF1A1F4E),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF2D3470), width: 1)),
      child: Theme(
        data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent,
            colorScheme: const ColorScheme.dark()),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          title: Text(sr.name,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold)),
          subtitle: Text('${sr.regNo}  •  ${sr.subjects.length} subjects',
              style: const TextStyle(color: Color(0xFF8B92B8), fontSize: 12)),
          iconColor: const Color(0xFF4ECDC4),
          collapsedIconColor: const Color(0xFF8B92B8),
          children: sr.subjects.map((sub) {
            final c = Color(GpaCalculator.gradeColor(sub.grade));
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(children: [
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(sub.code,
                          style: const TextStyle(
                              color: Color(0xFF6C63FF),
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                      Text(sub.name,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ])),
                Text('${sub.credits} cr',
                    style: const TextStyle(
                        color: Color(0xFF8B92B8), fontSize: 12)),
                const SizedBox(width: 10),
                Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        color: c.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8)),
                    child: Text(sub.grade,
                        style: TextStyle(
                            color: c,
                            fontWeight: FontWeight.bold,
                            fontSize: 14))),
              ]),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _ParsedStudent {
  final String regNo, name;
  final List<_SubjectGrade> subjects;
  _ParsedStudent(
      {required this.regNo, required this.name, required this.subjects});
}

class _SubjectGrade {
  final String code, name, grade;
  final double gp, credits;
  _SubjectGrade(
      {required this.code,
      required this.name,
      required this.grade,
      required this.gp,
      required this.credits});
}
