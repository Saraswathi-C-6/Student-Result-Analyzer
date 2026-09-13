import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({super.key});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _regNoController = TextEditingController();
  final _emailController = TextEditingController();
  final _deptController = TextEditingController();
  final _batchController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _regNoController.dispose();
    _emailController.dispose();
    _deptController.dispose();
    _batchController.dispose();
    super.dispose();
  }

  Future<void> _saveStudent() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);
    try {
      // Check if reg no already exists
      final existing = await FirebaseFirestore.instance
          .collection('students')
          .where('regNo', isEqualTo: _regNoController.text.trim().toUpperCase())
          .get();

      if (existing.docs.isNotEmpty) {
        _showError('A student with this register number already exists!');
        setState(() => isLoading = false);
        return;
      }

      await FirebaseFirestore.instance.collection('students').add({
        'name': _nameController.text.trim(),
        'regNo': _regNoController.text.trim().toUpperCase(),
        'email': _emailController.text.trim(),
        'department': _deptController.text.trim(),
        'batch': _batchController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      _showSuccess('Student added successfully!');
      Navigator.pop(context);
    } catch (e) {
      _showError('Failed to add student. Please try again.');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.error_outline, color: Colors.white, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(msg)),
      ]),
      backgroundColor: const Color(0xFFE53935),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
        const SizedBox(width: 8),
        Text(msg),
      ]),
      backgroundColor: const Color(0xFF43A047),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
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
        title: const Text('Add Student',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.person_add_rounded,
                          color: Colors.white, size: 40),
                      SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('New Student',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                          Text('Fill in the student details below',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                _buildField('Full Name', 'Enter student full name',
                    Icons.person_outline, _nameController,
                    validator: (v) =>
                        v!.isEmpty ? 'Please enter student name' : null),

                _buildField('Register Number', 'e.g. 22CS001',
                    Icons.badge_outlined, _regNoController,
                    validator: (v) =>
                        v!.isEmpty ? 'Please enter register number' : null),

                _buildField('Email Address', 'student@college.com',
                    Icons.email_outlined, _emailController,
                    keyboardType: TextInputType.emailAddress, validator: (v) {
                  if (v!.isEmpty) return 'Please enter email';
                  if (!v.contains('@')) return 'Enter valid email';
                  return null;
                }),

                _buildField('Department', 'e.g. Computer Science',
                    Icons.school_outlined, _deptController,
                    validator: (v) =>
                        v!.isEmpty ? 'Please enter department' : null),

                _buildField('Batch / Year', 'e.g. 2022-2026',
                    Icons.calendar_today_outlined, _batchController,
                    validator: (v) => v!.isEmpty ? 'Please enter batch' : null),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _saveStudent,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      disabledBackgroundColor:
                          const Color(0xFF6C63FF).withOpacity(0.5),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5))
                        : const Text('Save Student',
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, String hint, IconData icon,
      TextEditingController controller,
      {TextInputType? keyboardType, String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Color(0xFF8B92B8),
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            style: const TextStyle(color: Colors.white, fontSize: 15),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle:
                  const TextStyle(color: Color(0xFF4A5180), fontSize: 14),
              prefixIcon: Icon(icon, color: const Color(0xFF6C63FF), size: 20),
              filled: true,
              fillColor: const Color(0xFF1A1F4E),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: Color(0xFFE53935), width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: Color(0xFFE53935), width: 2),
              ),
              errorStyle: const TextStyle(color: Color(0xFFFF6B6B)),
            ),
          ),
        ],
      ),
    );
  }
}
