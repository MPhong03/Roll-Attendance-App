import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:blurry_modal_progress_hud/blurry_modal_progress_hud.dart';
import 'package:flutter/material.dart';
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

  // late Future<EventModel> _eventFuture;
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
      // _eventFuture = getDetail(widget.eventId);
      _usersFuture = fetchEventUsers(widget.eventId);
    });
  }

  @override
  void initState() {
    super.initState();
    // _eventFuture = getDetail(widget.eventId);
    _usersFuture = fetchEventUsers(widget.eventId);
  }

  @override
Widget build(BuildContext context) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;

  return BlurryModalProgressHUD(
    inAsyncCall: _isLoading,
    opacity: 0.3,
    blurEffectIntensity: 5,
    child: Scaffold(
      appBar: AppBar(
        backgroundColor: isDarkMode ? const Color(0xFF121212) : const Color(0xFFE9FCE9),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.add,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
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
                child: CircularProgressIndicator(),
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
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(user.avatar),
                        radius: 25,
                      ),
                      title: Text(
                        user.displayName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        user.email,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.more_vert),
                        onPressed: () {
                          // Handle more options for user
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Options for ${user.displayName} pressed'),
                            ),
                          );
                        },
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
