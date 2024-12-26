import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:blurry_modal_progress_hud/blurry_modal_progress_hud.dart';
import 'package:go_router/go_router.dart';
import 'package:itproject/enums/user_role.dart';
import 'package:itproject/models/event_model.dart';
import 'package:itproject/models/organization_model.dart';
import 'package:itproject/models/user_model.dart';
import 'package:itproject/services/api_service.dart';
import 'package:itproject/services/user_service.dart';

class OrganizationDetailScreen extends StatefulWidget {
  final String organizationId;

  const OrganizationDetailScreen({super.key, required this.organizationId});

  @override
  State<OrganizationDetailScreen> createState() =>
      _OrganizationDetailScreenState();
}

class _OrganizationDetailScreenState extends State<OrganizationDetailScreen> {
  final ApiService _apiService = ApiService();
  final UserService _userService = UserService();
  bool _isLoading = false;
  late Future<OrganizationModel> _organizationFuture;
  late Future<List<EventModel>> _eventListFuture;
  late Future<List<UserModel>> _userListFuture;
  int _page = 1;
  final int _limit = 10;

  String bannerPlaceHolder =
      'https://th.bing.com/th/id/OIP.agLNnNJWhgFjK8D7AO1VdAHaDt?rs=1&pid=ImgDetMain';
  String imagePlaceHolder =
      'https://yt3.ggpht.com/a/AGF-l78urB8ASkb0JO2a6AB0UAXeEHe6-pc9UJqxUw=s900-mo-c-c0xffffffff-rj-k-no';

  Future<OrganizationModel> getDetail(id) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final response = await _apiService.get('api/organization/detail/$id');

      if (response.statusCode == 200) {
        return OrganizationModel.fromMap(jsonDecode(response.body));
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

  Future<List<EventModel>> getEvents(id) async {
    try {
      final response = await _apiService
          .get('api/events/organization/$id?page=$_page&limit=$_limit');
      if (response.statusCode == 200) {
        final List eventsData = jsonDecode(response.body);
        return eventsData.map((event) => EventModel.fromMap(event)).toList();
      } else {
        throw Exception('Failed to load events');
      }
    } catch (e) {
      throw Exception('Failed to load events: $e');
    }
  }

  Future<List<UserModel>> getUsers(id) async {
    try {
      final response = await _apiService
          .get('api/organization/getusers/$id?page=$_page&limit=$_limit');
      if (response.statusCode == 200) {
        final List usersData = jsonDecode(response.body);

        print('Raw response data: $usersData');

        return usersData.map((user) => UserModel.fromMap(user)).toList();
      } else {
        throw Exception('Failed to load events');
      }
    } catch (e) {
      throw Exception('Failed to load events: $e');
    }
  }

  void _nextPage() {
    setState(() {
      _page++;
    });
    _onRefresh();
  }

  void _prevPage() {
    if (_page > 1) {
      setState(() {
        _page--;
      });
      _onRefresh();
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      _organizationFuture = getDetail(widget.organizationId);
      _eventListFuture = getEvents(widget.organizationId);
      _userListFuture = getUsers(widget.organizationId);
    });
  }

  @override
  void initState() {
    super.initState();
    _organizationFuture = getDetail(widget.organizationId);
    _eventListFuture = getEvents(widget.organizationId);
    _userListFuture = getUsers(widget.organizationId);
  }

