// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'firebase_options.dart';
// import 'screens/auth_screen.dart';
// import 'screens/add_student_screen.dart';
// import 'screens/add_result_screen.dart';
// import 'screens/student_list_screen.dart';
// import 'screens/student_detail_screen.dart';
// import 'screens/student_dashboard.dart';
// import 'screens/teacher_dashboard.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   try {
//     await Firebase.initializeApp(
//       options: DefaultFirebaseOptions.currentPlatform,
//     );
//   } catch (e) {
//     // already initialized
//   }
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Student Result Analyzer',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6C63FF)),
//         useMaterial3: true,
//       ),
//       home: const SplashScreen(),
//       routes: {
//         '/login': (context) => const AuthScreen(),
//         '/teacher-dashboard': (context) => const TeacherDashboard(),
//         '/student-dashboard': (context) => const StudentDashboard(),
//         '/add-student': (context) => const AddStudentScreen(),
//         '/add-result': (context) => const AddResultScreen(),
//         '/student-list': (context) => const StudentListScreen(),
//         '/student-detail': (context) => const StudentDetailScreen(),
//       },
//     );
//   }
// }

// // ─── Splash Screen ─────────────────────────────────────────────────
// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _scaleAnim;
//   late Animation<double> _fadeAnim;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1200),
//     );
//     _scaleAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
//       CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
//     );
//     _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
//       CurvedAnimation(parent: _controller, curve: Curves.easeIn),
//     );
//     _controller.forward();
//     _checkAuth();
//   }

//   Future<void> _checkAuth() async {
//     await Future.delayed(const Duration(seconds: 2));
//     if (!mounted) return;
//     final user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       final doc = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(user.uid)
//           .get();
//       if (!mounted) return;
//       final role = doc.data()?['role'] ?? 'student';
//       if (role == 'teacher') {
//         Navigator.pushReplacementNamed(context, '/teacher-dashboard');
//       } else {
//         Navigator.pushReplacementNamed(context, '/student-dashboard');
//       }
//     } else {
//       Navigator.pushReplacementNamed(context, '/login');
//     }
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF0A0E27),
//       body: Center(
//         child: FadeTransition(
//           opacity: _fadeAnim,
//           child: ScaleTransition(
//             scale: _scaleAnim,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Container(
//                   width: 90,
//                   height: 90,
//                   decoration: BoxDecoration(
//                     gradient: const LinearGradient(
//                       colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)],
//                     ),
//                     borderRadius: BorderRadius.circular(28),
//                   ),
//                   child: const Icon(Icons.school_rounded,
//                       color: Colors.white, size: 48),
//                 ),
//                 const SizedBox(height: 24),
//                 const Text('Result Analyzer',
//                     style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 28,
//                         fontWeight: FontWeight.bold,
//                         letterSpacing: 1)),
//                 const SizedBox(height: 8),
//                 const Text('Student Performance System',
//                     style: TextStyle(color: Color(0xFF8B92B8), fontSize: 14)),
//                 const SizedBox(height: 48),
//                 const SizedBox(
//                   width: 28,
//                   height: 28,
//                   child: CircularProgressIndicator(
//                       color: Color(0xFF6C63FF), strokeWidth: 2.5),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:provider/provider.dart';
// import 'firebase_options.dart';
// import 'providers/theme_provider.dart';
// import 'screens/auth_screen.dart';
// import 'screens/teacher_dashboard.dart';
// import 'screens/student_dashboard.dart';
// import 'screens/add_student_screen.dart';
// import 'screens/add_result_screen.dart';
// import 'screens/student_list_screen.dart';
// import 'screens/student_detail_screen.dart';
// import 'utils/notification_service.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   try {
//     await Firebase.initializeApp(
//       options: DefaultFirebaseOptions.currentPlatform,
//     );
//   } catch (e) {
//     // already initialized
//   }
//   await NotificationService.initialize();
//   runApp(
//     ChangeNotifierProvider(
//       create: (_) => ThemeProvider(),
//       child: const MyApp(),
//     ),
//   );
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final themeProvider = Provider.of<ThemeProvider>(context);
//     return MaterialApp(
//       title: 'Student Result Analyzer',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeProvider.lightTheme,
//       darkTheme: ThemeProvider.darkTheme,
//       themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
//       home: const SplashScreen(),
//       routes: {
//         '/login': (context) => const AuthScreen(),
//         '/teacher-dashboard': (context) => const TeacherDashboard(),
//         '/student-dashboard': (context) => const StudentDashboard(),
//         '/add-student': (context) => const AddStudentScreen(),
//         '/add-result': (context) => const AddResultScreen(),
//         '/student-list': (context) => const StudentListScreen(),
//         '/student-detail': (context) => const StudentDetailScreen(),
//         '/analytics': (context) => const AnalyticsScreen(...),  // passed via arguments
//         '/pdf-report': (context) => const PDFReportScreen(...),  // passed via arguments
//         '/settings': (context) => const SettingsScreen(),
//       },
//     );
//   }
// }

