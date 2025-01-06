import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:itproject/models/available_event_model.dart';

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

  String getEventStatus() {
    final now = DateTime.now();
    if (event.startTime != null && event.endTime != null) {
      if (now.isBefore(event.startTime!)) {
        return "Upcoming";
      } else if (now.isAfter(event.endTime!)) {
        return "Completed";
      } else {
        return "Ongoing";
      }
    }
    return "Unknown";
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
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    (event.isPrivate ?? false) ? Icons.lock : Icons.lock_open,
                    color: (event.isPrivate ?? false)
                        ? Colors.red
                        : Colors.blue,
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
                      style: const TextStyle(fontWeight: FontWeight.bold),
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
                      style: const TextStyle(fontWeight: FontWeight.bold),
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
                    style: TextStyle(color: textColor),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 20, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    "Date: ${formatDate(event.startTime)}",
                    style: TextStyle(color: textColor),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Trạng thái sự kiện
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  getEventStatus(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: getEventStatus() == "Ongoing"
                        ? Colors.green
                        : (getEventStatus() == "Completed"
                            ? Colors.red
                            : Colors.orange),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
