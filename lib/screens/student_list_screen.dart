import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  final _searchController = TextEditingController();
  String searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _deleteStudent(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F4E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Student',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
            'This will delete the student and all their results. Are you sure?',
            style: TextStyle(color: Color(0xFF8B92B8))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFF8B92B8))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // Delete all results for this student
      final results = await FirebaseFirestore.instance
          .collection('results')
          .where('studentId', isEqualTo: id)
          .get();
      for (var doc in results.docs) {
        await doc.reference.delete();
      }
      // Delete student
      await FirebaseFirestore.instance.collection('students').doc(id).delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Student deleted successfully'),
            backgroundColor: const Color(0xFF43A047),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1F4E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('All Students',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          IconButton(
            icon:
                const Icon(Icons.person_add_rounded, color: Color(0xFF6C63FF)),
            onPressed: () => Navigator.pushNamed(context, '/add-student'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                onChanged: (v) => setState(() => searchQuery = v.toLowerCase()),
                decoration: InputDecoration(
                  hintText: 'Search by name or register no...',
                  hintStyle:
                      const TextStyle(color: Color(0xFF4A5180), fontSize: 14),
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: Color(0xFF6C63FF), size: 22),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded,
                              color: Color(0xFF8B92B8), size: 20),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => searchQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: const Color(0xFF1A1F4E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        const BorderSide(color: Color(0xFF2D3470), width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        const BorderSide(color: Color(0xFF2D3470), width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        const BorderSide(color: Color(0xFF6C63FF), width: 2),
                  ),
                ),
              ),
            ),

            // Student List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('students')
                    .orderBy('name')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: Color(0xFF6C63FF)));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return _buildEmptyState();
                  }

                  final allStudents = snapshot.data!.docs;
                  final filtered = allStudents.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final name = (data['name'] ?? '').toString().toLowerCase();
                    final regNo =
                        (data['regNo'] ?? '').toString().toLowerCase();
                    return name.contains(searchQuery) ||
                        regNo.contains(searchQuery);
                  }).toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.search_off_rounded,
                              color: Color(0xFF8B92B8), size: 60),
                          const SizedBox(height: 12),
                          Text(
                            'No results for "$searchQuery"',
                            style: const TextStyle(
                                color: Color(0xFF8B92B8), fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Text(
                              '${filtered.length} student${filtered.length != 1 ? 's' : ''}',
                              style: const TextStyle(
                                  color: Color(0xFF8B92B8), fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final doc = filtered[index];
                            final data = doc.data() as Map<String, dynamic>;
                            return _buildStudentCard(doc.id, data);
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add-student'),
        backgroundColor: const Color(0xFF6C63FF),
        child: const Icon(Icons.person_add_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildStudentCard(String id, Map<String, dynamic> data) {
    final name = data['name'] ?? 'Unknown';
    final regNo = data['regNo'] ?? '';
    final dept = data['department'] ?? '';
    final batch = data['batch'] ?? '';

    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        '/student-detail',
        arguments: {'studentId': id, 'studentData': data},
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1F4E),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: const Color(0xFF2D3470).withOpacity(0.5), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)]),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(regNo,
                      style: const TextStyle(
                          color: Color(0xFF6C63FF),
                          fontSize: 13,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text('$dept • $batch',
                      style: const TextStyle(
                          color: Color(0xFF8B92B8), fontSize: 12)),
                ],
              ),
            ),
            PopupMenuButton<String>(
              color: const Color(0xFF1A1F4E),
              icon:
                  const Icon(Icons.more_vert_rounded, color: Color(0xFF8B92B8)),
              onSelected: (v) {
                if (v == 'view') {
                  Navigator.pushNamed(context, '/student-detail',
                      arguments: {'studentId': id, 'studentData': data});
                } else if (v == 'delete') {
                  _deleteStudent(id);
                }
              },
              itemBuilder: (ctx) => [
                const PopupMenuItem(
                    value: 'view',
                    child: Row(children: [
                      Icon(Icons.visibility_outlined,
                          color: Color(0xFF6C63FF), size: 18),
                      SizedBox(width: 8),
                      Text('View Results',
                          style: TextStyle(color: Colors.white))
                    ])),
                const PopupMenuItem(
                    value: 'delete',
                    child: Row(children: [
                      Icon(Icons.delete_outline,
                          color: Color(0xFFE53935), size: 18),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Color(0xFFE53935)))
                    ])),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.people_outline_rounded,
              color: Color(0xFF8B92B8), size: 72),
          const SizedBox(height: 16),
          const Text('No Students Yet',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Add your first student to get started!',
              style: TextStyle(color: Color(0xFF8B92B8), fontSize: 14)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/add-student'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
            icon: const Icon(Icons.person_add_rounded, color: Colors.white),
            label: const Text('Add Student',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
