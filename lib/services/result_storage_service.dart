// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import '../utils/gpa_calculator.dart';
// import '../utils/department_resolver.dart';

// /// Firestore structure:
// ///   students/{registerNumber}
// ///     name, registerNumber, regNo, department, batch
// ///     semesters/{semId}
// ///       semesterGPA, cumulativeCGPA, rank, totalStudents, arrears
// ///       resultStatus   ← NEW: "Available" | "No Result"
// ///       subjects/{subjectCode}
// ///         subjectCode, subjectName, credit, grade, gradePoint, isPractical
// class ResultStorageService {
//   final FirebaseFirestore _db = FirebaseFirestore.instance;
//   final FirebaseStorage _storage = FirebaseStorage.instance;

//   // ── Upload PDF ─────────────────────────────────────────────────
//   Future<String?> uploadPdf(String localPath, int semester) async {
//     try {
//       final ref = _storage.ref(
//           'results/semester_$semester/result_${DateTime.now().millisecondsSinceEpoch}.pdf');
//       await ref.putFile(File(localPath));
//       return await ref.getDownloadURL();
//     } catch (_) {
//       return null;
//     }
//   }

//   // ══════════════════════════════════════════════════════════════
//   //  PARSER — returns one entry per register number found,
//   //  even when the student has NO subjects ("-----")
//   // ══════════════════════════════════════════════════════════════

//   /// Each returned map:
//   /// {
//   ///   'registerNumber': '2303107031',
//   ///   'name':           'Sarshini P',
//   ///   'subjects': [     // empty list when no result
//   ///     {'code': 'MAA101', 'grade': 'A', 'isPractical': false}, ...
//   ///   ],
//   ///   'hasResult': true | false,
//   /// }
//   List<Map<String, dynamic>> parsePdfText(String rawText) {
//     // ── Normalise ──────────────────────────────────────────────
//     final normalised = rawText
//         .replaceAll('\r', '')
//         .replaceAll('\t', ' ')
//         .replaceAll(RegExp(r' {2,}'), ' ');

//     final rawLines = normalised
//         .split('\n')
//         .map((l) => l.trim())
//         .where((l) => l.isNotEmpty)
//         .toList();

//     // ── Merge continuation lines ────────────────────────────────
//     // PTU wraps long rows. Any line that does NOT contain a
//     // 10-digit reg-no is a continuation of the previous line.
//     final lines = _joinContinuationLines(rawLines);

//     final results = <Map<String, dynamic>>[];

//     for (final line in lines) {
//       if (_isHeader(line)) continue;

//       // ── STEP 1: Must contain a 10-digit register number ──────
//       final regMatch = RegExp(r'\b(\d{10})\b').firstMatch(line);
//       if (regMatch == null) continue;

//       final regNo = regMatch.group(1)!;

//       // ── STEP 2: Extract name (text between regNo and subjects) ─
//       final afterReg = line.substring(regMatch.end).trim();
//       final studentName = _extractName(afterReg);

//       // ── STEP 3: Extract subject-grade pairs ──────────────────
//       final pairs = _extractPairs(line.toUpperCase());

//       // ── STEP 4: Detect no-result marker ("-----") ────────────
//       final bool hasResult = pairs.isNotEmpty;

//       // ── DEBUG LOG ─────────────────────────────────────────────
//       _debugLog(regNo, studentName, pairs.length, hasResult);

//       results.add({
//         'registerNumber': regNo,
//         'name': studentName,
//         'subjects': pairs,
//         'hasResult': hasResult,
//       });
//     }

//     return results;
//   }

//   // ── Extract name from text that follows the register number ────
//   String _extractName(String afterReg) {
//     // Try: leading CAPS words before first subject-like token
//     final nameMatch = RegExp(r'^([A-Z][A-Z\s\.]+?)\s+(?=[A-Z]{2,5}\d{3})',
//             caseSensitive: true)
//         .firstMatch(afterReg);
//     if (nameMatch != null) {
//       return _toTitleCase(nameMatch.group(1)!.trim());
//     }

//     // Fallback: strip subject codes, grades, dashes, numbers
//     final stripped = afterReg
//         .replaceAll(RegExp(r'[A-Z]{2,5}\d{3,4}\s*-\s*[SABCDEFPZ]'), '')
//         .replaceAll(RegExp(r'[-]+'), '')
//         .replaceAll(RegExp(r'\d+'), '')
//         .replaceAll(RegExp(r'\s{2,}'), ' ')
//         .trim();

//     final words = stripped.split(' ').where((w) => w.isNotEmpty).toList();
//     final nameWords = <String>[];
//     for (final w in words) {
//       if (RegExp(r'^[A-Za-z\.]+$').hasMatch(w)) {
//         nameWords.add(w);
//         if (nameWords.length == 5) break;
//       } else {
//         break;
//       }
//     }
//     return nameWords.isEmpty ? '' : _toTitleCase(nameWords.join(' '));
//   }

//   // ── Extract subject-grade pairs from a single line ──────────────
//   List<Map<String, String>> _extractPairs(String line) {
//     final pairs = <Map<String, String>>[];
//     final seen = <String>{};

//     // Pattern A: "MAA101 - D" or "MAA101 -D" or "MAA101- D"
//     final patternA = RegExp(r'([A-Z]{2,5}\d{3,4})\s*-\s*([SABCDEFPZ])\b');
//     for (final m in patternA.allMatches(line)) {
//       final code = m.group(1)!;
//       final grade = m.group(2)!;
//       if (!seen.contains(code)) {
//         seen.add(code);
//         pairs.add({'code': code, 'grade': grade});
//       }
//     }
//     if (pairs.isNotEmpty) return pairs;

