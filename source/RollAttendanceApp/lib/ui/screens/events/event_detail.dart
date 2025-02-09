import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:blurry_modal_progress_hud/blurry_modal_progress_hud.dart';
import 'package:go_router/go_router.dart';
import 'package:itproject/enums/event_status.dart';
import 'package:itproject/models/event_history_model.dart';
import 'package:itproject/models/event_history_model.dart';
import 'package:itproject/models/event_model.dart';
import 'package:intl/intl.dart';
import 'package:itproject/services/api_service.dart';
import 'package:itproject/ui/components/events/preview_event_modal.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:geolocator/geolocator.dart';

class EventDetailScreen extends StatefulWidget {
  final String eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  late Future<List<dynamic>> _combinedFuture;
  late Future<EventModel> _eventFuture;
  late Future<HistoryModel> _historyFuture;

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

  Future<void> _onActivateEvent(String id) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final response = await _apiService.post('api/events/$id/activate');

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Event activated")),
        );
      } else {
        throw Exception('Failed to activate event');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _onAddEventAttempt(String id) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final response = await _apiService.post('api/events/$id/add-attempt');

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Successfully add attempt")),
          );
          context.push('/event-history/$id');
        }
      } else {
        if (mounted) {
          final message = jsonDecode(response.body)['message'];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _onCompleteEvent(String id) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final response = await _apiService.post('api/events/$id/complete');

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Completed!")),
          );
          context.push('/event-history/$id');
        }
      } else {
        if (mounted) {
          final message = jsonDecode(response.body)['message'];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _onCancelEvent() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response =
          await _apiService.post('api/events/${widget.eventId}/cancel');
      if (response.statusCode == 200) {
        if (mounted) {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.success,
            animType: AnimType.scale,
            title: 'Success',
            desc: 'Cancel successfully',
            btnOkOnPress: () {
              context.pop();
            },
          ).show();
        }
      } else {
        _showErrorDialog(
            'Failed to cancel event: ${jsonDecode(response.body)['message']}');
      }
    } catch (e) {
      _showErrorDialog('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _onDeleteEvent() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiService.delete('api/events/${widget.eventId}');
      if (response.statusCode == 200) {
        if (mounted) {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.success,
            animType: AnimType.scale,
            title: 'Success',
            desc: 'Delete successfully',
            btnOkOnPress: () {
              context.pop();
            },
          ).show();
        }
      } else {
        _showErrorDialog(
            'Failed to delete event: ${jsonDecode(response.body)['message']}');
      }
    } catch (e) {
      _showErrorDialog('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      _eventFuture = getDetail(widget.eventId);
      _historyFuture = getHistory(widget.eventId);
    });
  }

  Future<HistoryModel> getHistory(id) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final response = await _apiService.get('api/histories/$id');

      if (response.statusCode == 200) {
        final history = HistoryModel.fromMap(jsonDecode(response.body));
        return history;
      } else {
        return HistoryModel();
      }
    } catch (e) {
      print('Failed to load event: $e');
      return HistoryModel();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // METHOD
  void _showQrCodeDialog(BuildContext context, EventModel event) {
    final qrData = {
      'eventId': event.id,
      'qr': event.currentQR,
    };
    final qrDataString = jsonEncode(qrData);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("QR Code"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            QrImageView(
              data: qrDataString,
              backgroundColor: Colors.white,
              version: QrVersions.auto,
              size: 200.0,
            ),
            // const SizedBox(height: 16),
            // Text(
            //   'Event ID: ${event.id}\nQR Code: ${event.currentQR}',
            //   textAlign: TextAlign.center,
            //   style: const TextStyle(fontSize: 16),
            // ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLocationAction(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    _showLocationModal(context, position);
  }

  void _showLocationModal(BuildContext context, Position position) {
    TextEditingController radiusController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: radiusController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Enter radius (meters)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      String radius = radiusController.text;
                      print("Latitude: ${position.latitude}");
                      print("Longitude: ${position.longitude}");
                      print("Radius: $radius meters");

                      bool result = await updateEventCheckInLocation(
                        widget.eventId,
                        position.latitude,
                        position.longitude,
                        double.parse(radius),
                      );

                      if (mounted) {
                        if (result) {
                          AwesomeDialog(
                            context: context,
                            dialogType: DialogType.success,
                            animType: AnimType.scale,
                            title: "Thành công",
                            desc: "Đã cập nhật vị trí check-in thành công!",
                            btnOkOnPress: () {
                              Navigator.pop(context);
                            },
                          ).show();
                        } else {
                          AwesomeDialog(
                            context: context,
                            dialogType: DialogType.error,
                            animType: AnimType.scale,
                            title: "Lỗi",
                            desc:
                                "Có lỗi xảy ra khi cập nhật. Vui lòng thử lại!",
                            btnOkOnPress: () {},
                          ).show();
                        }
                      }
                    },
                    child: const Text("Activate"),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Future<bool> updateEventCheckInLocation(
      String id, double lat, double lon, double radius) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final response = await _apiService.post(
          'api/events/$id/activate-geography-checkin',
          {"Latitude": lat, "Longitude": lon, "Radius": radius});

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Failed to load event: $e');
      return false;
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _eventFuture = getDetail(widget.eventId);
    _historyFuture = getHistory(widget.eventId);

    _combinedFuture = Future.wait([_eventFuture, _historyFuture]);
  }

  String formatTime(DateTime? time) {
    if (time == null) return '';
    return DateFormat('hh:mm a').format(time);
  }

  String formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd/MM/yyyy').format(date);
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final isDarkMode = theme.brightness == Brightness.dark;
    final textColor =
        isDarkMode ? theme.textTheme.bodyLarge!.color! : Colors.black54;
    final titleColor =
        isDarkMode ? theme.textTheme.headlineLarge!.color! : Colors.black;

    double getResponsiveFontSize(double base) =>
        screenSize.width > 480 ? base * 1.25 : base;

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
      backgroundColor: theme.scaffoldBackgroundColor,
      body: BlurryModalProgressHUD(
        inAsyncCall: _isLoading,
        opacity: 0.3,
        blurEffectIntensity: 5,
        child: FutureBuilder<List<dynamic>>(
          future: Future.wait([_eventFuture, _historyFuture]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}',
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: getResponsiveFontSize(16))),
              );
            }
            if (!snapshot.hasData) {
              return Center(
                child: Text('No data available',
                    style: TextStyle(fontSize: getResponsiveFontSize(16))),
              );
            }

            final event = snapshot.data![0] as EventModel;
            final history = snapshot.data![1] as HistoryModel;

            return RefreshIndicator(
              onRefresh: _onRefresh,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Container(
                    width: screenSize.width * 0.9,
                    height: screenSize.height * 0.8, // Chiều cao cố định 80%
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color:
                          isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
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
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                          12), // Đảm bảo nội dung không tràn viền
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildEventTitle(
                                event.name, titleColor, getResponsiveFontSize),
                            _buildPrivacyRow(
                                event.isPrivate, theme, getResponsiveFontSize),
                            _buildDescription(event.description, textColor,
                                getResponsiveFontSize),
                            _buildDateTime(
                                event, textColor, getResponsiveFontSize),
                            _buildButtons(event, history, screenSize,
                                getResponsiveFontSize),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEventTitle(
      String name, Color titleColor, Function(double) fontSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: fontSize(24),
            color: titleColor,
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildPrivacyRow(
      bool isPrivate, ThemeData theme, Function(double) fontSize) {
    return Row(
      children: [
        const Icon(Icons.lock_outline, size: 20),
        const SizedBox(width: 8),
        Text(
          isPrivate ? "Private Event" : "Public Event",
          style: TextStyle(
            color: isPrivate ? Colors.red : Colors.green,
            fontSize: fontSize(16),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDescription(
      String description, Color textColor, Function(double) fontSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(description,
            style: TextStyle(fontSize: fontSize(16), color: textColor)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDateTime(
      EventModel event, Color textColor, Function(double) fontSize) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.access_time, size: 20, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  "${formatTime(event.startTime)} - ${formatTime(event.endTime)}",
                  style: TextStyle(color: textColor, fontSize: fontSize(14)),
                ),
              ],
            ),
            Text(
              getEventStatus(event.eventStatus)["text"],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: getEventStatus(event.eventStatus)["color"],
                fontSize: fontSize(14),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Icon(Icons.calendar_today, size: 20, color: Colors.blue),
            const SizedBox(width: 8),
            Text(
              formatDate(event.startTime),
              style: TextStyle(color: textColor, fontSize: fontSize(14)),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildButtons(EventModel event, HistoryModel history, Size screenSize,
      Function(double) fontSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (var action in _eventActions(event, history))
          if (action['condition'])
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: action['isLarge'] == true ? 16.0 : 8.0,
              ),
              child: Center(
                child: SizedBox(
                  width: screenSize.width * 0.6,
                  height: action['isLarge'] == true
                      ? screenSize.height * 0.07
                      : screenSize.height * 0.05,
                  child: ElevatedButton(
                    onPressed: action['onPressed'],
                    style: ElevatedButton.styleFrom(
                      backgroundColor: action['color'],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(action['icon'], color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          action['label'],
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: fontSize(16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
      ],
    );
  }

  List<Map<String, dynamic>> _eventActions(
      EventModel event, HistoryModel history) {
    return [
      // Start Check-In or Complete
      {
        'label': event.eventStatus == EventStatus.inProgress
            ? 'Complete'
            : 'Start Check-In',
        'icon': event.eventStatus == EventStatus.inProgress
            ? Icons.check
            : Icons.play_arrow,
        'color': event.eventStatus == EventStatus.inProgress
            ? Colors.blue
            : Colors.blue,
        'onPressed': () {
          if (event.eventStatus == EventStatus.inProgress) {
            // Logic for completing the event
            AwesomeDialog(
              context: context,
              dialogType: DialogType.info,
              animType: AnimType.bottomSlide,
              title: 'Confirm',
              desc: 'Confirm mark event as complete!',
              btnCancelOnPress: () {},
              btnOkOnPress: () async {
                await _onCompleteEvent(event.id);
              },
            ).show();
          } else {
            // Logic for starting check-in
            showDialog(
              context: context,
              builder: (_) => EventPreviewModal(
                eventName: event.name,
                startTime: event.startTime,
                endTime: event.endTime,
                onCancel: () {
                  Navigator.of(context).pop();
                },
                onConfirm: () async {
                  Navigator.of(context).pop();
                  await _onActivateEvent(event.id);
                  _onRefresh();
                },
              ),
            );
          }
        },
        'condition': true,
        'isLarge': true,
      },
      {
        'label': 'Edit',
        'icon': Icons.edit,
        'color': Colors.green,
        'onPressed': () => context.push('/edit-event/${event.id}'),
        'condition': true,
      },
      {
        'label': 'Absent/Late',
        'icon': Icons.person_off,
        'color': Colors.green,
        'onPressed': () =>
            context.push('/event-permission-request/${event.id}'),
        'condition': true,
      },
      // Access List
      {
        'label': 'Access List',
        'icon': Icons.list,
        'color': Colors.green,
        'onPressed': () => context.push('/event-access-list/${event.id}'),
        'condition': true,
      },
      // QR Code
      {
        'label': 'QR',
        'icon': Icons.qr_code,
        'color': Colors.green,
        'onPressed': () => _showQrCodeDialog(context, event),
        'condition': event.eventStatus == EventStatus.inProgress,
      },
      // Location
      {
        'label': 'Location',
        'icon': Icons.location_on,
        'color': Colors.green,
        'onPressed': () async {
          // Handle location action
          await _handleLocationAction(context);
        },
        'condition': event.eventStatus == EventStatus.inProgress,
      },
      // Biometrics
      {
        'label': 'Biometrics',
        'icon': Icons.fingerprint,
        'color': Colors.green,
        'onPressed': () {
          // Handle biometrics action
          context.push(
              '/event-face-check-in/${event.id}/${history.attendanceTimes}');
        },
        'condition': event.eventStatus == EventStatus.inProgress,
      },
      // History
      {
        'label': 'History',
        'icon': Icons.history,
        'color': Colors.green,
        'onPressed': () => context.push('/event-history/${event.id}'),
        'condition': true,
      },
      // Attempt
      {
        'label': 'Attempt',
        'icon': Icons.add,
        'color': Colors.green,
        'onPressed': () {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.info,
            animType: AnimType.bottomSlide,
            title: 'Confirm',
            desc: 'Confirm create new Attempt!',
            btnCancelOnPress: () {},
            btnOkOnPress: () async {
              await _onAddEventAttempt(event.id);
            },
          ).show();
        },
        'condition': event.eventStatus == EventStatus.inProgress,
      },
      {
        'label': 'Delete',
        'icon': Icons.delete,
        'color': Colors.red,
        'onPressed': () {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.warning,
            animType: AnimType.bottomSlide,
            title: 'Confirm Deletion',
            desc: 'Are you sure you want to delete this event?',
            btnCancelOnPress: () {},
            btnOkOnPress: () async {
              await _onDeleteEvent();
            },
          ).show();
        },
        'condition': true,
      },
      // Cancel Event
      {
        'label': 'Cancel Event',
        'icon': Icons.cancel_outlined,
        'color': Colors.red,
        'onPressed': () {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.warning,
            animType: AnimType.bottomSlide,
            title: 'Confirm Cancel',
            desc: 'Are you sure you want to cancel this event?',
            btnCancelOnPress: () {},
            btnOkOnPress: () async {
              await _onCancelEvent();
            },
          ).show();
        },
        'condition': true,
        'isLarge': true,
      },
    ];
  }
}
