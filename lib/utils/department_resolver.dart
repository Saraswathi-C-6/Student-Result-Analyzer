// utils/department_resolver.dart
// Automatically resolves department from PTU register number.
//
// PTU Register Number Format: YYIIIDDDNNN
//   YY  = Batch year suffix (e.g., 23 = 2023)         → index 0–1
//   II  = Institution code (e.g., 03 = PTU main)      → index 2–3
//   DDD = Department code (3 digits)                   → index 4–6
//   NNN = Roll number                                  → index 7–9
//
// Real examples verified from PTU result PDF:
//   2303102001 → deptCode "102" → AA  (B.Tech - AA)
//   2303107001 → deptCode "107" → CSE
//   2303108001 → deptCode "108" → EEE
//   2303109001 → deptCode "109" → ECE
//   2303121001 → deptCode "121" → ISE

class DepartmentResolver {
  static const Map<String, String> _deptCodeMap = {
    '102': 'AA', // Architecture / Civil Arch
    '103': 'MECH', // Mechanical Engineering
    '104': 'CIVIL', // Civil Engineering
    '105': 'IT', // Information Technology
    '107': 'CSE', // Computer Science & Engineering
    '108': 'EEE', // Electrical & Electronics Engineering
    '109': 'ECE', // Electronics & Communication Engineering
    '110': 'AIDS', // AI & Data Science
    '111': 'AIML', // AI & Machine Learning
    '112': 'CSD', // Computer Science & Design
    '113': 'CSM', // Computer Science & Mathematics
    '114': 'CSBS', // Computer Science & Business Systems
    '121': 'ISE', // Information Science Engineering
  };

  /// Resolves department name from a PTU 10-digit register number.
  ///
  /// Extracts characters at index 4–6 (3-digit dept code).
  ///
  /// Examples:
  ///   resolveDepartment("2303107030") → "CSE"
  ///   resolveDepartment("2303109005") → "ECE"
  ///   resolveDepartment("2303121031") → "ISE"
  ///   resolveDepartment("2303108003") → "EEE"
  ///   resolveDepartment("2303102001") → "AA"
  static String resolveDepartment(String registerNo) {
    final cleaned = registerNo.trim();
    if (cleaned.length < 7) return 'UNKNOWN';

    // Department code sits at positions index 4, 5, 6
    final deptCode = cleaned.substring(4, 7);
    return _deptCodeMap[deptCode] ?? 'UNKNOWN($deptCode)';
  }

  /// Resolves full batch year from register number.
  ///
  /// First 2 digits = year suffix ("23" → 2023).
  ///
  /// Examples:
  ///   resolveBatch("2303107030") → "2023"
  ///   resolveBatch("2203107030") → "2022"
  static String resolveBatch(String registerNo) {
    final cleaned = registerNo.trim();
    if (cleaned.length < 2) return 'UNKNOWN';

    final yearSuffix = cleaned.substring(0, 2);
    final year = int.tryParse(yearSuffix);
    if (year == null) return 'UNKNOWN';

    final fullYear = (year >= 0 && year <= 50) ? 2000 + year : 1900 + year;
    return fullYear.toString();
  }

  /// Returns the raw 3-digit department code from a register number.
  static String getDeptCode(String registerNo) {
    final cleaned = registerNo.trim();
    if (cleaned.length < 7) return 'UNK';
    return cleaned.substring(4, 7);
  }

  /// Returns true if register number is a valid 10-digit PTU format.
  static bool isValidRegisterNo(String registerNo) {
    return RegExp(r'^\d{10}$').hasMatch(registerNo.trim());
  }

  /// Returns all supported department codes and names (read-only).
  static Map<String, String> get departmentMap =>
      Map.unmodifiable(_deptCodeMap);
}
