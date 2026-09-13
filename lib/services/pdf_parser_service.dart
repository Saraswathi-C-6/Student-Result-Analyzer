// import '../utils/gpa_calculator.dart';

// /// Parses raw text extracted from a university result PDF.
// /// Supports:
// ///   1. Single-student PDF  — returns results for one student
// ///   2. Bulk PDF            — auto-detects multiple students & their results
// class PdfParserService {
//   // ── Common register-number patterns used by Tamil Nadu universities ──
//   static final _regNoPatterns = [
//     RegExp(r'\b\d{2}[A-Z]{2,4}\d{3,6}\b'), // 22CSC001, 21IT012
//     RegExp(r'\b[A-Z]{2}\d{2}[A-Z]{2}\d{3}\b'), // AU21CS001
//     RegExp(r'\b\d{6}[A-Z]{2}\d{3}\b'), // numeric+alpha combos
//     RegExp(r'\b\d{12}\b'), // 12-digit roll numbers
//     RegExp(r'\b\d{3}[A-Z]{2}\d{3}\b'),
//   ];

//   // ── Name line indicators ─────────────────────────────────────────
//   static final _nameLinePatterns = [
//     RegExp(r'(?:student\s*name|name)\s*[:\-]?\s*(.+)', caseSensitive: false),
//     RegExp(r'(?:candidate\s*name)\s*[:\-]?\s*(.+)', caseSensitive: false),
//   ];

//   // ── Grade set ────────────────────────────────────────────────────
//   static const _grades = {'S', 'A', 'B', 'C', 'D', 'E', 'F'};

//   // ════════════════════════════════════════════════════════════════
//   //  PUBLIC API
//   // ════════════════════════════════════════════════════════════════

//   /// Parse a PDF that may contain ONE student's results.
//   /// Returns parsed subject rows.  Also extracts name/regNo into [meta].
//   static List<Map<String, dynamic>> parseResultText({
//     required String rawText,
//     required int semester,
//     required String studentId,
//     required String studentName,
//     List<Map<String, dynamic>> subjectSetup = const [],
//     Map<String, dynamic>? meta, // optional out-param: {name, regNo}
//   }) {
//     final setupMap = _buildSetupMap(subjectSetup);

//     // Try to extract student identity from PDF
//     if (meta != null) {
//       final extracted = extractStudentIdentity(rawText);
//       meta['name'] = extracted['name'] ?? studentName;
//       meta['regNo'] = extracted['regNo'] ?? '';
//     }

//     final results = <Map<String, dynamic>>[];
//     final lines = _splitLines(rawText);

//     for (final line in lines) {
//       final parsed = _parseLine(line, setupMap);
//       if (parsed != null) {
//         results.add({
//           ...parsed,
//           'studentId': studentId,
//           'studentName': studentName,
//           'semester': semester,
//           'createdAt': DateTime.now().toIso8601String(),
//         });
//       }
//     }

//     return _deduplicate(results);
//   }

//   /// Parse a BULK PDF that contains results for MULTIPLE students.
//   /// Returns a list of student blocks:
//   /// [
//   ///   { 'regNo': '22CSC001', 'name': 'John', 'results': [...] },
//   ///   { 'regNo': '22CSC002', 'name': 'Jane', 'results': [...] },
//   /// ]
//   static List<Map<String, dynamic>> parseBulkResultText({
//     required String rawText,
//     required int semester,
//     List<Map<String, dynamic>> subjectSetup = const [],
//   }) {
//     final setupMap = _buildSetupMap(subjectSetup);
//     final lines = _splitLines(rawText);
//     final studentBlocks = <Map<String, dynamic>>[];

//     String? currentRegNo;
//     String? currentName;
//     List<Map<String, dynamic>> currentResults = [];

//     void flushStudent() {
//       if (currentRegNo != null && currentResults.isNotEmpty) {
//         studentBlocks.add({
//           'regNo': currentRegNo!.toUpperCase(),
//           'name': currentName ?? '',
//           'results': _deduplicate(currentResults),
//         });
//       }
//       currentRegNo = null;
//       currentName = null;
//       currentResults = [];
//     }

//     for (int i = 0; i < lines.length; i++) {
//       final line = lines[i];

