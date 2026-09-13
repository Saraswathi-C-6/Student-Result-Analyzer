// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class AuthScreen extends StatefulWidget {
//   const AuthScreen({super.key});

//   @override
//   State<AuthScreen> createState() => _AuthScreenState();
// }

// class _AuthScreenState extends State<AuthScreen>
//     with SingleTickerProviderStateMixin {
//   bool isLogin = true;
//   bool isLoading = false;
//   bool obscurePassword = true;
//   bool obscureConfirm = true;

//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _confirmController = TextEditingController();

//   String selectedRole = 'student';

//   late AnimationController _animController;
//   late Animation<double> _fadeAnim;
//   late Animation<Offset> _slideAnim;

//   @override
//   void initState() {
//     super.initState();
//     _animController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 600),
//     );
//     _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
//       CurvedAnimation(parent: _animController, curve: Curves.easeOut),
//     );
//     _slideAnim = Tween<Offset>(
//       begin: const Offset(0, 0.3),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
//     _animController.forward();
//   }

//   @override
//   void dispose() {
//     _animController.dispose();
//     _nameController.dispose();
//     _emailController.dispose();
//     _passwordController.dispose();
//     _confirmController.dispose();
//     super.dispose();
//   }

//   void _toggleMode() {
//     setState(() {
//       isLogin = !isLogin;
//       _formKey.currentState?.reset();
//       _nameController.clear();
//       _emailController.clear();
//       _passwordController.clear();
//       _confirmController.clear();
//     });
//     _animController.reset();
//     _animController.forward();
//   }

//   Future<void> _submit() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => isLoading = true);

//     try {
//       if (isLogin) {
//         // LOGIN
//         final credential =
//             await FirebaseAuth.instance.signInWithEmailAndPassword(
//           email: _emailController.text.trim(),
//           password: _passwordController.text.trim(),
//         );

//         // Get user role from Firestore
//         final doc = await FirebaseFirestore.instance
//             .collection('users')
//             .doc(credential.user!.uid)
//             .get();

//         if (!mounted) return;

//         if (doc.exists) {
//           final role = doc.data()?['role'] ?? 'student';
//           _navigateByRole(role);
//         } else {
//           _showError('User data not found. Please contact admin.');
//         }
//       } else {
//         // SIGNUP
//         if (_passwordController.text != _confirmController.text) {
//           _showError('Passwords do not match!');
//           setState(() => isLoading = false);
//           return;
//         }

//         final credential =
//             await FirebaseAuth.instance.createUserWithEmailAndPassword(
//           email: _emailController.text.trim(),
//           password: _passwordController.text.trim(),
//         );

//         // Save user data in Firestore
//         await FirebaseFirestore.instance
//             .collection('users')
//             .doc(credential.user!.uid)
//             .set({
//           'uid': credential.user!.uid,
//           'name': _nameController.text.trim(),
//           'email': _emailController.text.trim(),
//           'role': selectedRole,
//           'createdAt': FieldValue.serverTimestamp(),
//         });

//         if (!mounted) return;
//         _navigateByRole(selectedRole);
//       }
//     } on FirebaseAuthException catch (e) {
//       _showError(_getErrorMessage(e.code));
//     } catch (e) {
//       _showError('Something went wrong. Please try again.');
//     } finally {
//       if (mounted) setState(() => isLoading = false);
//     }
//   }

//   void _navigateByRole(String role) {
//     if (role == 'teacher') {
//       Navigator.pushReplacementNamed(context, '/teacher-dashboard');
//     } else {
//       Navigator.pushReplacementNamed(context, '/student-dashboard');
//     }
//   }

//   String _getErrorMessage(String code) {
//     switch (code) {
//       case 'user-not-found':
//         return 'No account found with this email.';
//       case 'wrong-password':
//         return 'Incorrect password. Please try again.';
//       case 'email-already-in-use':
//         return 'This email is already registered.';
//       case 'weak-password':
//         return 'Password must be at least 6 characters.';
//       case 'invalid-email':
//         return 'Please enter a valid email address.';
//       case 'too-many-requests':
//         return 'Too many attempts. Please try again later.';
//       case 'invalid-credential':
//         return 'Invalid email or password.';
//       default:
//         return 'An error occurred. Please try again.';
//     }
//   }

