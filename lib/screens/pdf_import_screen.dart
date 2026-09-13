// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:syncfusion_flutter_pdf/pdf.dart';
// import '../services/pdf_parser_service.dart';
// import '../utils/gpa_calculator.dart';

// class PdfImportScreen extends StatefulWidget {
//   const PdfImportScreen({super.key});

//   @override
//   State<PdfImportScreen> createState() => _PdfImportScreenState();
// }

// class _PdfImportScreenState extends State<PdfImportScreen> {
//   int _step = 0;
//   bool _isFetchingStudents = true;
//   bool _isProcessing = false;
//   bool _isSaving = false;

//   List<Map<String, dynamic>> _students = [];
//   String? _selectedStudentId;
//   String? _selectedStudentName;
//   int _selectedSemester = 1;

//   String? _pickedFileName;
//   List<Map<String, dynamic>> _parsedResults = [];
//   List<Map<String, dynamic>> _subjectSetup = [];

//   @override
//   void initState() {
//     super.initState();
//     _fetchStudents();
//   }

//   Future<void> _fetchStudents() async {
//     try {
//       final snap = await FirebaseFirestore.instance
//           .collection('students')
//           .orderBy('name')
//           .get();
//       setState(() {
//         _students = snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
//         _isFetchingStudents = false;
//       });
//     } catch (_) {
//       setState(() => _isFetchingStudents = false);
//     }
//   }

//   Future<List<Map<String, dynamic>>> _fetchSubjectSetup(int semester) async {
//     try {
//       final snap = await FirebaseFirestore.instance
//           .collection('subject_setup')
//           .where('semester', isEqualTo: semester)
//           .get();
//       return snap.docs.map((d) => d.data()).toList();
//     } catch (_) {
//       return [];
//     }
//   }

//   // ── Pick PDF and extract text via syncfusion_flutter_pdf ──────────
//   Future<void> _pickAndParsePdf() async {
//     if (_selectedStudentId == null) {
//       _showMsg('Please select a student first', isError: true);
//       return;
//     }

//     final result = await FilePicker.platform.pickFiles(
//       type: FileType.custom,
//       allowedExtensions: ['pdf'],
//     );
//     if (result == null || result.files.single.path == null) return;

//     final path = result.files.single.path!;
//     setState(() {
//       _isProcessing = true;
//       _pickedFileName = result.files.single.name;
//     });

//     try {
//       // ── Syncfusion text extraction (null-safe, no licence needed for basic use) ──
//       final bytes = File(path).readAsBytesSync();
//       final pdfDoc = PdfDocument(inputBytes: bytes);
//       final rawText = PdfTextExtractor(pdfDoc).extractText();
//       pdfDoc.dispose();
//       // ─────────────────────────────────────────────────────────────────────────────

//       _subjectSetup = await _fetchSubjectSetup(_selectedSemester);

//       final parsed = PdfParserService.parseResultText(
//         rawText: rawText,
//         semester: _selectedSemester,
//         studentId: _selectedStudentId!,
//         studentName: _selectedStudentName!,
//         subjectSetup: _subjectSetup,
//       );

//       final validated = PdfParserService.validate(parsed);

//       if (validated.isEmpty) {
//         _showMsg(
//             'Could not extract results from this PDF. Please check the format.',
//             isError: true);
//         setState(() => _isProcessing = false);
//         return;
//       }

//       setState(() {
//         _parsedResults = validated;
//         _step = 1;
//         _isProcessing = false;
//       });
//     } catch (e) {
//       _showMsg('Error reading PDF: $e', isError: true);
//       setState(() => _isProcessing = false);
//     }
//   }

//   Future<void> _saveResults() async {
//     setState(() => _isSaving = true);
//     try {
//       final batch = FirebaseFirestore.instance.batch();

//       for (final r in _parsedResults) {
//         final existing = await FirebaseFirestore.instance
//             .collection('results')
//             .where('studentId', isEqualTo: _selectedStudentId)
//             .where('semester', isEqualTo: _selectedSemester)
//             .where('subjectCode', isEqualTo: r['subjectCode'])
//             .get();

//         if (existing.docs.isNotEmpty) {
//           batch.update(existing.docs.first.reference, {
//             'grade': r['grade'],
//             'gradePoint': r['gradePoint'],
//             'credits': r['credits'],
//             'subjectName': r['subjectName'],
//             'updatedAt': FieldValue.serverTimestamp(),
//           });
//         } else {
//           final docRef = FirebaseFirestore.instance.collection('results').doc();
//           batch.set(docRef, {
//             'studentId': _selectedStudentId,
//             'studentName': _selectedStudentName,
//             'subjectCode': r['subjectCode'],
//             'subjectName': r['subjectName'],
//             'credits': r['credits'],
//             'grade': r['grade'],
//             'gradePoint': r['gradePoint'],
//             'semester': _selectedSemester,
//             'createdAt': FieldValue.serverTimestamp(),
//             'importedFromPdf': true,
//           });
//         }
//       }

//       await batch.commit();
//       await _updateRankings();

//       setState(() {
//         _step = 2;
//         _isSaving = false;
//       });
//     } catch (e) {
//       _showMsg('Failed to save results: $e', isError: true);
//       setState(() => _isSaving = false);
//     }
//   }