  @override
  Widget build(BuildContext context) {
    return BlurryModalProgressHUD(
      inAsyncCall: _isLoading,
      opacity: 0.3,
      blurEffectIntensity: 5,
      child: FutureBuilder<OrganizationModel>(
        future: _organizationFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const BlurryModalProgressHUD(
              inAsyncCall: true,
              opacity: 0.3,
              blurEffectIntensity: 5,
              child: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red)),
            );
          } else if (!snapshot.hasData) {
            return const Center(
              child: Text('No data available'),
            );
          } else {
            final organization = snapshot.data!;
            return Scaffold(
              appBar: AppBar(
                title: const Text('Organization Details'),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.pop(),
                ),
              ),
              body: RefreshIndicator(
                onRefresh: _onRefresh,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          clipBehavior: Clip.none,
                          children: <Widget>[
                            Container(
                              height: 200.0,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(
                                      organization.banner.isNotEmpty
                                          ? organization.banner
                                          : bannerPlaceHolder),
                                ),
                              ),
                              child: Container(
                                color: Colors.black.withOpacity(0.3),
                              ),
                            ),
                            Positioned(
                              top: 100.0,
                              child: Container(
                                height: 150.0,
                                width: 150.0,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: NetworkImage(
                                        organization.image.isNotEmpty
                                            ? organization.image
                                            : imagePlaceHolder),
                                  ),
                                  border: Border.all(
                                    color: Colors.transparent,
                                    width: 5.0,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 50),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(
                              organization.name,
                              style: Theme.of(context).textTheme.headlineLarge,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              organization.description,
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.location_on,
                                    color: Colors.grey),
                                const SizedBox(width: 5),
                                Text(
                                  organization.address.isNotEmpty
                                      ? organization.address
                                      : 'No address provided',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Chip(
                              label: Text(organization.isPrivate
                                  ? 'Private'
                                  : 'Public'),
                              backgroundColor: organization.isPrivate
                                  ? Colors.red
                                  : Colors.green,
                              labelStyle: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () {
                                    context.push(
                                        '/edit-organization/${widget.organizationId}');
                                  },
                                  icon: const Icon(Icons.edit),
                                  label: const Text('Edit'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // const Divider(thickness: 1, height: 40),
                      DefaultTabController(
                        length: 2, // Number of tabs
                        child: Column(
                          children: [
                            const TabBar(
                              tabs: [
                                Tab(text: 'Events'),
                                Tab(text: 'Users'),
                              ],
                            ),
                            SizedBox(
                              height: 400.0,
                              child: TabBarView(
                                children: [
                                  // Events Tab
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: SingleChildScrollView(
                                      // Wrap with SingleChildScrollView
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          const Text(
                                            'Events',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          ElevatedButton.icon(
                                            onPressed: () {
                                              context.push(
                                                  '/create-event/${widget.organizationId}');
                                            },
                                            icon: const Icon(Icons.add),
                                            label: const Text('Add Event'),
                                          ),
                                          const SizedBox(height: 10),
                                          FutureBuilder<List<EventModel>>(
                                            future: _eventListFuture,
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return const Center(
                                                    child:
                                                        CircularProgressIndicator());
                                              } else if (snapshot.hasError) {
                                                return Center(
                                                  child: Text(
                                                    'Error: ${snapshot.error}',
                                                    style: const TextStyle(
                                                        color: Colors.red),
                                                  ),
                                                );
                                              } else if (!snapshot.hasData ||
                                                  snapshot.data!.isEmpty) {
                                                return const Center(
                                                    child: Text(
                                                        'No events available'));
                                              } else {
                                                final events = snapshot.data!;
                                                return ListView.builder(
                                                  shrinkWrap: true,
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                  itemCount: events.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    final event = events[index];
                                                    return Card(
                                                      margin: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 8),
                                                      child: ListTile(
                                                        contentPadding:
                                                            const EdgeInsets
                                                                .all(16),
                                                        title: Text(event.name,
                                                            style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                        subtitle: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                                event
                                                                    .description,
                                                                maxLines: 2,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis),
                                                            const SizedBox(
                                                                height: 5),
                                                            Text(
                                                              'Start: ${event.startTime?.toLocal().toString() ?? 'N/A'}',
                                                              style: const TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .grey),
                                                            ),
                                                            Text(
                                                              'End: ${event.endTime?.toLocal().toString() ?? 'N/A'}',
                                                              style: const TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .grey),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                );
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Users Tab
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: SingleChildScrollView(
                                      // Wrap with SingleChildScrollView
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          const Text(
                                            'Users',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          ElevatedButton.icon(
                                            onPressed: () {
                                              context.push(
                                                  '/add-to-organization/${widget.organizationId}');
                                            },
                                            icon: const Icon(Icons.add),
                                            label: const Text('Add User'),
                                          ),
                                          const SizedBox(height: 10),
                                          FutureBuilder<List<UserModel>>(
                                            future: _userListFuture,
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return const Center(
                                                    child:
                                                        CircularProgressIndicator());
                                              } else if (snapshot.hasError) {
                                                return Center(
                                                  child: Text(
                                                    'Error: ${snapshot.error}',
                                                    style: const TextStyle(
                                                        color: Colors.red),
                                                  ),
                                                );
                                              } else if (!snapshot.hasData ||
                                                  snapshot.data!.isEmpty) {
                                                return const Center(
                                                    child: Text(
                                                        'No users available'));
                                              } else {
                                                final users = snapshot.data!;
                                                return ListView.builder(
                                                  shrinkWrap: true,
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                  itemCount: users.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    final user = users[index];
                                                    final role =
                                                        getRoleFromValue(
                                                            user.role ?? 0);
                                                    return Card(
                                                      margin: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 8),
                                                      child: ListTile(
                                                        contentPadding:
                                                            const EdgeInsets
                                                                .all(16),
                                                        leading: CircleAvatar(
                                                          backgroundImage:
                                                              NetworkImage(
                                                                  user.avatar),
                                                          radius: 25,
                                                        ),
                                                        title: Text(
                                                            user.displayName,
                                                            style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                        subtitle: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(user.email,
                                                                maxLines: 2,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis),
                                                            const SizedBox(
                                                                height: 5),
                                                            Text(
                                                              'Role: $role',
                                                              style: const TextStyle(
                                                                  fontStyle:
                                                                      FontStyle
                                                                          .italic),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                );
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
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
        },
      ),
    );
  }
}
