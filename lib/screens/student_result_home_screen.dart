// // screens/student_result_home_screen.dart
// // Student-facing result search.
// // Reads from: students/{registerNumber}/semesters/sem{N}/subjects/
// // Same Firestore path as the rest of the existing app.
// // DO NOT modify navigation or auth.

// import 'package:flutter/material.dart';
// import '../services/result_storage_service.dart';

// class StudentResultHomeScreen extends StatefulWidget {
//   const StudentResultHomeScreen({super.key});

//   @override
//   State<StudentResultHomeScreen> createState() =>
//       _StudentResultHomeScreenState();
// }

// class _StudentResultHomeScreenState extends State<StudentResultHomeScreen> {
//   final ResultStorageService _service = ResultStorageService();
//   final _formKey = GlobalKey<FormState>();
//   final _regNoController = TextEditingController();

//   int? _selectedSemester;
//   bool _isLoading = false;
//   Map<String, dynamic>? _semesterData;
//   Map<String, dynamic>? _studentProfile;
//   String? _errorMessage;

//   final List<int> _semesters = List.generate(8, (i) => i + 1);

//   @override
//   void dispose() {
//     _regNoController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return Scaffold(
//       appBar: AppBar(title: const Text('My Result'), elevation: 0),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             _buildSearchForm(theme),
//             const SizedBox(height: 20),
//             if (_isLoading) const Center(child: CircularProgressIndicator()),
//             if (!_isLoading && _errorMessage != null) _buildErrorCard(theme),
//             if (!_isLoading && _semesterData != null) _buildResultView(theme),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSearchForm(ThemeData theme) {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               Text('Search Your Result',
//                   style: theme.textTheme.titleMedium
//                       ?.copyWith(fontWeight: FontWeight.bold)),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _regNoController,
//                 keyboardType: TextInputType.number,
//                 decoration: InputDecoration(
//                   labelText: 'Register Number',
//                   prefixIcon: const Icon(Icons.badge),
//                   border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10)),
//                   filled: true,
//                 ),
//                 validator: (v) {
//                   if (v == null || v.trim().isEmpty) {
//                     return 'Enter your register number';
//                   }
//                   if (!RegExp(r'^\d{10}$').hasMatch(v.trim())) {
//                     return 'Enter a valid 10-digit register number';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 12),
//               DropdownButtonFormField<int>(
//                 value: _selectedSemester,
//                 decoration: InputDecoration(
//                   labelText: 'Semester',
//                   prefixIcon: const Icon(Icons.school),
//                   border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10)),
//                   filled: true,
//                 ),
//                 items: _semesters
//                     .map((s) =>
//                         DropdownMenuItem(value: s, child: Text('Semester $s')))
//                     .toList(),
//                 onChanged: (val) => setState(() => _selectedSemester = val),
//                 validator: (v) => v == null ? 'Select a semester' : null,
//               ),
//               const SizedBox(height: 16),
//               ElevatedButton.icon(
//                 onPressed: _isLoading ? null : _search,
//                 icon: const Icon(Icons.search),
//                 label: const Text('Search Result'),
//                 style: ElevatedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10)),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildErrorCard(ThemeData theme) {
//     return Card(
//       color: theme.colorScheme.errorContainer,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Row(
//           children: [
//             Icon(Icons.error_outline, color: theme.colorScheme.error),
//             const SizedBox(width: 8),
//             Expanded(
//               child: Text(_errorMessage!,
//                   style: TextStyle(color: theme.colorScheme.error)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildResultView(ThemeData theme) {
//     final data = _semesterData!;
//     final subjects = (data['subjects'] as List?) ?? [];
//     final gpa = (data['semesterGPA'] as num?)?.toDouble() ?? 0.0;
//     final cgpa = (data['cumulativeCGPA'] as num?)?.toDouble() ?? 0.0;
//     final rank = (data['rank'] as num?)?.toInt() ?? 0;
//     final total = (data['totalStudents'] as num?)?.toInt() ?? 0;
//     final arrears = (data['arrears'] as num?)?.toInt() ?? 0;