//       // ── Try to detect a register number line ──────────────────
//       final detectedReg = _extractRegNo(line);
//       if (detectedReg != null) {
//         // Save previous student block before starting a new one
//         if (currentRegNo != null && detectedReg != currentRegNo) {
//           flushStudent();
//         }
//         currentRegNo = detectedReg;

//         // Try to find name on same line or next line
//         final nameOnLine = _extractNameFromLine(line, detectedReg);
//         if (nameOnLine != null) {
//           currentName = nameOnLine;
//         } else if (i + 1 < lines.length) {
//           final nameLine = _extractNameFromNameLine(lines[i + 1]);
//           if (nameLine != null) currentName = nameLine;
//         }
//         continue;
//       }

//       // ── Try to detect student name line ───────────────────────
//       final nameFromPattern = _extractNameFromNameLine(line);
//       if (nameFromPattern != null && currentName == null) {
//         currentName = nameFromPattern;
//         continue;
//       }

//       // ── Try to parse as subject result row ────────────────────
//       if (currentRegNo != null) {
//         final parsed = _parseLine(line, setupMap);
//         if (parsed != null) {
//           currentResults.add({
//             ...parsed,
//             'semester': semester,
//             'createdAt': DateTime.now().toIso8601String(),
//           });
//         }
//       }
//     }

//     // Flush the last student
//     flushStudent();

//     return studentBlocks;
//   }

//   /// Extract student identity (name + regNo) from any PDF text.
//   static Map<String, String?> extractStudentIdentity(String rawText) {
//     String? name;
//     String? regNo;

//     final lines = _splitLines(rawText);
//     for (final line in lines) {
//       // Extract register number
//       regNo ??= _extractRegNo(line);

//       // Extract name from labelled line
//       name ??= _extractNameFromNameLine(line);
//     }

//     // Fallback: if no label found, look for an ALL-CAPS name line
//     if (name == null) {
//       for (final line in lines.take(30)) {
//         if (_looksLikeStudentName(line)) {
//           name = _cleanName(line);
//           break;
//         }
//       }
//     }

//     return {'name': name, 'regNo': regNo};
//   }

//   /// Validate parsed results — removes rows with obviously bad data.
//   static List<Map<String, dynamic>> validate(
//       List<Map<String, dynamic>> results) {
//     return results.where((r) {
//       final code = (r['subjectCode'] ?? '').toString();
//       final grade = (r['grade'] ?? '').toString().toUpperCase();
//       final credits = (r['credits'] as num?)?.toDouble() ?? 0;
//       return code.isNotEmpty && _grades.contains(grade) && credits > 0;
//     }).toList();
//   }

//   // ════════════════════════════════════════════════════════════════
//   //  PRIVATE HELPERS
//   // ════════════════════════════════════════════════════════════════

//   static Map<String, double> _buildSetupMap(
//       List<Map<String, dynamic>> subjectSetup) {
//     final map = <String, double>{};
//     for (final s in subjectSetup) {
//       final code = (s['subjectCode'] ?? '').toString().toUpperCase();
//       if (code.isNotEmpty) {
//         map[code] = (s['credits'] as num?)?.toDouble() ?? 3.0;
//       }
//     }
//     return map;
//   }

//   static List<String> _splitLines(String rawText) {
//     return rawText
//         .split('\n')
//         .map((l) => l.trim())
//         .where((l) => l.isNotEmpty)
//         .toList();
//   }

//   static List<Map<String, dynamic>> _deduplicate(
//       List<Map<String, dynamic>> results) {
//     final seen = <String>{};
//     return results.where((r) {
//       final code = r['subjectCode'] as String;
//       if (seen.contains(code)) return false;
//       seen.add(code);
//       return true;
//     }).toList();
//   }

//   // ── Register number extraction ───────────────────────────────────
//   static String? _extractRegNo(String line) {
//     for (final pattern in _regNoPatterns) {
//       final match = pattern.firstMatch(line);
//       if (match != null) return match.group(0);
//     }
//     return null;
//   }

//   // ── Name extraction from labelled line ──────────────────────────
//   static String? _extractNameFromNameLine(String line) {
//     for (final pattern in _nameLinePatterns) {
//       final match = pattern.firstMatch(line);
//       if (match != null) {
//         final raw = match.group(1)?.trim() ?? '';
//         if (raw.isNotEmpty) return _cleanName(raw);
//       }
//     }
//     return null;
//   }

