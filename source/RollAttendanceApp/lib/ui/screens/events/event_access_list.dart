import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:blurry_modal_progress_hud/blurry_modal_progress_hud.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:itproject/models/event_model.dart';
import 'package:itproject/models/user_model.dart';
import 'package:itproject/services/api_service.dart';
import 'package:itproject/ui/components/events/event_access_list_sheet.dart';

class EventAccessListScreen extends StatefulWidget {
  final String eventId;

  const EventAccessListScreen({super.key, required this.eventId});

  @override
  State<EventAccessListScreen> createState() => _EventAccessListScreenState();
}

class _EventAccessListScreenState extends State<EventAccessListScreen> {
  final ApiService _apiService = ApiService();
  final List<String> _selectedUserIds = [];

  String _organizationId = "";
  bool _isLoading = false;

  late Future<EventModel> _eventFuture;
  late Future<List<UserModel>> _usersFuture;

  Future<EventModel> getDetail(id) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final response = await _apiService.get('api/events/$id');

      if (response.statusCode == 200) {
        final event = EventModel.fromMap(jsonDecode(response.body));
        _populateFields(event);
        return event;
      } else {
        throw Exception('Failed to load event');
      }
    } catch (e) {
      throw Exception('Failed to load event: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _populateFields(EventModel event) {
    _organizationId = event.organizationId;
  }

  Future<List<UserModel>> fetchEventUsers(String eventId) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final response = await _apiService.get('api/events/users/$eventId');
      if (response.statusCode == 200) {
        final List<dynamic> userData = jsonDecode(response.body);
        _selectedUserIds.clear();
        _selectedUserIds
            .addAll(userData.map((e) => UserModel.fromJson(e).id).toList());
        return userData.map((e) => UserModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      throw Exception('Error fetching users: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _openUserSelectionSheet() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return EventAccessListSheet(
          eventId: widget.eventId,
          organizationId: _organizationId,
          alreadyAddedUserIds: _selectedUserIds,
          onUsersAdded: (List<String> selectedIds) {
            setState(() {
              _selectedUserIds.clear();
              _selectedUserIds.addAll(selectedIds);
            });
          },
        );
      },
    );

    // After modal closes, refresh access list or perform additional actions
    if (mounted) {
      _onRefresh();
    }
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

  Future<void> _onRefresh() async {
    setState(() {
      _eventFuture = getDetail(widget.eventId);
      _usersFuture = fetchEventUsers(widget.eventId);
    });
  }

  @override
  void initState() {
    super.initState();
    _eventFuture = getDetail(widget.eventId);
    _usersFuture = fetchEventUsers(widget.eventId);
  }

  @override
  Widget build(BuildContext context) {
    return BlurryModalProgressHUD(
      inAsyncCall: _isLoading,
      opacity: 0.3,
      blurEffectIntensity: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Event Access List'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _openUserSelectionSheet,
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _onRefresh,
          child: FutureBuilder<List<UserModel>>(
            future: _usersFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Text(
                    'Loading',
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              } else if (snapshot.hasData) {
                final users = snapshot.data!;
                if (users.isEmpty) {
                  return const Center(
                    child: Text('No users have access to this event.'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return Card(
                      elevation: 4.0,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundImage: NetworkImage(user.avatar),
                              onBackgroundImageError: (_, __) =>
                                  const Icon(Icons.person, size: 40),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.displayName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    user.email,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.more_vert),
                              onPressed: () {
                                // Handle more options for user
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Options for ${user.displayName} pressed'),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              } else {
                return const Center(
                  child: Text('No data found'),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