//   void _showError(String message) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             const Icon(Icons.error_outline, color: Colors.white, size: 20),
//             const SizedBox(width: 8),
//             Expanded(child: Text(message)),
//           ],
//         ),
//         backgroundColor: const Color(0xFFE53935),
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         margin: const EdgeInsets.all(16),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF0A0E27),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Container(
//             constraints: BoxConstraints(
//               minHeight: MediaQuery.of(context).size.height -
//                   MediaQuery.of(context).padding.top -
//                   MediaQuery.of(context).padding.bottom,
//             ),
//             child: Column(
//               children: [
//                 // TOP HEADER SECTION
//                 Container(
//                   width: double.infinity,
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
//                   decoration: const BoxDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                       colors: [
//                         Color(0xFF1A1F4E),
//                         Color(0xFF0A0E27),
//                       ],
//                     ),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Logo + App name
//                       Row(
//                         children: [
//                           Container(
//                             width: 52,
//                             height: 52,
//                             decoration: BoxDecoration(
//                               gradient: const LinearGradient(
//                                 colors: [
//                                   Color(0xFF6C63FF),
//                                   Color(0xFF4ECDC4),
//                                 ],
//                               ),
//                               borderRadius: BorderRadius.circular(16),
//                             ),
//                             child: const Icon(
//                               Icons.school_rounded,
//                               color: Colors.white,
//                               size: 28,
//                             ),
//                           ),
//                           const SizedBox(width: 14),
//                           const Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 'Result Analyzer',
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 20,
//                                   fontWeight: FontWeight.bold,
//                                   letterSpacing: 0.5,
//                                 ),
//                               ),
//                               Text(
//                                 'Student Performance System',
//                                 style: TextStyle(
//                                   color: Color(0xFF8B92B8),
//                                   fontSize: 12,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 36),
//                       Text(
//                         isLogin ? 'Welcome\nBack! 👋' : 'Create\nAccount ✨',
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 36,
//                           fontWeight: FontWeight.bold,
//                           height: 1.2,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         isLogin
//                             ? 'Sign in to continue to your dashboard'
//                             : 'Register to get started',
//                         style: const TextStyle(
//                           color: Color(0xFF8B92B8),
//                           fontSize: 15,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 // FORM SECTION
//                 FadeTransition(
//                   opacity: _fadeAnim,
//                   child: SlideTransition(
//                     position: _slideAnim,
//                     child: Container(
//                       width: double.infinity,
//                       padding: const EdgeInsets.all(24),
//                       decoration: const BoxDecoration(
//                         color: Color(0xFFF8F9FF),
//                         borderRadius: BorderRadius.only(
//                           topLeft: Radius.circular(32),
//                           topRight: Radius.circular(32),
//                         ),
//                       ),
//                       child: Form(
//                         key: _formKey,
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             const SizedBox(height: 8),

//                             // TAB SWITCHER
//                             Container(
//                               decoration: BoxDecoration(
//                                 color: const Color(0xFFEEF0F8),
//                                 borderRadius: BorderRadius.circular(16),
//                               ),
//                               padding: const EdgeInsets.all(4),
//                               child: Row(
//                                 children: [
//                                   _buildTab('Login', isLogin, () {
//                                     if (!isLogin) _toggleMode();
//                                   }),
//                                   _buildTab('Sign Up', !isLogin, () {
//                                     if (isLogin) _toggleMode();
//                                   }),
//                                 ],
//                               ),
//                             ),
//                             const SizedBox(height: 28),

//                             // NAME (signup only)
//                             if (!isLogin) ...[
//                               _buildLabel('Full Name'),
//                               const SizedBox(height: 8),
//                               _buildTextField(
//                                 controller: _nameController,
//                                 hint: 'Enter your full name',
//                                 icon: Icons.person_outline_rounded,
//                                 validator: (v) {
//                                   if (v == null || v.isEmpty) {
//                                     return 'Please enter your name';
//                                   }
//                                   return null;
//                                 },
//                               ),
//                               const SizedBox(height: 20),
//                             ],

//                             // EMAIL
//                             _buildLabel('Email Address'),
//                             const SizedBox(height: 8),
//                             _buildTextField(
//                               controller: _emailController,
//                               hint: 'Enter your email',
//                               icon: Icons.email_outlined,
//                               keyboardType: TextInputType.emailAddress,
//                               validator: (v) {
//                                 if (v == null || v.isEmpty) {
//                                   return 'Please enter your email';
//                                 }
//                                 if (!v.contains('@')) {
//                                   return 'Please enter a valid email';
//                                 }
//                                 return null;
//                               },
//                             ),
//                             const SizedBox(height: 20),

//                             // PASSWORD
//                             _buildLabel('Password'),
//                             const SizedBox(height: 8),
//                             _buildTextField(
//                               controller: _passwordController,
//                               hint: 'Enter your password',
//                               icon: Icons.lock_outline_rounded,
//                               obscure: obscurePassword,
//                               suffixIcon: IconButton(
//                                 icon: Icon(
//                                   obscurePassword
//                                       ? Icons.visibility_outlined
//                                       : Icons.visibility_off_outlined,
//                                   color: const Color(0xFF8B92B8),
//                                   size: 20,
//                                 ),
//                                 onPressed: () => setState(
//                                     () => obscurePassword = !obscurePassword),
//                               ),
//                               validator: (v) {
//                                 if (v == null || v.isEmpty) {
//                                   return 'Please enter your password';
//                                 }
//                                 if (v.length < 6) {
//                                   return 'Password must be at least 6 characters';
//                                 }
//                                 return null;
//                               },
//                             ),

//                             // CONFIRM PASSWORD (signup only)
//                             if (!isLogin) ...[
//                               const SizedBox(height: 20),
//                               _buildLabel('Confirm Password'),
//                               const SizedBox(height: 8),
//                               _buildTextField(
//                                 controller: _confirmController,
//                                 hint: 'Confirm your password',
//                                 icon: Icons.lock_outline_rounded,
//                                 obscure: obscureConfirm,
//                                 suffixIcon: IconButton(
//                                   icon: Icon(
//                                     obscureConfirm
//                                         ? Icons.visibility_outlined
//                                         : Icons.visibility_off_outlined,
//                                     color: const Color(0xFF8B92B8),
//                                     size: 20,
//                                   ),
//                                   onPressed: () => setState(
//                                       () => obscureConfirm = !obscureConfirm),
//                                 ),
//                                 validator: (v) {
//                                   if (v == null || v.isEmpty) {
//                                     return 'Please confirm your password';
//                                   }
//                                   if (v != _passwordController.text) {
//                                     return 'Passwords do not match';
//                                   }
//                                   return null;
//                                 },
//                               ),
//                               const SizedBox(height: 20),

//                               // ROLE SELECTOR
//                               _buildLabel('Register as'),
//                               const SizedBox(height: 8),
//                               Row(
//                                 children: [
//                                   _buildRoleCard(
//                                     'teacher',
//                                     'Teacher',
//                                     Icons.person_pin_rounded,
//                                     'Add & manage results',
//                                   ),
//                                   const SizedBox(width: 12),
//                                   _buildRoleCard(
//                                     'student',
//                                     'Student',
//                                     Icons.school_rounded,
//                                     'View your results',
//                                   ),
//                                 ],
//                               ),
//                             ],

//                             // FORGOT PASSWORD (login only)
//                             if (isLogin) ...[
//                               const SizedBox(height: 8),
//                               Align(
//                                 alignment: Alignment.centerRight,
//                                 child: TextButton(
//                                   onPressed: _forgotPassword,
//                                   style: TextButton.styleFrom(
//                                     padding: const EdgeInsets.symmetric(
//                                         horizontal: 4),
//                                   ),
//                                   child: const Text(
//                                     'Forgot Password?',
//                                     style: TextStyle(
//                                       color: Color(0xFF6C63FF),
//                                       fontWeight: FontWeight.w600,
//                                       fontSize: 13,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],

//                             const SizedBox(height: 28),

//                             // SUBMIT BUTTON
//                             SizedBox(
//                               width: double.infinity,
//                               height: 56,
//                               child: ElevatedButton(
//                                 onPressed: isLoading ? null : _submit,
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: const Color(0xFF6C63FF),
//                                   foregroundColor: Colors.white,
//                                   elevation: 0,
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(16),
//                                   ),
//                                   disabledBackgroundColor:
//                                       const Color(0xFF6C63FF).withOpacity(0.6),
//                                 ),
//                                 child: isLoading
//                                     ? const SizedBox(
//                                         width: 24,
//                                         height: 24,
//                                         child: CircularProgressIndicator(
//                                           color: Colors.white,
//                                           strokeWidth: 2.5,
//                                         ),
//                                       )
//                                     : Text(
//                                         isLogin ? 'Login' : 'Create Account',
//                                         style: const TextStyle(
//                                           fontSize: 17,
//                                           fontWeight: FontWeight.bold,
//                                           letterSpacing: 0.5,
//                                         ),
//                                       ),
//                               ),
//                             ),
//                             const SizedBox(height: 24),

//                             // SWITCH MODE TEXT
//                             Center(
//                               child: RichText(
//                                 text: TextSpan(
//                                   style: const TextStyle(
//                                     color: Color(0xFF8B92B8),
//                                     fontSize: 14,
//                                   ),
//                                   children: [
//                                     TextSpan(
//                                       text: isLogin
//                                           ? "Don't have an account? "
//                                           : 'Already have an account? ',
//                                     ),
//                                     WidgetSpan(
//                                       child: GestureDetector(
//                                         onTap: _toggleMode,
//                                         child: Text(
//                                           isLogin ? 'Sign Up' : 'Login',
//                                           style: const TextStyle(
//                                             color: Color(0xFF6C63FF),
//                                             fontWeight: FontWeight.bold,
//                                             fontSize: 14,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(height: 16),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTab(String label, bool active, VoidCallback onTap) {
//     return Expanded(
//       child: GestureDetector(
//         onTap: onTap,
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 250),
//           padding: const EdgeInsets.symmetric(vertical: 12),
//           decoration: BoxDecoration(
//             color: active ? Colors.white : Colors.transparent,
//             borderRadius: BorderRadius.circular(12),
//             boxShadow: active
//                 ? [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.08),
//                       blurRadius: 8,
//                       offset: const Offset(0, 2),
//                     ),
//                   ]
//                 : [],
//           ),
//           child: Text(
//             label,
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               color: active ? const Color(0xFF6C63FF) : const Color(0xFF8B92B8),
//               fontWeight: active ? FontWeight.bold : FontWeight.normal,
//               fontSize: 15,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildLabel(String text) {
//     return Text(
//       text,
//       style: const TextStyle(
//         color: Color(0xFF2D3142),
//         fontWeight: FontWeight.w600,
//         fontSize: 14,
//       ),
//     );
//   }