//   // ── Name extraction from same line as register number ───────────
//   static String? _extractNameFromLine(String line, String regNo) {
//     final withoutReg = line.replaceAll(regNo, '').trim();
//     if (withoutReg.isEmpty) return null;
//     // Remove numbers and special chars, keep letters and spaces
//     final cleaned = withoutReg.replaceAll(RegExp(r'[^A-Za-z\s]'), '').trim();
//     if (cleaned.length > 3 && !_isHeaderLine(cleaned.toLowerCase())) {
//       return _cleanName(cleaned);
//     }
//     return null;
//   }

//   // ── Does this line look like a student name? ─────────────────────
//   static bool _looksLikeStudentName(String line) {
//     // All caps, only letters and spaces, 2-4 words, no numbers
//     if (RegExp(r'\d').hasMatch(line)) return false;
//     final words = line.trim().split(RegExp(r'\s+'));
//     if (words.length < 2 || words.length > 5) return false;
//     final isAllCaps = line == line.toUpperCase();
//     final noSpecial = !RegExp(r'[^A-Za-z\s]').hasMatch(line);
//     return isAllCaps && noSpecial && !_isHeaderLine(line.toLowerCase());
//   }

//   static String _cleanName(String raw) {
//     return raw
//         .replaceAll(RegExp(r'[^A-Za-z\s]'), '')
//         .trim()
//         .split(RegExp(r'\s+'))
//         .map((w) => w.isNotEmpty
//             ? w[0].toUpperCase() + w.substring(1).toLowerCase()
//             : '')
//         .join(' ')
//         .trim();
//   }

//   // ── Subject row parser ───────────────────────────────────────────
//   static Map<String, dynamic>? _parseLine(
//       String line, Map<String, double> setupMap) {
//     final lower = line.toLowerCase();
//     if (_isHeaderLine(lower)) return null;

//     final tokens = line
//         .split(RegExp(r'\s{2,}|\t'))
//         .map((t) => t.trim())
//         .where((t) => t.isNotEmpty)
//         .toList();
//     if (tokens.isEmpty) return null;

//     // Strategy 1: structured columns (≥3 tokens, last token is a grade letter)
//     if (tokens.length >= 3) {
//       final last = tokens.last.toUpperCase();
//       if (_grades.contains(last)) {
//         double credits = 3.0;
//         final gradeIdx = tokens.length - 1;
//         int creditsIdx = -1;

//         for (int i = 1; i < tokens.length - 1; i++) {
//           final val = double.tryParse(tokens[i]);
//           if (val != null && val >= 1 && val <= 6) {
//             credits = val;
//             creditsIdx = i;
//             break;
//           }
//         }

//         final code = tokens[0].toUpperCase();
//         final nameEnd = creditsIdx > 0 ? creditsIdx : gradeIdx;
//         final name = tokens.sublist(1, nameEnd).join(' ');

//         if (setupMap.containsKey(code)) credits = setupMap[code]!;
//         if (code.isEmpty) return null;

//         return {
//           'subjectCode': code,
//           'subjectName': name.isEmpty ? code : name,
//           'credits': credits,
//           'grade': last,
//           'gradePoint': GpaCalculator.gradeToPoint(last).toDouble(),
//         };
//       }
//     }

//     // Strategy 2: regex grade search
//     final gradeMatch = RegExp(r'\b([SABCDEF])\b').firstMatch(line);
//     if (gradeMatch != null) {
//       final grade = gradeMatch.group(1)!.toUpperCase();
//       final before = line.substring(0, gradeMatch.start).trim();
//       final parts =
//           before.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
//       if (parts.isEmpty) return null;

//       final code = parts.first.toUpperCase();
//       double credits = setupMap[code] ?? 3.0;
//       for (final p in parts.skip(1)) {
//         final v = double.tryParse(p);
//         if (v != null && v >= 1 && v <= 6) {
//           credits = v;
//           break;
//         }
//       }
//       final nameTokens =
//           parts.skip(1).where((t) => double.tryParse(t) == null).toList();
//       final name = nameTokens.join(' ');

