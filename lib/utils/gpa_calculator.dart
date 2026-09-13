//import 'package:flutter/material.dart' show Color;

class GpaCalculator {
  /// Grade to Grade Point: S=10,A=9,B=8,C=7,D=6,E=5,F=0
  static int gradeToPoint(String grade) {
    const map = {'S': 10, 'A': 9, 'B': 8, 'C': 7, 'D': 6, 'E': 5, 'F': 0};
    return map[grade.toUpperCase()] ?? 0;
  }

  /// Get letter grade from numeric mark (0-100)
  static String getGrade(double mark) {
    if (mark >= 90) return 'S';
    if (mark >= 80) return 'A';
    if (mark >= 70) return 'B';
    if (mark >= 60) return 'C';
    if (mark >= 50) return 'D';
    if (mark >= 40) return 'E';
    return 'F';
  }

  /// Get grade point from numeric mark (0-100)
  static double getGradePoint(double mark) {
    if (mark >= 90) return 10.0;
    if (mark >= 80) return 9.0;
    if (mark >= 70) return 8.0;
    if (mark >= 60) return 7.0;
    if (mark >= 50) return 6.0;
    if (mark >= 40) return 5.0;
    return 0.0;
  }

  /// GPA for a semester: Σ(Ci × GPi) / Σ(Ci)
  static double calculateGPA(List<Map<String, dynamic>> semesterResults) {
    double totalWeighted = 0;
    double totalCredits = 0;
    for (var r in semesterResults) {
      final credits = (r['credits'] as num).toDouble();
      final gradePoint = (r['gradePoint'] as num).toDouble();
      totalWeighted += credits * gradePoint;
      totalCredits += credits;
    }
    if (totalCredits == 0) return 0.0;
    return totalWeighted / totalCredits;
  }

  /// CGPA across all semesters: Σ(Ci × GPi) / Σ(Ci)
  static double calculateCGPA(List<Map<String, dynamic>> allResults) {
    double totalWeighted = 0;
    double totalCredits = 0;
    for (var r in allResults) {
      final credits = (r['credits'] as num).toDouble();
      final gradePoint = (r['gradePoint'] as num).toDouble();
      totalWeighted += credits * gradePoint;
      totalCredits += credits;
    }
    if (totalCredits == 0) return 0.0;
    return totalWeighted / totalCredits;
  }

  /// Total credits earned (only passed subjects)
  static double totalCreditsEarned(List<Map<String, dynamic>> allResults) {
    return allResults.fold(0.0, (sum, r) {
      final grade = r['grade'] ?? 'F';
      if (isPassed(grade)) {
        return sum + (r['credits'] as num).toDouble();
      }
      return sum;
    });
  }

  /// Pass/Fail — F grade means failed
  static bool isPassed(String grade) => grade.toUpperCase() != 'F';

  /// Classification based on CGPA
  static String getClassification(double cgpa) {
    if (cgpa >= 9.0) return 'Outstanding';
    if (cgpa >= 8.0) return 'Excellent';
    if (cgpa >= 7.0) return 'Very Good';
    if (cgpa >= 6.0) return 'Good';
    if (cgpa >= 5.0) return 'Average';
    return 'Fail';
  }

  /// Grade color as int (use Color(GpaCalculator.gradeColor(grade)))
  static int gradeColor(String grade) {
    switch (grade.toUpperCase()) {
      case 'S':
        return 0xFF6C63FF;
      case 'A':
        return 0xFF4ECDC4;
      case 'B':
        return 0xFF43A047;
      case 'C':
        return 0xFFFFBE0B;
      case 'D':
        return 0xFFFF9800;
      case 'E':
        return 0xFFFF6B6B;
      default:
        return 0xFFE53935; // F
    }
  }
}
