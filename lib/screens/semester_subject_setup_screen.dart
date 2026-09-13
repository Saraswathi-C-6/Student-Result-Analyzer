import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Teacher can pre-define subjects (code, name, credits) for each semester.
/// These act as templates so the PDF parser can auto-fill credits.
class SemesterSubjectSetupScreen extends StatefulWidget {
  const SemesterSubjectSetupScreen({super.key});

  @override
  State<SemesterSubjectSetupScreen> createState() =>
      _SemesterSubjectSetupScreenState();
}

class _SemesterSubjectSetupScreenState
    extends State<SemesterSubjectSetupScreen> {
  int _selectedSemester = 1;
  bool _isLoading = false;
  bool _isFetching = true;

  // subjectsBySemester[sem] = list of {subjectCode, subjectName, credits, id}
  final Map<int, List<Map<String, dynamic>>> _subjectsBySemester = {};

  final _codeCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _creditsCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fetchAll();
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _nameCtrl.dispose();
    _creditsCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchAll() async {
    setState(() => _isFetching = true);
    try {
      final snap = await FirebaseFirestore.instance
          .collection('subject_setup')
          .orderBy('createdAt')
          .get();
      final map = <int, List<Map<String, dynamic>>>{};
      for (final doc in snap.docs) {
        final data = doc.data();
        final sem = (data['semester'] as num).toInt();
        map.putIfAbsent(sem, () => []);
        map[sem]!.add({'id': doc.id, ...data});
      }
      setState(() => _subjectsBySemester
        ..clear()
        ..addAll(map));
    } catch (e) {
      _showMsg('Failed to load subjects', isError: true);
    } finally {
      if (mounted) setState(() => _isFetching = false);
    }
  }

  Future<void> _addSubject() async {
    if (!_formKey.currentState!.validate()) return;
    final code = _codeCtrl.text.trim().toUpperCase();
    final name = _nameCtrl.text.trim();
    final credits = double.parse(_creditsCtrl.text.trim());

    // Check duplicate in same semester
    final existing = _subjectsBySemester[_selectedSemester] ?? [];
    if (existing.any((s) => s['subjectCode'] == code)) {
      _showMsg('Subject $code already exists in Semester $_selectedSemester',
          isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final doc =
          await FirebaseFirestore.instance.collection('subject_setup').add({
        'subjectCode': code,
        'subjectName': name,
        'credits': credits,
        'semester': _selectedSemester,
        'createdAt': FieldValue.serverTimestamp(),
      });
      setState(() {
        _subjectsBySemester.putIfAbsent(_selectedSemester, () => []);
        _subjectsBySemester[_selectedSemester]!.add({
          'id': doc.id,
          'subjectCode': code,
          'subjectName': name,
          'credits': credits,
          'semester': _selectedSemester,
        });
        _codeCtrl.clear();
        _nameCtrl.clear();
        _creditsCtrl.clear();
      });
      _showMsg('Subject added!');
    } catch (e) {
      _showMsg('Failed to add subject', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteSubject(String docId, int semester) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F4E),
        title:
            const Text('Delete Subject', style: TextStyle(color: Colors.white)),
        content: const Text('Remove this subject from setup?',
            style: TextStyle(color: Color(0xFF8B92B8))),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel',
                  style: TextStyle(color: Color(0xFF8B92B8)))),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete',
                  style: TextStyle(color: Color(0xFFE53935)))),
        ],
      ),
    );
    if (confirm != true) return;

    await FirebaseFirestore.instance
        .collection('subject_setup')
        .doc(docId)
        .delete();
    setState(() {
      _subjectsBySemester[semester]?.removeWhere((s) => s['id'] == docId);
    });
    _showMsg('Subject deleted');
  }

  void _showMsg(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor:
          isError ? const Color(0xFFE53935) : const Color(0xFF43A047),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final subjects = _subjectsBySemester[_selectedSemester] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1F4E),
        title: const Text('Subject Setup',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: _isFetching
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
          : Column(
              children: [
                // ── Semester Selector ──────────────────────────────
                Container(
                  color: const Color(0xFF1A1F4E),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Select Semester',
                          style: TextStyle(
                              color: Color(0xFF8B92B8),
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Row(
                        children: List.generate(8, (i) {
                          final sem = i + 1;
                          final isSelected = _selectedSemester == sem;
                          final hasData =
                              (_subjectsBySemester[sem] ?? []).isNotEmpty;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedSemester = sem),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: EdgeInsets.only(right: sem < 8 ? 6 : 0),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF6C63FF)
                                      : const Color(0xFF0A0E27),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF6C63FF)
                                        : hasData
                                            ? const Color(0xFF4ECDC4)
                                            : const Color(0xFF2D3470),
                                    width: 1.5,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Text('$sem',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal)),
                                    if (hasData)
                                      const Icon(Icons.circle,
                                          color: Color(0xFF4ECDC4), size: 6),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),

                // ── Subject List ───────────────────────────────────
                Expanded(
                  child: subjects.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.book_outlined,
                                  color: const Color(0xFF2D3470), size: 56),
                              const SizedBox(height: 12),
                              Text(
                                  'No subjects set up for Semester $_selectedSemester',
                                  style: const TextStyle(
                                      color: Color(0xFF8B92B8))),
                              const SizedBox(height: 4),
                              const Text('Add subjects below',
                                  style: TextStyle(
                                      color: Color(0xFF4A5180), fontSize: 12)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: subjects.length,
                          itemBuilder: (context, idx) {
                            final s = subjects[idx];
                            return _SubjectTile(
                              subject: s,
                              onDelete: () =>
                                  _deleteSubject(s['id'], _selectedSemester),
                            );
                          },
                        ),
                ),

                // ── Add Subject Form ───────────────────────────────
                Container(
                  color: const Color(0xFF1A1F4E),
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 16,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Add Subject — Semester $_selectedSemester',
                          style: const TextStyle(
                              color: Color(0xFF6C63FF),
                              fontWeight: FontWeight.bold,
                              fontSize: 13),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: _miniField('Code', 'CS101', _codeCtrl,
                                  validator: (v) =>
                                      v!.isEmpty ? 'Required' : null),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 4,
                              child: _miniField(
                                  'Subject Name', 'Data Structures', _nameCtrl,
                                  validator: (v) =>
                                      v!.isEmpty ? 'Required' : null),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 1,
                              child: _miniField('Cr', '4', _creditsCtrl,
                                  isNumber: true, validator: (v) {
                                if (v!.isEmpty) return 'Req';
                                if (double.tryParse(v) == null) {
                                  return 'Num';
                                }
                                return null;
                              }),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _addSubject,
                            icon: _isLoading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2))
                                : const Icon(Icons.add_rounded,
                                    color: Colors.white),
                            label: const Text('Add Subject',
                                style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6C63FF),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _miniField(
    String label,
    String hint,
    TextEditingController ctrl, {
    bool isNumber = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: isNumber
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      validator: validator,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: Color(0xFF8B92B8), fontSize: 12),
        hintStyle: const TextStyle(color: Color(0xFF4A5180), fontSize: 12),
        filled: true,
        fillColor: const Color(0xFF0A0E27),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF2D3470)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF2D3470)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 1.5),
        ),
        errorStyle: const TextStyle(fontSize: 10, color: Color(0xFFFF6B6B)),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE53935)),
        ),
      ),
    );
  }
}

class _SubjectTile extends StatelessWidget {
  final Map<String, dynamic> subject;
  final VoidCallback onDelete;
  const _SubjectTile({required this.subject, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F4E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2D3470)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              subject['subjectCode'] ?? '',
              style: const TextStyle(
                  color: Color(0xFF6C63FF),
                  fontWeight: FontWeight.bold,
                  fontSize: 12),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject['subjectName'] ?? '',
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${subject['credits']} Credits',
                  style:
                      const TextStyle(color: Color(0xFF8B92B8), fontSize: 11),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded,
                color: Color(0xFFE53935), size: 20),
            onPressed: onDelete,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
