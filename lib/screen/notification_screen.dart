import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/notification_provider.dart';
import '../theme/theme_colors.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Thông báo',
            style: GoogleFonts.quicksand(
              fontWeight: FontWeight.bold,
              color: MagicSkyColors.textDarkNavy,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: MagicSkyColors.textDarkNavy),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.done_all,
                color: MagicSkyColors.primaryBlue,
              ),
              tooltip: 'Đánh dấu đã đọc tất cả',
              onPressed: () {
                context.read<NotificationProvider>().markAllAsRead();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã đánh dấu đọc tất cả')),
                );
              },
            ),
          ],
          bottom: const TabBar(
            labelColor: MagicSkyColors.primaryBlue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: MagicSkyColors.primaryBlue,
            tabs: [
              Tab(text: 'Tất cả'),
              Tab(text: 'Chưa đọc'),
              Tab(text: 'Đã đọc'),
            ],
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: MagicSkyColors.backgroundGradient,
          ),
          child: const TabBarView(
            children: [
              _NotificationList(filter: 'all'),
              _NotificationList(filter: 'unread'),
              _NotificationList(filter: 'read'),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationList extends StatelessWidget {
  final String filter;
  const _NotificationList({required this.filter});

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, provider, child) {
        // Lọc danh sách theo Tab
        List<AppNotification> list = provider.notifications;
        if (filter == 'unread') {
          list = list.where((n) => !n.isRead).toList();
        } else if (filter == 'read') {
          list = list.where((n) => n.isRead).toList();
        }

        if (list.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_off_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Không có thông báo nào',
                  style: GoogleFonts.quicksand(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final notif = list[index];
            final bool isDanger =
                notif.title.toLowerCase().contains('cảnh báo') ||
                notif.title.toLowerCase().contains('nguy hiểm');

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: notif.isRead ? 0 : 2,
              color: notif.isRead ? Colors.white70 : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  backgroundColor: isDanger
                      ? Colors.red.withValues(alpha: 0.1)
                      : MagicSkyColors.primaryBlue.withValues(alpha: 0.1),
                  child: Icon(
                    isDanger ? Icons.warning_rounded : Icons.notifications,
                    color: isDanger ? Colors.red : MagicSkyColors.primaryBlue,
                  ),
                ),
                title: Text(
                  notif.title,
                  style: GoogleFonts.quicksand(
                    fontWeight: notif.isRead
                        ? FontWeight.w600
                        : FontWeight.bold,
                    color: MagicSkyColors.textDarkNavy,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),
                    Text(
                      notif.body,
                      style: GoogleFonts.quicksand(fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DateFormat('HH:mm - dd/MM/yyyy').format(notif.timestamp),
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ),
                trailing: notif.isRead
                    ? null
                    : Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                onTap: () {
                  // Đánh dấu đã đọc khi bấm vào
                  provider.markAsRead(notif.id);
                },
              ),
            );
          },
        );
      },
    );
  }
}