//   Future<void> _updateRankings() async {
//     try {
//       final snap = await FirebaseFirestore.instance
//           .collection('results')
//           .where('semester', isEqualTo: _selectedSemester)
//           .get();

//       final Map<String, List<Map<String, dynamic>>> grouped = {};
//       for (final doc in snap.docs) {
//         final data = doc.data();
//         final sid = data['studentId'] as String;
//         grouped.putIfAbsent(sid, () => []);
//         grouped[sid]!.add(data);
//       }

//       final rankings = grouped.entries.map((e) {
//         final gpa = GpaCalculator.calculateGPA(e.value);
//         return {'studentId': e.key, 'gpa': gpa};
//       }).toList()
//         ..sort((a, b) => (b['gpa'] as double).compareTo(a['gpa'] as double));

//       final batch = FirebaseFirestore.instance.batch();
//       for (int i = 0; i < rankings.length; i++) {
//         final ref = FirebaseFirestore.instance
//             .collection('rankings')
//             .doc('sem_${_selectedSemester}_${rankings[i]['studentId']}');
//         batch.set(ref, {
//           'studentId': rankings[i]['studentId'],
//           'semester': _selectedSemester,
//           'gpa': rankings[i]['gpa'],
//           'rank': i + 1,
//           'totalStudents': rankings.length,
//           'updatedAt': FieldValue.serverTimestamp(),
//         });
//       }
//       await batch.commit();
//     } catch (_) {}
//   }

//   void _showMsg(String msg, {bool isError = false}) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//       content: Text(msg),
//       backgroundColor:
//           isError ? const Color(0xFFE53935) : const Color(0xFF43A047),
//       behavior: SnackBarBehavior.floating,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       margin: const EdgeInsets.all(16),
//     ));
//   }

//   void _reset() {
//     setState(() {
//       _step = 0;
//       _parsedResults = [];
//       _pickedFileName = null;
//       _selectedStudentId = null;
//       _selectedStudentName = null;
//       _selectedSemester = 1;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF0A0E27),
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF1A1F4E),
//         title: const Text('Import Result PDF',
//             style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//         iconTheme: const IconThemeData(color: Colors.white),
//         elevation: 0,
//         actions: [
//           if (_step > 0)
//             TextButton.icon(
//               onPressed: _reset,
//               icon: const Icon(Icons.refresh_rounded,
//                   color: Color(0xFF4ECDC4), size: 18),
//               label: const Text('Reset',
//                   style: TextStyle(color: Color(0xFF4ECDC4))),
//             ),
//         ],
//       ),
//       body: _isFetchingStudents
//           ? const Center(
//               child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
//           : _step == 0
//               ? _buildSelectStep()
//               : _step == 1
//                   ? _buildPreviewStep()
//                   : _buildDoneStep(),
//     );
//   }

