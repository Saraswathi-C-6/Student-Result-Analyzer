// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../utils/gpa_calculator.dart';

// class StudentResultService {
//   final FirebaseFirestore _db = FirebaseFirestore.instance;

//   // ── Fetch all results for a student ─────────────────────────────
//   Future<List<Map<String, dynamic>>> fetchResults(String studentId) async {
//     final snap = await _db
//         .collection('results')
//         .where('studentId', isEqualTo: studentId)
//         .get();
//     return snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
//   }

//   // ── Fetch results for a specific semester ────────────────────────
//   Future<List<Map<String, dynamic>>> fetchSemesterResults(
//       String studentId, int semester) async {
//     final snap = await _db
//         .collection('results')
//         .where('studentId', isEqualTo: studentId)
//         .where('semester', isEqualTo: semester)
//         .get();
//     return snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
//   }

//   // ── Calculate GPA for a semester ─────────────────────────────────
//   double calculateSemesterGPA(List<Map<String, dynamic>> results) {
//     return GpaCalculator.calculateGPA(results);
//   }

//   // ── Calculate CGPA across all semesters ──────────────────────────
//   double calculateCGPA(List<Map<String, dynamic>> allResults) {
//     return GpaCalculator.calculateCGPA(allResults);
//   }

//   // ── Count total arrears (failed subjects) ────────────────────────
//   int countArrears(List<Map<String, dynamic>> allResults) {
//     return allResults
//         .where((r) => !GpaCalculator.isPassed(r['grade'] ?? 'F'))
//         .length;
//   }

//   // ── Count arrears per semester ────────────────────────────────────
//   int countSemesterArrears(List<Map<String, dynamic>> semResults) {
//     return semResults
//         .where((r) => !GpaCalculator.isPassed(r['grade'] ?? 'F'))
//         .length;
//   }

//   // ── Get completed semesters (semesters that have results) ─────────
//   List<int> getCompletedSemesters(List<Map<String, dynamic>> allResults) {
//     final sems = allResults.map((r) => r['semester'] as int).toSet().toList();
//     sems.sort();
//     return sems;
//   }

//   // ── Calculate rank for a student in a semester ───────────────────
//   Future<Map<String, dynamic>> calculateRank(
//       String studentId, int semester) async {
//     // Get all results for this semester across all students
//     final snap = await _db
//         .collection('results')
//         .where('semester', isEqualTo: semester)
//         .get();

//     // Group results by studentId
//     final Map<String, List<Map<String, dynamic>>> studentResults = {};
//     for (final doc in snap.docs) {
//       final data = doc.data();
//       final sId = data['studentId'] as String;
//       studentResults.putIfAbsent(sId, () => []);
//       studentResults[sId]!.add(data);
//     }

//     // Calculate GPA for each student
//     final List<Map<String, dynamic>> rankings = [];
//     studentResults.forEach((sId, results) {
//       final gpa = GpaCalculator.calculateGPA(results);
//       rankings.add({'studentId': sId, 'gpa': gpa});
//     });

//     // Sort by GPA descending
//     rankings.sort((a, b) => (b['gpa'] as double).compareTo(a['gpa'] as double));

//     // Find this student's rank
//     final rank = rankings.indexWhere((r) => r['studentId'] == studentId) + 1;
//     final totalStudents = rankings.length;
//     final topperGpa =
//         rankings.isNotEmpty ? (rankings.first['gpa'] as double) : 0.0;
//     final studentGpa = studentResults.containsKey(studentId)
//         ? GpaCalculator.calculateGPA(studentResults[studentId]!)
//         : 0.0;

//     return {
//       'rank': rank,
//       'totalStudents': totalStudents,
//       'topperGpa': topperGpa,
//       'studentGpa': studentGpa,
//       'gapFromTopper': topperGpa - studentGpa,
//       'rankings': rankings,
//     };
//   }

//   // ── Calculate overall CGPA rank ───────────────────────────────────
//   Future<Map<String, dynamic>> calculateOverallRank(String studentId) async {
//     final snap = await _db.collection('results').get();