// // ─── Splash Screen ──────────────────────────────────────────────────
// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _scaleAnim;
//   late Animation<double> _fadeAnim;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//         vsync: this, duration: const Duration(milliseconds: 1200));
//     _scaleAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
//         CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
//     _fadeAnim = Tween<double>(begin: 0, end: 1)
//         .animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
//     _controller.forward();
//     _checkAuth();
//   }

//   Future<void> _checkAuth() async {
//     await Future.delayed(const Duration(seconds: 2));
//     if (!mounted) return;
//     final user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       final doc = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(user.uid)
//           .get();
//       if (!mounted) return;
//       final role = doc.data()?['role'] ?? 'student';
//       Navigator.pushReplacementNamed(context,
//           role == 'teacher' ? '/teacher-dashboard' : '/student-dashboard');
//     } else {
//       Navigator.pushReplacementNamed(context, '/login');
//     }
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     return Scaffold(
//       backgroundColor:
//           isDark ? const Color(0xFF0A0E27) : const Color(0xFFF4F6FF),
//       body: Center(
//         child: FadeTransition(
//           opacity: _fadeAnim,
//           child: ScaleTransition(
//             scale: _scaleAnim,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Container(
//                   width: 90,
//                   height: 90,
//                   decoration: BoxDecoration(
//                     gradient: const LinearGradient(
//                         colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)]),
//                     borderRadius: BorderRadius.circular(28),
//                   ),
//                   child: const Icon(Icons.school_rounded,
//                       color: Colors.white, size: 48),
//                 ),
//                 const SizedBox(height: 24),
//                 Text('Result Analyzer',
//                     style: TextStyle(
//                         color: isDark ? Colors.white : const Color(0xFF2D3142),
//                         fontSize: 28,
//                         fontWeight: FontWeight.bold,
//                         letterSpacing: 1)),
//                 const SizedBox(height: 8),
//                 const Text('Student Performance System',
//                     style: TextStyle(color: Color(0xFF8B92B8), fontSize: 14)),
//                 const SizedBox(height: 48),
//                 const SizedBox(
//                   width: 28,
//                   height: 28,
//                   child: CircularProgressIndicator(
//                       color: Color(0xFF6C63FF), strokeWidth: 2.5),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/theme_provider.dart';
import 'screens/auth_screen.dart';
import 'screens/teacher_dashboard.dart';
import 'screens/student_dashboard.dart';
import 'screens/add_student_screen.dart';
import 'screens/add_result_screen.dart';
import 'screens/student_list_screen.dart';
import 'screens/student_detail_screen.dart';
import 'screens/settings_screen.dart';
import 'utils/notification_service.dart';
import 'screens/student_result_home_screen.dart';
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase already initialized: $e');
  }
  try {
    if (!kIsWeb) {
      await NotificationService().initialize();
    }
  } catch (_) {
    // Firebase Messaging not supported on web — skip silently
  }
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'Student Result Analyzer',
      debugShowCheckedModeBanner: false,
      theme: ThemeProvider.lightTheme,
      darkTheme: ThemeProvider.darkTheme,
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const AuthScreen(),
        '/teacher-dashboard': (context) => const TeacherDashboard(),
        '/student-dashboard': (context) => const StudentDashboard(),
        '/add-student': (context) => const AddStudentScreen(),
        '/add-result': (context) => const AddResultScreen(),
        '/student-list': (context) => const StudentListScreen(),
        // '/student-detail': (context) => const StudentDetailScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/student-result-home': (context) => const StudentResultHomeScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/student-detail') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) => StudentDetailScreen(
              studentId: args['studentId'],
              studentData: args['studentData'],
            ),
          );
        }
        return null;
      },
    );
  }
}

// ─── Splash Screen ───────────────────────────────────────────────────
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _scaleAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _fadeAnim = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _controller.forward();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (!mounted) return;
      final role = doc.data()?['role'] ?? 'student';
      Navigator.pushReplacementNamed(context,
          role == 'teacher' ? '/teacher-dashboard' : '/student-dashboard');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0A0E27) : const Color(0xFFF4F6FF),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)]),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Icon(Icons.school_rounded,
                      color: Colors.white, size: 48),
                ),
                const SizedBox(height: 24),
                Text(
                  'Result Analyzer',
                  style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF2D3142),
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1),
                ),
                const SizedBox(height: 8),
                const Text('Student Performance System',
                    style: TextStyle(color: Color(0xFF8B92B8), fontSize: 14)),
                const SizedBox(height: 48),
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                      color: Color(0xFF6C63FF), strokeWidth: 2.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