//     // Pattern B: "MAA101 D" followed by another subject or end
//     final patternB = RegExp(
//         r'([A-Z]{2,5}\d{3,4})\s+([SABCDEFPZ])(?:\s+[A-Z]{2,5}\d{3,4}|\s*$)');
//     for (final m in patternB.allMatches(line)) {
//       final code = m.group(1)!;
//       final grade = m.group(2)!;
//       if (!seen.contains(code)) {
//         seen.add(code);
//         pairs.add({'code': code, 'grade': grade});
//       }
//     }
//     if (pairs.isNotEmpty) return pairs;

//     // Pattern C: "MAA101D" — no separator
//     final patternC = RegExp(r'([A-Z]{2,5}\d{3,4})([SABCDEFPZ])(?:\s|$)');
//     for (final m in patternC.allMatches(line)) {
//       final code = m.group(1)!;
//       final grade = m.group(2)!;
//       if (!seen.contains(code)) {
//         seen.add(code);
//         pairs.add({'code': code, 'grade': grade});
//       }
//     }
//     return pairs;
//   }

//   // ── Join continuation lines ─────────────────────────────────────
//   List<String> _joinContinuationLines(List<String> lines) {
//     final result = <String>[];
//     String buffer = '';

//     for (final line in lines) {
//       final hasReg = RegExp(r'\b\d{10}\b').hasMatch(line);
//       if (hasReg) {
//         if (buffer.isNotEmpty) result.add(buffer);
//         buffer = line;
//       } else if (buffer.isNotEmpty) {
//         buffer = '$buffer $line';
//       }
//     }
//     if (buffer.isNotEmpty) result.add(buffer);
//     return result;
//   }

//   // ══════════════════════════════════════════════════════════════
//   //  FULL IMPORT PIPELINE
//   // ══════════════════════════════════════════════════════════════

//   Future<ImportResult> importResultsFromPdf({
//     required String rawText,
//     required String localPdfPath,
//     required int semester,
//   }) async {
//     final pdfUrl = await uploadPdf(localPdfPath, semester);

//     final parsedRows = parsePdfText(rawText);

//     if (parsedRows.isEmpty) {
//       return ImportResult(
//         success: false,
//         message: 'No student records found in PDF.\n\n'
//             'Expected format:\n'
//             '2303107014  STUDENT NAME  MAA101 - D  PHA101 - S\n\n'
//             'The PDF text extraction may have failed for this file.',
//         studentsProcessed: 0,
//         pdfUrl: pdfUrl,
//       );
//     }

//     final subjectMaster = await _fetchSubjectMaster(semester);
//     int processed = 0, created = 0, updated = 0, noResultCount = 0;

//     for (final row in parsedRows) {
//       final regNo = row['registerNumber'] as String;
//       final studentName = (row['name'] as String?) ?? '';
//       final pairs = row['subjects'] as List<Map<String, String>>;
//       final hasResult = row['hasResult'] as bool;

//       final department = DepartmentResolver.resolveDepartment(regNo);
//       final batch = DepartmentResolver.resolveBatch(regNo);

//       // ── Always ensure student document exists ─────────────────
//       final wasCreated =
//           await _ensureStudentExists(regNo, studentName, department, batch);
//       wasCreated ? created++ : updated++;

//       if (!hasResult) {
//         // ── CASE B: No subjects — store empty semester record ────
//         noResultCount++;
//         await _saveEmptySemesterResult(
//           registerNumber: regNo,
//           semester: semester,
//           pdfUrl: pdfUrl,
//         );
//       } else {
//         // ── CASE A: Has subjects — store normally ─────────────
//         final subjects = <Map<String, dynamic>>[];
//         for (final pair in pairs) {
//           final code = pair['code']!;
//           final grade = pair['grade']!;
//           final isPractical = grade == 'P';
//           final master = subjectMaster[code];
//           final effectiveGrade = grade == 'Z' ? 'F' : grade;
//           final gradePoint = isPractical
//               ? 0.0
//               : GpaCalculator.gradeToPoint(effectiveGrade).toDouble();

//           subjects.add({
//             'subjectCode': code,
//             'subjectName': master?['subjectName'] ?? code,
//             'credit': isPractical
//                 ? 0.0
//                 : (master?['credits'] as num?)?.toDouble() ?? 3.0,
//             'grade': grade,
//             'gradePoint': gradePoint,
//             'isPractical': isPractical,
//           });
//         }

//         await _saveSemesterResults(
//           registerNumber: regNo,
//           semester: semester,
//           subjects: subjects,
//           pdfUrl: pdfUrl,
//         );
//       }

//       processed++;
//     }

//     // Rankings & CGPA
//     await updateSemesterRankings(semester);
//     for (final row in parsedRows) {
//       await _updateCumulativeCGPA(row['registerNumber'] as String);
//     }

//     return ImportResult(
//       success: true,
//       message: 'Imported $processed students '
//           '($created new, $updated updated) — Semester $semester.\n'
//           '$noResultCount student(s) had no result ("-----").',
//       studentsProcessed: processed,
//       newStudentsCreated: created,
//       updatedStudents: updated,
//       noResultStudents: noResultCount,
//       pdfUrl: pdfUrl,
//     );
//   }

//   // ══════════════════════════════════════════════════════════════
//   //  FIRESTORE WRITES
//   // ══════════════════════════════════════════════════════════════

//   Future<void> _saveSemesterResults({
//     required String registerNumber,
//     required int semester,
//     required List<Map<String, dynamic>> subjects,
//     String? pdfUrl,
//   }) async {
//     final semId = 'sem$semester';
//     final semRef = _db
//         .collection('students')
//         .doc(registerNumber)
//         .collection('semesters')
//         .doc(semId);

//     final gpaSubjects =
//         subjects.where((s) => !(s['isPractical'] as bool? ?? false)).toList();
//     final gpa = _calcGPA(gpaSubjects);
//     final arrears =
//         gpaSubjects.where((s) => s['grade'] == 'F' || s['grade'] == 'Z').length;