//     final name = (_studentProfile?['name'] ?? '').toString();
//     final dept = (_studentProfile?['department'] ?? '').toString();
//     final batch = (_studentProfile?['batch'] ?? '').toString();
//     final regNo = _regNoController.text.trim();

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.stretch,
//       children: [
//         Card(
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(name.isNotEmpty ? name : regNo,
//                               style: theme.textTheme.titleLarge
//                                   ?.copyWith(fontWeight: FontWeight.bold)),
//                           if (dept.isNotEmpty)
//                             Text('$regNo • $dept • Batch $batch',
//                                 style: theme.textTheme.bodySmall?.copyWith(
//                                     color: theme.colorScheme.onSurfaceVariant)),
//                         ],
//                       ),
//                     ),
//                     if (rank > 0)
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 12, vertical: 6),
//                         decoration: BoxDecoration(
//                           color: theme.colorScheme.primaryContainer,
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: Text(
//                           'Rank $rank${total > 0 ? '/$total' : ''}',
//                           style: theme.textTheme.labelLarge?.copyWith(
//                             color: theme.colorScheme.onPrimaryContainer,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//                 const Divider(height: 20),
//                 Row(
//                   children: [
//                     _statBox(theme, 'Sem GPA', gpa.toStringAsFixed(2)),
//                     const SizedBox(width: 12),
//                     _statBox(theme, 'CGPA', cgpa.toStringAsFixed(2)),
//                     const SizedBox(width: 12),
//                     _statBox(theme, 'Arrears', '$arrears'),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//         const SizedBox(height: 16),
//         Card(
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text('Subject-wise Results',
//                     style: theme.textTheme.titleMedium
//                         ?.copyWith(fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 12),
//                 _subjectHeader(theme),
//                 const Divider(height: 8),
//                 ...subjects
//                     .map((s) => _subjectRow(theme, s as Map<String, dynamic>)),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _statBox(ThemeData theme, String label, String value) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.all(10),
//         decoration: BoxDecoration(
//           color: theme.colorScheme.surfaceVariant,
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Column(
//           children: [
//             Text(value,
//                 style: theme.textTheme.titleMedium?.copyWith(
//                   fontWeight: FontWeight.bold,
//                   color: theme.colorScheme.primary,
//                 )),
//             Text(label,
//                 style: theme.textTheme.labelSmall
//                     ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
//                 textAlign: TextAlign.center),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _subjectHeader(ThemeData theme) {
//     final style = theme.textTheme.labelSmall?.copyWith(
//         fontWeight: FontWeight.bold, color: theme.colorScheme.onSurfaceVariant);
//     return Row(children: [
//       SizedBox(width: 70, child: Text('Code', style: style)),
//       Expanded(child: Text('Subject', style: style)),
//       SizedBox(
//           width: 28,
//           child: Text('Cr', style: style, textAlign: TextAlign.center)),
//       SizedBox(
//           width: 28,
//           child: Text('Gr', style: style, textAlign: TextAlign.center)),
//       SizedBox(
//           width: 28,
//           child: Text('GP', style: style, textAlign: TextAlign.center)),
//     ]);
//   }

//   Widget _subjectRow(ThemeData theme, Map<String, dynamic> s) {
//     final grade = (s['grade'] ?? '-').toString();
//     final isFail = grade == 'F' || grade == 'Z';
//     final isPractical = s['isPractical'] == true;

//     final style = theme.textTheme.bodySmall?.copyWith(
//       color: isFail ? theme.colorScheme.error : null,
//       fontWeight: isFail ? FontWeight.w600 : null,
//     );

//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(children: [
//         SizedBox(
//             width: 70,
//             child: Text((s['subjectCode'] ?? '').toString(), style: style)),
//         Expanded(
//             child: Text(
//           (s['subjectName'] ?? s['subjectCode'] ?? '').toString(),
//           style: isPractical
//               ? style?.copyWith(
//                   fontStyle: FontStyle.italic,
//                   color: theme.colorScheme.onSurfaceVariant)
//               : style,
//         )),
//         SizedBox(
//             width: 28,
//             child: Text(
//               isPractical ? '-' : (s['credit'] ?? s['credits'] ?? 0).toString(),
//               style: style,
//               textAlign: TextAlign.center,
//             )),
//         SizedBox(
//             width: 28,
//             child: Text(grade, style: style, textAlign: TextAlign.center)),
//         SizedBox(
//             width: 28,
//             child: Text(
//               isPractical ? 'P' : (s['gradePoint'] ?? 0).toString(),
//               style: style,
//               textAlign: TextAlign.center,
//             )),
//       ]),
//     );
//   }

//   Future<void> _search() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() {
//       _isLoading = true;
//       _semesterData = null;
//       _studentProfile = null;
//       _errorMessage = null;
//     });

//     try {
//       final regNo = _regNoController.text.trim();
//       final sem = _selectedSemester!;

//       final data = await _service.fetchSemesterData(regNo, sem);
//       final profile = await _service.fetchStudentProfile(regNo);

//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//           final subjects = data['subjects'] as List?;
//           if (subjects == null || subjects.isEmpty) {
//             _errorMessage = 'No result found for $regNo in Semester $sem.\n'
//                 'Please check your register number or contact your teacher.';
//           } else {
//             _semesterData = data;
//             _studentProfile = profile;
//           }
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//           _errorMessage = 'Error fetching result: $e';
//         });
//       }
//     }
//   }
// }

// screens/student_result_home_screen.dart
// Auto-fetches register number from logged-in user.
// No manual input required.

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/result_storage_service.dart';

class StudentResultHomeScreen extends StatefulWidget {
  /// If provided (from StudentDashboard), skips the Firestore user lookup.
  final String? autoRegisterNumber;

  const StudentResultHomeScreen({
    super.key,
    this.autoRegisterNumber,
  });

  @override
  State<StudentResultHomeScreen> createState() =>
      _StudentResultHomeScreenState();
}

class _StudentResultHomeScreenState extends State<StudentResultHomeScreen> {
  final ResultStorageService _service = ResultStorageService();

  String _registerNumber = '';
  int? _selectedSemester;
  bool _isLoadingUser = true;
  bool _isSearching = false;
  Map<String, dynamic>? _semesterData;
  Map<String, dynamic>? _studentProfile;
  String? _errorMessage;

  final List<int> _semesters = List.generate(8, (i) => i + 1);

  @override
  void initState() {
    super.initState();
    _initRegisterNumber();
  }

  // ── Auto-resolve register number ─────────────────────────────────
  Future<void> _initRegisterNumber() async {
    // If passed directly from dashboard, use it immediately
    if (widget.autoRegisterNumber != null &&
        widget.autoRegisterNumber!.isNotEmpty) {
      setState(() {
        _registerNumber = widget.autoRegisterNumber!;
        _isLoadingUser = false;
      });
      return;
    }

    // Otherwise fetch from users/{uid}
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        setState(() => _isLoadingUser = false);
        return;
      }
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final regNo =
          (doc.data()?['registerNumber'] ?? doc.data()?['regNo'] ?? '')
              .toString();
      setState(() {
        _registerNumber = regNo;
        _isLoadingUser = false;
      });
    } catch (_) {
      setState(() => _isLoadingUser = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('My Result'), elevation: 0),
      body: _isLoadingUser
          ? const Center(child: CircularProgressIndicator())
          : _registerNumber.isEmpty
              ? _buildNoRegNoCard(theme)
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Register number info card ──────────────
                      _buildRegNoCard(theme),
                      const SizedBox(height: 16),

                      // ── Semester picker ────────────────────────
                      _buildSemesterPicker(theme),
                      const SizedBox(height: 20),

                      // ── Search button ──────────────────────────
                      ElevatedButton.icon(
                        onPressed: _isSearching || _selectedSemester == null
                            ? null
                            : _search,
                        icon: const Icon(Icons.search),
                        label: const Text('View Result'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 20),

                      if (_isSearching)
                        const Center(child: CircularProgressIndicator()),
                      if (!_isSearching && _errorMessage != null)
                        _buildErrorCard(theme),
                      if (!_isSearching && _semesterData != null)
                        _buildResultView(theme),
                    ],
                  ),
                ),
    );
  }

  Widget _buildNoRegNoCard(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.badge_outlined,
                size: 64, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text('Register number not found in your profile.',
                textAlign: TextAlign.center, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 8),
            Text('Please contact your teacher to link your register number.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  Widget _buildRegNoCard(ThemeData theme) {
    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(Icons.badge_rounded,
                color: theme.colorScheme.onPrimaryContainer),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your Register Number',
                    style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer)),
                Text(_registerNumber,
                    style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSemesterPicker(ThemeData theme) {
    return DropdownButtonFormField<int>(
      value: _selectedSemester,
      decoration: InputDecoration(
        labelText: 'Select Semester',
        prefixIcon: const Icon(Icons.school),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
      ),
      items: _semesters
          .map((s) => DropdownMenuItem(value: s, child: Text('Semester $s')))
          .toList(),
      onChanged: (val) => setState(() {
        _selectedSemester = val;
        _semesterData = null;
        _errorMessage = null;
      }),
    );
  }

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

  Widget _buildResultView(ThemeData theme) {
    final data = _semesterData!;
    final subjects = (data['subjects'] as List?) ?? [];
    final gpa = (data['semesterGPA'] as num?)?.toDouble() ?? 0.0;
    final cgpa = (data['cumulativeCGPA'] as num?)?.toDouble() ?? 0.0;
    final rank = (data['rank'] as num?)?.toInt() ?? 0;
    final total = (data['totalStudents'] as num?)?.toInt() ?? 0;
    final arrears = (data['arrears'] as num?)?.toInt() ?? 0;
    final resultStatus = (data['resultStatus'] as String?) ?? 'Available';

    final name = (_studentProfile?['name'] ?? '').toString();
    final dept = (_studentProfile?['department'] ?? '').toString();
    final batchVal = (_studentProfile?['batch'] ?? '').toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Student + GPA summary ──────────────────────────────
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name.isNotEmpty ? name : _registerNumber,
                              style: theme.textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                          if (dept.isNotEmpty)
                            Text('$_registerNumber • $dept • Batch $batchVal',
                                style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    if (rank > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Rank $rank${total > 0 ? '/$total' : ''}',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),

                // ── No Result banner ───────────────────────────
                if (resultStatus == 'No Result') ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline,
                            color: theme.colorScheme.error, size: 18),
                        const SizedBox(width: 8),
                        Text('Result Not Available for this semester',
                            style: TextStyle(
                                color: theme.colorScheme.error,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ] else ...[
                  const Divider(height: 20),
                  Row(
                    children: [
                      _statBox(theme, 'Sem GPA', gpa.toStringAsFixed(2)),
                      const SizedBox(width: 12),
                      _statBox(theme, 'CGPA', cgpa.toStringAsFixed(2)),
                      const SizedBox(width: 12),
                      _statBox(theme, 'Arrears', '$arrears'),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),

        // ── Subject table (only if result available) ───────────
        if (resultStatus != 'No Result' && subjects.isNotEmpty) ...[
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Subject-wise Results',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _subjectHeader(theme),
                  const Divider(height: 8),
                  ...subjects.map(
                      (s) => _subjectRow(theme, s as Map<String, dynamic>)),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _statBox(ThemeData theme, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                )),
            Text(label,
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _subjectHeader(ThemeData theme) {
    final style = theme.textTheme.labelSmall?.copyWith(
        fontWeight: FontWeight.bold, color: theme.colorScheme.onSurfaceVariant);
    return Row(children: [
      SizedBox(width: 70, child: Text('Code', style: style)),
      Expanded(child: Text('Subject', style: style)),
      SizedBox(
          width: 28,
          child: Text('Cr', style: style, textAlign: TextAlign.center)),
      SizedBox(
          width: 28,
          child: Text('Gr', style: style, textAlign: TextAlign.center)),
      SizedBox(
          width: 28,
          child: Text('GP', style: style, textAlign: TextAlign.center)),
    ]);
  }

  Widget _subjectRow(ThemeData theme, Map<String, dynamic> s) {
    final grade = (s['grade'] ?? '-').toString();
    final isFail = grade == 'F' || grade == 'Z';
    final isPractical = s['isPractical'] == true;

    final style = theme.textTheme.bodySmall?.copyWith(
      color: isFail ? theme.colorScheme.error : null,
      fontWeight: isFail ? FontWeight.w600 : null,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        SizedBox(
            width: 70,
            child: Text((s['subjectCode'] ?? '').toString(), style: style)),
        Expanded(
            child: Text(
          (s['subjectName'] ?? s['subjectCode'] ?? '').toString(),
          style: isPractical
              ? style?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: theme.colorScheme.onSurfaceVariant)
              : style,
        )),
        SizedBox(
            width: 28,
            child: Text(
              isPractical ? '-' : (s['credit'] ?? s['credits'] ?? 0).toString(),
              style: style,
              textAlign: TextAlign.center,
            )),
        SizedBox(
            width: 28,
            child: Text(grade, style: style, textAlign: TextAlign.center)),
        SizedBox(
            width: 28,
            child: Text(
              isPractical ? 'P' : (s['gradePoint'] ?? 0).toString(),
              style: style,
              textAlign: TextAlign.center,
            )),
      ]),
    );
  }

  Future<void> _search() async {
    if (_selectedSemester == null || _registerNumber.isEmpty) return;

    setState(() {
      _isSearching = true;
      _semesterData = null;
      _studentProfile = null;
      _errorMessage = null;
    });

    try {
      final sem = _selectedSemester!;
      final data = await _service.fetchSemesterData(_registerNumber, sem);
      final profile = await _service.fetchStudentProfile(_registerNumber);

      if (mounted) {
        setState(() {
          _isSearching = false;
          final resultStatus = (data['resultStatus'] as String?) ?? '';
          final subjects = data['subjects'] as List?;

          if (resultStatus.isEmpty && (subjects == null || subjects.isEmpty)) {
            _errorMessage = 'No result found for Semester $sem.\n'
                'Results may not have been uploaded yet.';
          } else {
            _semesterData = data;
            _studentProfile = profile;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearching = false;
          _errorMessage = 'Error fetching result: $e';
        });
      }
    }
  }
}
