import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart'; // Thêm thư viện intl
import 'package:itproject/models/available_event_model.dart';

class EventCard extends StatelessWidget {
  final AvailableEventModel event;
  const EventCard({super.key, required this.event});

  // Hàm format ngày tháng
  String formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd/MM/yyyy hh:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDarkMode ? Colors.white70 : Colors.black54;
    final Color titleColor = isDarkMode ? Colors.white : Colors.black;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          context.push('/event-check-in/${event.id}');
        },
        child: Column(
          children: [
            // Tiêu đề sự kiện và biểu tượng ổ khóa trên cùng một dòng
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Tiêu đề sự kiện
                  Expanded(
                    child: Text(
                      event.name ?? '',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                      ),
                      overflow:
                          TextOverflow.ellipsis, // Đảm bảo không bị overflow
                    ),
                  ),
                  // Biểu tượng ổ khóa
                  Icon(
                    (event.isPrivate ?? false) ? Icons.lock : Icons.lock_open,
                    color:
                        (event.isPrivate ?? false) ? Colors.red : Colors.blue,
                    size: 30.0,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mô tả sự kiện
                  Text(
                    event.description ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Ngày và giờ bắt đầu - Định dạng lại ngày tháng
                  Text(
                    "Start: ${formatDate(event.startTime)}",
                    style: TextStyle(color: textColor),
                  ),
                  Text(
                    "End: ${formatDate(event.endTime)}",
                    style: TextStyle(color: textColor),
                  ),
                  const SizedBox(height: 10),

                  // Thông tin người tổ chức
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage:
                            NetworkImage(event.organizerAvatar ?? ''),
                        radius: 16,
                      ),
                      const SizedBox(width: 8),
                      // Sử dụng từ ngữ sáng tạo hơn
                      Flexible(
                        child: Tooltip(
                          message: event.organizerName ??
                              'Unknown', // Hiển thị tên đầy đủ khi hover
                          child: Text(
                            "Host: ${event.organizerName ?? 'Unknown'}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            overflow: TextOverflow
                                .ellipsis, // Đảm bảo không bị overflow
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Thông tin tổ chức
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage:
                            NetworkImage(event.organizationImage ?? ''),
                        radius: 16,
                      ),
                      const SizedBox(width: 8),
                      // Sử dụng từ ngữ sáng tạo hơn
                      Flexible(
                        child: Tooltip(
                          message: event.organizationName ??
                              'N/A', // Hiển thị tên đầy đủ khi hover
                          child: Text(
                            "Hosted By: ${event.organizationName ?? 'N/A'}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            overflow: TextOverflow
                                .ellipsis, // Đảm bảo không bị overflow
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
