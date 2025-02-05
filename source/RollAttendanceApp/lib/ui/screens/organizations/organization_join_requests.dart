import 'dart:convert';
import 'package:blurry_modal_progress_hud/blurry_modal_progress_hud.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:itproject/models/request_model.dart';
import 'package:itproject/services/api_service.dart';

class OrganizationJoinRequestsScreen extends StatefulWidget {
  final String organizationId;

  const OrganizationJoinRequestsScreen(
      {super.key, required this.organizationId});

  @override
  State<OrganizationJoinRequestsScreen> createState() =>
      _OrganizationJoinRequestsScreenState();
}

class _OrganizationJoinRequestsScreenState
    extends State<OrganizationJoinRequestsScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<ParticipationRequestModel>> _requestListFuture;
  bool _isLoading = false;
  int _page = 1;
  final int _limit = 100;
  int _selectedStatus = 0;

  String imagePlaceHolder =
      'https://yt3.ggpht.com/a/AGF-l78urB8ASkb0JO2a6AB0UAXeEHe6-pc9UJqxUw=s900-mo-c-c0xffffffff-rj-k-no';

  Future<List<ParticipationRequestModel>> getRequests() async {
    try {
      final response = await _apiService.get(
        'api/ParticipationRequests',
        queryParams: {
          'organizationId': widget.organizationId.toString(),
          'forUser': false.toString(),
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
              .map((data) => ParticipationRequestModel.fromMap(data))
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

  Future<void> _confirmRequest(String requestId, int status) async {
    setState(() {
      _isLoading = true;
    });

    if (requestId.isEmpty) return;

    try {
      final response =
          await _apiService.put('api/ParticipationRequests/status', {
        'requestId': requestId.toString(),
        'newStatus': status,
      });
      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Successfully status updated!")),
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

  Future<void> _onRefresh() async {
    setState(() {
      _requestListFuture = getRequests();
    });
  }

  @override
  void initState() {
    super.initState();
    _requestListFuture = getRequests();
  }

  // void _nextPage() {
  //   setState(() {
  //     _page++;
  //     _onRefresh();
  //   });
  // }

  // void _prevPage() {
  //   if (_page > 1) {
  //     setState(() {
  //       _page--;
  //       _onRefresh();
  //     });
  //   }
  // }

  void _showRequestDetailModal(ParticipationRequestModel request) {
    showDialog(
      context: context,
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Danh sách thông tin chi tiết
                _buildDetailCard('User', request.userName),
                _buildDetailCard('Email', request.userEmail),
                // _buildDetailCard('From', request.organizationName),
                _buildDetailCard('Notes', request.notes),
                // _buildDetailCard('Status', _getStatusLabel(request.requestStatus)),
                // _buildDetailCard('Participation Method', request.participationMethod),

                const SizedBox(height: 20),

                // Nút hành động
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          'Close',
                          style: TextStyle(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _confirmRequest(request.id ?? '', 1); // Approve
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Approve',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _confirmRequest(request.id ?? '', 2); // Reject
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Reject',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
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

  /// Widget hiển thị chi tiết dưới dạng card
  Widget _buildDetailCard(String title, String? value) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(
            '$title: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
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

  @override
  Widget build(BuildContext context) {
    return BlurryModalProgressHUD(
      inAsyncCall: _isLoading,
      opacity: 0.3,
      blurEffectIntensity: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Requests'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: FutureBuilder<List<ParticipationRequestModel>>(
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
                            subtitle: Text(request.userEmail ?? ''),
                            trailing: const Icon(Icons.arrow_forward),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