//     final Map<String, List<Map<String, dynamic>>> studentResults = {};
//     for (final doc in snap.docs) {
//       final data = doc.data();
//       final sId = data['studentId'] as String;
//       studentResults.putIfAbsent(sId, () => []);
//       studentResults[sId]!.add(data);
//     }

//     final List<Map<String, dynamic>> rankings = [];
//     studentResults.forEach((sId, results) {
//       final cgpa = GpaCalculator.calculateCGPA(results);
//       rankings.add({'studentId': sId, 'cgpa': cgpa});
//     });

//     rankings
//         .sort((a, b) => (b['cgpa'] as double).compareTo(a['cgpa'] as double));

//     final rank = rankings.indexWhere((r) => r['studentId'] == studentId) + 1;
//     final totalStudents = rankings.length;
//     final topperCgpa =
//         rankings.isNotEmpty ? (rankings.first['cgpa'] as double) : 0.0;
//     final studentCgpa = studentResults.containsKey(studentId)
//         ? GpaCalculator.calculateCGPA(studentResults[studentId]!)
//         : 0.0;

//     // Top 5 with student info
//     final top5 = rankings.take(5).toList();
//     final top5WithInfo = <Map<String, dynamic>>[];
//     for (int i = 0; i < top5.length; i++) {
//       final sId = top5[i]['studentId'] as String;
//       String regNo = sId;
//       String name = 'Unknown';
//       try {
//         final sDoc = await _db.collection('students').doc(sId).get();
//         if (sDoc.exists) {
//           regNo = sDoc.data()?['regNo'] ?? sId;
//           name = sDoc.data()?['name'] ?? 'Unknown';
//         }
//       } catch (_) {}
//       top5WithInfo.add({
//         'rank': i + 1,
//         'studentId': sId,
//         'regNo': regNo,
//         'name': name,
//         'cgpa': top5[i]['cgpa'],
//       });
//     }

//     return {
//       'rank': rank,
//       'totalStudents': totalStudents,
//       'topperCgpa': topperCgpa,
//       'studentCgpa': studentCgpa,
//       'gapFromTopper': topperCgpa - studentCgpa,
//       'top5': top5WithInfo,
//     };
//   }
// }

// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../utils/gpa_calculator.dart';
// import 'result_storage_service.dart';

// /// READ-ONLY service for student-facing screens.
// /// Reads from: students/{registerNumber}/semesters/{semId}/subjects/{code}
// /// Falls back to old flat 'results' collection for backwards compatibility.
// class StudentResultService {
//   final FirebaseFirestore _db = FirebaseFirestore.instance;
//   final ResultStorageService _storage = ResultStorageService();

//   // Fetch ALL results for a student (flat list compatible with existing UI)
//   Future<List<Map<String, dynamic>>> fetchResults(String registerNumber) async {
//     final newResults = await _storage.fetchAllResults(registerNumber);
//     if (newResults.isNotEmpty) return newResults;
//     // Fallback to old collection
//     try {
//       final snap = await _db
//           .collection('results')
//           .where('studentId', isEqualTo: registerNumber)
//           .get();
//       return snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
//     } catch (_) {
//       return [];
//     }
//   }

//   // Fetch results for one semester
//   Future<List<Map<String, dynamic>>> fetchSemesterResults(
//       String registerNumber, int semester) async {
//     try {
//       final semData =
//           await _storage.fetchSemesterData(registerNumber, semester);
//       final subjects =
//           (semData['subjects'] as List?)?.cast<Map<String, dynamic>>() ?? [];
//       if (subjects.isNotEmpty) return subjects;
//     } catch (_) {}
//     try {
//       final snap = await _db
//           .collection('results')
//           .where('studentId', isEqualTo: registerNumber)
//           .where('semester', isEqualTo: semester)
//           .get();
//       return snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
//     } catch (_) {
//       return [];
//     }
//   }

//   double calculateSemesterGPA(List<Map<String, dynamic>> results) =>
//       GpaCalculator.calculateGPA(results);
//   double calculateCGPA(List<Map<String, dynamic>> allResults) =>
//       GpaCalculator.calculateCGPA(allResults);