//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String hint,
//     required IconData icon,
//     bool obscure = false,
//     Widget? suffixIcon,
//     TextInputType? keyboardType,
//     String? Function(String?)? validator,
//   }) {
//     return TextFormField(
//       controller: controller,
//       obscureText: obscure,
//       keyboardType: keyboardType,
//       validator: validator,
//       style: const TextStyle(
//         color: Color(0xFF2D3142),
//         fontSize: 15,
//       ),
//       decoration: InputDecoration(
//         hintText: hint,
//         hintStyle: const TextStyle(
//           color: Color(0xFFB0B7D3),
//           fontSize: 14,
//         ),
//         prefixIcon: Icon(icon, color: const Color(0xFF8B92B8), size: 20),
//         suffixIcon: suffixIcon,
//         filled: true,
//         fillColor: Colors.white,
//         contentPadding: const EdgeInsets.symmetric(
//           horizontal: 16,
//           vertical: 16,
//         ),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(14),
//           borderSide: const BorderSide(
//             color: Color(0xFFE8EAF6),
//             width: 1.5,
//           ),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(14),
//           borderSide: const BorderSide(
//             color: Color(0xFFE8EAF6),
//             width: 1.5,
//           ),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(14),
//           borderSide: const BorderSide(
//             color: Color(0xFF6C63FF),
//             width: 2,
//           ),
//         ),
//         errorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(14),
//           borderSide: const BorderSide(
//             color: Color(0xFFE53935),
//             width: 1.5,
//           ),
//         ),
//         focusedErrorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(14),
//           borderSide: const BorderSide(
//             color: Color(0xFFE53935),
//             width: 2,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildRoleCard(
//       String role, String label, IconData icon, String subtitle) {
//     final isSelected = selectedRole == role;
//     return Expanded(
//       child: GestureDetector(
//         onTap: () => setState(() => selectedRole = role),
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 200),
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: isSelected
//                 ? const Color(0xFF6C63FF).withOpacity(0.08)
//                 : Colors.white,
//             borderRadius: BorderRadius.circular(16),
//             border: Border.all(
//               color: isSelected
//                   ? const Color(0xFF6C63FF)
//                   : const Color(0xFFE8EAF6),
//               width: isSelected ? 2 : 1.5,
//             ),
//           ),
//           child: Column(
//             children: [
//               Container(
//                 width: 44,
//                 height: 44,
//                 decoration: BoxDecoration(
//                   color: isSelected
//                       ? const Color(0xFF6C63FF)
//                       : const Color(0xFFEEF0F8),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Icon(
//                   icon,
//                   color: isSelected ? Colors.white : const Color(0xFF8B92B8),
//                   size: 22,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 label,
//                 style: TextStyle(
//                   color: isSelected
//                       ? const Color(0xFF6C63FF)
//                       : const Color(0xFF2D3142),
//                   fontWeight: FontWeight.bold,
//                   fontSize: 14,
//                 ),
//               ),
//               const SizedBox(height: 2),
//               Text(
//                 subtitle,
//                 style: const TextStyle(
//                   color: Color(0xFF8B92B8),
//                   fontSize: 11,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _forgotPassword() async {
//     if (_emailController.text.isEmpty) {
//       _showError('Please enter your email first');
//       return;
//     }
//     try {
//       await FirebaseAuth.instance.sendPasswordResetEmail(
//         email: _emailController.text.trim(),
//       );
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: const Row(
//             children: [
//               Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
//               SizedBox(width: 8),
//               Text('Password reset email sent!'),
//             ],
//           ),
//           backgroundColor: const Color(0xFF43A047),
//           behavior: SnackBarBehavior.floating,
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           margin: const EdgeInsets.all(16),
//         ),
//       );
//     } catch (e) {
//       _showError('Failed to send reset email. Check your email address.');
//     }
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class AuthScreen extends StatefulWidget {
//   const AuthScreen({super.key});

//   @override
//   State<AuthScreen> createState() => _AuthScreenState();
// }

// class _AuthScreenState extends State<AuthScreen>
//     with SingleTickerProviderStateMixin {
//   bool isLogin = true;
//   bool isLoading = false;
//   bool obscurePassword = true;
//   bool obscureConfirm = true;

//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _confirmController = TextEditingController();

//   // ── NEW: Student extra fields ──────────────────────────────────
//   final _registerNumberController = TextEditingController();
//   String _selectedDepartment = 'CSE';
//   String _selectedBatch = '2023-2027';

//   static const _departments = ['CSE', 'ISE', 'ECE', 'EEE'];
//   static const _batches = [
//     '2021-2025', '2022-2026', '2023-2027', '2024-2028', '2025-2029'
//   ];
//   // ───────────────────────────────────────────────────────────────

//   String selectedRole = 'student';

//   late AnimationController _animController;
//   late Animation<double> _fadeAnim;
//   late Animation<Offset> _slideAnim;

//   @override
//   void initState() {
//     super.initState();
//     _animController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 600),
//     );
//     _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
//       CurvedAnimation(parent: _animController, curve: Curves.easeOut),
//     );
//     _slideAnim = Tween<Offset>(
//       begin: const Offset(0, 0.3),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
//     _animController.forward();
//   }

//   @override
//   void dispose() {
//     _animController.dispose();
//     _nameController.dispose();
//     _emailController.dispose();
//     _passwordController.dispose();
//     _confirmController.dispose();
//     _registerNumberController.dispose(); // NEW
//     super.dispose();
//   }

//   void _toggleMode() {
//     setState(() {
//       isLogin = !isLogin;
//       _formKey.currentState?.reset();
//       _nameController.clear();
//       _emailController.clear();
//       _passwordController.clear();
//       _confirmController.clear();
//       _registerNumberController.clear(); // NEW
//       _selectedDepartment = 'CSE';       // NEW
//       _selectedBatch = '2023-2027';      // NEW
//     });
//     _animController.reset();
//     _animController.forward();
//   }

//   Future<void> _submit() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => isLoading = true);

//     try {
//       if (isLogin) {
//         // ── LOGIN (unchanged) ──────────────────────────────────
//         final credential =
//             await FirebaseAuth.instance.signInWithEmailAndPassword(
//           email: _emailController.text.trim(),
//           password: _passwordController.text.trim(),
//         );

//         final doc = await FirebaseFirestore.instance
//             .collection('users')
//             .doc(credential.user!.uid)
//             .get();

//         if (!mounted) return;

//         if (doc.exists) {
//           final role = doc.data()?['role'] ?? 'student';
//           _navigateByRole(role);
//         } else {
//           _showError('User data not found. Please contact admin.');
//         }
//       } else {
//         // ── SIGNUP ─────────────────────────────────────────────
//         if (_passwordController.text != _confirmController.text) {
//           _showError('Passwords do not match!');
//           setState(() => isLoading = false);
//           return;
//         }

//         final credential =
//             await FirebaseAuth.instance.createUserWithEmailAndPassword(
//           email: _emailController.text.trim(),
//           password: _passwordController.text.trim(),
//         );

//         // ── Build Firestore data based on role ─────────────────
//         final Map<String, dynamic> userData = {
//           'uid': credential.user!.uid,
//           'name': _nameController.text.trim(),
//           'email': _emailController.text.trim(),
//           'role': selectedRole,
//           'createdAt': FieldValue.serverTimestamp(),
//         };

//         // Student-only fields
//         if (selectedRole == 'student') {
//           userData['registerNumber'] =
//               _registerNumberController.text.trim().toUpperCase();
//           userData['department'] = _selectedDepartment;
//           userData['batch'] = _selectedBatch;
//         }

//         await FirebaseFirestore.instance
//             .collection('users')
//             .doc(credential.user!.uid)
//             .set(userData);

//         if (!mounted) return;
//         _navigateByRole(selectedRole);
//       }
//     } on FirebaseAuthException catch (e) {
//       _showError(_getErrorMessage(e.code));
//     } catch (e) {
//       _showError('Something went wrong. Please try again.');
//     } finally {
//       if (mounted) setState(() => isLoading = false);
//     }
//   }

//   void _navigateByRole(String role) {
//     if (role == 'teacher') {
//       Navigator.pushReplacementNamed(context, '/teacher-dashboard');
//     } else {
//       Navigator.pushReplacementNamed(context, '/student-dashboard');
//     }
//   }

//   String _getErrorMessage(String code) {
//     switch (code) {
//       case 'user-not-found':
//         return 'No account found with this email.';
//       case 'wrong-password':
//         return 'Incorrect password. Please try again.';
//       case 'email-already-in-use':
//         return 'This email is already registered.';
//       case 'weak-password':
//         return 'Password must be at least 6 characters.';
//       case 'invalid-email':
//         return 'Please enter a valid email address.';
//       case 'too-many-requests':
//         return 'Too many attempts. Please try again later.';
//       case 'invalid-credential':
//         return 'Invalid email or password.';
//       default:
//         return 'An error occurred. Please try again.';
//     }
//   }

//   void _showError(String message) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             const Icon(Icons.error_outline, color: Colors.white, size: 20),
//             const SizedBox(width: 8),
//             Expanded(child: Text(message)),
//           ],
//         ),
//         backgroundColor: const Color(0xFFE53935),
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         margin: const EdgeInsets.all(16),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF0A0E27),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Container(
//             constraints: BoxConstraints(
//               minHeight: MediaQuery.of(context).size.height -
//                   MediaQuery.of(context).padding.top -
//                   MediaQuery.of(context).padding.bottom,
//             ),
//             child: Column(
//               children: [
//                 // TOP HEADER SECTION (unchanged)
//                 Container(
//                   width: double.infinity,
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
//                   decoration: const BoxDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                       colors: [Color(0xFF1A1F4E), Color(0xFF0A0E27)],
//                     ),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Container(
//                             width: 52,
//                             height: 52,
//                             decoration: BoxDecoration(
//                               gradient: const LinearGradient(
//                                 colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)],
//                               ),
//                               borderRadius: BorderRadius.circular(16),
//                             ),
//                             child: const Icon(Icons.school_rounded,
//                                 color: Colors.white, size: 28),
//                           ),
//                           const SizedBox(width: 14),
//                           const Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text('Result Analyzer',
//                                   style: TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 20,
//                                       fontWeight: FontWeight.bold,
//                                       letterSpacing: 0.5)),
//                               Text('Student Performance System',
//                                   style: TextStyle(
//                                       color: Color(0xFF8B92B8), fontSize: 12)),
//                             ],
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 36),
//                       Text(
//                         isLogin ? 'Welcome\nBack! 👋' : 'Create\nAccount ✨',
//                         style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 36,
//                             fontWeight: FontWeight.bold,
//                             height: 1.2),
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         isLogin
//                             ? 'Sign in to continue to your dashboard'
//                             : 'Register to get started',
//                         style: const TextStyle(
//                             color: Color(0xFF8B92B8), fontSize: 15),
//                       ),
//                     ],
//                   ),
//                 ),

//                 // FORM SECTION
//                 FadeTransition(
//                   opacity: _fadeAnim,
//                   child: SlideTransition(
//                     position: _slideAnim,
//                     child: Container(
//                       width: double.infinity,
//                       padding: const EdgeInsets.all(24),
//                       decoration: const BoxDecoration(
//                         color: Color(0xFFF8F9FF),
//                         borderRadius: BorderRadius.only(
//                           topLeft: Radius.circular(32),
//                           topRight: Radius.circular(32),
//                         ),
//                       ),
//                       child: Form(
//                         key: _formKey,
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             const SizedBox(height: 8),

//                             // TAB SWITCHER (unchanged)
//                             Container(
//                               decoration: BoxDecoration(
//                                 color: const Color(0xFFEEF0F8),
//                                 borderRadius: BorderRadius.circular(16),
//                               ),
//                               padding: const EdgeInsets.all(4),
//                               child: Row(
//                                 children: [
//                                   _buildTab('Login', isLogin,
//                                       () { if (!isLogin) _toggleMode(); }),
//                                   _buildTab('Sign Up', !isLogin,
//                                       () { if (isLogin) _toggleMode(); }),
//                                 ],
//                               ),
//                             ),
//                             const SizedBox(height: 28),

//                             // NAME (signup only)
//                             if (!isLogin) ...[
//                               _buildLabel('Full Name'),
//                               const SizedBox(height: 8),
//                               _buildTextField(
//                                 controller: _nameController,
//                                 hint: 'Enter your full name',
//                                 icon: Icons.person_outline_rounded,
//                                 validator: (v) => (v == null || v.isEmpty)
//                                     ? 'Please enter your name'
//                                     : null,
//                               ),
//                               const SizedBox(height: 20),
//                             ],

//                             // EMAIL (unchanged)
//                             _buildLabel('Email Address'),
//                             const SizedBox(height: 8),
//                             _buildTextField(
//                               controller: _emailController,
//                               hint: 'Enter your email',
//                               icon: Icons.email_outlined,
//                               keyboardType: TextInputType.emailAddress,
//                               validator: (v) {
//                                 if (v == null || v.isEmpty) {
//                                   return 'Please enter your email';
//                                 }
//                                 if (!v.contains('@')) {
//                                   return 'Please enter a valid email';
//                                 }
//                                 return null;
//                               },
//                             ),
//                             const SizedBox(height: 20),

//                             // PASSWORD (unchanged)
//                             _buildLabel('Password'),
//                             const SizedBox(height: 8),
//                             _buildTextField(
//                               controller: _passwordController,
//                               hint: 'Enter your password',
//                               icon: Icons.lock_outline_rounded,
//                               obscure: obscurePassword,
//                               suffixIcon: IconButton(
//                                 icon: Icon(
//                                   obscurePassword
//                                       ? Icons.visibility_outlined
//                                       : Icons.visibility_off_outlined,
//                                   color: const Color(0xFF8B92B8),
//                                   size: 20,
//                                 ),
//                                 onPressed: () => setState(
//                                     () => obscurePassword = !obscurePassword),
//                               ),
//                               validator: (v) {
//                                 if (v == null || v.isEmpty) {
//                                   return 'Please enter your password';
//                                 }
//                                 if (v.length < 6) {
//                                   return 'Password must be at least 6 characters';
//                                 }
//                                 return null;
//                               },
//                             ),

//                             // CONFIRM PASSWORD + ROLE + STUDENT FIELDS (signup only)
//                             if (!isLogin) ...[
//                               const SizedBox(height: 20),
//                               _buildLabel('Confirm Password'),
//                               const SizedBox(height: 8),
//                               _buildTextField(
//                                 controller: _confirmController,
//                                 hint: 'Confirm your password',
//                                 icon: Icons.lock_outline_rounded,
//                                 obscure: obscureConfirm,
//                                 suffixIcon: IconButton(
//                                   icon: Icon(
//                                     obscureConfirm
//                                         ? Icons.visibility_outlined
//                                         : Icons.visibility_off_outlined,
//                                     color: const Color(0xFF8B92B8),
//                                     size: 20,
//                                   ),
//                                   onPressed: () => setState(
//                                       () => obscureConfirm = !obscureConfirm),
//                                 ),
//                                 validator: (v) {
//                                   if (v == null || v.isEmpty) {
//                                     return 'Please confirm your password';
//                                   }
//                                   if (v != _passwordController.text) {
//                                     return 'Passwords do not match';
//                                   }
//                                   return null;
//                                 },
//                               ),
//                               const SizedBox(height: 20),

//                               // ROLE SELECTOR (unchanged UI)
//                               _buildLabel('Register as'),
//                               const SizedBox(height: 8),
//                               Row(
//                                 children: [
//                                   _buildRoleCard('teacher', 'Teacher',
//                                       Icons.person_pin_rounded,
//                                       'Add & manage results'),
//                                   const SizedBox(width: 12),
//                                   _buildRoleCard('student', 'Student',
//                                       Icons.school_rounded, 'View your results'),
//                                 ],
//                               ),

//                               // ── STUDENT EXTRA FIELDS ──────────────────────
//                               if (selectedRole == 'student') ...[
//                                 const SizedBox(height: 20),

//                                 // Register Number
//                                 _buildLabel('Register Number'),
//                                 const SizedBox(height: 8),
//                                 _buildTextField(
//                                   controller: _registerNumberController,
//                                   hint: 'e.g. 22CS001',
//                                   icon: Icons.badge_outlined,
//                                   caps: true,
//                                   validator: (v) {
//                                     if (v == null || v.trim().isEmpty) {
//                                       return 'Register number is required';
//                                     }
//                                     return null;
//                                   },
//                                 ),
//                                 const SizedBox(height: 20),

//                                 // Department
//                                 _buildLabel('Department'),
//                                 const SizedBox(height: 8),
//                                 _buildDropdown(
//                                   value: _selectedDepartment,
//                                   items: _departments,
//                                   icon: Icons.apartment_outlined,
//                                   onChanged: (v) =>
//                                       setState(() => _selectedDepartment = v!),
//                                 ),
//                                 const SizedBox(height: 20),

//                                 // Batch
//                                 _buildLabel('Batch'),
//                                 const SizedBox(height: 8),
//                                 _buildDropdown(
//                                   value: _selectedBatch,
//                                   items: _batches,
//                                   icon: Icons.calendar_today_outlined,
//                                   onChanged: (v) =>
//                                       setState(() => _selectedBatch = v!),
//                                 ),
//                               ],
//                               // ─────────────────────────────────────────────
//                             ],

//                             // FORGOT PASSWORD (login only — unchanged)
//                             if (isLogin) ...[
//                               const SizedBox(height: 8),
//                               Align(
//                                 alignment: Alignment.centerRight,
//                                 child: TextButton(
//                                   onPressed: _forgotPassword,
//                                   style: TextButton.styleFrom(
//                                       padding: const EdgeInsets.symmetric(
//                                           horizontal: 4)),
//                                   child: const Text('Forgot Password?',
//                                       style: TextStyle(
//                                           color: Color(0xFF6C63FF),
//                                           fontWeight: FontWeight.w600,
//                                           fontSize: 13)),
//                                 ),
//                               ),
//                             ],

//                             const SizedBox(height: 28),

//                             // SUBMIT BUTTON (unchanged)
//                             SizedBox(
//                               width: double.infinity,
//                               height: 56,
//                               child: ElevatedButton(
//                                 onPressed: isLoading ? null : _submit,
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: const Color(0xFF6C63FF),
//                                   foregroundColor: Colors.white,
//                                   elevation: 0,
//                                   shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(16)),
//                                   disabledBackgroundColor:
//                                       const Color(0xFF6C63FF).withOpacity(0.6),
//                                 ),
//                                 child: isLoading
//                                     ? const SizedBox(
//                                         width: 24,
//                                         height: 24,
//                                         child: CircularProgressIndicator(
//                                             color: Colors.white,
//                                             strokeWidth: 2.5),
//                                       )
//                                     : Text(
//                                         isLogin ? 'Login' : 'Create Account',
//                                         style: const TextStyle(
//                                             fontSize: 17,
//                                             fontWeight: FontWeight.bold,
//                                             letterSpacing: 0.5),
//                                       ),
//                               ),
//                             ),
//                             const SizedBox(height: 24),

//                             // SWITCH MODE TEXT (unchanged)
//                             Center(
//                               child: RichText(
//                                 text: TextSpan(
//                                   style: const TextStyle(
//                                       color: Color(0xFF8B92B8), fontSize: 14),
//                                   children: [
//                                     TextSpan(
//                                       text: isLogin
//                                           ? "Don't have an account? "
//                                           : 'Already have an account? ',
//                                     ),
//                                     WidgetSpan(
//                                       child: GestureDetector(
//                                         onTap: _toggleMode,
//                                         child: Text(
//                                           isLogin ? 'Sign Up' : 'Login',
//                                           style: const TextStyle(
//                                               color: Color(0xFF6C63FF),
//                                               fontWeight: FontWeight.bold,
//                                               fontSize: 14),
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(height: 16),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // ── Widgets (unchanged originals kept, new ones added below) ────

//   Widget _buildTab(String label, bool active, VoidCallback onTap) {
//     return Expanded(
//       child: GestureDetector(
//         onTap: onTap,
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 250),
//           padding: const EdgeInsets.symmetric(vertical: 12),
//           decoration: BoxDecoration(
//             color: active ? Colors.white : Colors.transparent,
//             borderRadius: BorderRadius.circular(12),
//             boxShadow: active
//                 ? [BoxShadow(
//                     color: Colors.black.withOpacity(0.08),
//                     blurRadius: 8,
//                     offset: const Offset(0, 2))]
//                 : [],
//           ),
//           child: Text(label,
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                   color: active
//                       ? const Color(0xFF6C63FF)
//                       : const Color(0xFF8B92B8),
//                   fontWeight:
//                       active ? FontWeight.bold : FontWeight.normal,
//                   fontSize: 15)),
//         ),
//       ),
//     );
//   }

