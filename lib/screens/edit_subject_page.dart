import 'package:flutter/material.dart';
import '../services/subject_master_service.dart';

class EditSubjectPage extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> data;
  const EditSubjectPage({super.key, required this.docId, required this.data});
  @override
  State<EditSubjectPage> createState() => _EditSubjectPageState();
}

class _EditSubjectPageState extends State<EditSubjectPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  final _service = SubjectMasterService();
  late String _department;
  late int _semester;
  late double _credits;
  bool _saving = false;

  static const _departments = [
    'CSE',
    'IT',
    'ECE',
    'EEE',
    'MECH',
    'CIVIL',
    'AIDS',
    'AIML',
    'CSD',
    'OTHER'
  ];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.data['subjectName'] ?? '');
    _department = widget.data['department'] ?? 'CSE';
    if (!_departments.contains(_department)) _department = 'OTHER';
    _semester = (widget.data['semester'] as num?)?.toInt() ?? 1;
    _credits = (widget.data['credits'] as num?)?.toDouble() ?? 3.0;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _update() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final error = await _service.updateSubject(
      docId: widget.docId,
      subjectName: _nameCtrl.text,
      department: _department,
      semester: _semester,
      credits: _credits,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Subject updated ✔'),
          backgroundColor: Color(0xFF43A047)));
      Navigator.pop(context);
    }
  }

  InputDecoration _dec(String label, IconData icon, Color cardBg, Color sub) =>
      InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: sub),
        prefixIcon: Icon(icon, color: const Color(0xFF6C63FF), size: 20),
        filled: true,
        fillColor: cardBg,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: const Color(0xFF6C63FF).withOpacity(0.2))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 1.5)),
      );

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0A0E27) : const Color(0xFFF4F6FF);
    final cardBg = isDark ? const Color(0xFF1A1F4E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF2D3142);
    final sub = isDark ? const Color(0xFF8B92B8) : const Color(0xFF6B7280);
    final code = widget.data['subjectCode'] ?? '';

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0,
        title: Text('Edit Subject',
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        iconTheme: IconThemeData(color: textColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Code badge — read only
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: const Color(0xFF6C63FF).withOpacity(0.3)),
              ),
              child: Row(children: [
                const Icon(Icons.lock_rounded,
                    color: Color(0xFF6C63FF), size: 18),
                const SizedBox(width: 10),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Subject Code (cannot change)',
                      style: TextStyle(color: sub, fontSize: 11)),
                  const SizedBox(height: 2),
                  Text(code,
                      style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 18)),
                ]),
              ]),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameCtrl,
              style: TextStyle(color: textColor),
              decoration:
                  _dec('Subject Name', Icons.menu_book_rounded, cardBg, sub),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _department,
              dropdownColor: cardBg,
              style: TextStyle(color: textColor),
              decoration:
                  _dec('Department', Icons.apartment_rounded, cardBg, sub),
              items: _departments
                  .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                  .toList(),
              onChanged: (v) => setState(() => _department = v!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _semester,
              dropdownColor: cardBg,
              style: TextStyle(color: textColor),
              decoration: _dec('Semester', Icons.school_rounded, cardBg, sub),
              items: List.generate(8, (i) => i + 1)
                  .map((s) =>
                      DropdownMenuItem(value: s, child: Text('Semester $s')))
                  .toList(),
              onChanged: (v) => setState(() => _semester = v!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<double>(
              value: _credits,
              dropdownColor: cardBg,
              style: TextStyle(color: textColor),
              decoration: _dec('Credits', Icons.stars_rounded, cardBg, sub),
              items: [1, 2, 3, 4, 5, 6]
                  .map((c) => DropdownMenuItem(
                      value: c.toDouble(), child: Text('$c Credits')))
                  .toList(),
              onChanged: (v) => setState(() => _credits = v!),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _saving ? null : _update,
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14))),
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5))
                    : const Text('UPDATE SUBJECT',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            letterSpacing: 1)),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