//   int countArrears(List<Map<String, dynamic>> allResults) => allResults
//       .where((r) => !GpaCalculator.isPassed(r['grade'] ?? 'F'))
//       .length;

//   int countSemesterArrears(List<Map<String, dynamic>> semResults) => semResults
//       .where((r) => !GpaCalculator.isPassed(r['grade'] ?? 'F'))
//       .length;

//   List<int> getCompletedSemesters(List<Map<String, dynamic>> allResults) {
//     final sems = allResults
//         .map((r) => r['semester'] as int? ?? 0)
//         .where((s) => s > 0)
//         .toSet()
//         .toList();
//     sems.sort();
//     return sems;
//   }

//   // Overall CGPA rank — reads stored CGPA from Firestore
//   Future<Map<String, dynamic>> calculateOverallRank(
//       String registerNumber) async {
//     try {
//       final allStudentsSnap = await _db.collection('students').get();
//       final List<Map<String, dynamic>> cgpaList = [];
//       for (final studentDoc in allStudentsSnap.docs) {
//         final regNo = studentDoc.id;
//         final semsSnap = await _db
//             .collection('students')
//             .doc(regNo)
//             .collection('semesters')
//             .limit(1)
//             .get();
//         if (semsSnap.docs.isEmpty) continue;
//         final cgpa = (semsSnap.docs.first.data()['cumulativeCGPA'] as num?)
//                 ?.toDouble() ??
//             0.0;
//         if (cgpa > 0) cgpaList.add({'registerNumber': regNo, 'cgpa': cgpa});
//       }
//       cgpaList
//           .sort((a, b) => (b['cgpa'] as double).compareTo(a['cgpa'] as double));
//       final rank =
//           cgpaList.indexWhere((r) => r['registerNumber'] == registerNumber) + 1;
//       final total = cgpaList.length;
//       final topperCgpa =
//           cgpaList.isNotEmpty ? (cgpaList.first['cgpa'] as double) : 0.0;
//       final studentCgpa = cgpaList.firstWhere(
//           (r) => r['registerNumber'] == registerNumber,
//           orElse: () => {'cgpa': 0.0})['cgpa'] as double;
//       final top5 = <Map<String, dynamic>>[];
//       for (int i = 0; i < cgpaList.length && i < 5; i++) {
//         final rn = cgpaList[i]['registerNumber'] as String;
//         String name = rn;
//         try {
//           final doc = await _db.collection('students').doc(rn).get();
//           name = doc.data()?['name'] ?? rn;
//         } catch (_) {}
//         top5.add({
//           'rank': i + 1,
//           'registerNumber': rn,
//           'name': name,
//           'cgpa': cgpaList[i]['cgpa']
//         });
//       }
//       return {
//         'rank': rank,
//         'totalStudents': total,
//         'topperCgpa': topperCgpa,
//         'studentCgpa': studentCgpa,
//         'gapFromTopper': topperCgpa - studentCgpa,
//         'top5': top5
//       };
//     } catch (_) {
//       return {
//         'rank': 0,
//         'totalStudents': 0,
//         'topperCgpa': 0.0,
//         'studentCgpa': 0.0,
//         'gapFromTopper': 0.0,
//         'top5': <Map<String, dynamic>>[]
//       };
//     }
//   }

//   // Semester rank (backwards compat)
//   Future<Map<String, dynamic>> calculateRank(
//       String registerNumber, int semester) async {
//     try {
//       final semData =
//           await _storage.fetchSemesterData(registerNumber, semester);
//       return {
//         'rank': semData['rank'] ?? 0,
//         'totalStudents': semData['totalStudents'] ?? 0,
//         'semesterGPA': semData['semesterGPA'] ?? 0.0
//       };
//     } catch (_) {
//       return {'rank': 0, 'totalStudents': 0, 'semesterGPA': 0.0};
//     }
//   }
// }

// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../utils/gpa_calculator.dart';