//   Widget _buildLabel(String text) {
//     return Text(text,
//         style: const TextStyle(
//             color: Color(0xFF2D3142),
//             fontWeight: FontWeight.w600,
//             fontSize: 14));
//   }

//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String hint,
//     required IconData icon,
//     bool obscure = false,
//     bool caps = false,
//     Widget? suffixIcon,
//     TextInputType? keyboardType,
//     String? Function(String?)? validator,
//   }) {
//     return TextFormField(
//       controller: controller,
//       obscureText: obscure,
//       keyboardType: keyboardType,
//       validator: validator,
//       textCapitalization:
//           caps ? TextCapitalization.characters : TextCapitalization.none,
//       style: const TextStyle(color: Color(0xFF2D3142), fontSize: 15),
//       decoration: InputDecoration(
//         hintText: hint,
//         hintStyle: const TextStyle(color: Color(0xFFB0B7D3), fontSize: 14),
//         prefixIcon: Icon(icon, color: const Color(0xFF8B92B8), size: 20),
//         suffixIcon: suffixIcon,
//         filled: true,
//         fillColor: Colors.white,
//         contentPadding:
//             const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//         border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(14),
//             borderSide:
//                 const BorderSide(color: Color(0xFFE8EAF6), width: 1.5)),
//         enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(14),
//             borderSide:
//                 const BorderSide(color: Color(0xFFE8EAF6), width: 1.5)),
//         focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(14),
//             borderSide:
//                 const BorderSide(color: Color(0xFF6C63FF), width: 2)),
//         errorBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(14),
//             borderSide:
//                 const BorderSide(color: Color(0xFFE53935), width: 1.5)),
//         focusedErrorBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(14),
//             borderSide:
//                 const BorderSide(color: Color(0xFFE53935), width: 2)),
//       ),
//     );
//   }

