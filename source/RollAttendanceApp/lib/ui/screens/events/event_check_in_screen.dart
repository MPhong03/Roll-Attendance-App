import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:blurry_modal_progress_hud/blurry_modal_progress_hud.dart';
import 'package:go_router/go_router.dart';
import 'package:itproject/enums/event_status.dart';
import 'package:itproject/models/event_model.dart';
import 'package:intl/intl.dart';
import 'package:itproject/services/api_service.dart';
import 'package:itproject/ui/components/events/qr_scanner_modal.dart';

class EventCheckInScreen extends StatefulWidget {
  final String eventId;

  const EventCheckInScreen({super.key, required this.eventId});

  @override
  State<EventCheckInScreen> createState() => _EventCheckInScreenState();
}

Map<String, dynamic> getEventStatus(EventStatus status) {
  switch (status) {
    case EventStatus.notStarted:
      return {
        "text": "Not Started",
        "color": Colors.orange, // Màu cam cho Not Started
      };
    case EventStatus.inProgress:
      return {
        "text": "In Progress",
        "color": Colors.green, // Màu xanh lá cho In Progress
      };
    case EventStatus.completed:
      return {
        "text": "Completed",
        "color": Colors.grey, // Màu xám cho Completed
      };
    case EventStatus.cancelled:
      return {
        "text": "Cancelled",
        "color": Colors.red, // Màu đỏ cho Cancelled
      };
    case EventStatus.postponed:
      return {
        "text": "Postponed",
        "color": Colors.blue, // Màu xanh dương cho Postponed
      };
    default:
      return {
        "text": "Unknown",
        "color": Colors.black, // Mặc định màu đen
      };
  }
}

double getResponsiveFontSize(double baseFontSize, BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  if (screenWidth > 480) {
    return baseFontSize * 1.4;
  } else {
    return baseFontSize;
  }
}

class _EventCheckInScreenState extends State<EventCheckInScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  late Future<EventModel> _eventFuture;

  // ASYNCHRONOUS METHODS
  Future<EventModel> getDetail(id) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final response = await _apiService.get('api/events/$id');

      if (response.statusCode == 200) {
        return EventModel.fromMap(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load organization');
      }
    } catch (e) {
      throw Exception('Failed to load organization: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      _eventFuture = getDetail(widget.eventId);
    });
  }

  // METHOD
  void _showQrCodeScanner(BuildContext context, EventModel event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.8,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: QRScannerModal(event: event),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _eventFuture = getDetail(widget.eventId);
  }

  String formatTime(DateTime? time) {
    if (time == null) return '';
    return DateFormat('hh:mm a').format(time);
  }

  String formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  @override
Widget build(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;
  final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
  final Color textColor = isDarkMode ? Colors.white70 : Colors.black54;

  // Hàm tính kích thước chữ responsive
  double getResponsiveFontSize(double baseFontSize) {
    if (screenWidth > 480) {
      return baseFontSize * 1.2;
    } else {
      return baseFontSize;
    }
  }

  return Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
      ),
    ),
    backgroundColor: const Color(0xFFC5F0C8),
    body: BlurryModalProgressHUD(
      inAsyncCall: _isLoading,
      opacity: 0.3,
      blurEffectIntensity: 5,
      child: FutureBuilder<EventModel>(
        future: _eventFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: getResponsiveFontSize(16),
                ),
              ),
            );
          } else if (!snapshot.hasData) {
            return Center(
              child: Text(
                'No data available',
                style: TextStyle(
                  fontSize: getResponsiveFontSize(16),
                ),
              ),
            );
          } else {
            final event = snapshot.data!;
            return RefreshIndicator(
              onRefresh: _onRefresh,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Container(
                      width: screenWidth * 0.9,
                      height: screenHeight * 0.85,
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 3,
                            blurRadius: 4,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: getResponsiveFontSize(24),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.lock_outline, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                event.isPrivate
                                    ? "Private Event"
                                    : "Public Event",
                                style: TextStyle(
                                  color: event.isPrivate
                                      ? Colors.red
                                      : Colors.blue,
                                  fontSize: getResponsiveFontSize(16),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            event.description,
                            style: TextStyle(
                              fontSize: getResponsiveFontSize(16),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Event Date and Time
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Time
                              Row(
                                children: [
                                  const Icon(Icons.access_time,
                                      size: 20, color: Colors.blue),
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
                              // Status
                              Row(
                                children: [
                                  const SizedBox(width: 8),
                                  Text(
                                    getEventStatus(event.eventStatus)["text"],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: getEventStatus(
                                          event.eventStatus)["color"],
                                      fontSize: getResponsiveFontSize(14),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Date
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
                          const SizedBox(height: 50),
                          if (event.eventStatus == EventStatus.inProgress) ...[
                            Center(
                              child: Text(
                                "Check In",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: getResponsiveFontSize(24),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Center(
                              child: SizedBox(
                                width: screenWidth * 0.5,
                                height: screenHeight * 0.05,
                                child: ElevatedButton(
                                  onPressed: () {
                                    _showQrCodeScanner(context, event);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0FB900),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.qr_code,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        "QR SCAN",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: getResponsiveFontSize(16),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
        },
      ),
    ),
  );
}

}