// /// READ-ONLY service for student-facing screens.
// /// Reads from flat 'results' collection where studentId = Firestore doc ID.
// class StudentResultService {
//   final FirebaseFirestore _db = FirebaseFirestore.instance;

//   // ── Fetch ALL results for a student ─────────────────────────────
//   Future<List<Map<String, dynamic>>> fetchResults(String studentId) async {
//     try {
//       final snap = await _db
//           .collection('results')
//           .where('studentId', isEqualTo: studentId)
//           .get();
//       return snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
//     } catch (_) {
//       return [];
//     }
//   }

//   // ── Fetch results for one semester ───────────────────────────────
//   Future<List<Map<String, dynamic>>> fetchSemesterResults(
//       String studentId, int semester) async {
//     try {
//       final snap = await _db
//           .collection('results')
//           .where('studentId', isEqualTo: studentId)
//           .where('semester', isEqualTo: semester)
//           .get();
//       return snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
//     } catch (_) {
//       return [];
//     }
//   }

//   // ── GPA calculations ─────────────────────────────────────────────
//   double calculateSemesterGPA(List<Map<String, dynamic>> results) =>
//       GpaCalculator.calculateGPA(results);

//   double calculateCGPA(List<Map<String, dynamic>> allResults) =>
//       GpaCalculator.calculateCGPA(allResults);

//   // ── Arrear counts ────────────────────────────────────────────────
//   int countArrears(List<Map<String, dynamic>> allResults) => allResults
//       .where((r) => !GpaCalculator.isPassed(r['grade'] ?? 'F'))
//       .length;

//   int countSemesterArrears(List<Map<String, dynamic>> semResults) => semResults
//       .where((r) => !GpaCalculator.isPassed(r['grade'] ?? 'F'))
//       .length;

//   // ── Completed semesters ──────────────────────────────────────────
//   List<int> getCompletedSemesters(List<Map<String, dynamic>> allResults) {
//     final sems = allResults
//         .map((r) => r['semester'] as int? ?? 0)
//         .where((s) => s > 0)
//         .toSet()
//         .toList();
//     sems.sort();
//     return sems;
//   }

//   // ── Overall CGPA rank across ALL students ────────────────────────
//   // Reads from flat 'results' collection — works with existing data
//   Future<Map<String, dynamic>> calculateOverallRank(String studentId) async {
//     try {
//       // 1. Get all results
//       final snap = await _db.collection('results').get();

//       // 2. Group by studentId
//       final Map<String, List<Map<String, dynamic>>> grouped = {};
//       for (final doc in snap.docs) {
//         final data = doc.data();
//         final sid = (data['studentId'] ?? '').toString();
//         if (sid.isEmpty) continue;
//         grouped.putIfAbsent(sid, () => []);
//         grouped[sid]!.add(data);
//       }

//       if (grouped.isEmpty) {
//         return _emptyRank();
//       }

//       // 3. Calculate CGPA for each student
//       final List<Map<String, dynamic>> cgpaList = grouped.entries.map((e) {
//         final cgpa = GpaCalculator.calculateCGPA(e.value);
//         return {'studentId': e.key, 'cgpa': cgpa};
//       }).toList();

//       // 4. Sort descending
//       cgpaList
//           .sort((a, b) => (b['cgpa'] as double).compareTo(a['cgpa'] as double));

//       // 5. Find this student's rank
//       final rank = cgpaList.indexWhere((r) => r['studentId'] == studentId) + 1;
//       final total = cgpaList.length;
//       final topperCgpa =
//           cgpaList.isNotEmpty ? (cgpaList.first['cgpa'] as double) : 0.0;
//       final studentEntry = cgpaList.firstWhere(
//           (r) => r['studentId'] == studentId,
//           orElse: () => {'cgpa': 0.0});
//       final studentCgpa = (studentEntry['cgpa'] as double?) ?? 0.0;