//     await semRef.set({
//       'semesterNumber': semester,
//       'semesterId': semId,
//       'semesterGPA': gpa,
//       'arrears': arrears,
//       'resultStatus': 'Available',
//       'pdfUrl': pdfUrl ?? '',
//       'importedAt': FieldValue.serverTimestamp(),
//     }, SetOptions(merge: true));

//     final batch = _db.batch();
//     for (final s in subjects) {
//       final subRef = semRef.collection('subjects').doc(s['subjectCode']);
//       batch.set(subRef, {
//         'subjectCode': s['subjectCode'],
//         'subjectName': s['subjectName'],
//         'credit': s['credit'],
//         'grade': s['grade'],
//         'gradePoint': s['gradePoint'],
//         'isPractical': s['isPractical'] ?? false,
//       });
//     }
//     await batch.commit();
//   }

//   Future<void> _saveEmptySemesterResult({
//     required String registerNumber,
//     required int semester,
//     String? pdfUrl,
//   }) async {
//     final semId = 'sem$semester';
//     final semRef = _db
//         .collection('students')
//         .doc(registerNumber)
//         .collection('semesters')
//         .doc(semId);

//     await semRef.set({
//       'semesterNumber': semester,
//       'semesterId': semId,
//       'semesterGPA': 0.0,
//       'arrears': 0,
//       'resultStatus': 'No Result',
//       'pdfUrl': pdfUrl ?? '',
//       'importedAt': FieldValue.serverTimestamp(),
//     }, SetOptions(merge: true));
//     // subjects sub-collection intentionally left empty
//   }

//   Future<void> _updateCumulativeCGPA(String registerNumber) async {
//     try {
//       final semsSnap = await _db
//           .collection('students')
//           .doc(registerNumber)
//           .collection('semesters')
//           .get();

//       double tw = 0, tc = 0;
//       for (final semDoc in semsSnap.docs) {
//         final subSnap = await semDoc.reference.collection('subjects').get();
//         for (final sub in subSnap.docs) {
//           if (sub.data()['isPractical'] == true) continue;
//           final credit = (sub.data()['credit'] as num).toDouble();
//           final gp = (sub.data()['gradePoint'] as num).toDouble();
//           tw += credit * gp;
//           tc += credit;
//         }
//       }

//       final cgpa = tc > 0 ? double.parse((tw / tc).toStringAsFixed(2)) : 0.0;
//       final writeBatch = _db.batch();
//       for (final semDoc in semsSnap.docs) {
//         writeBatch.update(semDoc.reference, {'cumulativeCGPA': cgpa});
//       }
//       await writeBatch.commit();
//     } catch (_) {}
//   }

//   Future<void> updateSemesterRankings(int semester) async {
//     try {
//       final semId = 'sem$semester';
//       final semsSnap = await _db
//           .collectionGroup('semesters')
//           .where('semesterId', isEqualTo: semId)
//           .get();

//       final Map<String, List<Map<String, dynamic>>> byDept = {};
//       for (final doc in semsSnap.docs) {
//         // Skip no-result students from ranking
//         final status = (doc.data()['resultStatus'] as String?) ?? 'Available';
//         if (status == 'No Result') continue;

//         final regNo = doc.reference.parent.parent!.id;
//         final gpa = (doc.data()['semesterGPA'] as num?)?.toDouble() ?? 0.0;
//         final studentDoc = await _db.collection('students').doc(regNo).get();
//         final dept = (studentDoc.data()?['department'] as String?) ?? 'UNKNOWN';
//         byDept.putIfAbsent(dept, () => []);
//         byDept[dept]!.add(
//             {'registerNumber': regNo, 'gpa': gpa, 'semRef': doc.reference});
//       }

//       final writeBatch = _db.batch();
//       for (final deptEntry in byDept.entries) {
//         final students = deptEntry.value;
//         students
//             .sort((a, b) => (b['gpa'] as double).compareTo(a['gpa'] as double));
//         final total = students.length;
//         int rank = 1;
//         double? prevGpa;
//         for (int i = 0; i < students.length; i++) {
//           final gpa = students[i]['gpa'] as double;
//           if (prevGpa != null && gpa != prevGpa) rank = i + 1;
//           prevGpa = gpa;
//           writeBatch.update(students[i]['semRef'] as DocumentReference,
//               {'rank': rank, 'totalStudents': total});
//         }
//       }
//       await writeBatch.commit();
//     } catch (_) {}
//   }

//   // ══════════════════════════════════════════════════════════════
//   //  READ METHODS (unchanged)
//   // ══════════════════════════════════════════════════════════════

//   Future<List<Map<String, dynamic>>> fetchAllResults(
//       String registerNumber) async {
//     final results = <Map<String, dynamic>>[];
//     try {
//       final semsSnap = await _db
//           .collection('students')
//           .doc(registerNumber)
//           .collection('semesters')
//           .orderBy('semesterNumber')
//           .get();

//       for (final semDoc in semsSnap.docs) {
//         final semData = semDoc.data();
//         final semNum = (semData['semesterNumber'] as num?)?.toInt() ?? 0;
//         final subSnap = await semDoc.reference.collection('subjects').get();
//         for (final sub in subSnap.docs) {
//           results.add({
//             ...sub.data(),
//             'credits': sub.data()['credit'],
//             'semester': semNum,
//             'semesterGPA': semData['semesterGPA'] ?? 0.0,
//             'cumulativeCGPA': semData['cumulativeCGPA'] ?? 0.0,
//             'rank': semData['rank'] ?? 0,
//             'totalStudents': semData['totalStudents'] ?? 0,
//             'resultStatus': semData['resultStatus'] ?? 'Available',
//           });
//         }
//       }
//     } catch (_) {}
//     return results;
//   }

//   Future<Map<String, dynamic>> fetchSemesterData(
//       String registerNumber, int semester) async {
//     final semId = 'sem$semester';
//     final semRef = _db
//         .collection('students')
//         .doc(registerNumber)
//         .collection('semesters')
//         .doc(semId);

