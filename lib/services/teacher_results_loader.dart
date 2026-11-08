import 'package:cloud_firestore/cloud_firestore.dart';

/// Loads results for ALL students in one go, in the flat row format the
/// teacher screens already use:
///   {studentId, subjectCode, subjectName, credits, grade, gradePoint, semester}
///
/// Sources:
///   1. students/{regNo}/semesters/{semN}/subjects/*   (PDF import — main)
///   2. results collection (old manual entry) — only for semesters that
///      have no imported data for that student.
class TeacherResultsLoader {
  static const int maxSemesters = 8;

  static Future<Map<String, List<Map<String, dynamic>>>>? _pending;
  static DateTime? _loadedAt;

  static void invalidate() {
    _pending = null;
    _loadedAt = null;
  }

  static Future<Map<String, List<Map<String, dynamic>>>> loadAll(
      {bool force = false}) {
    final fresh = _loadedAt != null &&
        DateTime.now().difference(_loadedAt!) < const Duration(seconds: 20);
    if (!force && _pending != null && fresh) return _pending!;
    _loadedAt = DateTime.now();
    final f = _load();
    _pending = f;
    f.catchError((_) {
      invalidate();
      return <String, List<Map<String, dynamic>>>{};
    });
    return f;
  }

  static Future<List<Map<String, dynamic>>> loadForStudent(String studentId,
      {bool force = false}) async {
    final all = await loadAll(force: force);
    return all[studentId] ?? <Map<String, dynamic>>[];
  }

  static Future<Map<String, List<Map<String, dynamic>>>> _load() async {
    final db = FirebaseFirestore.instance;
    final byStudent = <String, List<Map<String, dynamic>>>{};

    // 1) Imported results — one collection-group query for every subject
    final subSnap = await db.collectionGroup('subjects').get();
    for (final doc in subSnap.docs) {
      final semDoc = doc.reference.parent.parent; // semesters/{semId}
      final studentDoc = semDoc?.parent.parent; // students/{regNo}
      if (semDoc == null || studentDoc == null) continue;
      if (semDoc.parent.id != 'semesters' ||
          studentDoc.parent.id != 'students') {
        continue;
      }
      final semNum =
          int.tryParse(semDoc.id.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      if (semNum == 0) continue;
      final d = doc.data();
      byStudent.putIfAbsent(studentDoc.id, () => []).add({
        ...d,
        'studentId': studentDoc.id,
        'subjectName': d['subjectName'] ?? d['subjectCode'] ?? doc.id,
        'credits': d['credit'] ?? d['credits'] ?? 0,
        'gradePoint': d['gradePoint'] ?? 0,
        'grade': (d['grade'] ?? 'F').toString(),
        'semester': semNum,
      });
    }

    // 2) Old manual-entry results (fallback)
    try {
      final covered = <String, Set<int>>{};
      byStudent.forEach((sid, rows) {
        covered[sid] = rows.map((r) => r['semester'] as int).toSet();
      });
      final legacy = await db.collection('results').get();
      for (final doc in legacy.docs) {
        final d = doc.data();
        final sid = (d['studentId'] ?? '').toString();
        if (sid.isEmpty) continue;
        final sem = (d['semester'] as num?)?.toInt() ?? 1;
        if (covered[sid]?.contains(sem) ?? false) continue;
        byStudent.putIfAbsent(sid, () => []).add({
          ...d,
          'studentId': sid,
          'credits': d['credits'] ?? d['credit'] ?? 0,
          'gradePoint': d['gradePoint'] ?? 0,
          'grade': (d['grade'] ?? 'F').toString(),
          'semester': sem,
        });
      }
    } catch (_) {}

    return byStudent;
  }
}