//       // 6. Build top 5 leaderboard with names
//       final top5 = <Map<String, dynamic>>[];
//       for (int i = 0; i < cgpaList.length && i < 5; i++) {
//         final sid = cgpaList[i]['studentId'] as String;
//         String name = sid;
//         String regNo = sid;
//         try {
//           final doc = await _db.collection('students').doc(sid).get();
//           if (doc.exists) {
//             name = doc.data()?['name'] ?? sid;
//             regNo = doc.data()?['regNo'] ?? sid;
//           }
//         } catch (_) {}
//         top5.add({
//           'rank': i + 1,
//           'studentId': sid,
//           'name': name,
//           'regNo': regNo,
//           'cgpa': cgpaList[i]['cgpa'],
//         });
//       }

//       return {
//         'rank': rank,
//         'totalStudents': total,
//         'topperCgpa': topperCgpa,
//         'studentCgpa': studentCgpa,
//         'gapFromTopper': topperCgpa - studentCgpa,
//         'top5': top5,
//       };
//     } catch (_) {
//       return _emptyRank();
//     }
//   }

//   // ── Semester rank ────────────────────────────────────────────────
//   Future<Map<String, dynamic>> calculateRank(
//       String studentId, int semester) async {
//     try {
//       // 1. Get all results for this semester
//       final snap = await _db
//           .collection('results')
//           .where('semester', isEqualTo: semester)
//           .get();

//       // 2. Group by studentId
//       final Map<String, List<Map<String, dynamic>>> grouped = {};
//       for (final doc in snap.docs) {
//         final data = doc.data();
//         final sid = (data['studentId'] ?? '').toString();
//         if (sid.isEmpty) continue;
//         grouped.putIfAbsent(sid, () => []);
//         grouped[sid]!.add(data);
//       }

//       if (grouped.isEmpty) {
//         return {
//           'rank': 0,
//           'totalStudents': 0,
//           'studentGpa': 0.0,
//           'topperGpa': 0.0,
//           'gapFromTopper': 0.0
//         };
//       }

//       // 3. Calculate GPA for each student in this semester
//       final List<Map<String, dynamic>> gpaList = grouped.entries.map((e) {
//         return {
//           'studentId': e.key,
//           'gpa': GpaCalculator.calculateGPA(e.value),
//         };
//       }).toList();

//       // 4. Sort descending
//       gpaList
//           .sort((a, b) => (b['gpa'] as double).compareTo(a['gpa'] as double));

//       // 5. Find this student's rank
//       final rank = gpaList.indexWhere((r) => r['studentId'] == studentId) + 1;
//       final total = gpaList.length;
//       final topperGpa =
//           gpaList.isNotEmpty ? (gpaList.first['gpa'] as double) : 0.0;
//       final studentEntry = gpaList.firstWhere(
//           (r) => r['studentId'] == studentId,
//           orElse: () => {'gpa': 0.0});
//       final studentGpa = (studentEntry['gpa'] as double?) ?? 0.0;

//       return {
//         'rank': rank,
//         'totalStudents': total,
//         'studentGpa': studentGpa,
//         'topperGpa': topperGpa,
//         'gapFromTopper': topperGpa - studentGpa,
//       };
//     } catch (_) {
//       return {
//         'rank': 0,
//         'totalStudents': 0,
//         'studentGpa': 0.0,
//         'topperGpa': 0.0,
//         'gapFromTopper': 0.0,
//       };
//     }
//   }

//   // ── Empty rank template ──────────────────────────────────────────
//   Map<String, dynamic> _emptyRank() => {
//         'rank': 0,
//         'totalStudents': 0,
//         'topperCgpa': 0.0,
//         'studentCgpa': 0.0,
//         'gapFromTopper': 0.0,
//         'top5': <Map<String, dynamic>>[],
//       };
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/gpa_calculator.dart';