//     final semDoc = await semRef.get();
//     if (!semDoc.exists) {
//       return {
//         'subjects': <Map<String, dynamic>>[],
//         'semesterGPA': 0.0,
//         'rank': 0,
//         'cumulativeCGPA': 0.0,
//         'arrears': 0,
//         'resultStatus': 'Not Imported',
//       };
//     }

//     final semData = semDoc.data()!;
//     final subSnap = await semRef.collection('subjects').get();
//     final subjects = subSnap.docs.map((d) {
//       return {
//         ...d.data(),
//         'credits': d.data()['credit'],
//         'semester': semester,
//       };
//     }).toList();

//     return {...semData, 'subjects': subjects};
//   }

//   Future<Map<String, dynamic>?> fetchStudentProfile(
//       String registerNumber) async {
//     final doc = await _db.collection('students').doc(registerNumber).get();
//     return doc.exists ? doc.data() : null;
//   }

//   Future<List<Map<String, dynamic>>> fetchTopRankers({
//     required String department,
//     required int semester,
//     int topN = 10,
//   }) async {
//     final semId = 'sem$semester';
//     final studentsSnap = await _db
//         .collection('students')
//         .where('department', isEqualTo: department)
//         .get();

//     final rankers = <Map<String, dynamic>>[];
//     for (final studentDoc in studentsSnap.docs) {
//       final semDoc =
//           await studentDoc.reference.collection('semesters').doc(semId).get();
//       if (!semDoc.exists) continue;
//       final semData = semDoc.data()!;
//       // Skip no-result students from leaderboard
//       if ((semData['resultStatus'] as String?) == 'No Result') continue;
//       rankers.add({
//         'registerNumber': studentDoc.id,
//         'name': studentDoc.data()['name'] ?? '',
//         'department': department,
//         'semesterGPA': semData['semesterGPA'] ?? 0.0,
//         'cumulativeCGPA': semData['cumulativeCGPA'] ?? 0.0,
//         'rank': semData['rank'] ?? 0,
//         'arrears': semData['arrears'] ?? 0,
//       });
//     }
//     rankers.sort((a, b) => (a['rank'] as int).compareTo(b['rank'] as int));
//     return rankers.take(topN).toList();
//   }

//   Future<Map<String, dynamic>> fetchDepartmentAnalytics({
//     required String department,
//     required int semester,
//   }) async {
//     final semId = 'sem$semester';
//     final studentsSnap = await _db
//         .collection('students')
//         .where('department', isEqualTo: department)
//         .get();

//     double totalGpa = 0;
//     int totalArrears = 0;
//     int count = 0;

//     for (final studentDoc in studentsSnap.docs) {
//       final semDoc =
//           await studentDoc.reference.collection('semesters').doc(semId).get();
//       if (!semDoc.exists) continue;
//       final data = semDoc.data()!;
//       // Exclude no-result students from GPA average
//       if ((data['resultStatus'] as String?) == 'No Result') continue;
//       totalGpa += (data['semesterGPA'] as num?)?.toDouble() ?? 0.0;
//       totalArrears += (data['arrears'] as num?)?.toInt() ?? 0;
//       count++;
//     }

//     return {
//       'department': department,
//       'semester': semester,
//       'totalStudents': count,
//       'classAverageGpa':
//           count > 0 ? double.parse((totalGpa / count).toStringAsFixed(2)) : 0.0,
//       'totalArrears': totalArrears,
//     };
//   }

//   // ── Helpers ─────────────────────────────────────────────────────

//   Future<bool> _ensureStudentExists(
//     String registerNumber,
//     String name,
//     String department,
//     String batch,
//   ) async {
//     final ref = _db.collection('students').doc(registerNumber);
//     final snap = await ref.get();
//     if (!snap.exists) {
//       await ref.set({
//         'registerNumber': registerNumber,
//         'regNo': registerNumber,
//         'name': name.isEmpty ? registerNumber : name,
//         'department': department,
//         'batch': batch,
//         'createdAt': FieldValue.serverTimestamp(),
//         'autoCreated': true,
//         'createdFrom': 'Result PDF Import',
//       });
//       return true;
//     } else {
//       final existing = snap.data() ?? {};
//       final updates = <String, dynamic>{};
//       if ((existing['name'] ?? '').toString().isEmpty && name.isNotEmpty) {
//         updates['name'] = name;
//       }
//       if ((existing['department'] ?? '').toString().isEmpty) {
//         updates['department'] = department;
//       }
//       if ((existing['batch'] ?? '').toString().isEmpty) {
//         updates['batch'] = batch;
//       }
//       if (updates.isNotEmpty) await ref.update(updates);
//       return false;
//     }
//   }

//   Future<Map<String, Map<String, dynamic>>> _fetchSubjectMaster(
//       int semester) async {
//     final map = <String, Map<String, dynamic>>{};
//     try {
//       final snap = await _db
//           .collection('subject_setup')
//           .where('semester', isEqualTo: semester)
//           .get();
//       for (final doc in snap.docs) {
//         final code = (doc.data()['subjectCode'] ?? '').toString().toUpperCase();
//         if (code.isNotEmpty) map[code] = doc.data();
//       }
//     } catch (_) {}
//     return map;
//   }

//   double _calcGPA(List<Map<String, dynamic>> subjects) {
//     double tw = 0, tc = 0;
//     for (final s in subjects) {
//       final c = (s['credit'] as num).toDouble();
//       final gp = (s['gradePoint'] as num).toDouble();
//       tw += c * gp;
//       tc += c;
//     }
//     return tc == 0 ? 0.0 : double.parse((tw / tc).toStringAsFixed(2));
//   }

