import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:blurry_modal_progress_hud/blurry_modal_progress_hud.dart';
import 'package:go_router/go_router.dart';
import 'package:itproject/enums/event_status.dart';
import 'package:itproject/models/event_model.dart';
import 'package:itproject/services/api_service.dart';

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
                              },
                            ),
                            const Divider(),
                            ListTile(
                              leading: const Icon(Icons.check_circle_outline,
                                  color: Colors.blue),
                              title: const Text("Activate"),
                              onTap: () {
                                // Handle activation
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
