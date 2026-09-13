import '../utils/gpa_calculator.dart';

class PerformanceService {
  // ── GPA trend per semester ────────────────────────────────────────
  static List<Map<String, dynamic>> gpatrend(
      List<Map<String, dynamic>> allResults, List<int> completedSemesters) {
    return completedSemesters.map((sem) {
      final semResults = allResults.where((r) => r['semester'] == sem).toList();
      final gpa = GpaCalculator.calculateGPA(semResults);
      return {'semester': sem, 'gpa': gpa};
    }).toList();
  }

  // ── CGPA growth over semesters ────────────────────────────────────
  static List<Map<String, dynamic>> cgpaGrowth(
      List<Map<String, dynamic>> allResults, List<int> completedSemesters) {
    final growth = <Map<String, dynamic>>[];
    for (final sem in completedSemesters) {
      final resultsUpToSem =
          allResults.where((r) => (r['semester'] as int) <= sem).toList();
      final cgpa = GpaCalculator.calculateCGPA(resultsUpToSem);
      growth.add({'semester': sem, 'cgpa': cgpa});
    }
    return growth;
  }

  // ── Arrear history per semester ───────────────────────────────────
  static List<Map<String, dynamic>> arrearHistory(
      List<Map<String, dynamic>> allResults, List<int> completedSemesters) {
    return completedSemesters.map((sem) {
      final semResults = allResults.where((r) => r['semester'] == sem).toList();
      final arrears = semResults
          .where((r) => !GpaCalculator.isPassed(r['grade'] ?? 'F'))
          .length;
      return {'semester': sem, 'arrears': arrears};
    }).toList();
  }

  // ── Best semester ─────────────────────────────────────────────────
  static Map<String, dynamic> bestSemester(
      List<Map<String, dynamic>> allResults, List<int> completedSemesters) {
    if (completedSemesters.isEmpty) {
      return {'semester': 0, 'gpa': 0.0};
    }
    Map<String, dynamic> best = {'semester': 0, 'gpa': 0.0};
    for (final sem in completedSemesters) {
      final semResults = allResults.where((r) => r['semester'] == sem).toList();
      final gpa = GpaCalculator.calculateGPA(semResults);
      if (gpa > (best['gpa'] as double)) {
        best = {'semester': sem, 'gpa': gpa};
      }
    }
    return best;
  }

  // ── Improvement indicator (trend direction) ───────────────────────
  static String improvementStatus(
      List<Map<String, dynamic>> allResults, List<int> completedSemesters) {
    if (completedSemesters.length < 2) return 'Not enough data';
    final trend = gpatrend(allResults, completedSemesters);
    final last = (trend.last['gpa'] as double);
    final secondLast = (trend[trend.length - 2]['gpa'] as double);
    final diff = last - secondLast;
    if (diff > 0.3) return 'Significant Improvement ↑';
    if (diff > 0) return 'Slight Improvement ↑';
    if (diff == 0) return 'Stable →';
    if (diff > -0.3) return 'Slight Decline ↓';
    return 'Significant Decline ↓';
  }

  // ── Improvement color ─────────────────────────────────────────────
  static int improvementColor(String status) {
    if (status.contains('Significant Improvement')) return 0xFF43A047;
    if (status.contains('Slight Improvement')) return 0xFF4ECDC4;
    if (status.contains('Stable')) return 0xFFFFBE0B;
    if (status.contains('Slight Decline')) return 0xFFFF9800;
    return 0xFFE53935;
  }

  // ── Pass percentage for a student in a semester ───────────────────
  static double passPercentage(List<Map<String, dynamic>> semResults) {
    if (semResults.isEmpty) return 0.0;
    final passed = semResults
        .where((r) => GpaCalculator.isPassed(r['grade'] ?? 'F'))
        .length;
    return (passed / semResults.length) * 100;
  }
}
