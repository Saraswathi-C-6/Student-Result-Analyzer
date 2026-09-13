import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final bg = isDark ? const Color(0xFF0A0E27) : const Color(0xFFF4F6FF);
    final cardBg = isDark ? const Color(0xFF1A1F4E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF2D3142);
    final subColor = isDark ? const Color(0xFF8B92B8) : const Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1A1F4E) : Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Settings',
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Appearance section
            _buildSectionTitle('Appearance', subColor),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Column(
                children: [
                  _buildToggleTile(
                    icon: isDark
                        ? Icons.dark_mode_rounded
                        : Icons.light_mode_rounded,
                    iconColor: isDark
                        ? const Color(0xFF6C63FF)
                        : const Color(0xFFFFBE0B),
                    title: 'Dark Mode',
                    subtitle: isDark
                        ? 'Currently using dark theme'
                        : 'Currently using light theme',
                    value: isDark,
                    textColor: textColor,
                    subColor: subColor,
                    onChanged: (_) => themeProvider.toggleTheme(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Grade Scale section
            _buildSectionTitle('Grade Scale Reference', subColor),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Column(
                children: [
                  _buildGradeRow('S', '10', 'Outstanding',
                      const Color(0xFF6C63FF), textColor),
                  _buildGradeRow('A', '9', 'Excellent', const Color(0xFF4ECDC4),
                      textColor),
                  _buildGradeRow('B', '8', 'Very Good', const Color(0xFF43A047),
                      textColor),
                  _buildGradeRow(
                      'C', '7', 'Good', const Color(0xFFFFBE0B), textColor),
                  _buildGradeRow(
                      'D', '6', 'Average', const Color(0xFFFF9800), textColor),
                  _buildGradeRow(
                      'E', '5', 'Pass', const Color(0xFFFF6B6B), textColor),
                  _buildGradeRow(
                      'F', '0', 'Fail', const Color(0xFFE53935), textColor,
                      showDivider: false),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Formula section
            _buildSectionTitle('GPA / CGPA Formula', subColor),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFormula(
                    'GPA (per semester)',
                    'Σ(Cᵢ × GPᵢ) / Σ(Cᵢ)',
                    'Only subjects in that semester',
                    const Color(0xFF6C63FF),
                    textColor,
                    subColor,
                  ),
                  const SizedBox(height: 16),
                  _buildFormula(
                    'CGPA (cumulative)',
                    'Σ(Cᵢ × GPᵢ) / Σ(Cᵢ)',
                    'All subjects from Sem 1 to current',
                    const Color(0xFF4ECDC4),
                    textColor,
                    subColor,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Cᵢ = Credit of course  •  GPᵢ = Grade Point obtained',
                    style: TextStyle(color: subColor, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Account section
            _buildSectionTitle('Account', subColor),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: _buildActionTile(
                icon: Icons.logout_rounded,
                iconColor: const Color(0xFFE53935),
                title: 'Logout',
                subtitle: 'Sign out of your account',
                textColor: const Color(0xFFE53935),
                subColor: subColor,
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: cardBg,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      title: Text('Logout',
                          style: TextStyle(
                              color: textColor, fontWeight: FontWeight.bold)),
                      content: Text('Are you sure you want to logout?',
                          style: TextStyle(color: subColor)),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child:
                              Text('Cancel', style: TextStyle(color: subColor)),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE53935),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Logout',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(context, '/login');
                    }
                  }
                },
              ),
            ),
            const SizedBox(height: 32),

            // App version
            Center(
              child: Text('Student Result Analyzer v1.0.0',
                  style: TextStyle(color: subColor, fontSize: 12)),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(title,
          style: TextStyle(
              color: color, fontSize: 13, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildToggleTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required Color textColor,
    required Color subColor,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 15)),
                Text(subtitle, style: TextStyle(color: subColor, fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF6C63FF),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Color textColor,
    required Color subColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 15)),
                  Text(subtitle,
                      style: TextStyle(color: subColor, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: subColor, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildGradeRow(
      String grade, String point, String label, Color color, Color textColor,
      {bool showDivider = true}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(grade,
                      style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(label,
                    style: TextStyle(color: textColor, fontSize: 14)),
              ),
              Text('$point points',
                  style: TextStyle(
                      color: color, fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
        ),
        if (showDivider) Divider(color: color.withOpacity(0.1), height: 1),
      ],
    );
  }

  Widget _buildFormula(String title, String formula, String note, Color color,
      Color textColor, Color subColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
                color: textColor, fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.3), width: 1),
          ),
          child: Text(formula,
              style: TextStyle(
                  color: color, fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 6),
        Text(note, style: TextStyle(color: subColor, fontSize: 11)),
      ],
    );
  }
}
