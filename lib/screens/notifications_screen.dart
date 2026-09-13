import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/gpa_calculator.dart';
import '../utils/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<_NotifItem> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('students').get();

      final List<_NotifItem> items = [];

      items.add(_NotifItem(
        type: _NotifType.info,
        title: 'Analytics Ready',
        body:
            'Results for ${snapshot.docs.length} students have been analyzed.',
        studentName: '',
      ));

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final name = data['name'] ?? 'Unknown';
        final results = data['results'] as Map<String, dynamic>? ?? {};
        if (results.isEmpty) continue;

        double total = 0;
        int count = 0;
        bool hasFail = false;

        results.forEach((_, mark) {
          final m = (mark as num).toDouble();
          total += GpaCalculator.getGradePoint(m);
          count++;
          if (m < 40) hasFail = true;
        });

        if (count == 0) continue;
        final avg = total / count;

        if (avg < 5.0) {
          items.add(_NotifItem(
            type: _NotifType.warning,
            title: 'Low GPA Alert',
            body:
                '$name has a GPA of ${avg.toStringAsFixed(2)}. Needs attention!',
            studentName: name,
          ));
        }
        if (hasFail) {
          items.add(_NotifItem(
            type: _NotifType.error,
            title: 'Subject Failure',
            body: '$name has failed one or more subjects.',
            studentName: name,
          ));
        }
        if (avg >= 9.0) {
          items.add(_NotifItem(
            type: _NotifType.success,
            title: 'Outstanding Performance',
            body:
                '$name achieved an excellent GPA of ${avg.toStringAsFixed(2)}!',
            studentName: name,
          ));
        }
      }

      if (mounted)
        setState(() {
          _notifications = items;
          _isLoading = false;
        });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendPush(_NotifItem item) async {
    if (item.type == _NotifType.warning) {
      await NotificationService().showLowGpaWarning(item.studentName, 0);
    } else {
      await NotificationService()
          .showLocalNotification(title: item.title, body: item.body);
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Push notification sent!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0A0E27) : const Color(0xFFF4F6FF);
    final textColor = isDark ? Colors.white : const Color(0xFF2D3142);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1A1F4E) : Colors.white,
        title: Text('Notifications',
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: textColor),
            onPressed: _loadNotifications,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_none,
                          size: 64,
                          color:
                              isDark ? Colors.white30 : Colors.grey.shade400),
                      const SizedBox(height: 12),
                      Text('No notifications',
                          style: TextStyle(
                              color: isDark
                                  ? Colors.white54
                                  : Colors.grey.shade600,
                              fontSize: 16)),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _notifications.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = _notifications[index];
                    return _buildCard(item, isDark, textColor);
                  },
                ),
    );
  }

  Widget _buildCard(_NotifItem item, bool isDark, Color textColor) {
    final cardBg = isDark ? const Color(0xFF1A1F4E) : Colors.white;
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: item.color.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: item.color.withOpacity(0.15),
          child: Icon(item.icon, color: item.color, size: 22),
        ),
        title: Text(item.title,
            style: TextStyle(
                color: textColor, fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(item.body,
                style: TextStyle(
                    color: isDark ? Colors.white60 : Colors.grey.shade600,
                    fontSize: 12)),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.send_rounded, size: 20),
          color: const Color(0xFF6C63FF),
          tooltip: 'Send Push',
          onPressed: () => _sendPush(item),
        ),
      ),
    );
  }
}

enum _NotifType { info, success, warning, error }

class _NotifItem {
  final _NotifType type;
  final String title;
  final String body;
  final String studentName;

  _NotifItem({
    required this.type,
    required this.title,
    required this.body,
    required this.studentName,
  });

  Color get color {
    switch (type) {
      case _NotifType.info:
        return const Color(0xFF6C63FF);
      case _NotifType.success:
        return const Color(0xFF43A047);
      case _NotifType.warning:
        return const Color(0xFFFF9800);
      case _NotifType.error:
        return const Color(0xFFE53935);
    }
  }

  IconData get icon {
    switch (type) {
      case _NotifType.info:
        return Icons.info_outline_rounded;
      case _NotifType.success:
        return Icons.check_circle_outline_rounded;
      case _NotifType.warning:
        return Icons.warning_amber_rounded;
      case _NotifType.error:
        return Icons.error_outline_rounded;
    }
  }
}
