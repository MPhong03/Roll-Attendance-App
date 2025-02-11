import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:blurry_modal_progress_hud/blurry_modal_progress_hud.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:itproject/models/event_model.dart';
import 'package:itproject/models/organization_model.dart';
import 'package:itproject/models/user_model.dart';
import 'package:itproject/services/api_service.dart';
import 'package:itproject/services/user_service.dart';
import 'package:itproject/ui/components/organizations/org_event_card.dart';
import 'package:itproject/ui/components/organizations/org_user_card.dart';

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
  List<String> _selectedUserIds = [];

  late int roleNumber = 0;
  late String roleName = "Unknown";

  // int _page = 1;
  int _pageEvent = 1;
  int _pageUser = 1;
  final int _limit = 10;

  bool _hasMoreEvents = true;
  bool _hasMoreUsers = true;

  String bannerPlaceHolder =
      'https://th.bing.com/th/id/OIP.agLNnNJWhgFjK8D7AO1VdAHaDt?rs=1&pid=ImgDetMain';
  String imagePlaceHolder =
      'https://yt3.ggpht.com/a/AGF-l78urB8ASkb0JO2a6AB0UAXeEHe6-pc9UJqxUw=s900-mo-c-c0xffffffff-rj-k-no';

  Future<void> initData(id) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final data = await _userService.getUserRoleInOrganization(id);

      roleNumber = data.keys.first;
      roleName = data.values.first;
    } catch (e) {
      throw Exception('Failed to load user role: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

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
      final response = await _apiService.get(
          'api/events/organization/$id?pageIndex=$_pageEvent&pageSize=$_limit');
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
      final response = await _apiService.get(
          'api/organization/getusers/$id?pageIndex=$_pageUser&pageSize=$_limit');
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

  Future<void> _loadMoreEvents() async {
    if (!_hasMoreEvents) return;

    try {
      final response = await _apiService.get(
          'api/events/organization/${widget.organizationId}?pageIndex=${_pageEvent + 1}&pageSize=$_limit');
      if (response.statusCode == 200) {
        final List eventsData = jsonDecode(response.body);
        if (eventsData.isNotEmpty) {
          setState(() {
            _pageEvent++;
            _eventListFuture = _eventListFuture.then((existingEvents) =>
                existingEvents +
                eventsData.map((e) => EventModel.fromMap(e)).toList());
          });
        } else {
          setState(() {
            _hasMoreEvents = false;
          });
        }
      }
    } catch (e) {
      throw Exception('Failed to load more events: $e');
    }
  }

  Future<void> _loadMoreUsers() async {
    if (!_hasMoreUsers) return;

    try {
      final response = await _apiService.get(
          'api/organization/getusers/${widget.organizationId}?pageIndex=${_pageUser + 1}&pageSize=$_limit');
      if (response.statusCode == 200) {
        final List usersData = jsonDecode(response.body);
        if (usersData.isNotEmpty) {
          setState(() {
            _pageUser++;
            _userListFuture = _userListFuture.then((existingUsers) =>
                existingUsers +
                usersData.map((u) => UserModel.fromMap(u)).toList());
          });
        } else {
          setState(() {
            _hasMoreUsers = false;
          });
        }
      }
    } catch (e) {
      throw Exception('Failed to load more users: $e');
    }
  }

  Future<void> _removeUsers(List<String> userIds) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final requestBody = {
        "userIds": userIds,
      };
      final response = await _apiService.put(
          'api/organization/remove-list/${widget.organizationId}', requestBody);
      if (response.statusCode == 200) {
        if (mounted) {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.success,
            animType: AnimType.scale,
            title: 'Success',
            desc: 'Remove users successfully',
            btnOkOnPress: () {
              context.pop();
            },
          ).show();
        }
      } else {
        _showErrorDialog(
            'Failed to update event: ${jsonDecode(response.body)['message']}');
      }
    } catch (e) {
      _showErrorDialog('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteOrganization() async {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.scale,
      title: 'Confirm Delete',
      desc: 'Are you sure you want to delete this organization?',
      btnOkText: 'Yes',
      btnCancelText: 'No',
      btnOkOnPress: () async {
        setState(() {
          _isLoading = true;
        });

        try {
          final response = await _apiService
              .delete('api/organization/${widget.organizationId}');
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
                'Failed to delete organization: ${jsonDecode(response.body)['message']}');
          }
        } catch (e) {
          _showErrorDialog('Error: $e');
        } finally {
          setState(() {
            _isLoading = false;
          });
        }
      },
      btnCancelOnPress: () {},
    ).show();
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

    initData(widget.organizationId);
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return BlurryModalProgressHUD(
      inAsyncCall: _isLoading,
      opacity: 0.3,
      blurEffectIntensity: 5,
      child: FutureBuilder<OrganizationModel>(
        future: _organizationFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red)),
            );
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data available'));
          } else {
            final organization = snapshot.data!;

            return DefaultTabController(
              length: 3,
              child: Scaffold(
                appBar: AppBar(
                  backgroundColor:
                      isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                  elevation: 0,
                  leading: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                    onPressed: () {
                      GoRouter.of(context).go('/organization');
                    },
                  ),
                  iconTheme: IconThemeData(
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(48.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: isDarkMode
                                ? Colors.white.withOpacity(0.2)
                                : Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TabBar(
                        indicator: BoxDecoration(
                          color: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        labelColor: Colors.green,
                        unselectedLabelColor:
                            isDarkMode ? Colors.white : Colors.black,
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        unselectedLabelStyle: const TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 16,
                        ),
                        tabs: const [
                          Tab(text: 'Info'),
                          Tab(text: 'Events'),
                          Tab(text: 'Users'),
                        ],
                      ),
                    ),
                  ),
                ),
                body: RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: TabBarView(
                    children: [
                      SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Stack(
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
                                            : bannerPlaceHolder,
                                      ),
                                    ),
                                  ),
                                  child: Container(
                                    color: Colors.black.withOpacity(0.3),
                                  ),
                                ),
                                Positioned(
                                  top: 150.0,
                                  child: Container(
                                    height: 120.0,
                                    width: 120.0,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: NetworkImage(
                                          organization.image.isNotEmpty
                                              ? organization.image
                                              : imagePlaceHolder,
                                        ),
                                      ),
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 3.0,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 6,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 70),

                            // Thông tin tổ chức
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    organization.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall!
                                        .copyWith(fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    organization.description,
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 20),

                                  // Địa chỉ
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.location_on,
                                          color: Colors.grey.shade700),
                                      const SizedBox(width: 5),
                                      Text(
                                        organization.address.isNotEmpty
                                            ? organization.address
                                            : 'No address provided',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 15),

                                  // Trạng thái tổ chức và Role người dùng
                                  Wrap(
                                    spacing: 10,
                                    alignment: WrapAlignment.center,
                                    children: [
                                      Chip(
                                        label: Text(
                                          organization.isPrivate
                                              ? 'Private'
                                              : 'Public',
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                        backgroundColor: organization.isPrivate
                                            ? Colors.red
                                            : Colors.green,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 15),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 4, horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.person,
                                            size: 16, color: Colors.black54),
                                        SizedBox(width: 5),
                                        Text(
                                          roleName,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 40),

                            // Các nút hành động
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Column(
                                children: [
                                  _buildButton(
                                    context: context,
                                    roleNumber: roleNumber,
                                    title: 'Edit',
                                    icon: Icons.edit,
                                    color: Colors.green,
                                    onPressed: () {
                                      context.push(
                                          '/edit-organization/${widget.organizationId}');
                                    },
                                    permissionMessage:
                                        "You don't have permission to edit this organization",
                                  ),
                                  const SizedBox(height: 12),
                                  _buildButton(
                                    context: context,
                                    roleNumber: roleNumber,
                                    title: 'Requests',
                                    icon: Icons.mail,
                                    color: Colors.blue,
                                    onPressed: () {
                                      context.push(
                                          '/organization-requests/${widget.organizationId}');
                                    },
                                    permissionMessage:
                                        "You don't have permission to view requests",
                                  ),
                                  const SizedBox(height: 12),
                                  _buildButton(
                                    context: context,
                                    roleNumber: roleNumber,
                                    title: 'Delete',
                                    icon: Icons.delete,
                                    color: Colors.red,
                                    onPressed: _deleteOrganization,
                                    permissionMessage:
                                        "You don't have permission to delete this organization",
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 30),
                          ],
                        ),
                      ),

                      // **Tab Events**
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Stack(
                          children: [
                            // Danh sách sự kiện có thể cuộn
                            Padding(
                              padding: const EdgeInsets.only(top: 60.0),
                              child: SingleChildScrollView(
                                child: FutureBuilder<List<EventModel>>(
                                  future: _eventListFuture,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    } else if (snapshot.hasError) {
                                      return Center(
                                          child:
                                              Text('Error: ${snapshot.error}'));
                                    } else if (!snapshot.hasData ||
                                        snapshot.data!.isEmpty) {
                                      return const Center(
                                          child: Text('No events available'));
                                    } else {
                                      final events = snapshot.data!;
                                      return Column(
                                        children: [
                                          ListView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemCount: events.length,
                                            itemBuilder: (context, index) {
                                              final event = events[index];
                                              return OrgEventCard(
                                                  event: event,
                                                  roleNumber: roleNumber);
                                            },
                                          ),
                                          if (_hasMoreEvents)
                                            Center(
                                              child: GestureDetector(
                                                onTap: _loadMoreEvents,
                                                child: const Text(
                                                  "Load More",
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                        ],
                                      );
                                    }
                                  },
                                ),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  if (roleNumber == 1) {
                                    Fluttertoast.showToast(
                                      msg:
                                          "You don't have permission to create an event",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                    );
                                  } else {
                                    context.push(
                                        '/create-event/${widget.organizationId}');
                                  }
                                },
                                icon:
                                    const Icon(Icons.add, color: Colors.white),
                                label: const Text(
                                  'Add Event',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: roleNumber == 1
                                      ? Colors.grey
                                      : Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // **Tab Users**
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 60.0),
                              child: SingleChildScrollView(
                                child: FutureBuilder<List<UserModel>>(
                                  future: _userListFuture,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    } else if (snapshot.hasError) {
                                      return Center(
                                          child:
                                              Text('Error: ${snapshot.error}'));
                                    } else if (!snapshot.hasData ||
                                        snapshot.data!.isEmpty) {
                                      return const Center(
                                          child: Text('No users available'));
                                    } else {
                                      final users = snapshot.data!;
                                      return Column(
                                        children: [
                                          OrgUserCard(
                                            users: users,
                                            onUserSelectionChanged:
                                                (selectedUserIds) {
                                              setState(() {
                                                _selectedUserIds =
                                                    selectedUserIds;
                                              });
                                            },
                                          ),
                                          if (_hasMoreUsers)
                                            Center(
                                              child: GestureDetector(
                                                onTap: _loadMoreUsers,
                                                child: const Text(
                                                  "Load More",
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                        ],
                                      );
                                    }
                                  },
                                ),
                              ),
                            ),
                            if (_selectedUserIds.isNotEmpty)
                              Positioned(
                                bottom: 16,
                                left: 16,
                                right: 16,
                                child: ElevatedButton.icon(
                                  onPressed: roleNumber == 3
                                      ? () async {
                                          bool shouldRemove = false;

                                          await AwesomeDialog(
                                            context: context,
                                            dialogType: DialogType.warning,
                                            animType: AnimType.topSlide,
                                            title: 'Confirm Remove',
                                            desc:
                                                'Are you sure you want to remove selected users?',
                                            btnOkOnPress: () {
                                              shouldRemove = true;
                                            },
                                            btnCancelOnPress: () {
                                              shouldRemove = false;
                                            },
                                          ).show();

                                          if (shouldRemove) {
                                            await _removeUsers(
                                                _selectedUserIds);
                                            _onRefresh();
                                          }
                                        }
                                      : () {
                                          Fluttertoast.showToast(
                                            msg:
                                                "You don't have permission to remove users",
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.BOTTOM,
                                            backgroundColor: Colors.red,
                                            textColor: Colors.white,
                                          );
                                        },
                                  icon: const Icon(Icons.delete,
                                      color: Colors.white),
                                  label: const Text(
                                    'Remove',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: roleNumber == 3
                                        ? Colors.red
                                        : Colors.grey,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              child: ElevatedButton.icon(
                                onPressed: roleNumber == 3
                                    ? () {
                                        context.push(
                                            '/add-to-organization/${widget.organizationId}');
                                      }
                                    : () {
                                        Fluttertoast.showToast(
                                          msg:
                                              "You don't have permission to add users",
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                          backgroundColor: Colors.red,
                                          textColor: Colors.white,
                                        );
                                      },
                                icon:
                                    const Icon(Icons.add, color: Colors.white),
                                label: const Text(
                                  'Add User',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: roleNumber == 3
                                      ? Colors.green
                                      : Colors.grey, // Disable màu nút
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
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

  Widget _buildButton({
    required BuildContext context,
    required int roleNumber,
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required String permissionMessage,
  }) {
    bool hasPermission = roleNumber == 3;

    return Container(
      width: MediaQuery.of(context).size.width * 0.5,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: hasPermission ? color : Colors.grey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: hasPermission ? color : Colors.grey),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextButton.icon(
        onPressed: hasPermission
            ? onPressed
            : () {
                Fluttertoast.showToast(
                  msg: permissionMessage,
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                );
              },
        icon: Icon(icon, color: hasPermission ? Colors.white : Colors.black45),
        label: Text(
          title,
          style:
              TextStyle(color: hasPermission ? Colors.white : Colors.black45),
        ),
      ),
    );
  }
}