/// READ-ONLY service for student-facing screens.
/// Reads from: students/{registerNumber}/semesters/sem{N}/subjects/
/// This matches the path written by ResultStorageService.
class StudentResultService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Fetch ALL results for a student (all semesters flattened) ────
  Future<List<Map<String, dynamic>>> fetchResults(String registerNumber) async {
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
        final resultStatus =
            (semData['resultStatus'] as String?) ?? 'Available';

        // Skip semesters with no result
        if (resultStatus == 'No Result') continue;

        final subSnap = await semDoc.reference.collection('subjects').get();
        for (final sub in subSnap.docs) {
          final data = sub.data();
          results.add({
            ...data,
            'credits': data['credit'] ?? data['credits'] ?? 0,
            'semester': semNum,
            'semesterGPA': semData['semesterGPA'] ?? 0.0,
            'cumulativeCGPA': semData['cumulativeCGPA'] ?? 0.0,
          });
        }
      }
    } catch (_) {}
    return results;
  }

  // ── Fetch results for one semester ───────────────────────────────
  Future<List<Map<String, dynamic>>> fetchSemesterResults(
      String registerNumber, int semester) async {
    try {
      final semId = 'sem$semester';
      final semRef = _db
          .collection('students')
          .doc(registerNumber)
          .collection('semesters')
          .doc(semId);

      final semDoc = await semRef.get();
      if (!semDoc.exists) return [];

      final semData = semDoc.data()!;
      final resultStatus = (semData['resultStatus'] as String?) ?? 'Available';
      if (resultStatus == 'No Result') return [];

      final subSnap = await semRef.collection('subjects').get();
      return subSnap.docs.map((d) {
        final data = d.data();
        return {
          ...data,
          'credits': data['credit'] ?? data['credits'] ?? 0,
          'semester': semester,
        };
      }).toList();
    } catch (_) {
      return [];
    }
  }

  // ── Fetch semester metadata (GPA, rank, status etc.) ────────────
  Future<Map<String, dynamic>> fetchSemesterMeta(
      String registerNumber, int semester) async {
    try {
      final semId = 'sem$semester';
      final semDoc = await _db
          .collection('students')
          .doc(registerNumber)
          .collection('semesters')
          .doc(semId)
          .get();

      if (!semDoc.exists) return {};
      return semDoc.data()!;
    } catch (_) {
      return {};
    }
  }

  // ── Which semesters have data? ───────────────────────────────────
  Future<Set<int>> fetchAvailableSemesters(String registerNumber) async {
    final available = <int>{};
    try {
      final semsSnap = await _db
          .collection('students')
          .doc(registerNumber)
          .collection('semesters')
          .get();
      for (final doc in semsSnap.docs) {
        final semNum = (doc.data()['semesterNumber'] as num?)?.toInt();
        if (semNum != null) available.add(semNum);
      }
    } catch (_) {}
    return available;
  }

  // ── GPA calculations ─────────────────────────────────────────────
  double calculateSemesterGPA(List<Map<String, dynamic>> results) =>
      GpaCalculator.calculateGPA(results);

  double calculateCGPA(List<Map<String, dynamic>> allResults) =>
      GpaCalculator.calculateCGPA(allResults);

  // ── Arrear counts ────────────────────────────────────────────────
  int countArrears(List<Map<String, dynamic>> allResults) => allResults
      .where((r) => !GpaCalculator.isPassed(r['grade'] ?? 'F'))
      .length;

  int countSemesterArrears(List<Map<String, dynamic>> semResults) => semResults
      .where((r) => !GpaCalculator.isPassed(r['grade'] ?? 'F'))
      .length;

  // ── Completed semesters ──────────────────────────────────────────
  List<int> getCompletedSemesters(List<Map<String, dynamic>> allResults) {
    final sems = allResults
        .map((r) => r['semester'] as int? ?? 0)
        .where((s) => s > 0)
        .toSet()
        .toList();
    sems.sort();
    return sems;
  }

  // ── Semester rank (reads from stored rank field) ─────────────────
  Future<Map<String, dynamic>> calculateRank(
      String registerNumber, int semester) async {
    try {
      final meta = await fetchSemesterMeta(registerNumber, semester);
      if (meta.isEmpty) {
        return {
          'rank': 0,
          'totalStudents': 0,
          'studentGpa': 0.0,
          'topperGpa': 0.0,
          'gapFromTopper': 0.0,
        };
      }
      final rank = (meta['rank'] as num?)?.toInt() ?? 0;
      final total = (meta['totalStudents'] as num?)?.toInt() ?? 0;
      final studentGpa = (meta['semesterGPA'] as num?)?.toDouble() ?? 0.0;

      // Find topper GPA from department
      double topperGpa = studentGpa;
      try {
        final studentDoc =
            await _db.collection('students').doc(registerNumber).get();
        final dept = studentDoc.data()?['department'] ?? '';
        if (dept.isNotEmpty) {
          final semId = 'sem$semester';
          final topSnap = await _db
              .collectionGroup('semesters')
              .where('semesterId', isEqualTo: semId)
              .orderBy('semesterGPA', descending: true)
              .limit(1)
              .get();
          if (topSnap.docs.isNotEmpty) {
            topperGpa = (topSnap.docs.first.data()['semesterGPA'] as num?)
                    ?.toDouble() ??
                studentGpa;
          }
        }
      } catch (_) {}

      return {
        'rank': rank,
        'totalStudents': total,
        'studentGpa': studentGpa,
        'topperGpa': topperGpa,
        'gapFromTopper': topperGpa - studentGpa,
      };
    } catch (_) {
      return {
        'rank': 0,
        'totalStudents': 0,
        'studentGpa': 0.0,
        'topperGpa': 0.0,
        'gapFromTopper': 0.0,
      };
    }
  }

  // ── Overall CGPA rank ────────────────────────────────────────────
  Future<Map<String, dynamic>> calculateOverallRank(
      String registerNumber) async {
    try {
      final studentDoc =
          await _db.collection('students').doc(registerNumber).get();
      if (!studentDoc.exists) return _emptyRank();

      final dept = studentDoc.data()?['department'] ?? '';
      final studentsSnap = await _db
          .collection('students')
          .where('department', isEqualTo: dept)
          .get();

      final cgpaList = <Map<String, dynamic>>[];
      for (final doc in studentsSnap.docs) {
        final semsSnap = await doc.reference.collection('semesters').get();
        double tw = 0, tc = 0;
        for (final sem in semsSnap.docs) {
          final subSnap = await sem.reference.collection('subjects').get();
          for (final sub in subSnap.docs) {
            if (sub.data()['isPractical'] == true) continue;
            final c = (sub.data()['credit'] as num?)?.toDouble() ?? 0;
            final gp = (sub.data()['gradePoint'] as num?)?.toDouble() ?? 0;
            tw += c * gp;
            tc += c;
          }
        }
        final cgpa = tc > 0 ? tw / tc : 0.0;
        cgpaList.add({
          'registerNumber': doc.id,
          'name': doc.data()['name'] ?? doc.id,
          'cgpa': cgpa,
        });
      }

      cgpaList
          .sort((a, b) => (b['cgpa'] as double).compareTo(a['cgpa'] as double));

      final rank =
          cgpaList.indexWhere((r) => r['registerNumber'] == registerNumber) + 1;
      final total = cgpaList.length;
      final topperCgpa =
          cgpaList.isNotEmpty ? (cgpaList.first['cgpa'] as double) : 0.0;
      final entry = cgpaList.firstWhere(
          (r) => r['registerNumber'] == registerNumber,
          orElse: () => {'cgpa': 0.0});
      final studentCgpa = (entry['cgpa'] as double?) ?? 0.0;

      final top5 = cgpaList.take(5).toList().asMap().entries.map((e) {
        return {
          'rank': e.key + 1,
          'registerNumber': e.value['registerNumber'],
          'name': e.value['name'],
          'cgpa': e.value['cgpa'],
        };
      }).toList();

      return {
        'rank': rank,
        'totalStudents': total,
        'topperCgpa': topperCgpa,
        'studentCgpa': studentCgpa,
        'gapFromTopper': topperCgpa - studentCgpa,
        'top5': top5,
      };
    } catch (_) {
      return _emptyRank();
    }
  }

  Map<String, dynamic> _emptyRank() => {
        'rank': 0,
        'totalStudents': 0,
        'topperCgpa': 0.0,
        'studentCgpa': 0.0,
        'gapFromTopper': 0.0,
        'top5': <Map<String, dynamic>>[],
      };
}