//       return {
//         'subjectCode': code,
//         'subjectName': name.isEmpty ? code : name,
//         'credits': credits,
//         'grade': grade,
//         'gradePoint': GpaCalculator.gradeToPoint(grade).toDouble(),
//       };
//     }

//     return null;
//   }

//   static bool _isHeaderLine(String lower) {
//     const headers = [
//       'subject',
//       'code',
//       'grade',
//       'credit',
//       'result',
//       'semester',
//       'name',
//       'register',
//       'reg no',
//       'sl.no',
//       'sl no',
//       'total',
//       'course',
//       'detail',
//       'marks',
//       'internal',
//       'external',
//     ];
//     return headers.any((h) => lower.startsWith(h) || lower == h);
//   }
// }

import '../utils/gpa_calculator.dart';

/// Parses raw text extracted from a university result PDF.
/// Supports:
///   1. Single-student PDF  — returns results for one student
///   2. Bulk PDF            — auto-detects multiple students & their results
class PdfParserService {
  // ── Common register-number patterns used by Tamil Nadu universities ──
  static final _regNoPatterns = [
    RegExp(r'\b\d{2}[A-Z]{2,4}\d{3,6}\b'), // 22CSC001, 21IT012
    RegExp(r'\b[A-Z]{2}\d{2}[A-Z]{2}\d{3}\b'), // AU21CS001
    RegExp(r'\b\d{6}[A-Z]{2}\d{3}\b'), // numeric+alpha combos
    RegExp(r'\b\d{12}\b'), // 12-digit roll numbers
    RegExp(r'\b\d{3}[A-Z]{2}\d{3}\b'),
  ];

  // ── Name line indicators ─────────────────────────────────────────
  static final _nameLinePatterns = [
    RegExp(r'(?:student\s*name|name)\s*[:\-]?\s*(.+)', caseSensitive: false),
    RegExp(r'(?:candidate\s*name)\s*[:\-]?\s*(.+)', caseSensitive: false),
  ];

  // ── Grade set ────────────────────────────────────────────────────
  static const _grades = {'S', 'A', 'B', 'C', 'D', 'E', 'F'};

  // ── Subject pattern: "MAA101 - B" variants ───────────────────────
  // Uses exactly 3 letters + 3 digits as per university format.
  static final _subjectPattern = RegExp(r'([A-Z]{3}\d{3})\s*-\s*([SABCDEFP])');

  // ════════════════════════════════════════════════════════════════
  //  PUBLIC API
  // ════════════════════════════════════════════════════════════════

  /// Parse a PDF that may contain ONE student's results.
  /// Returns parsed subject rows.  Also extracts name/regNo into [meta].
  static List<Map<String, dynamic>> parseResultText({
    required String rawText,
    required int semester,
    required String studentId,
    required String studentName,
    List<Map<String, dynamic>> subjectSetup = const [],
    Map<String, dynamic>? meta,
  }) {
    final setupMap = _buildSetupMap(subjectSetup);

    if (meta != null) {
      final extracted = extractStudentIdentity(rawText);
      meta['name'] = extracted['name'] ?? studentName;
      meta['regNo'] = extracted['regNo'] ?? '';
    }

    // ── Use block approach even for single student ──────────────
    // Normalise, find the first register number, treat full text as one block.
    final normalised = rawText.replaceAll('\r', '').replaceAll('\t', ' ');

    final results = <Map<String, dynamic>>[];

    // allMatches over the entire text to find ALL subject-grade pairs
    for (final m in _subjectPattern.allMatches(normalised.toUpperCase())) {
      final code = m.group(1)!;
      final grade = m.group(2)!;
      if (!_grades.contains(grade)) continue;

      final credits = setupMap[code] ?? 3.0;
      results.add({
        'subjectCode': code,
        'subjectName': code,
        'credits': credits,
        'grade': grade,
        'gradePoint': GpaCalculator.gradeToPoint(grade).toDouble(),
        'studentId': studentId,
        'studentName': studentName,
        'semester': semester,
        'createdAt': DateTime.now().toIso8601String(),
      });
    }

    return _deduplicate(results);
  }