//   // ── NEW: Dropdown field matching existing text field style ───────
//   Widget _buildDropdown({
//     required String value,
//     required List<String> items,
//     required IconData icon,
//     required void Function(String?) onChanged,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         border: const BorderSide(color: Color(0xFFE8EAF6), width: 1.5)
//             .toBoxDecoration(BorderRadius.circular(14)),
//       ),
//       child: DropdownButtonFormField<String>(
//         value: value,
//         decoration: InputDecoration(
//           prefixIcon: Icon(icon, color: const Color(0xFF8B92B8), size: 20),
//           filled: true,
//           fillColor: Colors.white,
//           contentPadding:
//               const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//           border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(14),
//               borderSide:
//                   const BorderSide(color: Color(0xFFE8EAF6), width: 1.5)),
//           enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(14),
//               borderSide:
//                   const BorderSide(color: Color(0xFFE8EAF6), width: 1.5)),
//           focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(14),
//               borderSide:
//                   const BorderSide(color: Color(0xFF6C63FF), width: 2)),
//         ),
//         dropdownColor: Colors.white,
//         style: const TextStyle(color: Color(0xFF2D3142), fontSize: 15),
//         icon: const Icon(Icons.keyboard_arrow_down_rounded,
//             color: Color(0xFF8B92B8)),
//         items: items
//             .map((e) => DropdownMenuItem(value: e, child: Text(e)))
//             .toList(),
//         onChanged: onChanged,
//       ),
//     );
//   }

