import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/subject_master_service.dart';
import 'add_subject_page.dart';
import 'edit_subject_page.dart';

class SubjectManagementPage extends StatefulWidget {
  const SubjectManagementPage({super.key});
  @override
  State<SubjectManagementPage> createState() => _SubjectManagementPageState();
}

class _SubjectManagementPageState extends State<SubjectManagementPage> {
  final _service = SubjectMasterService();
  int? _filterSemester; // null = all semesters

  Future<void> _delete(String docId, String code) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Subject?'),
        content: Text(
            'Deleting "$code" may affect result display.\nStudent results will NOT be deleted.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm != true) return;
    final error = await _service.deleteSubject(docId);
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Subject deleted'),
          backgroundColor: Color(0xFFE53935)));
    }
  }

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
        title: Text('Subject Master',
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        iconTheme: IconThemeData(color: textColor),
        actions: [
          // Semester filter chip
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: DropdownButton<int?>(
              value: _filterSemester,
              dropdownColor: cardBg,
              underline: const SizedBox(),
              style: TextStyle(color: textColor, fontSize: 13),
              hint: Text('All Sem', style: TextStyle(color: sub, fontSize: 13)),
              items: [
                DropdownMenuItem<int?>(
                    value: null,
                    child: Text('All Sem', style: TextStyle(color: textColor))),
                ...List.generate(8, (i) => i + 1).map((s) => DropdownMenuItem<
                        int?>(
                    value: s,
                    child: Text('Sem $s', style: TextStyle(color: textColor)))),
              ],
              onChanged: (v) => setState(() => _filterSemester = v),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF6C63FF),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Subject', style: TextStyle(color: Colors.white)),
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const AddSubjectPage())),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _service.subjectsStream(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snap.hasData || snap.data!.docs.isEmpty) {
            return Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.book_outlined, size: 64, color: sub),
                    const SizedBox(height: 16),
                    Text('No subjects yet',
                        style: TextStyle(color: sub, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text('Tap + Add Subject to get started',
                        style: TextStyle(color: sub, fontSize: 13)),
                  ]),
            );
          }

          var docs = snap.data!.docs;
          // Apply semester filter
          if (_filterSemester != null) {
            docs = docs.where((d) {
              final data = d.data() as Map<String, dynamic>;
              return (data['semester'] as num?)?.toInt() == _filterSemester;
            }).toList();
          }

          // Group by semester for section headers
          final Map<int, List<QueryDocumentSnapshot>> bySem = {};
          for (final d in docs) {
            final data = d.data() as Map<String, dynamic>;
            final sem = (data['semester'] as num?)?.toInt() ?? 0;
            bySem.putIfAbsent(sem, () => []);
            bySem[sem]!.add(d);
          }
          final semesters = bySem.keys.toList()..sort();

          // Debug log
          debugPrint('Subject Master Loaded: ${docs.length} subjects');

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            children: [
              for (final sem in semesters) ...[
                // Semester header
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 8),
                  child: Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C63FF).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('Semester $sem',
                          style: const TextStyle(
                              color: Color(0xFF6C63FF),
                              fontWeight: FontWeight.bold,
                              fontSize: 13)),
                    ),
                    const SizedBox(width: 8),
                    Text('${bySem[sem]!.length} subjects',
                        style: TextStyle(color: sub, fontSize: 12)),
                  ]),
                ),
                // Subject cards
                for (final doc in bySem[sem]!) ...[
                  _SubjectCard(
                    docId: doc.id,
                    data: doc.data() as Map<String, dynamic>,
                    cardBg: cardBg,
                    textColor: textColor,
                    sub: sub,
                    onEdit: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => EditSubjectPage(
                                docId: doc.id,
                                data: doc.data() as Map<String, dynamic>))),
                    onDelete: () => _delete(
                        doc.id,
                        (doc.data() as Map<String, dynamic>)['subjectCode'] ??
                            ''),
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ],
          );
        },
      ),
    );
  }
}

class _SubjectCard extends StatelessWidget {
  final String docId;
  final Map<String, dynamic> data;
  final Color cardBg, textColor, sub;
  final VoidCallback onEdit, onDelete;

  const _SubjectCard({
    required this.docId,
    required this.data,
    required this.cardBg,
    required this.textColor,
    required this.sub,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final code = data['subjectCode'] ?? '';
    final name = data['subjectName'] ?? 'Unknown Subject';
    final dept = data['department'] ?? '';
    final credits = (data['credits'] as num?)?.toInt() ?? 0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(children: [
        // Code badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF6C63FF).withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(code,
              style: const TextStyle(
                  color: Color(0xFF6C63FF),
                  fontWeight: FontWeight.bold,
                  fontSize: 13)),
        ),
        const SizedBox(width: 12),
        // Name + dept + credits
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name,
                style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Row(children: [
              Icon(Icons.apartment_rounded, size: 12, color: sub),
              const SizedBox(width: 4),
              Text(dept, style: TextStyle(color: sub, fontSize: 11)),
              const SizedBox(width: 10),
              Icon(Icons.stars_rounded, size: 12, color: sub),
              const SizedBox(width: 4),
              Text('$credits Cr', style: TextStyle(color: sub, fontSize: 11)),
            ]),
          ]),
        ),
        // Edit
        IconButton(
          icon: const Icon(Icons.edit_rounded,
              color: Color(0xFF6C63FF), size: 20),
          onPressed: onEdit,
          tooltip: 'Edit',
        ),
        // Delete
        IconButton(
          icon: const Icon(Icons.delete_rounded,
              color: Color(0xFFE53935), size: 20),
          onPressed: onDelete,
          tooltip: 'Delete',
        ),
      ]),
    );
  }
}
