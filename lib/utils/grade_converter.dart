// utils/grade_converter.dart
// Grade to Grade Point conversion utility

class GradeConverter {
  static const Map<String, int> _gradePointMap = {
    'S': 10,
    'A': 9,
    'B': 8,
    'C': 7,
    'D': 6,
    'E': 5,
    'F': 0,
  };

  /// Returns grade point for a given grade letter.
  /// Returns 0 for unknown grades.
  static int toGradePoint(String grade) {
    return _gradePointMap[grade.trim().toUpperCase()] ?? 0;
  }

  /// Returns whether a grade is a passing grade (not F).
  static bool isPassing(String grade) {
    return grade.trim().toUpperCase() != 'F';
  }

  /// Returns all valid grade letters.
  static List<String> get validGrades => _gradePointMap.keys.toList();

  /// Returns grade point map for reference.
  static Map<String, int> get gradePointMap => Map.unmodifiable(_gradePointMap);
}