//   Widget _buildSelectStep() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               gradient: const LinearGradient(
//                   colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)]),
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: const Row(
//               children: [
//                 Icon(Icons.picture_as_pdf_rounded,
//                     color: Colors.white, size: 40),
//                 SizedBox(width: 16),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text('Upload Result PDF',
//                           style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold)),
//                       SizedBox(height: 2),
//                       Text('Select student & semester, then pick the PDF',
//                           style:
//                               TextStyle(color: Colors.white70, fontSize: 12)),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 24),
//           const _Label('Select Student'),
//           const SizedBox(height: 8),
//           Container(
//             decoration: BoxDecoration(
//               color: const Color(0xFF1A1F4E),
//               borderRadius: BorderRadius.circular(14),
//               border: Border.all(color: const Color(0xFF2D3470), width: 1.5),
//             ),
//             child: DropdownButtonFormField<String>(
//               value: _selectedStudentId,
//               dropdownColor: const Color(0xFF1A1F4E),
//               style: const TextStyle(color: Colors.white, fontSize: 14),
//               icon: const Icon(Icons.keyboard_arrow_down_rounded,
//                   color: Color(0xFF6C63FF)),
//               decoration: const InputDecoration(
//                 contentPadding:
//                     EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//                 border: InputBorder.none,
//                 prefixIcon: Icon(Icons.person_search_rounded,
//                     color: Color(0xFF6C63FF), size: 20),
//               ),
//               hint: const Text('Select a student',
//                   style: TextStyle(color: Color(0xFF4A5180))),
//               items: _students.map((s) {
//                 return DropdownMenuItem<String>(
//                   value: s['id'],
//                   child: Text('${s['name']} (${s['regNo'] ?? ''})'),
//                 );
//               }).toList(),
//               onChanged: (val) {
//                 setState(() {
//                   _selectedStudentId = val;
//                   _selectedStudentName =
//                       _students.firstWhere((s) => s['id'] == val)['name'];
//                 });
//               },
//             ),
//           ),
//           const SizedBox(height: 20),
//           const _Label('Semester'),
//           const SizedBox(height: 8),
//           Row(
//             children: List.generate(8, (i) {
//               final sem = i + 1;
//               final isSelected = _selectedSemester == sem;
//               return Expanded(
//                 child: GestureDetector(
//                   onTap: () => setState(() => _selectedSemester = sem),
//                   child: AnimatedContainer(
//                     duration: const Duration(milliseconds: 200),
//                     margin: EdgeInsets.only(right: sem < 8 ? 6 : 0),
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                     decoration: BoxDecoration(
//                       color: isSelected
//                           ? const Color(0xFF6C63FF)
//                           : const Color(0xFF1A1F4E),
//                       borderRadius: BorderRadius.circular(10),
//                       border: Border.all(
//                         color: isSelected
//                             ? const Color(0xFF6C63FF)
//                             : const Color(0xFF2D3470),
//                         width: 1.5,
//                       ),
//                     ),
//                     child: Text('$sem',
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                             color: Colors.white,
//                             fontWeight: isSelected
//                                 ? FontWeight.bold
//                                 : FontWeight.normal)),
//                   ),
//                 ),
//               );
//             }),
//           ),
//           const SizedBox(height: 32),
//           SizedBox(
//             width: double.infinity,
//             height: 56,
//             child: ElevatedButton.icon(
//               onPressed: _isProcessing ? null : _pickAndParsePdf,
//               icon: _isProcessing
//                   ? const SizedBox(
//                       width: 20,
//                       height: 20,
//                       child: CircularProgressIndicator(
//                           color: Colors.white, strokeWidth: 2.5))
//                   : const Icon(Icons.upload_file_rounded, color: Colors.white),
//               label: Text(
//                 _isProcessing ? 'Parsing PDF...' : 'Pick Result PDF',
//                 style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold),
//               ),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF6C63FF),
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16)),
//                 elevation: 0,
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),
//           Container(
//             padding: const EdgeInsets.all(14),
//             decoration: BoxDecoration(
//               color: const Color(0xFF1A1F4E),
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: const Color(0xFF2D3470)),
//             ),
//             child: const Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Icon(Icons.info_outline_rounded,
//                     color: Color(0xFF4ECDC4), size: 18),
//                 SizedBox(width: 10),
//                 Expanded(
//                   child: Text(
//                     'Tip: Set up subjects first in "Subject Setup" so credits '
//                     'are auto-matched. The PDF should have Subject Code, '
//                     'Subject Name, Credits and Grade columns.',
//                     style: TextStyle(color: Color(0xFF8B92B8), fontSize: 12),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPreviewStep() {
//     final gpa = GpaCalculator.calculateGPA(_parsedResults);
//     return Column(
//       children: [
//         Container(
//           color: const Color(0xFF1A1F4E),
//           padding: const EdgeInsets.all(16),
//           child: Row(
//             children: [
//               const Icon(Icons.check_circle_rounded,
//                   color: Color(0xFF43A047), size: 20),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text('$_selectedStudentName — Sem $_selectedSemester',
//                         style: const TextStyle(
//                             color: Colors.white, fontWeight: FontWeight.bold)),
//                     Text(
//                         '${_parsedResults.length} subjects • GPA: ${gpa.toStringAsFixed(2)}',
//                         style: const TextStyle(
//                             color: Color(0xFF8B92B8), fontSize: 12)),
//                   ],
//                 ),
//               ),
//               Text(gpa.toStringAsFixed(2),
//                   style: const TextStyle(
//                       color: Color(0xFF6C63FF),
//                       fontWeight: FontWeight.bold,
//                       fontSize: 22)),
//             ],
//           ),
//         ),
//         Expanded(
//           child: ListView.builder(
//             padding: const EdgeInsets.all(16),
//             itemCount: _parsedResults.length,
//             itemBuilder: (ctx, i) {
//               final r = _parsedResults[i];
//               final grade = r['grade'] as String;
//               final gc = Color(GpaCalculator.gradeColor(grade));
//               return Container(
//                 margin: const EdgeInsets.only(bottom: 10),
//                 padding: const EdgeInsets.all(14),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFF1A1F4E),
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: const Color(0xFF2D3470)),
//                 ),
//                 child: Row(
//                   children: [
//                     Text('${i + 1}',
//                         style: const TextStyle(
//                             color: Color(0xFF4A5180), fontSize: 12)),
//                     const SizedBox(width: 10),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(r['subjectCode'] ?? '',
//                               style: const TextStyle(
//                                   color: Color(0xFF6C63FF),
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 12)),
//                           Text(r['subjectName'] ?? '',
//                               style: const TextStyle(
//                                   color: Colors.white, fontSize: 13),
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis),
//                         ],
//                       ),
//                     ),
//                     Text('${r['credits']}cr',
//                         style: const TextStyle(
//                             color: Color(0xFF8B92B8), fontSize: 12)),
//                     const SizedBox(width: 12),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 10, vertical: 4),
//                       decoration: BoxDecoration(
//                         color: gc.withOpacity(0.15),
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(color: gc.withOpacity(0.5)),
//                       ),
//                       child: Text(grade,
//                           style: TextStyle(
//                               color: gc,
//                               fontWeight: FontWeight.bold,
//                               fontSize: 14)),
//                     ),
//                     const SizedBox(width: 4),
//                     GestureDetector(
//                       onTap: () => _editGrade(i),
//                       child: const Icon(Icons.edit_rounded,
//                           color: Color(0xFF4A5180), size: 16),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ),
//         Container(
//           color: const Color(0xFF1A1F4E),
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             children: [
//               const Text(
//                 'Review above. Tap ✏️ to fix any grade.',
//                 style: TextStyle(color: Color(0xFF8B92B8), fontSize: 12),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 12),
//               SizedBox(
//                 width: double.infinity,
//                 height: 52,
//                 child: ElevatedButton.icon(
//                   onPressed: _isSaving ? null : _saveResults,
//                   icon: _isSaving
//                       ? const SizedBox(
//                           width: 20,
//                           height: 20,
//                           child: CircularProgressIndicator(
//                               color: Colors.white, strokeWidth: 2.5))
//                       : const Icon(Icons.save_rounded, color: Colors.white),
//                   label: Text(
//                       _isSaving ? 'Saving...' : 'Confirm & Save Results',
//                       style: const TextStyle(
//                           color: Colors.white, fontWeight: FontWeight.bold)),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF43A047),
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(14)),
//                     elevation: 0,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildDoneStep() {
//     final gpa = GpaCalculator.calculateGPA(_parsedResults);
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(32),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.check_circle_rounded,
//                 color: Color(0xFF43A047), size: 80),
//             const SizedBox(height: 20),
//             const Text('Results Saved!',
//                 style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold)),
//             const SizedBox(height: 8),
//             Text('$_selectedStudentName — Semester $_selectedSemester',
//                 style: const TextStyle(color: Color(0xFF8B92B8)),
//                 textAlign: TextAlign.center),
//             const SizedBox(height: 24),
//             Container(
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: const Color(0xFF1A1F4E),
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: [
//                   _summaryItem('${_parsedResults.length}', 'Subjects',
//                       Icons.book_rounded),
//                   _summaryItem(
//                       gpa.toStringAsFixed(2), 'GPA', Icons.grade_rounded),
//                   _summaryItem(
//                       '${_parsedResults.where((r) => r['grade'] == 'F').length}',
//                       'Arrears',
//                       Icons.warning_rounded),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 32),
//             Row(
//               children: [
//                 Expanded(
//                   child: OutlinedButton.icon(
//                     onPressed: _reset,
//                     icon: const Icon(Icons.upload_file_rounded,
//                         color: Color(0xFF6C63FF)),
//                     label: const Text('Import Another',
//                         style: TextStyle(color: Color(0xFF6C63FF))),
//                     style: OutlinedButton.styleFrom(
//                       side: const BorderSide(color: Color(0xFF6C63FF)),
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12)),
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: ElevatedButton.icon(
//                     onPressed: () => Navigator.pop(context),
//                     icon: const Icon(Icons.home_rounded, color: Colors.white),
//                     label: const Text('Dashboard',
//                         style: TextStyle(color: Colors.white)),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFF6C63FF),
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12)),
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       elevation: 0,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _summaryItem(String value, String label, IconData icon) {
//     return Column(
//       children: [
//         Icon(icon, color: const Color(0xFF6C63FF), size: 20),
//         const SizedBox(height: 4),
//         Text(value,
//             style: const TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 20)),
//         Text(label,
//             style: const TextStyle(color: Color(0xFF8B92B8), fontSize: 11)),
//       ],
//     );
//   }

//   Future<void> _editGrade(int index) async {
//     final grades = ['S', 'A', 'B', 'C', 'D', 'E', 'F'];
//     final currentGrade = _parsedResults[index]['grade'] as String;

//     final selected = await showDialog<String>(
//       context: context,
//       builder: (_) => AlertDialog(
//         backgroundColor: const Color(0xFF1A1F4E),
//         title: Text(
//           'Edit Grade — ${_parsedResults[index]['subjectCode']}',
//           style: const TextStyle(color: Colors.white, fontSize: 15),
//         ),
//         content: Wrap(
//           spacing: 8,
//           runSpacing: 8,
//           children: grades.map((g) {
//             final color = Color(GpaCalculator.gradeColor(g));
//             final isSel = g == currentGrade;
//             return GestureDetector(
//               onTap: () => Navigator.pop(_, g),
//               child: Container(
//                 width: 52,
//                 height: 52,
//                 decoration: BoxDecoration(
//                   color:
//                       isSel ? color.withOpacity(0.2) : const Color(0xFF0A0E27),
//                   borderRadius: BorderRadius.circular(10),
//                   border: Border.all(
//                       color: isSel ? color : const Color(0xFF2D3470),
//                       width: isSel ? 2 : 1),
//                 ),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(g,
//                         style: TextStyle(
//                             color: isSel ? color : Colors.white,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 18)),
//                     Text('${GpaCalculator.gradeToPoint(g)}',
//                         style: const TextStyle(
//                             color: Color(0xFF8B92B8), fontSize: 10)),
//                   ],
//                 ),
//               ),
//             );
//           }).toList(),
//         ),
//       ),
//     );

//     if (selected != null && mounted) {
//       setState(() {
//         _parsedResults[index]['grade'] = selected;
//         _parsedResults[index]['gradePoint'] =
//             GpaCalculator.gradeToPoint(selected).toDouble();
//       });
//     }
//   }
// }

// class _Label extends StatelessWidget {
//   final String text;
//   const _Label(this.text);

//   @override
//   Widget build(BuildContext context) => Text(
//         text,
//         style: const TextStyle(
//             color: Color(0xFF8B92B8),
//             fontSize: 13,
//             fontWeight: FontWeight.w600),
//       );
// }

// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:syncfusion_flutter_pdf/pdf.dart';
// import '../services/result_storage_service.dart';

// class PdfImportScreen extends StatefulWidget {
//   const PdfImportScreen({super.key});
//   @override
//   State<PdfImportScreen> createState() => _PdfImportScreenState();
// }

// class _PdfImportScreenState extends State<PdfImportScreen> {
//   final _service = ResultStorageService();
//   int _step = 0;
//   bool _isFetchingStudents = true;
//   int _selectedSemester = 1;
//   String? _pickedFileName;
//   ImportResult? _importResult;
//   String _rawExtractedText = '';
//   bool _showDebug = false;
//   List<Map<String, dynamic>> _students = [];

//   @override
//   void initState() {
//     super.initState();
//     _fetchStudents();
//   }

//   Future<void> _fetchStudents() async {
//     try {
//       final snap = await FirebaseFirestore.instance
//           .collection('students')
//           .orderBy('name')
//           .get();
//       setState(() {
//         _students = snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
//         _isFetchingStudents = false;
//       });
//     } catch (_) {
//       setState(() => _isFetchingStudents = false);
//     }
//   }

//   Future<void> _pickAndImport() async {
//     final result = await FilePicker.platform
//         .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
//     if (result == null || result.files.single.path == null) return;

//     final path = result.files.single.path!;
//     setState(() {
//       _step = 1;
//       _pickedFileName = result.files.single.name;
//     });

//     try {
//       // Page-by-page extraction preserves line breaks better
//       final bytes = File(path).readAsBytesSync();
//       final pdfDoc = PdfDocument(inputBytes: bytes);
//       final sb = StringBuffer();
//       for (int i = 0; i < pdfDoc.pages.count; i++) {
//         final t = PdfTextExtractor(pdfDoc)
//             .extractText(startPageIndex: i, endPageIndex: i);
//         sb.writeln(t);
//       }
//       pdfDoc.dispose();
//       final rawText = sb.toString();
//       setState(() => _rawExtractedText = rawText);

//       final importResult = await _service.importResultsFromPdf(
//         rawText: rawText,
//         localPdfPath: path,
//         semester: _selectedSemester,
//       );
//       setState(() {
//         _importResult = importResult;
//         _step = importResult.success ? 2 : 3;
//       });
//     } catch (e) {
//       setState(() {
//         _importResult = ImportResult(
//             success: false, message: 'Error: $e', studentsProcessed: 0);
//         _step = 3;
//       });
//     }
//   }

//   void _reset() => setState(() {
//         _step = 0;
//         _importResult = null;
//         _pickedFileName = null;
//         _selectedSemester = 1;
//         _rawExtractedText = '';
//         _showDebug = false;
//       });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF0A0E27),
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF1A1F4E),
//         title: const Text('Import Result PDF',
//             style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//         iconTheme: const IconThemeData(color: Colors.white),
//         elevation: 0,
//         actions: [
//           if (_rawExtractedText.isNotEmpty)
//             IconButton(
//               icon: Icon(
//                   _showDebug ? Icons.bug_report : Icons.bug_report_outlined,
//                   color: const Color(0xFFFFBE0B)),
//               tooltip: 'View raw PDF text',
//               onPressed: () => setState(() => _showDebug = !_showDebug),
//             ),
//           if (_step > 0)
//             TextButton.icon(
//               onPressed: _reset,
//               icon: const Icon(Icons.refresh_rounded,
//                   color: Color(0xFF4ECDC4), size: 18),
//               label: const Text('Reset',
//                   style: TextStyle(color: Color(0xFF4ECDC4))),
//             ),
//         ],
//       ),
//       body: _showDebug
//           ? _buildDebugView()
//           : _isFetchingStudents
//               ? const Center(
//                   child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
//               : _step == 0
//                   ? _buildSelectStep()
//                   : _step == 1
//                       ? _buildProcessingStep()
//                       : _step == 2
//                           ? _buildDoneStep()
//                           : _buildErrorStep(),
//     );
//   }

