import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:itproject/models/user_model.dart';
import 'package:itproject/services/api_service.dart';

class EventAccessListSheet extends StatefulWidget {
  final String eventId;
  final String organizationId;
  final List<String> alreadyAddedUserIds;
  final Function(List<String>) onUsersAdded;

  const EventAccessListSheet({
    Key? key,
    required this.eventId,
    required this.organizationId,
    required this.alreadyAddedUserIds,
    required this.onUsersAdded,
  }) : super(key: key);

  @override
  State<EventAccessListSheet> createState() => _EventAccessListSheetState();
}

class _EventAccessListSheetState extends State<EventAccessListSheet> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  bool _isLoadingUsers = false;
  bool _isLoadingAddUsers = false;

  int _currentPage = 1;
  final int _pageSize = 5;
  bool _hasMoreData = true;

  List<UserModel> _users = [];
  List<String> _selectedUserIds = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedUserIds = List<String>.from(widget.alreadyAddedUserIds);
    _fetchUsers();
  }

  void _loadNextPage(ScrollNotification notification) {
    if (_isLoadingUsers || !_hasMoreData) return;

    // Kiểm tra khi nào cần gọi API để tải thêm dữ liệu
    if (notification is ScrollUpdateNotification &&
        notification.metrics.pixels >=
            notification.metrics.maxScrollExtent - 10) {
      _currentPage++;
      _fetchUsers(); // Tải trang tiếp theo
    }
  }

  Future<void> _fetchUsers({bool isRefresh = false}) async {
    if (_isLoadingUsers || (!_hasMoreData && !isRefresh)) return;

    setState(() {
      _isLoadingUsers = true;
      if (isRefresh) {
        _users.clear(); // Làm mới danh sách khi tìm kiếm hoặc trang đầu tiên
        _currentPage = 1; // Đặt lại trang đầu tiên
      }
    });

    try {
      final response = await _apiService.get(
        'api/organization/getusers/${widget.organizationId}?pageIndex=$_currentPage&pageSize=$_pageSize&keyword=$_searchQuery',
      );
      if (response.statusCode == 200) {
        final List usersData = jsonDecode(response.body);
        setState(() {
          if (usersData.length < _pageSize) {
            _hasMoreData = false; // Kiểm tra nếu hết dữ liệu
          }
          if (isRefresh) {
            _users = usersData.map((user) => UserModel.fromMap(user)).toList();
          } else {
            // Khi không phải làm mới, thay thế toàn bộ danh sách
            _users = usersData.map((user) => UserModel.fromMap(user)).toList();
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading users: $e')),
      );
    } finally {
      if (mounted) {
        setState(
            () => _isLoadingUsers = false); // Cập nhật lại trạng thái loading
      }
    }
  }

  void _toggleUserSelection(String userId) {
    setState(() {
      if (_selectedUserIds.contains(userId)) {
        _selectedUserIds.remove(userId);
      } else {
        _selectedUserIds.add(userId);
      }
    });
  }

  Future<void> _addSelectedUsersToEvent() async {
    if (_isLoadingAddUsers) return;

    setState(() => _isLoadingAddUsers = true);
    try {
      // Truyền trực tiếp danh sách userIds thay vì đối tượng
      final response = await _apiService.post(
        'api/events/${widget.eventId}/add-users',
        {'userIds': _selectedUserIds}, // Truyền trực tiếp mảng userIds
      );

      if (response.statusCode == 200) {
        if (mounted) {
          widget.onUsersAdded(_selectedUserIds);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User selection updated!')),
          );
          Navigator.pop(context);
        }
      } else {
        throw Exception('Failed to add users');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add users: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingAddUsers = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      maxChildSize: 0.9,
      minChildSize: 0.6,
      builder: (context, scrollController) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Select Users'),
            actions: [
              IconButton(
                icon: _isLoadingAddUsers
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Icon(Icons.check),
                onPressed: _isLoadingAddUsers ? null : _addSelectedUsersToEvent,
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search users...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                      _currentPage = 1;
                      _hasMoreData = true;
                    });
                    _fetchUsers(isRefresh: true);
                  },
                ),
              ),
              Expanded(
                child: _isLoadingUsers && _users.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : NotificationListener<ScrollNotification>(
                        onNotification: (notification) {
                          _loadNextPage(notification);
                          return false;
                        },
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: _users.length,
                          itemBuilder: (context, index) {
                            print(index);
                            if (index == _users.length) {
                              print("$index , ${_users.length}");
                              return const Center(
                                  child:
                                      CircularProgressIndicator()); // Vòng tròn tải thêm
                            }

                            final user = _users[index];
                            final isChecked =
                                _selectedUserIds.contains(user.id);

                            return CheckboxListTile(
                              value: isChecked,
                              title: Text(user.displayName),
                              subtitle: Text(user.email),
                              onChanged: (_) => _toggleUserSelection(user.id),
                            );
                          },
                        ),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: _currentPage > 1
                          ? () {
                              setState(() {
                                _currentPage--;
                                _hasMoreData = true;
                              });
                              _fetchUsers(isRefresh: true);
                            }
                          : null,
                    ),
                    Text('Page $_currentPage'),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: _hasMoreData
                          ? () {
                              setState(() {
                                _currentPage++;
                              });
                              _fetchUsers();
                            }
                          : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
