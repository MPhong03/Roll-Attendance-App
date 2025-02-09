import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:itproject/enums/user_attendance_status.dart';
import 'package:itproject/models/available_event_model.dart';
import 'package:itproject/enums/event_status.dart';

class EventCard extends StatelessWidget {
  final AvailableEventModel event;
  const EventCard({super.key, required this.event});

  String formatTime(DateTime? time) {
    if (time == null) return '';
    return DateFormat('hh:mm a').format(time);
  }

  String formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  Map<String, dynamic> getEventStatus(EventStatus status) {
    switch (status) {
      case EventStatus.notStarted:
        return {"text": "Not Started", "color": Colors.orange};
      case EventStatus.inProgress:
        return {"text": "In Progress", "color": Colors.green};
      case EventStatus.completed:
        return {"text": "Completed", "color": Colors.grey};
      case EventStatus.cancelled:
        return {"text": "Cancelled", "color": Colors.red};
      case EventStatus.postponed:
        return {"text": "Postponed", "color": Colors.blue};
      default:
        return {"text": "Unknown", "color": Colors.black};
    }
  }

  EventStatus parseEventStatus(int? status) {
    switch (status) {
      case 0:
        return EventStatus.notStarted;
      case 1:
        return EventStatus.inProgress;
      case 2:
        return EventStatus.completed;
      case 3:
        return EventStatus.cancelled;
      case 4:
        return EventStatus.postponed;
      default:
        return EventStatus.notStarted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDarkMode ? Colors.white70 : Colors.black54;
    final Color titleColor = isDarkMode ? Colors.white : Colors.black;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Hàm tính kích thước chữ responsive
    double getResponsiveFontSize(double baseFontSize) {
      if (screenWidth > 480) {
        return baseFontSize * 1.4;
      } else {
        return baseFontSize;
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
      child: InkWell(
        onTap: () {
          context.push('/event-check-in/${event.id}');
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      event.name ?? '',
                      style: TextStyle(
                        fontSize: getResponsiveFontSize(18),
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    (event.isPrivate ?? false) ? Icons.lock : Icons.lock_open,
                    color:
                        (event.isPrivate ?? false) ? Colors.red : Colors.blue,
                    size: 20.0,
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Tên người Host và tổ chức Host
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(event.organizerAvatar ?? ''),
                    radius: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      event.organizerName ?? 'Unknown',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: getResponsiveFontSize(14),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage:
                        NetworkImage(event.organizationImage ?? ''),
                    radius: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      event.organizationName ?? 'N/A',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: getResponsiveFontSize(14),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Time và Date
              Row(
                children: [
                  const Icon(Icons.access_time, size: 20, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    "Time: ${formatTime(event.startTime)} - ${formatTime(event.endTime)}",
                    style: TextStyle(
                      color: textColor,
                      fontSize: getResponsiveFontSize(14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.calendar_today,
                      size: 20, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    "Date: ${formatDate(event.startTime)}",
                    style: TextStyle(
                      color: textColor,
                      fontSize: getResponsiveFontSize(14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Trạng thái sự kiện
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Trạng thái điểm danh
                    Expanded(
                      child: Text(
                        event.isCheckInYet == true
                            ? "${getRoleFromValue(event.attendanceStatus ?? -1)['text']}"
                            : "Not Absent Yet",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: event.isCheckInYet == true
                              ? getRoleFromValue(
                                  event.attendanceStatus ?? -1)['color']
                              : Colors.grey,
                          fontSize: getResponsiveFontSize(14),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8), // Tạo khoảng cách nhỏ

                    // Trạng thái sự kiện
                    Expanded(
                      child: Text(
                        getEventStatus(
                            parseEventStatus(event.eventStatus))["text"],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: getEventStatus(
                              parseEventStatus(event.eventStatus))["color"],
                          fontSize: getResponsiveFontSize(14),
                        ),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right, // Canh phải
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