//   // ─── DEBUG VIEW ──────────────────────────────────────────────────
//   Widget _buildDebugView() {
//     final lines = _rawExtractedText
//         .split('\n')
//         .map((l) => l.trim())
//         .where((l) => l.isNotEmpty)
//         .toList();
//     final parsed = _service.parsePdfText(_rawExtractedText);

//     return Column(
//       children: [
//         Container(
//           color: const Color(0xFF1A1F4E),
//           padding: const EdgeInsets.all(12),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text('${lines.length} lines extracted from PDF',
//                   style: const TextStyle(
//                       color: Color(0xFF4ECDC4), fontWeight: FontWeight.bold)),
//               Text(
//                 'Parser found ${parsed.length} subject-grade rows for ${parsed.map((r) => r['registerNumber']).toSet().length} students',
//                 style: TextStyle(
//                   color: parsed.isEmpty
//                       ? const Color(0xFFE53935)
//                       : const Color(0xFF43A047),
//                   fontSize: 12,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               const Text(
//                 '🟢 Green = student line matched  🟡 Yellow = has register no but no subjects',
//                 style: TextStyle(color: Color(0xFF8B92B8), fontSize: 10),
//               ),
//             ],
//           ),
//         ),
//         Expanded(
//           child: ListView.builder(
//             padding: const EdgeInsets.all(8),
//             itemCount: lines.length,
//             itemBuilder: (_, i) {
//               final line = lines[i];
//               final hasReg = RegExp(r'\b\d{10}\b').hasMatch(line);
//               final hasPairs = RegExp(r'[A-Z]{2,4}\d{3,4}\s*-\s*[SABCDEFP]',
//                       caseSensitive: false)
//                   .hasMatch(line);
//               return Container(
//                 margin: const EdgeInsets.only(bottom: 2),
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//                 decoration: BoxDecoration(
//                   color: hasReg && hasPairs
//                       ? const Color(0xFF43A047).withOpacity(0.15)
//                       : hasReg
//                           ? const Color(0xFFFFBE0B).withOpacity(0.1)
//                           : const Color(0xFF1A1F4E),
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     SizedBox(
//                       width: 26,
//                       child: Text('${i + 1}',
//                           style: const TextStyle(
//                               color: Color(0xFF4A5180), fontSize: 10)),
//                     ),
//                     Expanded(
//                       child: Text(line,
//                           style: TextStyle(
//                             color: hasReg && hasPairs
//                                 ? Colors.white
//                                 : hasReg
//                                     ? const Color(0xFFFFBE0B)
//                                     : const Color(0xFF6B7280),
//                             fontSize: 10,
//                           )),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ),
//         if (parsed.isNotEmpty)
//           Container(
//             color: const Color(0xFF1A1F4E),
//             padding: const EdgeInsets.all(12),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text('✅ First 5 parsed rows:',
//                     style: TextStyle(
//                         color: Color(0xFF43A047),
//                         fontWeight: FontWeight.bold,
//                         fontSize: 12)),
//                 const SizedBox(height: 4),
//                 ...parsed.take(5).map((r) => Text(
//                       'RegNo: ${r['registerNumber']}  Code: ${r['subjectCode']}  Grade: ${r['grade']}',
//                       style: const TextStyle(color: Colors.white, fontSize: 11),
//                     )),
//               ],
//             ),
//           ),
//       ],
//     );
//   }

//   // ─── STEP 0: Select ──────────────────────────────────────────────
//   Widget _buildSelectStep() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               gradient: const LinearGradient(
//                   colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)]),
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: const Row(children: [
//               Icon(Icons.picture_as_pdf_rounded, color: Colors.white, size: 40),
//               SizedBox(width: 16),
//               Expanded(
//                 child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text('Upload Result PDF',
//                           style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold)),
//                       SizedBox(height: 2),
//                       Text(
//                           'Select semester → pick PDF → all students auto-processed',
//                           style:
//                               TextStyle(color: Colors.white70, fontSize: 12)),
//                     ]),
//               ),
//             ]),
//           ),
//           const SizedBox(height: 24),
//           const Text('Select Semester',
//               style: TextStyle(
//                   color: Color(0xFF8B92B8),
//                   fontSize: 13,
//                   fontWeight: FontWeight.w600)),
//           const SizedBox(height: 8),
//           Row(
//             children: List.generate(8, (i) {
//               final sem = i + 1;
//               final isSel = _selectedSemester == sem;
//               return Expanded(
//                 child: GestureDetector(
//                   onTap: () => setState(() => _selectedSemester = sem),
//                   child: AnimatedContainer(
//                     duration: const Duration(milliseconds: 200),
//                     margin: EdgeInsets.only(right: sem < 8 ? 6 : 0),
//                     padding: const EdgeInsets.symmetric(vertical: 14),
//                     decoration: BoxDecoration(
//                       color: isSel
//                           ? const Color(0xFF6C63FF)
//                           : const Color(0xFF1A1F4E),
//                       borderRadius: BorderRadius.circular(10),
//                       border: Border.all(
//                           color: isSel
//                               ? const Color(0xFF6C63FF)
//                               : const Color(0xFF2D3470),
//                           width: 1.5),
//                     ),
//                     child: Column(children: [
//                       Text('Sem',
//                           style: TextStyle(
//                               color: isSel
//                                   ? Colors.white70
//                                   : const Color(0xFF8B92B8),
//                               fontSize: 9)),
//                       Text('$sem',
//                           style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 16,
//                               fontWeight:
//                                   isSel ? FontWeight.bold : FontWeight.normal)),
//                     ]),
//                   ),
//                 ),
//               );
//             }),
//           ),
//           const SizedBox(height: 32),
//           SizedBox(
//             width: double.infinity,
//             height: 56,
//             child: ElevatedButton.icon(
//               onPressed: _pickAndImport,
//               icon: const Icon(Icons.upload_file_rounded, color: Colors.white),
//               label: const Text('Pick Result PDF & Import',
//                   style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold)),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF6C63FF),
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16)),
//                 elevation: 0,
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),
//           Container(
//             padding: const EdgeInsets.all(14),
//             decoration: BoxDecoration(
//                 color: const Color(0xFF1A1F4E),
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: const Color(0xFF2D3470))),
//             child: const Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Icon(Icons.info_outline_rounded,
//                     color: Color(0xFF4ECDC4), size: 18),
//                 SizedBox(width: 10),
//                 Expanded(
//                   child: Text(
//                     'Expected: 10-digit register no, student name, then SubjectCode - Grade pairs.\n'
//                     'Example: 2303107014  JAYAPRADHA J  MAA101 - D  PHA101 - D',
//                     style: TextStyle(color: Color(0xFF8B92B8), fontSize: 12),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ─── STEP 1 ──────────────────────────────────────────────────────
//   Widget _buildProcessingStep() {
//     return Center(
//       child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
//         const CircularProgressIndicator(
//             color: Color(0xFF6C63FF), strokeWidth: 3),
//         const SizedBox(height: 24),
//         const Text('Processing PDF...',
//             style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold)),
//         const SizedBox(height: 8),
//         Text(_pickedFileName ?? '',
//             style: const TextStyle(color: Color(0xFF8B92B8), fontSize: 13)),
//       ]),
//     );
//   }

