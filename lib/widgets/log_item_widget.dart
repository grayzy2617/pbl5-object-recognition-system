import 'package:flutter/material.dart';
import '../models/log_item_model.dart';

class LogItemWidget extends StatelessWidget {
  final LogItemModel logItem;

  const LogItemWidget({super.key, required this.logItem});

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF22C55E);
    const lightGreenBg = Color(0xFFF0FDF4);
    const primaryRed = Color(0xFFEF4444);
    const lightRedBg = Color(0xFFFEF2F2);
    const textSecondary = Color(0xFF4A5565);
    const textMain = Color(0xFF101828);

    final statusColor = logItem.isSafe ? primaryGreen : primaryRed;
    final statusBg = logItem.isSafe ? lightGreenBg : lightRedBg;
    final statusText = logItem.isSafe ? 'Safe' : 'Dangerous';
    final statusIcon = logItem.isSafe
        ? Icons.shield_outlined
        : Icons.warning_amber_rounded;

    return Card(
      elevation: 0,
      color: statusBg,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: statusColor.withOpacity(0.5), width: 1.0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dot + Line thẳng hàng
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: statusColor.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                ),
                Container(
                  width: 2,
                  height: 40,
                  color: const Color(0xFFE5E7EB).withOpacity(0.7),
                  margin: const EdgeInsets.symmetric(vertical: 10),
                ),
              ],
            ),

            const SizedBox(width: 12),

            // IMAGE
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                logItem.imageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[300],
                  width: 60,
                  height: 60,
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // TEXT INFO
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        logItem.nameVietnamese,
                        style: const TextStyle(
                          color: textMain,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: textSecondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        logItem.nameEnglish,
                        style: const TextStyle(
                          color: textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 13,
                        color: textSecondary,
                      ),
                      Text(
                        '${logItem.time} |',
                        style: const TextStyle(
                          color: textSecondary,
                          fontSize: 11,
                        ),
                      ),
                      const Icon(
                        Icons.calendar_today,
                        size: 13,
                        color: textSecondary,
                      ),
                      Text(
                        logItem.date,
                        style: const TextStyle(
                          color: textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // STATUS (Tự thiết kế lại bằng Container để kiểm soát kích thước tuyệt đối)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ), // Ép nhỏ viền xung quanh
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(
                      20,
                    ), // Bo tròn giống hình viên thuốc
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize
                        .min, // Đảm bảo ô chỉ rộng bằng nội dung bên trong
                    children: [
                      Icon(
                        statusIcon,
                        size: 14, // Giảm size icon một chút
                        color: Colors.white,
                      ),
                      const SizedBox(
                        width: 3,
                      ), // KHOẢNG CÁCH SIÊU NHỎ GIỮA ICON VÀ CHỮ
                      Text(
                        statusText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12, // Giảm font chữ một chút
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(logItem.confidence * 100).toStringAsFixed(1)}% conf.',
                  style: const TextStyle(color: textSecondary, fontSize: 10),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
