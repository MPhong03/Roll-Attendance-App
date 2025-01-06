import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:blurry_modal_progress_hud/blurry_modal_progress_hud.dart';
import 'package:go_router/go_router.dart';
import 'package:itproject/enums/event_status.dart';
import 'package:itproject/models/event_model.dart';
import 'package:itproject/services/api_service.dart';
import 'package:itproject/ui/components/events/preview_event_modal.dart';
import 'package:qr_flutter/qr_flutter.dart';

class EventDetailScreen extends StatefulWidget {
  final String eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
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

  Future<void> _onDeleteEvent() async {
    // TODO:
  }

  Future<void> _onRefresh() async {
    setState(() {
      _eventFuture = getDetail(widget.eventId);
    });
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

  @override
  void initState() {
    super.initState();
    _eventFuture = getDetail(widget.eventId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
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
                  style: const TextStyle(color: Colors.red),
                ),
              );
            } else if (!snapshot.hasData) {
              return const Center(child: Text('No data available'));
            } else {
              final event = snapshot.data!;
              return RefreshIndicator(
                onRefresh: _onRefresh,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Event Details
                        Text(
                          event.name,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
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
                                color:
                                    event.isPrivate ? Colors.red : Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          event.description,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),

                        // Event Date and Time
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              event.startTime != null
                                  ? "Starts: ${event.startTime}"
                                  : "Start time not available",
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              event.endTime != null
                                  ? "Ends: ${event.endTime}"
                                  : "End time not available",
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Event Status
                        Row(
                          children: [
                            const Icon(Icons.info_outline, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              "Status: ${event.eventStatus.name}",
                              style: TextStyle(
                                color:
                                    event.eventStatus == EventStatus.inProgress
                                        ? Colors.green
                                        : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ACTIONS
                            Text(
                              "Actions",
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            ListTile(
                              leading:
                                  const Icon(Icons.edit, color: Colors.blue),
                              title: const Text("Edit"),
                              onTap: () {
                                // Navigate to edit screen
                                context.push('/edit-event/${event.id}');
                              },
                            ),
                            const Divider(),
                            ListTile(
                              leading:
                                  const Icon(Icons.list, color: Colors.blue),
                              title: const Text("Access List"),
                              onTap: () {
                                // Navigate to access list screen
                                context.push('/event-access-list/${event.id}');
                              },
                            ),
                            const Divider(),
                            ListTile(
                              leading: const Icon(Icons.check_circle_outline,
                                  color: Colors.blue),
                              title: const Text("Activate"),
                              onTap: () {
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
                              },
                            ),
                            const Divider(),
                            ListTile(
                              leading: const Icon(Icons.delete_outline,
                                  color: Colors.red),
                              title: const Text("Delete"),
                              onTap: () {
                                // Handle deletion
                              },
                            ),
                            const SizedBox(height: 20),

                            // "CHECK IN
                            if (event.eventStatus ==
                                EventStatus.inProgress) ...[
                              Text(
                                "Check In",
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 16),
                              ListTile(
                                leading: const Icon(Icons.qr_code,
                                    color: Colors.blue),
                                title: const Text("QR"),
                                onTap: () {
                                  _showQrCodeDialog(context, event);
                                },
                              ),
                              const Divider(),
                              ListTile(
                                leading: const Icon(Icons.location_on,
                                    color: Colors.blue),
                                title: const Text("Location"),
                                onTap: () {
                                  // Handle location action (Develop later)
                                },
                              ),
                              const Divider(),
                              ListTile(
                                leading: const Icon(Icons.fingerprint,
                                    color: Colors.blue),
                                title: const Text("Biometrics"),
                                onTap: () {
                                  // Handle biometrics action (Develop later)
                                },
                              ),
                              const Divider(),
                              ListTile(
                                leading: const Icon(Icons.history,
                                    color: Colors.blue),
                                title: const Text("History"),
                                onTap: () {
                                  // Handle history action (Develop later)
                                },
                              ),
                              const Divider(),
                              ListTile(
                                leading:
                                    const Icon(Icons.add, color: Colors.blue),
                                title: const Text("Attempt"),
                                onTap: () {
                                  // Handle attempt action (Develop later)
                                },
                              ),
                              const Divider(),
                              ListTile(
                                leading: const Icon(Icons.check,
                                    color: Colors.green),
                                title: const Text("Complete"),
                                onTap: () {
                                  // Handle attempt action (Develop later)
                                },
                              ),
                            ],
                          ],
                        ),
                      ],
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