//   bool _isHeader(String line) {
//     final l = line.toLowerCase();
//     const skip = [
//       'register',
//       'reg no',
//       'reg.no',
//       'subject',
//       'grade',
//       'result',
//       'semester',
//       'sl.no',
//       'sl no',
//       's.no',
//       'name',
//       'total',
//       'course',
//       'marks',
//       'credit',
//       'gpa',
//       'cgpa',
//       'university',
//       'college',
//       'examination',
//       'controller',
//       'puducherry',
//       'provisional',
//       'degree',
//       'branch',
//     ];
//     return skip.any((h) => l.startsWith(h));
//   }

//   String _toTitleCase(String s) {
//     return s
//         .toLowerCase()
//         .split(' ')
//         .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
//         .join(' ');
//   }

//   // ── Temporary debug log — remove after testing ─────────────────
//   void _debugLog(String regNo, String name, int subjectCount, bool hasResult) {
//     print('═══════════════════════════════════════');
//     print('Student Detected : $regNo');
//     print('Name             : ${name.isEmpty ? "(not found)" : name}');
//     print('Subjects Found   : $subjectCount');
//     print('Status           : ${hasResult ? "Available" : "No Result"}');
//     print('Student Saved    : YES ✔');
//     print('═══════════════════════════════════════');
//   }
// }

// // ── Import result summary ─────────────────────────────────────────
// class ImportResult {
//   final bool success;
//   final String message;
//   final int studentsProcessed;
//   final int newStudentsCreated;
//   final int updatedStudents;
//   final int noResultStudents;
//   final String? pdfUrl;

//   const ImportResult({
//     required this.success,
//     required this.message,
//     required this.studentsProcessed,
//     this.newStudentsCreated = 0,
//     this.updatedStudents = 0,
//     this.noResultStudents = 0,
//     this.pdfUrl,
//   });
// }

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../utils/gpa_calculator.dart';
import '../utils/department_resolver.dart';
import 'package:flutter/foundation.dart';

