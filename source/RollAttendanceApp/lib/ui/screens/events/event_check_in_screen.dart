import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:blurry_modal_progress_hud/blurry_modal_progress_hud.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:itproject/enums/event_status.dart';
import 'package:itproject/models/event_history_model.dart';
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

class _EventCheckInScreenState extends State<EventCheckInScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  late Future<EventModel> _eventFuture;
  late Future<HistoryModel> _eventHistoryFuture;

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

  Future<HistoryModel> getHistoryDetail(id) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final response = await _apiService.get('api/histories/$id');

      if (response.statusCode == 200) {
        return HistoryModel.fromMap(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load history');
      }
    } catch (e) {
      throw Exception('Failed to load history: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    setState(() async {
      _eventFuture = getDetail(widget.eventId);
      _eventHistoryFuture = getHistoryDetail(widget.eventId);
    });
  }

  // METHOD
  void _showQrCodeScanner(
      BuildContext context, EventModel event, HistoryModel history) {
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
            child: QRScannerModal(event: event, history: history),
          ),
        );
      },
    );
  }

  void _showAbsentLateDialog(BuildContext context) {
    int selectedStatus = 0;
    TextEditingController reasonController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(
                "Absent/Late Request",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    value: selectedStatus,
                    decoration:
                        const InputDecoration(labelText: "Select Status"),
                    items: const [
                      DropdownMenuItem(value: 1, child: Text("Late")),
                      DropdownMenuItem(value: 0, child: Text("Absent")),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedStatus = value ?? 1;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: reasonController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: "Reason",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          String reason = reasonController.text.trim();
                          if (reason.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please enter a reason"),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          setState(() {
                            isLoading = true;
                          });

                          try {
                            final response = await _apiService.post(
                              'api/events/${widget.eventId}/absented-request',
                              {
                                'Type': selectedStatus,
                                'Notes': reason,
                              },
                            );

                            final message =
                                jsonDecode(response.body)['message'];

                            Fluttertoast.showToast(
                              msg: message,
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: Colors.black,
                              textColor: Colors.white,
                            );

                            if (response.statusCode == 200) {
                              Navigator.pop(context);
                            }
                          } catch (e) {
                            Fluttertoast.showToast(
                              msg: "Error: $e",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                            );
                          } finally {
                            setState(() {
                              isLoading = false;
                            });
                          }
                        },
                  child: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : const Text("Send"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> locationCheckIn(
      double lat, double lon, HistoryModel history) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiService
          .post('api/events/${widget.eventId}/geography-checkin', {
        'Latitude': lat,
        'Longitude': lon,
        'AttendanceAttempt': history.attendanceTimes,
      });
      if (response.statusCode == 200) {
        if (mounted) {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.success,
            animType: AnimType.scale,
            title: 'Success',
            desc: 'Successfully checked in',
            btnOkOnPress: () {
              context.pop();
            },
          ).show();
        }
      } else {
        _showErrorDialog('Failed to check in: ${response.body}');
      }
    } catch (e) {
      _showErrorDialog('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _checkLocationAndCheckIn(HistoryModel history) async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showErrorDialog("Turn on GPS to check in.");
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showErrorDialog("GPS permission is denied.");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showErrorDialog(
          "GPS permission is permanently denied, you can enable it in app settings.");
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    // Gọi API để điểm danh
    await locationCheckIn(position.latitude, position.longitude, history);
  }

  void _showErrorDialog(String message) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.bottomSlide,
      title: 'Error',
      desc: message,
      btnCancelOnPress: () {},
    ).show();
  }

  @override
  void initState() {
    super.initState();
    _eventFuture = getDetail(widget.eventId);
    _eventHistoryFuture = getHistoryDetail(widget.eventId);
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
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDarkMode
        ? Theme.of(context).textTheme.bodyLarge!.color!
        : Colors.black54;
    final Color titleColor = isDarkMode
        ? Theme.of(context).textTheme.headlineLarge!.color!
        : Colors.black;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    double getResponsiveFontSize(double baseFontSize) {
      if (screenWidth > 480) {
        return baseFontSize * 1.25;
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
            icon: Icon(Icons.arrow_back, color: titleColor),
            onPressed: () => context.pop(),
          ),
        ),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: BlurryModalProgressHUD(
        inAsyncCall: _isLoading,
        opacity: 0.3,
        blurEffectIntensity: 5,
        child: FutureBuilder<List<dynamic>>(
          future: Future.wait([
            _eventFuture,
            _eventHistoryFuture,
          ]),
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
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  'No data available',
                  style: TextStyle(
                    fontSize: getResponsiveFontSize(16),
                  ),
                ),
              );
            } else {
              final event = snapshot.data![0] as EventModel;
              final history = snapshot.data![1] as HistoryModel;

              return RefreshIndicator(
                onRefresh: _onRefresh,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Container(
                        width: screenWidth * 0.9,
                        height: screenHeight * 0.8,
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
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
                                color: titleColor,
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
                                        : Colors.green,
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
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Event Date and Time
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.access_time,
                                        size: 20, color: Colors.blue),
                                    const SizedBox(width: 8),
                                    Text(
                                      "${formatTime(event.startTime)} - ${formatTime(event.endTime)}",
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: getResponsiveFontSize(14),
                                      ),
                                    ),
                                  ],
                                ),
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
                                  "${formatDate(event.startTime)}",
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: getResponsiveFontSize(14),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 50),
                            if (event.eventStatus ==
                                EventStatus.inProgress) ...[
                              Center(
                                child: Text(
                                  "Check In",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: getResponsiveFontSize(24),
                                    color: textColor,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Center(
                                child: SizedBox(
                                  // width: screenWidth * 0.5,
                                  // height: screenHeight * 0.05,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      _showQrCodeScanner(
                                          context, event, history);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF0FB900),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                              const SizedBox(height: 20),
                              Center(
                                child: SizedBox(
                                  // width: screenWidth * 0.5,
                                  // height: screenHeight * 0.05,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      context.push(
                                          '/event-face-check-in/${event.id}/${history.attendanceTimes}');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF0FB900),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.face,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "BIOMETRICS",
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
                              const SizedBox(height: 20),
                              Center(
                                child: SizedBox(
                                  // width: screenWidth * 0.5,
                                  // height: screenHeight * 0.05,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      _checkLocationAndCheckIn(history);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF0FB900),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.pin_drop,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "LOCATION",
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
                              const SizedBox(height: 20),
                              Center(
                                child: SizedBox(
                                  // width: screenWidth * 0.5,
                                  // height: screenHeight * 0.05,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      _showAbsentLateDialog(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(
                                          255, 255, 204, 0),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.access_time,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "ABSENT/LATE",
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