//   Widget _buildRoleCard(
//       String role, String label, IconData icon, String subtitle) {
//     final isSelected = selectedRole == role;
//     return Expanded(
//       child: GestureDetector(
//         onTap: () => setState(() {
//           selectedRole = role;
//           // Reset student fields when switching to teacher
//           if (role == 'teacher') {
//             _registerNumberController.clear();
//             _selectedDepartment = 'CSE';
//             _selectedBatch = '2023-2027';
//           }
//         }),
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 200),
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: isSelected
//                 ? const Color(0xFF6C63FF).withOpacity(0.08)
//                 : Colors.white,
//             borderRadius: BorderRadius.circular(16),
//             border: Border.all(
//               color: isSelected
//                   ? const Color(0xFF6C63FF)
//                   : const Color(0xFFE8EAF6),
//               width: isSelected ? 2 : 1.5,
//             ),
//           ),
//           child: Column(
//             children: [
//               Container(
//                 width: 44,
//                 height: 44,
//                 decoration: BoxDecoration(
//                   color: isSelected
//                       ? const Color(0xFF6C63FF)
//                       : const Color(0xFFEEF0F8),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Icon(icon,
//                     color: isSelected ? Colors.white : const Color(0xFF8B92B8),
//                     size: 22),
//               ),
//               const SizedBox(height: 8),
//               Text(label,
//                   style: TextStyle(
//                       color: isSelected
//                           ? const Color(0xFF6C63FF)
//                           : const Color(0xFF2D3142),
//                       fontWeight: FontWeight.bold,
//                       fontSize: 14)),
//               const SizedBox(height: 2),
//               Text(subtitle,
//                   style: const TextStyle(
//                       color: Color(0xFF8B92B8), fontSize: 11),
//                   textAlign: TextAlign.center),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _forgotPassword() async {
//     if (_emailController.text.isEmpty) {
//       _showError('Please enter your email first');
//       return;
//     }
//     try {
//       await FirebaseAuth.instance.sendPasswordResetEmail(
//           email: _emailController.text.trim());
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: const Row(
//             children: [
//               Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
//               SizedBox(width: 8),
//               Text('Password reset email sent!'),
//             ],
//           ),
//           backgroundColor: const Color(0xFF43A047),
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12)),
//           margin: const EdgeInsets.all(16),
//         ),
//       );
//     } catch (e) {
//       _showError('Failed to send reset email. Check your email address.');
//     }
//   }
// }