//   // ─── STEP 2: Done ────────────────────────────────────────────────
//   Widget _buildDoneStep() {
//     final r = _importResult!;
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(32),
//         child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
//           const Icon(Icons.check_circle_rounded,
//               color: Color(0xFF43A047), size: 80),
//           const SizedBox(height: 20),
//           const Text('Import Complete!',
//               style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold)),
//           const SizedBox(height: 8),
//           Text(r.message,
//               style: const TextStyle(color: Color(0xFF8B92B8)),
//               textAlign: TextAlign.center),
//           const SizedBox(height: 24),
//           Container(
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//                 color: const Color(0xFF1A1F4E),
//                 borderRadius: BorderRadius.circular(16)),
//             child: Column(children: [
//               _doneRow(
//                   Icons.people_rounded,
//                   '${r.studentsProcessed} students processed',
//                   const Color(0xFF6C63FF)),
//               const SizedBox(height: 10),
//               _doneRow(Icons.cloud_done_rounded,
//                   'PDF stored in Firebase Storage', const Color(0xFF4ECDC4)),
//               const SizedBox(height: 10),
//               _doneRow(Icons.leaderboard_rounded, 'Rankings updated',
//                   const Color(0xFFFFD700)),
//               const SizedBox(height: 10),
//               _doneRow(Icons.grade_rounded, 'GPA & CGPA stored',
//                   const Color(0xFF43A047)),
//             ]),
//           ),
//           const SizedBox(height: 32),
//           Row(children: [
//             Expanded(
//               child: OutlinedButton.icon(
//                 onPressed: _reset,
//                 icon: const Icon(Icons.upload_file_rounded,
//                     color: Color(0xFF6C63FF)),
//                 label: const Text('Import Another',
//                     style: TextStyle(color: Color(0xFF6C63FF))),
//                 style: OutlinedButton.styleFrom(
//                   side: const BorderSide(color: Color(0xFF6C63FF)),
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12)),
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: ElevatedButton.icon(
//                 onPressed: () => Navigator.pop(context),
//                 icon: const Icon(Icons.home_rounded, color: Colors.white),
//                 label: const Text('Dashboard',
//                     style: TextStyle(color: Colors.white)),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF6C63FF),
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12)),
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                   elevation: 0,
//                 ),
//               ),
//             ),
//           ]),
//         ]),
//       ),
//     );
//   }