  /// Parse a BULK PDF that contains results for MULTIPLE students.
  ///
  /// STEP 1 — Full text extracted first (no line-by-line splitting).
  /// STEP 2 — Student blocks created by splitting at every register number.
  /// STEP 3 — allMatches() used on each block to find ALL subjects.
  ///
  /// Returns:
  /// [
  ///   { 'regNo': '22CSC001', 'name': 'John', 'results': [...] },
  ///   { 'regNo': '22CSC002', 'name': 'Jane', 'results': [...] },
  /// ]
  static List<Map<String, dynamic>> parseBulkResultText({
    required String rawText,
    required int semester,
    List<Map<String, dynamic>> subjectSetup = const [],
  }) {
    final setupMap = _buildSetupMap(subjectSetup);

    // ── STEP 1: Normalise FULL text — do NOT split into lines yet ─
    final normalised = rawText.replaceAll('\r', '').replaceAll('\t', ' ');

    // ── STEP 2: Locate every register number in the full text ─────
    // Use 10-digit pattern first (most common for PTU-style PDFs).
    // Fall back to the broader patterns if no 10-digit numbers found.
    RegExp activeRegPattern = RegExp(r'\b(\d{10})\b');
    var regMatches = activeRegPattern.allMatches(normalised).toList();

    if (regMatches.isEmpty) {
      // Fallback: try each known pattern until we find matches
      for (final pat in _regNoPatterns) {
        final m = pat.allMatches(normalised).toList();
        if (m.isNotEmpty) {
          activeRegPattern = RegExp('(${pat.pattern})');
          regMatches = activeRegPattern.allMatches(normalised).toList();
          break;
        }
      }
    }

    if (regMatches.isEmpty) return [];

    final studentBlocks = <Map<String, dynamic>>[];

    for (int i = 0; i < regMatches.length; i++) {
      final regMatch = regMatches[i];
      final regNo = regMatch.group(1)!.toUpperCase();

      // Text from this reg number to the next (or end of document)
      final blockStart = regMatch.start;
      final blockEnd = (i + 1 < regMatches.length)
          ? regMatches[i + 1].start
          : normalised.length;

      final studentBlock = normalised.substring(blockStart, blockEnd);

      // Extract name from text immediately after the register number
      final afterReg = normalised.substring(regMatch.end, blockEnd).trim();
      final name = _extractNameFromBlock(afterReg);

      // ── STEP 3: allMatches on the FULL student block ─────────────
      // MUST use allMatches — NEVER firstMatch.
      final matches =
          _subjectPattern.allMatches(studentBlock.toUpperCase()).toList();

      // Debug log (temporary)
      print('Student: $regNo');
      print('Subjects Found: ${matches.length}');

      // ── STEP 4: Fresh map per student — subjects NEVER carry over ─
      final results = <Map<String, dynamic>>[];
      final seen = <String>{};

      for (final m in matches) {
        final code = m.group(1)!;
        final grade = m.group(2)!;

        if (seen.contains(code)) continue; // deduplicate
        seen.add(code);

        final credits = setupMap[code] ?? 3.0;
        results.add({
          'subjectCode': code,
          'subjectName': code,
          'credits': credits,
          'grade': grade,
          'gradePoint': GpaCalculator.gradeToPoint(grade).toDouble(),
          'semester': semester,
          'createdAt': DateTime.now().toIso8601String(),
        });
      }

      // ── STEP 6: Reset — new map created next iteration automatically
      studentBlocks.add({
        'regNo': regNo,
        'name': name,
        'results': results, // all subjects for this student
      });
    }

    return studentBlocks;
  }

  /// Extract student identity (name + regNo) from any PDF text.
  static Map<String, String?> extractStudentIdentity(String rawText) {
    String? name;
    String? regNo;

    final lines = _splitLines(rawText);
    for (final line in lines) {
      regNo ??= _extractRegNo(line);
      name ??= _extractNameFromNameLine(line);
    }

    if (name == null) {
      for (final line in lines.take(30)) {
        if (_looksLikeStudentName(line)) {
          name = _cleanName(line);
          break;
        }
      }
    }

    return {'name': name, 'regNo': regNo};
  }

  /// Validate parsed results — removes rows with obviously bad data.
  static List<Map<String, dynamic>> validate(
      List<Map<String, dynamic>> results) {
    return results.where((r) {
      final code = (r['subjectCode'] ?? '').toString();
      final grade = (r['grade'] ?? '').toString().toUpperCase();
      final credits = (r['credits'] as num?)?.toDouble() ?? 0;
      return code.isNotEmpty && _grades.contains(grade) && credits > 0;
    }).toList();
  }

