// import 'package:flutter/material.dart';
// import '../services/subject_master_service.dart';

// class AddSubjectPage extends StatefulWidget {
//   const AddSubjectPage({super.key});
//   @override
//   State<AddSubjectPage> createState() => _AddSubjectPageState();
// }

// class _AddSubjectPageState extends State<AddSubjectPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _codeCtrl = TextEditingController();
//   final _nameCtrl = TextEditingController();
//   final _service = SubjectMasterService();

//   String _department = 'CSE';
//   int _semester = 1;
//   double _credits = 3;
//   bool _saving = false;

//   static const _departments = [
//     'CSE',
//     'IT',
//     'ECE',
//     'EEE',
//   ];

//   @override
//   void dispose() {
//     _codeCtrl.dispose();
//     _nameCtrl.dispose();
//     super.dispose();
//   }

//   Future<void> _save() async {
//     if (!_formKey.currentState!.validate()) return;
//     setState(() => _saving = true);
//     final error = await _service.addSubject(
//       subjectCode: _codeCtrl.text,
//       subjectName: _nameCtrl.text,
//       department: _department,
//       semester: _semester,
//       credits: _credits,
//     );
//     if (!mounted) return;
//     setState(() => _saving = false);
//     if (error != null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(error), backgroundColor: Colors.red));
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//           content: Text('Subject added successfully ✔'),
//           backgroundColor: Color(0xFF43A047)));
//       Navigator.pop(context);
//     }
//   }

//   InputDecoration _dec(String label, IconData icon, Color cardBg, Color sub) =>
//       InputDecoration(
//         labelText: label,
//         labelStyle: TextStyle(color: sub),
//         prefixIcon: Icon(icon, color: const Color(0xFF6C63FF), size: 20),
//         filled: true,
//         fillColor: cardBg,
//         border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide.none),
//         enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide:
//                 BorderSide(color: const Color(0xFF6C63FF).withOpacity(0.2))),
//         focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 1.5)),
//       );

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final bg = isDark ? const Color(0xFF0A0E27) : const Color(0xFFF4F6FF);
//     final cardBg = isDark ? const Color(0xFF1A1F4E) : Colors.white;
//     final textColor = isDark ? Colors.white : const Color(0xFF2D3142);
//     final sub = isDark ? const Color(0xFF8B92B8) : const Color(0xFF6B7280);

//     return Scaffold(
//       backgroundColor: bg,
//       appBar: AppBar(
//         backgroundColor: cardBg,
//         elevation: 0,
//         title: Text('Add Subject',
//             style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
//         iconTheme: IconThemeData(color: textColor),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Form(
//           key: _formKey,
//           child: Column(children: [
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(18),
//               decoration: BoxDecoration(
//                 gradient: const LinearGradient(
//                     colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)]),
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: const Row(children: [
//                 Icon(Icons.book_rounded, color: Colors.white, size: 32),
//                 SizedBox(width: 12),
//                 Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                   Text('New Subject',
//                       style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold)),
//                   Text('Fill all fields to add subject',
//                       style: TextStyle(color: Colors.white70, fontSize: 12)),
//                 ]),
//               ]),
//             ),
//             const SizedBox(height: 24),
//             TextFormField(
//               controller: _codeCtrl,
//               style: TextStyle(color: textColor),
//               textCapitalization: TextCapitalization.characters,
//               decoration: _dec('Subject Code (e.g. MAA101)', Icons.code_rounded,
//                   cardBg, sub),
//               validator: (v) {
//                 if (v == null || v.trim().isEmpty) return 'Required';
//                 if (!RegExp(r'^[A-Za-z]{3}\d{3}$').hasMatch(v.trim()))
//                   return 'Format: 3 letters + 3 digits (e.g. MAA101)';
//                 return null;
//               },
//             ),
//             const SizedBox(height: 16),
//             TextFormField(
//               controller: _nameCtrl,
//               style: TextStyle(color: textColor),
//               decoration:
//                   _dec('Subject Name', Icons.menu_book_rounded, cardBg, sub),
//               validator: (v) =>
//                   (v == null || v.trim().isEmpty) ? 'Required' : null,
//             ),
//             const SizedBox(height: 16),
//             DropdownButtonFormField<String>(
//               value: _department,
//               dropdownColor: cardBg,
//               style: TextStyle(color: textColor),
//               decoration:
//                   _dec('Department', Icons.apartment_rounded, cardBg, sub),
//               items: _departments
//                   .map((d) => DropdownMenuItem(value: d, child: Text(d)))
//                   .toList(),
//               onChanged: (v) => setState(() => _department = v!),
//             ),
//             const SizedBox(height: 16),
//             DropdownButtonFormField<int>(
//               value: _semester,
//               dropdownColor: cardBg,
//               style: TextStyle(color: textColor),
//               decoration: _dec('Semester', Icons.school_rounded, cardBg, sub),
//               items: List.generate(8, (i) => i + 1)
//                   .map((s) =>
//                       DropdownMenuItem(value: s, child: Text('Semester $s')))
//                   .toList(),
//               onChanged: (v) => setState(() => _semester = v!),
//             ),
//             const SizedBox(height: 16),
//             DropdownButtonFormField<double>(
//               value: _credits,
//               dropdownColor: cardBg,
//               style: TextStyle(color: textColor),
//               decoration: _dec('Credits', Icons.stars_rounded, cardBg, sub),
//               items: [1, 2, 3, 4, 5, 6]
//                   .map((c) => DropdownMenuItem(
//                       value: c.toDouble(), child: Text('$c Credits')))
//                   .toList(),
//               onChanged: (v) => setState(() => _credits = v!),
//             ),
//             const SizedBox(height: 32),
//             SizedBox(
//               width: double.infinity,
//               height: 52,
//               child: ElevatedButton(
//                 onPressed: _saving ? null : _save,
//                 style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF6C63FF),
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(14))),
//                 child: _saving
//                     ? const SizedBox(
//                         width: 22,
//                         height: 22,
//                         child: CircularProgressIndicator(
//                             color: Colors.white, strokeWidth: 2.5))
//                     : const Text('SAVE SUBJECT',
//                         style: TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 15,
//                             letterSpacing: 1)),
//               ),
//             ),
//           ]),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/subject_master_service.dart';