//   // ─── STEP 3: Error ───────────────────────────────────────────────
//   Widget _buildErrorStep() {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(32),
//         child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
//           const Icon(Icons.error_outline_rounded,
//               color: Color(0xFFE53935), size: 80),
//           const SizedBox(height: 20),
//           const Text('Import Failed',
//               style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold)),
//           const SizedBox(height: 8),
//           Text(_importResult?.message ?? 'Unknown error',
//               style: const TextStyle(color: Color(0xFF8B92B8)),
//               textAlign: TextAlign.center),
//           const SizedBox(height: 16),
//           if (_rawExtractedText.isNotEmpty)
//             ElevatedButton.icon(
//               onPressed: () => setState(() => _showDebug = true),
//               icon: const Icon(Icons.bug_report_rounded, color: Colors.white),
//               label: const Text('View Raw PDF Text',
//                   style: TextStyle(color: Colors.white)),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFFFFBE0B),
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12)),
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                 elevation: 0,
//               ),
//             ),
//           const SizedBox(height: 12),
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton.icon(
//               onPressed: _reset,
//               icon: const Icon(Icons.refresh_rounded, color: Colors.white),
//               label: const Text('Try Again',
//                   style: TextStyle(color: Colors.white)),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF6C63FF),
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(14)),
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//                 elevation: 0,
//               ),
//             ),
//           ),
//         ]),
//       ),
//     );
//   }

