import 'dart:convert';
import 'package:blurry_modal_progress_hud/blurry_modal_progress_hud.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:itproject/enums/user_role.dart';
import 'package:itproject/models/invite_request_model.dart';
import 'package:itproject/models/request_model.dart';
import 'package:itproject/services/api_service.dart';

class MyInvitationsScreen extends StatefulWidget {
  const MyInvitationsScreen({super.key});

  @override
  State<MyInvitationsScreen> createState() => _MyInvitationsScreenState();
}

class _MyInvitationsScreenState extends State<MyInvitationsScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<InviteRequestModel>> _requestListFuture;
  bool _isLoading = false;
  int _page = 1;
  final int _limit = 10;
  int _selectedStatus = 0;

  String imagePlaceHolder =
      'https://yt3.ggpht.com/a/AGF-l78urB8ASkb0JO2a6AB0UAXeEHe6-pc9UJqxUw=s900-mo-c-c0xffffffff-rj-k-no';

  static const Map<int, String> statuses = {
    0: 'WAITING',
    1: 'APPROVED',
    2: 'REJECTED',
    3: 'CANCELLED',
  };

  Future<List<InviteRequestModel>> getInvitations() async {
    try {
      final response = await _apiService.get(
        'api/Organization/invite-list',
        queryParams: {
          'forUser': true.toString(),
          'status': _selectedStatus.toString(),
          'pageIndex': _page.toString(),
          'pageSize': _limit.toString(),
        },
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);

        if (responseBody is Map && responseBody.containsKey('data')) {
          final List requestsData = responseBody['data'];
          if (requestsData.isEmpty) {
            return [];
          }
          return requestsData
              .map((data) => InviteRequestModel.fromMap(data))
              .toList();
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception('Failed to load requests');
      }
    } catch (e) {
      throw Exception('Failed to load requests: $e');
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      _requestListFuture = getInvitations();
    });
  }

  @override
  void initState() {
    super.initState();
    _requestListFuture = getInvitations();
  }

  void _nextPage() {
    setState(() {
      _page++;
      _onRefresh();
    });
  }

  void _prevPage() {
    if (_page > 1) {
      setState(() {
        _page--;
        _onRefresh();
      });
    }
  }

  void _showRequestDetailModal(InviteRequestModel request) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          title: Text(
            request.userName ?? 'Request Details',
            style: Theme.of(context)
                .textTheme
                .headlineLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailTile('User Name', request.userName),
                _buildDetailTile('Email', request.userEmail),
                _buildDetailTile('Organization', request.organizationName),
                _buildDetailTile('Notes', request.notes),
                _buildDetailTile(
                  'Status',
                  _getStatusLabel(request.requestStatus),
                ),
                _buildDetailTile(
                  'Role',
                  getRoleFromValue(request.role ?? 0),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Close',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            if (request.requestStatus == 0)
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _approveRequest(request.id ?? '');
                },
                child: const Text(
                  'Approve',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
            if (request.requestStatus == 0)
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _rejectRequest(request.id ?? '');
                },
                child: const Text(
                  'Reject',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildDetailTile(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value ?? 'N/A',
            style: const TextStyle(fontSize: 16),
          ),
          const Divider(),
        ],
      ),
    );
  }

  String _getStatusLabel(int? status) {
    const statuses = {
      0: 'WAITING',
      1: 'APPROVED',
      2: 'REJECTED',
      3: 'CANCELLED',
    };
    return statuses[status] ?? 'Unknown';
  }

  Future<void> _approveRequest(String requestId) async {
    setState(() {
      _isLoading = true;
    });

    if (requestId.isEmpty) return;

    try {
      final response = await _apiService
          .put('api/organization/invite/accept/$requestId', {});
      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Request accepted!")),
          );
        }
      } else {
        if (mounted) {
          final message = jsonDecode(response.body)['message'];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("$message")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("$e")),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _rejectRequest(String requestId) async {
    setState(() {
      _isLoading = true;
    });

    if (requestId.isEmpty) return;

    try {
      final response = await _apiService
          .put('api/organization/invite/reject/$requestId', {});
      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Request rejected!")),
          );
        }
      } else {
        if (mounted) {
          final message = jsonDecode(response.body)['message'];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("$message")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("$e")),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlurryModalProgressHUD(
      inAsyncCall: _isLoading,
      opacity: 0.3,
      blurEffectIntensity: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Invitations'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: Column(
          children: [
            DefaultTabController(
              length: statuses.length,
              child: Column(
                children: [
                  TabBar(
                    onTap: (index) {
                      setState(() {
                        _selectedStatus = index;
                        _page = 1;
                      });
                      _onRefresh();
                    },
                    tabs: statuses.entries.map((entry) {
                      return Tab(
                        text: entry.value,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<InviteRequestModel>>(
                future: _requestListFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (snapshot.data == null || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No requests available.'));
                  }

                  final requests = snapshot.data!;
                  return ListView.builder(
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      final request = requests[index];
                      return GestureDetector(
                        onTap: () {
                          _showRequestDetailModal(request);
                        },
                        child: Card(
                          margin: const EdgeInsets.all(10),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(imagePlaceHolder),
                            ),
                            title: Text(request.userName ?? 'Unknown'),
                            subtitle: Text(getRoleFromValue(request.role ?? 0)),
                            trailing: const Icon(Icons.arrow_forward),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _prevPage,
                ),
                Text('Page $_page'),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: _nextPage,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