  // ════════════════════════════════════════════════════════════════
  //  PRIVATE HELPERS
  // ════════════════════════════════════════════════════════════════

  static Map<String, double> _buildSetupMap(
      List<Map<String, dynamic>> subjectSetup) {
    final map = <String, double>{};
    for (final s in subjectSetup) {
      final code = (s['subjectCode'] ?? '').toString().toUpperCase();
      if (code.isNotEmpty) {
        map[code] = (s['credits'] as num?)?.toDouble() ?? 3.0;
      }
    }
    return map;
  }

  static List<String> _splitLines(String rawText) {
    return rawText
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
  }

  static List<Map<String, dynamic>> _deduplicate(
      List<Map<String, dynamic>> results) {
    final seen = <String>{};
    return results.where((r) {
      final code = r['subjectCode'] as String;
      if (seen.contains(code)) return false;
      seen.add(code);
      return true;
    }).toList();
  }

  // ── Register number extraction ───────────────────────────────────
  static String? _extractRegNo(String line) {
    for (final pattern in _regNoPatterns) {
      final match = pattern.firstMatch(line);
      if (match != null) return match.group(0);
    }
    return null;
  }

  // ── Name extraction from labelled line ──────────────────────────
  static String? _extractNameFromNameLine(String line) {
    for (final pattern in _nameLinePatterns) {
      final match = pattern.firstMatch(line);
      if (match != null) {
        final raw = match.group(1)?.trim() ?? '';
        if (raw.isNotEmpty) return _cleanName(raw);
      }
    }
    return null;
  }

  // ── Name from block text (text immediately after register number) ─
  static String _extractNameFromBlock(String afterReg) {
    // Strategy 1: leading CAPS words before first subject-code token
    final nameMatch =
        RegExp(r'^([A-Z][A-Z\s\.]+?)\s+(?=[A-Z]{3}\d{3})', caseSensitive: true)
            .firstMatch(afterReg);
    if (nameMatch != null) {
      return _cleanName(nameMatch.group(1)!.trim());
    }

    // Strategy 2: strip subject codes + grades, keep leading name words
    final stripped = afterReg
        .replaceAll(RegExp(r'[A-Z]{3}\d{3}\s*-\s*[SABCDEFP]'), '')
        .replaceAll(RegExp(r'[-]+'), '')
        .replaceAll(RegExp(r'\d+'), '')
        .replaceAll(RegExp(r'\s{2,}'), ' ')
        .trim();

    final words = stripped.split(' ').where((w) => w.isNotEmpty).toList();
    final nameWords = <String>[];
    for (final w in words) {
      if (RegExp(r'^[A-Za-z\.]+$').hasMatch(w)) {
        nameWords.add(w);
        if (nameWords.length == 5) break;
      } else {
        break;
      }
    }
    return nameWords.isEmpty ? '' : _cleanName(nameWords.join(' '));
  }

  // ── Does this line look like a student name? ─────────────────────
  static bool _looksLikeStudentName(String line) {
    if (RegExp(r'\d').hasMatch(line)) return false;
    final words = line.trim().split(RegExp(r'\s+'));
    if (words.length < 2 || words.length > 5) return false;
    final isAllCaps = line == line.toUpperCase();
    final noSpecial = !RegExp(r'[^A-Za-z\s]').hasMatch(line);
    return isAllCaps && noSpecial && !_isHeaderLine(line.toLowerCase());
  }

  static String _cleanName(String raw) {
    return raw
        .replaceAll(RegExp(r'[^A-Za-z\s]'), '')
        .trim()
        .split(RegExp(r'\s+'))
        .map((w) => w.isNotEmpty
            ? w[0].toUpperCase() + w.substring(1).toLowerCase()
            : '')
        .join(' ')
        .trim();
  }

  static bool _isHeaderLine(String lower) {
    const headers = [
      'subject',
      'code',
      'grade',
      'credit',
      'result',
      'semester',
      'name',
      'register',
      'reg no',
      'sl.no',
      'sl no',
      'total',
      'course',
      'detail',
      'marks',
      'internal',
      'external',
    ];
    return headers.any((h) => lower.startsWith(h) || lower == h);
  }
}
