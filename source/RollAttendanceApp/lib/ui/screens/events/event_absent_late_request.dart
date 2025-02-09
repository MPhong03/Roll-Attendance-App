import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:itproject/models/permission_request_model.dart';
import 'package:itproject/services/api_service.dart';

class EventAbsentLateRequestScreen extends StatefulWidget {
  final String eventId;

  const EventAbsentLateRequestScreen({super.key, required this.eventId});

  @override
  State<EventAbsentLateRequestScreen> createState() =>
      _EventAbsentLateRequestScreenState();
}

class _EventAbsentLateRequestScreenState
    extends State<EventAbsentLateRequestScreen> {
  final ApiService _apiService = ApiService();
  List<PermissionRequestModel> _requests = [];
  int _totalRecords = 0;
  final int _pageIndex = 1;
  final int _pageSize = 10;
  bool _isLoading = false;

  Future<void> _fetchRequests(String eventId) async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.get(
        'api/events/absented-requests/$eventId',
        queryParams: {
          'pageIndex': _pageIndex.toString(),
          'pageSize': _pageSize.toString(),
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final List items = responseBody['items'] ?? [];
        setState(() {
          _requests =
              items.map((e) => PermissionRequestModel.fromJson(e)).toList();
          _totalRecords = responseBody['totalRecords'] ?? 0;
        });
      }
    } catch (e) {
      debugPrint('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showRequestDetail(PermissionRequestModel request) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  backgroundImage: request.userAvatar != null
                      ? NetworkImage(request.userAvatar!)
                      : null,
                  radius: 40,
                  child: request.userAvatar == null
                      ? const Icon(Icons.person, size: 40)
                      : null,
                ),
                const SizedBox(height: 12),
                Text(request.userName ?? "N/A",
                    style: Theme.of(context).textTheme.titleLarge),
                Text(request.userEmail ?? "N/A",
                    style: const TextStyle(color: Colors.grey)),
                const Divider(),
                _infoRow(Icons.event, 'Event', request.eventName ?? "N/A"),
                _infoRow(Icons.business, 'Organization',
                    request.organizationName ?? "N/A"),
                _infoRow(Icons.category, 'Request Type',
                    _getRequestType(request.requestType ?? 0)),
                _infoRow(Icons.timelapse, 'Status',
                    _getRequestStatus(request.requestStatus ?? 0)),
                _infoRow(
                    Icons.calendar_today,
                    'Date',
                    request.createdAt?.toLocal().toString().split(' ')[0] ??
                        "N/A"),
                const SizedBox(height: 10),
                const Text('Reason:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(request.notes ?? "N/A", textAlign: TextAlign.center),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  alignment: WrapAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                    ElevatedButton(
                      onPressed: () => _updateRequestStatus(request.id!, 1),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green),
                      child: const Text('Approve'),
                    ),
                    ElevatedButton(
                      onPressed: () => _updateRequestStatus(request.id!, 2),
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Reject'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _infoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blueGrey),
          const SizedBox(width: 8),
          Text('$title: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Future<void> _updateRequestStatus(String id, int status) async {
    try {
      final response = await _apiService.put(
        'api/events/$id/update-request',
        {'Status': status},
      );
      if (response.statusCode == 200) {
        if (mounted) {
          Navigator.pop(context);
          _fetchRequests(widget.eventId);
        }
      }
    } catch (e) {
      debugPrint('Error updating request: $e');
    }
  }

  String _getRequestType(int type) {
    return type == 0 ? 'Absent' : 'Late Arrival';
  }

  String _getRequestStatus(int status) {
    switch (status) {
      case 0:
        return 'Pending';
      case 1:
        return 'Approved';
      case 2:
        return 'Rejected';
      default:
        return 'Unknown';
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchRequests(widget.eventId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Request List')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _requests.length,
              itemBuilder: (context, index) {
                final request = _requests[index];
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: request.userAvatar != null
                          ? NetworkImage(request.userAvatar!)
                          : null,
                      child: request.userAvatar == null
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    title: Text(request.userName ?? 'No Name'),
                    subtitle: Text(
                        'Status: ${_getRequestStatus(request.requestStatus ?? 0)}'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _showRequestDetail(request),
                  ),
                );
              },
            ),
    );
  }
}