//   Widget _doneRow(IconData icon, String text, Color color) {
//     return Row(children: [
//       Icon(icon, color: color, size: 20),
//       const SizedBox(width: 10),
//       Expanded(
//           child: Text(text,
//               style: const TextStyle(color: Colors.white, fontSize: 13))),
//     ]);
//   }
// }

// screens/pdf_import_screen.dart
// Teacher UI for importing result PDFs.
// Uses ResultStorageService.importResultsFromPdf() directly.
// DO NOT modify navigation or auth logic.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../services/result_storage_service.dart';

class PdfImportScreen extends StatefulWidget {
  const PdfImportScreen({super.key});

  @override
  State<PdfImportScreen> createState() => _PdfImportScreenState();
}

class _PdfImportScreenState extends State<PdfImportScreen> {
  final ResultStorageService _service = ResultStorageService();

  int? _selectedSemester;
  File? _selectedFile;
  String? _selectedFileName;

  bool _isImporting = false;
  String _statusMessage = '';
  ImportResult? _lastResult;
  String? _errorMessage;

  final List<int> _semesters = List.generate(8, (i) => i + 1);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Import Result PDF'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInfoCard(theme),
            const SizedBox(height: 20),
            _buildSemesterSelector(theme),
            const SizedBox(height: 16),
            _buildFilePicker(theme),
            const SizedBox(height: 24),
            if (_isImporting) _buildProgress(theme),
            if (!_isImporting && _lastResult != null) _buildResultCard(theme),
            if (!_isImporting && _errorMessage != null) _buildErrorCard(theme),
            if (!_isImporting) _buildImportButton(theme),
          ],
        ),
      ),
    );
  }

  // ─── Widgets ───────────────────────────────────────────────────

  Widget _buildInfoCard(ThemeData theme) {
    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline,
                    color: theme.colorScheme.onPrimaryContainer),
                const SizedBox(width: 8),
                Text('Auto PDF Import System',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    )),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '• Upload ONE PDF containing all departments\n'
              '• Students are created automatically\n'
              '• Department resolved from register number\n'
              '• GPA, CGPA & Ranks calculated automatically',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onPrimaryContainer),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSemesterSelector(ThemeData theme) {
    return DropdownButtonFormField<int>(
      value: _selectedSemester,
      decoration: InputDecoration(
        labelText: 'Select Semester',
        prefixIcon: const Icon(Icons.school),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
      ),
      items: _semesters
          .map((s) => DropdownMenuItem(value: s, child: Text('Semester $s')))
          .toList(),
      onChanged: _isImporting
          ? null
          : (val) => setState(() => _selectedSemester = val),
    );
  }

  Widget _buildFilePicker(ThemeData theme) {
    return GestureDetector(
      onTap: _isImporting ? null : _pickFile,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(
            color: _selectedFile != null
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
            width: _selectedFile != null ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: _selectedFile != null
              ? theme.colorScheme.primaryContainer.withOpacity(0.3)
              : theme.colorScheme.surface,
        ),
        child: Column(
          children: [
            Icon(
              _selectedFile != null ? Icons.picture_as_pdf : Icons.upload_file,
              size: 40,
              color: _selectedFile != null
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline,
            ),
            const SizedBox(height: 8),
            Text(
              _selectedFile != null
                  ? (_selectedFileName ?? 'PDF Selected')
                  : 'Tap to select Result PDF',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: _selectedFile != null
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight:
                    _selectedFile != null ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
            if (_selectedFile != null) ...[
              const SizedBox(height: 4),
              Text('Tap to change file',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProgress(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(_statusMessage, style: theme.textTheme.bodyMedium),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(ThemeData theme) {
    final r = _lastResult!;
    return Card(
      color: theme.colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green.shade700),
                const SizedBox(width: 8),
                Text('Import Successful',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    )),
              ],
            ),
            const Divider(height: 16),
            _row('Total Students', '${r.studentsProcessed}'),
            _row('Newly Created', '${r.newStudentsCreated}'),
            _row('Updated', '${r.updatedStudents}'),
            const SizedBox(height: 4),
            Text(r.message,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            Text(value),
          ],
        ),
      );

  Widget _buildErrorCard(ThemeData theme) {
    return Card(
      color: theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: theme.colorScheme.error),
            const SizedBox(width: 8),
            Expanded(
              child: Text(_errorMessage!,
                  style: TextStyle(color: theme.colorScheme.error)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImportButton(ThemeData theme) {
    final isReady = _selectedSemester != null && _selectedFile != null;
    return ElevatedButton.icon(
      onPressed: isReady ? _startImport : null,
      icon: const Icon(Icons.cloud_upload),
      label: const Text('Import Result PDF'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ─── Actions ──────────────────────────────────────────────────

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        _selectedFileName = result.files.single.name;
        _lastResult = null;
        _errorMessage = null;
      });
    }
  }

  Future<void> _startImport() async {
    if (_selectedSemester == null || _selectedFile == null) return;

    setState(() {
      _isImporting = true;
      _statusMessage = 'Reading PDF...';
      _lastResult = null;
      _errorMessage = null;
    });

    try {
      // Extract text from PDF using Syncfusion
      setState(() => _statusMessage = 'Extracting text from PDF...');
      final bytes = await _selectedFile!.readAsBytes();
      final document = PdfDocument(inputBytes: bytes);
      final rawText = PdfTextExtractor(document).extractText();
      document.dispose();

      setState(() => _statusMessage = 'Importing results to Firestore...');

      final result = await _service.importResultsFromPdf(
        rawText: rawText,
        localPdfPath: _selectedFile!.path,
        semester: _selectedSemester!,
      );

      if (mounted) {
        setState(() {
          _isImporting = false;
          if (result.success) {
            _lastResult = result;
          } else {
            _errorMessage = result.message;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isImporting = false;
          _errorMessage = 'Error: $e';
        });
      }
    }
  }
}
