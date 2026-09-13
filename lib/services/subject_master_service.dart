import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class SubjectMasterService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const _col = 'subject_master';

  Stream<QuerySnapshot> subjectsStream() =>
      _db.collection(_col).orderBy('semester').snapshots();

  Future<String?> addSubject({
    required String subjectCode,
    required String subjectName,
    required String department,
    required int semester,
    required double credits,
  }) async {
    try {
      final code = subjectCode.trim().toUpperCase();
      final existing = await _db
          .collection(_col)
          .where('subjectCode', isEqualTo: code)
          .limit(1)
          .get();
      if (existing.docs.isNotEmpty) {
        return 'Subject code $code already exists.';
      }
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      await _db.collection(_col).add({
        'subjectCode': code,
        'subjectName': subjectName.trim(),
        'department': department,
        'semester': semester,
        'credits': credits,
        'createdBy': uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
      debugPrint('Subject Master Added: $code');
      return null;
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<String?> updateSubject({
    required String docId,
    required String subjectName,
    required String department,
    required int semester,
    required double credits,
  }) async {
    try {
      await _db.collection(_col).doc(docId).update({
        'subjectName': subjectName.trim(),
        'department': department,
        'semester': semester,
        'credits': credits,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return null;
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<String?> deleteSubject(String docId) async {
    try {
      await _db.collection(_col).doc(docId).delete();
      return null;
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<Map<String, Map<String, dynamic>>> fetchSubjectMap(
      int semester) async {
    final map = <String, Map<String, dynamic>>{};
    try {
      final snap = await _db
          .collection(_col)
          .where('semester', isEqualTo: semester)
          .get();
      for (final doc in snap.docs) {
        final data = doc.data();
        final code = (data['subjectCode'] ?? '').toString().toUpperCase();
        if (code.isNotEmpty) map[code] = data;
      }
      debugPrint('Subject Master Loaded: ${map.length} subjects');
    } catch (_) {}
    return map;
  }

  Future<Map<String, Map<String, dynamic>>> fetchAllSubjectMap() async {
    final map = <String, Map<String, dynamic>>{};
    try {
      final snap = await _db.collection(_col).get();
      for (final doc in snap.docs) {
        final data = doc.data();
        final code = (data['subjectCode'] ?? '').toString().toUpperCase();
        if (code.isNotEmpty) map[code] = data;
      }
      debugPrint('Subject Master Loaded: ${map.length} subjects');
    } catch (_) {}
    return map;
  }
}
