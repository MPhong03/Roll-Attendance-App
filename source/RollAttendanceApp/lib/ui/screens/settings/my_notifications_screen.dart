import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:itproject/models/notification_model.dart';
import 'package:itproject/services/api_service.dart';

class MyNotificationsScreen extends StatefulWidget {
  const MyNotificationsScreen({super.key});

  @override
  State<MyNotificationsScreen> createState() => _MyNotificationsScreenState();
}

class _MyNotificationsScreenState extends State<MyNotificationsScreen> {
  final ApiService _apiService = ApiService();
  List<NotificationModel> _notifications = [];
  int _totalRecords = 0;
  int _pageIndex = 1;
  final int _pageSize = 10;
  bool _isLoading = false;

  Future<void> _fetchNotifications() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.get(
        'api/Users/notifications',
        queryParams: {
          'pageNumber': _pageIndex.toString(),
          'pageSize': _pageSize.toString(),
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final List items = responseBody['items'] ?? [];
        setState(() {
          _notifications =
              items.map((e) => NotificationModel.fromJson(e)).toList();
          _totalRecords = responseBody['totalRecords'] ?? 0;
        });
      } else {
        throw Exception('Failed to load notifications');
      }
    } catch (e) {
      debugPrint('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _nextPage() {
    if ((_pageIndex * _pageSize) < _totalRecords) {
      setState(() {
        _pageIndex++;
      });
      _fetchNotifications();
    }
  }

  void _prevPage() {
    if (_pageIndex > 1) {
      setState(() {
        _pageIndex--;
      });
      _fetchNotifications();
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _notifications.isEmpty
                    ? const Center(child: Text('No notifications available.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(8.0),
                        itemCount: _notifications.length,
                        itemBuilder: (context, index) {
                          final notification = _notifications[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    notification.title ?? "Unknown",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    notification.body ?? "Unknown",
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  const SizedBox(height: 10),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: TextButton(
                                      onPressed: () => context
                                          .push(notification.route ?? "/home"),
                                      child: const Text(
                                        "Xem chi tiết",
                                        style: TextStyle(color: Colors.green),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _pageIndex > 1 ? _prevPage : null,
                  child: const Text('Previous'),
                ),
                Text('Page $_pageIndex'),
                ElevatedButton(
                  onPressed: (_pageIndex * _pageSize) < _totalRecords
                      ? _nextPage
                      : null,
                  child: const Text('Next'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