/// Firestore structure:
///   students/{registerNumber}
///     name, registerNumber, regNo, department, batch
///     semesters/{semId}
///       semesterGPA, cumulativeCGPA, rank, totalStudents, arrears
///       resultStatus   ← "Available" | "No Result"
///       subjects/{subjectCode}
///         subjectCode, subjectName, credit, grade, gradePoint, isPractical
class ResultStorageService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ── Upload PDF ─────────────────────────────────────────────────
  Future<String?> uploadPdf(String localPath, int semester) async {
    try {
      final ref = _storage.ref(
          'results/semester_$semester/result_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await ref.putFile(File(localPath));
      return await ref.getDownloadURL();
    } catch (_) {
      return null;
    }
  }

  // ══════════════════════════════════════════════════════════════
  //  PARSER — block-based: one block per register number found,
  //  even when the student has NO subjects ("-----")
  // ══════════════════════════════════════════════════════════════

  /// Each returned map:
  /// {
  ///   'registerNumber': '2303107031',
  ///   'name':           'Sarshini P',
  ///   'subjects': [     // empty list when no result
  ///     {'code': 'MAA101', 'grade': 'A', 'isPractical': false}, ...
  ///   ],
  ///   'hasResult': true | false,
  /// }
  List<Map<String, dynamic>> parsePdfText(String rawText) {
    // ── STEP 1: Extract FULL PDF text — normalise only, do NOT split lines ──
    final normalised = rawText.replaceAll('\r', '').replaceAll('\t', ' ');

    // ── STEP 2: Find every 10-digit register number in the full text ────────
    // Text between one register number and the next = one student block.
    final regNoPattern = RegExp(r'\b(\d{10})\b');
    final regMatches = regNoPattern.allMatches(normalised).toList();

    if (regMatches.isEmpty) return [];

    final results = <Map<String, dynamic>>[];

    for (int i = 0; i < regMatches.length; i++) {
      final regMatch = regMatches[i];
      final regNo = regMatch.group(1)!;

      // Student block: from this reg-number position to the next one (or EOF)
      final blockStart = regMatch.start;
      final blockEnd = (i + 1 < regMatches.length)
          ? regMatches[i + 1].start
          : normalised.length;

      final studentBlock = normalised.substring(blockStart, blockEnd);

      // ── Extract name from text immediately after the register number ──────
      final afterReg = normalised.substring(regMatch.end, blockEnd).trim();
      final studentName = _extractName(afterReg);

      // ── STEP 3: Extract ALL subjects using allMatches (NEVER firstMatch) ──
      //   Pattern: "MAA101 - B" or "MAA101 -B" or "MAA101- B"
      //   Grade set: S A B C D E F P  (Z is mapped to F below)
      final subjectPattern = RegExp(r'([A-Z]{3}\d{3})\s*-\s*([SABCDEFP])');

      final matches =
          subjectPattern.allMatches(studentBlock.toUpperCase()).toList();

      // ── STEP 4: Build subjects list — NEVER overwrite previous subjects ───
      // Fresh map per student; subjects must NOT carry over between students.
      final pairs = <Map<String, String>>[];
      final seen = <String>{};
      for (final m in matches) {
        final code = m.group(1)!;
        final grade = m.group(2)!;
        if (!seen.contains(code)) {
          // deduplicate
          seen.add(code);
          pairs.add({'code': code, 'grade': grade});
        }
      }

      final bool hasResult = pairs.isNotEmpty;

      // ── STEP 7: Debug log (temporary — remove after testing) ─────────────
      debugPrint('Student: $regNo');
      debugPrint('Subjects Found: ${pairs.length}');
      _debugLog(regNo, studentName, pairs.length, hasResult);

      results.add({
        'registerNumber': regNo,
        'name': studentName,
        'subjects': pairs,
        'hasResult': hasResult,
      });
    }

    return results;
  }

  // ── Extract name from text that follows the register number ────────────────
  // Runs BEFORE subject extraction so subject text is still intact in the block;
  // we only look at the first few words here.
  String _extractName(String afterReg) {
    // Strategy 1: leading CAPS words before first subject-code token
    final nameMatch = RegExp(r'^([A-Z][A-Z\s\.]+?)\s+(?=[A-Z]{2,5}\d{3})',
            caseSensitive: true)
        .firstMatch(afterReg);
    if (nameMatch != null) {
      final raw = nameMatch.group(1)!.trim().toLowerCase();
      return raw
          .split(' ')
          .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
          .join(' ');
    }

    // Strategy 2: strip subject codes, grades, dashes, digits — keep letters
    final stripped = afterReg
        .replaceAll(RegExp(r'[A-Z]{2,5}\d{3,4}\s*-\s*[SABCDEFPZ]'), '')
        .replaceAll(RegExp(r'[-]+'), '')
        .replaceAll(RegExp(r'\d+'), '')
        .replaceAll(RegExp(r'\s{2,}'), ' ')
        .trim();

    final words = stripped.split(' ').where((w) => w.isNotEmpty).toList();
    final nameWords = <String>[];
    for (final w in words) {
      if (RegExp(r'^[A-Za-z\.]+$').hasMatch(w)) {
        nameWords.add(w);
        if (nameWords.length == 5) break;
      } else {
        break;
      }
    }
    if (nameWords.isEmpty) return '';
    final raw = nameWords.join(' ').toLowerCase();
    return raw
        .split(' ')
        .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  // ══════════════════════════════════════════════════════════════
  //  FULL IMPORT PIPELINE
  // ══════════════════════════════════════════════════════════════

  Future<ImportResult> importResultsFromPdf({
    required String rawText,
    required String localPdfPath,
    required int semester,
  }) async {
    final pdfUrl = await uploadPdf(localPdfPath, semester);

    final parsedRows = parsePdfText(rawText);

    if (parsedRows.isEmpty) {
      return ImportResult(
        success: false,
        message: 'No student records found in PDF.\n\n'
            'Expected format:\n'
            '2303107014  STUDENT NAME  MAA101 - D  PHA101 - S\n\n'
            'The PDF text extraction may have failed for this file.',
        studentsProcessed: 0,
        pdfUrl: pdfUrl,
      );
    }

    final subjectMaster = await _fetchSubjectMaster(semester);
    int processed = 0, created = 0, updated = 0, noResultCount = 0;

    for (final row in parsedRows) {
      final regNo = row['registerNumber'] as String;
      final studentName = (row['name'] as String?) ?? '';
      final pairs = row['subjects'] as List<Map<String, String>>;
      final hasResult = row['hasResult'] as bool;

      final department = DepartmentResolver.resolveDepartment(regNo);
      final batch = DepartmentResolver.resolveBatch(regNo);

      // ── Always ensure student document exists ─────────────────
      final wasCreated =
          await _ensureStudentExists(regNo, studentName, department, batch);
      wasCreated ? created++ : updated++;

      if (!hasResult) {
        // ── CASE B: No subjects — store empty semester record ────
        noResultCount++;
        await _saveEmptySemesterResult(
          registerNumber: regNo,
          semester: semester,
          pdfUrl: pdfUrl,
        );
      } else {
        // ── CASE A: Has subjects — build subjects list then save ONCE ──
        // STEP 4: Create a fresh subjectsMap for EACH student.
        // STEP 5: Save to Firestore ONLY ONCE after all subjects extracted.
        final subjects = <Map<String, dynamic>>[];

        for (final pair in pairs) {
          final code = pair['code']!;
          final grade = pair['grade']!;
          final isPractical = grade == 'P';
          final master = subjectMaster[code];
          // Map 'Z' grade to 'F' for GPA calculation
          final effectiveGrade = grade == 'Z' ? 'F' : grade;
          final gradePoint = isPractical
              ? 0.0
              : GpaCalculator.gradeToPoint(effectiveGrade).toDouble();

          subjects.add({
            'subjectCode': code,
            'subjectName': master?['subjectName'] ?? code,
            'credit': isPractical
                ? 0.0
                : (master?['credits'] as num?)?.toDouble() ?? 3.0,
            'grade': grade,
            'gradePoint': gradePoint,
            'isPractical': isPractical,
          });
        }

        // Single Firestore write per student (STEP 5)
        await _saveSemesterResults(
          registerNumber: regNo,
          semester: semester,
          subjects: subjects,
          pdfUrl: pdfUrl,
        );
      }

      processed++;
    }

    // Rankings & CGPA
    await updateSemesterRankings(semester);
    for (final row in parsedRows) {
      await _updateCumulativeCGPA(row['registerNumber'] as String);
    }

    return ImportResult(
      success: true,
      message: 'Imported $processed students '
          '($created new, $updated updated) — Semester $semester.\n'
          '$noResultCount student(s) had no result ("-----").',
      studentsProcessed: processed,
      newStudentsCreated: created,
      updatedStudents: updated,
      noResultStudents: noResultCount,
      pdfUrl: pdfUrl,
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  FIRESTORE WRITES
  // ══════════════════════════════════════════════════════════════

  Future<void> _saveSemesterResults({
    required String registerNumber,
    required int semester,
    required List<Map<String, dynamic>> subjects,
    String? pdfUrl,
  }) async {
    final semId = 'sem$semester';
    final semRef = _db
        .collection('students')
        .doc(registerNumber)
        .collection('semesters')
        .doc(semId);

    final gpaSubjects =
        subjects.where((s) => !(s['isPractical'] as bool? ?? false)).toList();
    final gpa = _calcGPA(gpaSubjects);
    final arrears =
        gpaSubjects.where((s) => s['grade'] == 'F' || s['grade'] == 'Z').length;

    // Semester document
    await semRef.set({
      'semesterNumber': semester,
      'semesterId': semId,
      'semesterGPA': gpa,
      'arrears': arrears,
      'resultStatus': 'Available',
      'pdfUrl': pdfUrl ?? '',
      'importedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // All subjects in a single batch commit (STEP 5 — write once)
    // Delete ALL existing subject documents first (removes stale/wrong data)
    final existingSubjects = await semRef.collection('subjects').get();
    final deleteBatch = _db.batch();
    for (final doc in existingSubjects.docs) {
      deleteBatch.delete(doc.reference);
    }
    await deleteBatch.commit();

    // Write all fresh subjects in a single batch (STEP 5 — write once)
    final batch = _db.batch();
    for (final s in subjects) {
      final subRef = semRef.collection('subjects').doc(s['subjectCode']);
      batch.set(subRef, {
        'subjectCode': s['subjectCode'],
        'subjectName': s['subjectName'],
        'credit': s['credit'],
        'grade': s['grade'],
        'gradePoint': s['gradePoint'],
        'isPractical': s['isPractical'] ?? false,
      });
    }
    await batch.commit();
  }

  Future<void> _saveEmptySemesterResult({
    required String registerNumber,
    required int semester,
    String? pdfUrl,
  }) async {
    final semId = 'sem$semester';
    final semRef = _db
        .collection('students')
        .doc(registerNumber)
        .collection('semesters')
        .doc(semId);

    await semRef.set({
      'semesterNumber': semester,
      'semesterId': semId,
      'semesterGPA': 0.0,
      'arrears': 0,
      'resultStatus': 'No Result',
      'pdfUrl': pdfUrl ?? '',
      'importedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    // subjects sub-collection intentionally left empty
  }

  Future<void> _updateCumulativeCGPA(String registerNumber) async {
    try {
      final semsSnap = await _db
          .collection('students')
          .doc(registerNumber)
          .collection('semesters')
          .get();

      double tw = 0, tc = 0;
      for (final semDoc in semsSnap.docs) {
        final subSnap = await semDoc.reference.collection('subjects').get();
        for (final sub in subSnap.docs) {
          if (sub.data()['isPractical'] == true) continue;
          final credit = (sub.data()['credit'] as num).toDouble();
          final gp = (sub.data()['gradePoint'] as num).toDouble();
          tw += credit * gp;
          tc += credit;
        }
      }

      final cgpa = tc > 0 ? double.parse((tw / tc).toStringAsFixed(2)) : 0.0;
      final writeBatch = _db.batch();
      for (final semDoc in semsSnap.docs) {
        writeBatch.update(semDoc.reference, {'cumulativeCGPA': cgpa});
      }
      await writeBatch.commit();
    } catch (_) {}
  }

  Future<void> updateSemesterRankings(int semester) async {
    try {
      final semId = 'sem$semester';
      final semsSnap = await _db
          .collectionGroup('semesters')
          .where('semesterId', isEqualTo: semId)
          .get();

      final Map<String, List<Map<String, dynamic>>> byDept = {};
      for (final doc in semsSnap.docs) {
        // Skip no-result students from ranking
        final status = (doc.data()['resultStatus'] as String?) ?? 'Available';
        if (status == 'No Result') continue;

        final regNo = doc.reference.parent.parent!.id;
        final gpa = (doc.data()['semesterGPA'] as num?)?.toDouble() ?? 0.0;
        final studentDoc = await _db.collection('students').doc(regNo).get();
        final dept = (studentDoc.data()?['department'] as String?) ?? 'UNKNOWN';
        byDept.putIfAbsent(dept, () => []);
        byDept[dept]!.add(
            {'registerNumber': regNo, 'gpa': gpa, 'semRef': doc.reference});
      }

      final writeBatch = _db.batch();
      for (final deptEntry in byDept.entries) {
        final students = deptEntry.value;
        students
            .sort((a, b) => (b['gpa'] as double).compareTo(a['gpa'] as double));
        final total = students.length;
        int rank = 1;
        double? prevGpa;
        for (int i = 0; i < students.length; i++) {
          final gpa = students[i]['gpa'] as double;
          if (prevGpa != null && gpa != prevGpa) rank = i + 1;
          prevGpa = gpa;
          writeBatch.update(students[i]['semRef'] as DocumentReference,
              {'rank': rank, 'totalStudents': total});
        }
      }
      await writeBatch.commit();
    } catch (_) {}
  }

  // ══════════════════════════════════════════════════════════════
  //  READ METHODS (unchanged)
  // ══════════════════════════════════════════════════════════════

  Future<List<Map<String, dynamic>>> fetchAllResults(
      String registerNumber) async {
    final results = <Map<String, dynamic>>[];
    try {
      final semsSnap = await _db
          .collection('students')
          .doc(registerNumber)
          .collection('semesters')
          .orderBy('semesterNumber')
          .get();

      for (final semDoc in semsSnap.docs) {
        final semData = semDoc.data();
        final semNum = (semData['semesterNumber'] as num?)?.toInt() ?? 0;
        final subSnap = await semDoc.reference.collection('subjects').get();
        for (final sub in subSnap.docs) {
          results.add({
            ...sub.data(),
            'credits': sub.data()['credit'],
            'semester': semNum,
            'semesterGPA': semData['semesterGPA'] ?? 0.0,
            'cumulativeCGPA': semData['cumulativeCGPA'] ?? 0.0,
            'rank': semData['rank'] ?? 0,
            'totalStudents': semData['totalStudents'] ?? 0,
            'resultStatus': semData['resultStatus'] ?? 'Available',
          });
        }
      }
    } catch (_) {}
    return results;
  }

  Future<Map<String, dynamic>> fetchSemesterData(
      String registerNumber, int semester) async {
    final semId = 'sem$semester';
    final semRef = _db
        .collection('students')
        .doc(registerNumber)
        .collection('semesters')
        .doc(semId);

    final semDoc = await semRef.get();
    if (!semDoc.exists) {
      return {
        'subjects': <Map<String, dynamic>>[],
        'semesterGPA': 0.0,
        'rank': 0,
        'cumulativeCGPA': 0.0,
        'arrears': 0,
        'resultStatus': 'Not Imported',
      };
    }

    final semData = semDoc.data()!;
    final subSnap = await semRef.collection('subjects').get();
    final subjects = subSnap.docs.map((d) {
      return {
        ...d.data(),
        'credits': d.data()['credit'],
        'semester': semester,
      };
    }).toList();

    return {...semData, 'subjects': subjects};
  }

  Future<Map<String, dynamic>?> fetchStudentProfile(
      String registerNumber) async {
    final doc = await _db.collection('students').doc(registerNumber).get();
    return doc.exists ? doc.data() : null;
  }

  Future<List<Map<String, dynamic>>> fetchTopRankers({
    required String department,
    required int semester,
    int topN = 10,
  }) async {
    final semId = 'sem$semester';
    final studentsSnap = await _db
        .collection('students')
        .where('department', isEqualTo: department)
        .get();

    final rankers = <Map<String, dynamic>>[];
    for (final studentDoc in studentsSnap.docs) {
      final semDoc =
          await studentDoc.reference.collection('semesters').doc(semId).get();
      if (!semDoc.exists) continue;
      final semData = semDoc.data()!;
      // Skip no-result students from leaderboard
      if ((semData['resultStatus'] as String?) == 'No Result') continue;
      rankers.add({
        'registerNumber': studentDoc.id,
        'name': studentDoc.data()['name'] ?? '',
        'department': department,
        'semesterGPA': semData['semesterGPA'] ?? 0.0,
        'cumulativeCGPA': semData['cumulativeCGPA'] ?? 0.0,
        'rank': semData['rank'] ?? 0,
        'arrears': semData['arrears'] ?? 0,
      });
    }
    rankers.sort((a, b) => (a['rank'] as int).compareTo(b['rank'] as int));
    return rankers.take(topN).toList();
  }

  Future<Map<String, dynamic>> fetchDepartmentAnalytics({
    required String department,
    required int semester,
  }) async {
    final semId = 'sem$semester';
    final studentsSnap = await _db
        .collection('students')
        .where('department', isEqualTo: department)
        .get();

    double totalGpa = 0;
    int totalArrears = 0;
    int count = 0;

    for (final studentDoc in studentsSnap.docs) {
      final semDoc =
          await studentDoc.reference.collection('semesters').doc(semId).get();
      if (!semDoc.exists) continue;
      final data = semDoc.data()!;
      // Exclude no-result students from GPA average
      if ((data['resultStatus'] as String?) == 'No Result') continue;
      totalGpa += (data['semesterGPA'] as num?)?.toDouble() ?? 0.0;
      totalArrears += (data['arrears'] as num?)?.toInt() ?? 0;
      count++;
    }

    return {
      'department': department,
      'semester': semester,
      'totalStudents': count,
      'classAverageGpa':
          count > 0 ? double.parse((totalGpa / count).toStringAsFixed(2)) : 0.0,
      'totalArrears': totalArrears,
    };
  }

  // ── Helpers ─────────────────────────────────────────────────────

  Future<bool> _ensureStudentExists(
    String registerNumber,
    String name,
    String department,
    String batch,
  ) async {
    final ref = _db.collection('students').doc(registerNumber);
    final snap = await ref.get();
    if (!snap.exists) {
      await ref.set({
        'registerNumber': registerNumber,
        'regNo': registerNumber,
        'name': name.isEmpty ? registerNumber : name,
        'department': department,
        'batch': batch,
        'createdAt': FieldValue.serverTimestamp(),
        'autoCreated': true,
        'createdFrom': 'Result PDF Import',
      });
      return true;
    } else {
      final existing = snap.data() ?? {};
      final updates = <String, dynamic>{};
      if ((existing['name'] ?? '').toString().isEmpty && name.isNotEmpty) {
        updates['name'] = name;
      }
      if ((existing['department'] ?? '').toString().isEmpty) {
        updates['department'] = department;
      }
      if ((existing['batch'] ?? '').toString().isEmpty) {
        updates['batch'] = batch;
      }
      if (updates.isNotEmpty) await ref.update(updates);
      return false;
    }
  }

  Future<Map<String, Map<String, dynamic>>> _fetchSubjectMaster(
      int semester) async {
    final map = <String, Map<String, dynamic>>{};
    try {
      final snap = await _db
          .collection('subject_setup')
          .where('semester', isEqualTo: semester)
          .get();
      for (final doc in snap.docs) {
        final code = (doc.data()['subjectCode'] ?? '').toString().toUpperCase();
        if (code.isNotEmpty) map[code] = doc.data();
      }
    } catch (_) {}
    return map;
  }

  double _calcGPA(List<Map<String, dynamic>> subjects) {
    double tw = 0, tc = 0;
    for (final s in subjects) {
      final c = (s['credit'] as num).toDouble();
      final gp = (s['gradePoint'] as num).toDouble();
      tw += c * gp;
      tc += c;
    }
    return tc == 0 ? 0.0 : double.parse((tw / tc).toStringAsFixed(2));
  }

  // ── Temporary debug log — remove after testing ─────────────────
  void _debugLog(String regNo, String name, int subjectCount, bool hasResult) {
    debugPrint('═══════════════════════════════════════');
    debugPrint('Student Detected : $regNo');
    debugPrint('Name             : ${name.isEmpty ? "(not found)" : name}');
    debugPrint('Subjects Found   : $subjectCount');
    debugPrint('Status           : ${hasResult ? "Available" : "No Result"}');
    debugPrint('Student Saved    : YES ✔');
    debugPrint('═══════════════════════════════════════');
  }
}

// ── Import result summary ─────────────────────────────────────────
class ImportResult {
  final bool success;
  final String message;
  final int studentsProcessed;
  final int newStudentsCreated;
  final int updatedStudents;
  final int noResultStudents;
  final String? pdfUrl;

  const ImportResult({
    required this.success,
    required this.message,
    required this.studentsProcessed,
    this.newStudentsCreated = 0,
    this.updatedStudents = 0,
    this.noResultStudents = 0,
    this.pdfUrl,
  });
}