class AddSubjectPage extends StatefulWidget {
  const AddSubjectPage({super.key});
  @override
  State<AddSubjectPage> createState() => _AddSubjectPageState();
}

class _AddSubjectPageState extends State<AddSubjectPage> {
  final _formKey = GlobalKey<FormState>();
  final _codeCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _creditsCtrl = TextEditingController(); // FIX 2: TextField for credits
  final _service = SubjectMasterService();

  String _department = 'CSE';
  int _semester = 1;
  bool _saving = false;

  // FIX 1: Only CSE / ISE / ECE / EEE — no typing, no dynamic values
  static const _departments = ['CSE', 'ISE', 'ECE', 'EEE'];

  @override
  void dispose() {
    _codeCtrl.dispose();
    _nameCtrl.dispose();
    _creditsCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    // FIX 3: credits parse + zero-check (validator already guards this,
    //         but double-check here before the Firestore call)
    final credits = double.tryParse(_creditsCtrl.text.trim()) ?? 0;
    if (credits <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Credits must be greater than 0'),
          backgroundColor: Colors.red));
      return;
    }

    setState(() => _saving = true);
    final error = await _service.addSubject(
      subjectCode: _codeCtrl.text.trim(),
      subjectName: _nameCtrl.text.trim(),
      department: _department,
      semester: _semester,
      credits: credits,
    );
    if (!mounted) return;
    setState(() => _saving = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Subject added successfully ✔'),
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

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0,
        title: Text('Add Subject',
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        iconTheme: IconThemeData(color: textColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(children: [
            // ── Header banner (unchanged) ──────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(children: [
                Icon(Icons.book_rounded, color: Colors.white, size: 32),
                SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('New Subject',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  Text('Fill all fields to add subject',
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                ]),
              ]),
            ),
            const SizedBox(height: 24),

            // ── Subject Code ───────────────────────────────────
            TextFormField(
              controller: _codeCtrl,
              style: TextStyle(color: textColor),
              textCapitalization: TextCapitalization.characters,
              decoration: _dec('Subject Code (e.g. MAA101)', Icons.code_rounded,
                  cardBg, sub),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                if (!RegExp(r'^[A-Za-z]{3}\d{3}$').hasMatch(v.trim()))
                  return 'Format: 3 letters + 3 digits (e.g. MAA101)';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // ── Subject Name ───────────────────────────────────
            TextFormField(
              controller: _nameCtrl,
              style: TextStyle(color: textColor),
              decoration:
                  _dec('Subject Name', Icons.menu_book_rounded, cardBg, sub),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 16),

            // ── FIX 1: Department — CSE / ISE / ECE / EEE only ─
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
              // validator not needed — always has a valid default
            ),
            const SizedBox(height: 16),

            // ── Semester (unchanged) ───────────────────────────
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

            // ── FIX 2: Credits — manual TextField, numbers only ─
            TextFormField(
              controller: _creditsCtrl,
              style: TextStyle(color: textColor),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                // Allow digits and a single decimal point only
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              decoration:
                  _dec('Credits (e.g. 3)', Icons.stars_rounded, cardBg, sub),
              // FIX 3: Validation — cannot be empty, cannot be 0
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Credits is required';
                final parsed = double.tryParse(v.trim());
                if (parsed == null) return 'Enter a valid number';
                if (parsed < 0) return 'Credits must be negative';
                if (parsed > 6) return 'Credits cannot exceed 6';
                return null;
              },
            ),
            const SizedBox(height: 32),

            // ── Save button (unchanged) ────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
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
                    : const Text('SAVE SUBJECT',
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