// // ── Helper extension (avoids duplicate border code) ─────────────────
// extension _BorderSideBox on BorderSide {
//   BoxDecoration toBoxDecoration(BorderRadius radius) => BoxDecoration(
//         borderRadius: radius,
//         border: Border.fromBorderSide(this),
//       );
// }

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  bool isLogin = true;
  bool isLoading = false;
  bool obscurePassword = true;
  bool obscureConfirm = true;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  String selectedRole = 'student';
  String _department = 'CSE';
  String _batch = '2023-2027';
  final _registerController = TextEditingController();

  static const _departments = ['CSE', 'ISE', 'ECE', 'EEE'];
  static const _batches = [
    '2022-2026',
    '2023-2027',
    '2024-2028',
    '2025-2029',
  ];

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _registerController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      isLogin = !isLogin;
      _formKey.currentState?.reset();
      _nameController.clear();
      _emailController.clear();
      _passwordController.clear();
      _confirmController.clear();
      _registerController.clear();
      _department = 'CSE';
      _batch = '2023-2027';
    });
    _animController.reset();
    _animController.forward();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      if (isLogin) {
        // LOGIN — unchanged
        final credential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(credential.user!.uid)
            .get();

        if (!mounted) return;

        if (doc.exists) {
          final role = doc.data()?['role'] ?? 'student';
          _navigateByRole(role);
        } else {
          _showError('User data not found. Please contact admin.');
        }
      } else {
        // SIGNUP
        if (_passwordController.text != _confirmController.text) {
          _showError('Passwords do not match!');
          setState(() => isLoading = false);
          return;
        }

        final credential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Build Firestore user data
        final userData = <String, dynamic>{
          'uid': credential.user!.uid,
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'role': selectedRole,
          'createdAt': FieldValue.serverTimestamp(),
        };

        // Add student-specific fields only for student role
        if (selectedRole == 'student') {
          userData['registerNumber'] = _registerController.text.trim();
          userData['department'] = _department;
          userData['batch'] = _batch;
        }

        await FirebaseFirestore.instance
            .collection('users')
            .doc(credential.user!.uid)
            .set(userData);

        if (!mounted) return;
        _navigateByRole(selectedRole);
      }
    } on FirebaseAuthException catch (e) {
      _showError(_getErrorMessage(e.code));
    } catch (e) {
      _showError('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _navigateByRole(String role) {
    if (role == 'teacher') {
      Navigator.pushReplacementNamed(context, '/teacher-dashboard');
    } else {
      Navigator.pushReplacementNamed(context, '/student-dashboard');
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFFE53935),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: Column(
              children: [
                // TOP HEADER SECTION
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1A1F4E), Color(0xFF0A0E27)],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.school_rounded,
                                color: Colors.white, size: 28),
                          ),
                          const SizedBox(width: 14),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Result Analyzer',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5)),
                              Text('Student Performance System',
                                  style: TextStyle(
                                      color: Color(0xFF8B92B8), fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 36),
                      Text(
                        isLogin ? 'Welcome\nBack! 👋' : 'Create\nAccount ✨',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            height: 1.2),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isLogin
                            ? 'Sign in to continue to your dashboard'
                            : 'Register to get started',
                        style: const TextStyle(
                            color: Color(0xFF8B92B8), fontSize: 15),
                      ),
                    ],
                  ),
                ),

                // FORM SECTION
                FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF8F9FF),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(32),
                          topRight: Radius.circular(32),
                        ),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),

                            // TAB SWITCHER
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEF0F8),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.all(4),
                              child: Row(
                                children: [
                                  _buildTab('Login', isLogin, () {
                                    if (!isLogin) _toggleMode();
                                  }),
                                  _buildTab('Sign Up', !isLogin, () {
                                    if (isLogin) _toggleMode();
                                  }),
                                ],
                              ),
                            ),
                            const SizedBox(height: 28),

                            // NAME (signup only)
                            if (!isLogin) ...[
                              _buildLabel('Full Name'),
                              const SizedBox(height: 8),
                              _buildTextField(
                                controller: _nameController,
                                hint: 'Enter your full name',
                                icon: Icons.person_outline_rounded,
                                validator: (v) => (v == null || v.isEmpty)
                                    ? 'Please enter your name'
                                    : null,
                              ),
                              const SizedBox(height: 20),
                            ],

                            // EMAIL
                            _buildLabel('Email Address'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: _emailController,
                              hint: 'Enter your email',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!v.contains('@')) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            // PASSWORD
                            _buildLabel('Password'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: _passwordController,
                              hint: 'Enter your password',
                              icon: Icons.lock_outline_rounded,
                              obscure: obscurePassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: const Color(0xFF8B92B8),
                                  size: 20,
                                ),
                                onPressed: () => setState(
                                    () => obscurePassword = !obscurePassword),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Please enter your password';
                                }
                                if (v.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),

                            // SIGNUP-ONLY FIELDS
                            if (!isLogin) ...[
                              const SizedBox(height: 20),

                              // CONFIRM PASSWORD
                              _buildLabel('Confirm Password'),
                              const SizedBox(height: 8),
                              _buildTextField(
                                controller: _confirmController,
                                hint: 'Confirm your password',
                                icon: Icons.lock_outline_rounded,
                                obscure: obscureConfirm,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    obscureConfirm
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: const Color(0xFF8B92B8),
                                    size: 20,
                                  ),
                                  onPressed: () => setState(
                                      () => obscureConfirm = !obscureConfirm),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Please confirm your password';
                                  }
                                  if (v != _passwordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),

                              // ROLE SELECTOR
                              _buildLabel('Register as'),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  _buildRoleCard(
                                      'teacher',
                                      'Teacher',
                                      Icons.person_pin_rounded,
                                      'Add & manage results'),
                                  const SizedBox(width: 12),
                                  _buildRoleCard(
                                      'student',
                                      'Student',
                                      Icons.school_rounded,
                                      'View your results'),
                                ],
                              ),

                              // STUDENT EXTRA FIELDS
                              if (selectedRole == 'student') ...[
                                const SizedBox(height: 20),
                                _buildLabel('Register Number'),
                                const SizedBox(height: 8),
                                _buildTextField(
                                  controller: _registerController,
                                  hint: 'e.g. 22CS001',
                                  icon: Icons.badge_outlined,
                                  validator: (v) {
                                    if (selectedRole != 'student') return null;
                                    if (v == null || v.trim().isEmpty) {
                                      return 'Register number is required';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),
                                _buildLabel('Department'),
                                const SizedBox(height: 8),
                                _buildDropdown(
                                  value: _department,
                                  items: _departments,
                                  icon: Icons.account_balance_outlined,
                                  onChanged: (v) =>
                                      setState(() => _department = v!),
                                ),
                                const SizedBox(height: 20),
                                _buildLabel('Batch'),
                                const SizedBox(height: 8),
                                _buildDropdown(
                                  value: _batch,
                                  items: _batches,
                                  icon: Icons.calendar_today_outlined,
                                  onChanged: (v) => setState(() => _batch = v!),
                                ),
                              ],
                            ],

                            // FORGOT PASSWORD (login only)
                            if (isLogin) ...[
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: _forgotPassword,
                                  style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4)),
                                  child: const Text('Forgot Password?',
                                      style: TextStyle(
                                          color: Color(0xFF6C63FF),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13)),
                                ),
                              ),
                            ],

                            const SizedBox(height: 28),

                            // SUBMIT BUTTON
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: isLoading ? null : _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6C63FF),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16)),
                                  disabledBackgroundColor:
                                      const Color(0xFF6C63FF).withOpacity(0.6),
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5),
                                      )
                                    : Text(
                                        isLogin ? 'Login' : 'Create Account',
                                        style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // SWITCH MODE TEXT
                            Center(
                              child: RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                      color: Color(0xFF8B92B8), fontSize: 14),
                                  children: [
                                    TextSpan(
                                      text: isLogin
                                          ? "Don't have an account? "
                                          : 'Already have an account? ',
                                    ),
                                    WidgetSpan(
                                      child: GestureDetector(
                                        onTap: _toggleMode,
                                        child: Text(
                                          isLogin ? 'Sign Up' : 'Login',
                                          style: const TextStyle(
                                              color: Color(0xFF6C63FF),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: active
                ? [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2))
                  ]
                : [],
          ),
          child: Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: active
                      ? const Color(0xFF6C63FF)
                      : const Color(0xFF8B92B8),
                  fontWeight: active ? FontWeight.bold : FontWeight.normal,
                  fontSize: 15)),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text,
        style: const TextStyle(
            color: Color(0xFF2D3142),
            fontWeight: FontWeight.w600,
            fontSize: 14));
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Color(0xFF2D3142), fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFB0B7D3), fontSize: 14),
        prefixIcon: Icon(icon, color: const Color(0xFF8B92B8), size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE8EAF6), width: 1.5)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE8EAF6), width: 1.5)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE53935), width: 1.5)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE53935), width: 2)),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required IconData icon,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFF8B92B8), size: 20),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE8EAF6), width: 1.5)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE8EAF6), width: 1.5)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2)),
      ),
      dropdownColor: Colors.white,
      style: const TextStyle(color: Color(0xFF2D3142), fontSize: 15),
      icon: const Icon(Icons.keyboard_arrow_down_rounded,
          color: Color(0xFF8B92B8)),
      items:
          items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildRoleCard(
      String role, String label, IconData icon, String subtitle) {
    final isSelected = selectedRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedRole = role),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF6C63FF).withOpacity(0.08)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF6C63FF)
                  : const Color(0xFFE8EAF6),
              width: isSelected ? 2 : 1.5,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF6C63FF)
                      : const Color(0xFFEEF0F8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon,
                    color: isSelected ? Colors.white : const Color(0xFF8B92B8),
                    size: 22),
              ),
              const SizedBox(height: 8),
              Text(label,
                  style: TextStyle(
                      color: isSelected
                          ? const Color(0xFF6C63FF)
                          : const Color(0xFF2D3142),
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
              const SizedBox(height: 2),
              Text(subtitle,
                  style:
                      const TextStyle(color: Color(0xFF8B92B8), fontSize: 11),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  void _forgotPassword() async {
    if (_emailController.text.isEmpty) {
      _showError('Please enter your email first');
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('Password reset email sent!'),
            ],
          ),
          backgroundColor: const Color(0xFF43A047),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    } catch (e) {
      _showError('Failed to send reset email. Check your email address.');
    }
  }
}
