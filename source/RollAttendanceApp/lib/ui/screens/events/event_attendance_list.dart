import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:blurry_modal_progress_hud/blurry_modal_progress_hud.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:itproject/enums/user_attendance_status.dart';
import 'package:itproject/models/event_history_detail_model.dart';
import 'package:itproject/models/event_history_model.dart';
import 'package:itproject/services/api_service.dart';
import 'package:itproject/ui/widgets/info_chip.dart';
import 'package:itproject/utils/format_value.dart';

class EventAttendanceListScreen extends StatefulWidget {
  final String eventId;

  const EventAttendanceListScreen({super.key, required this.eventId});

  @override
  State<EventAttendanceListScreen> createState() =>
      _EventAttendanceListScreenState();
}

class _EventAttendanceListScreenState extends State<EventAttendanceListScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  late Future<List<HistoryModel>> _historiesFuture;
  Map<String, Future<List<HistoryDetailModel>>> _historyDetailsMap = {};
  Set<String> _expandedHistories = {};

  Future<List<HistoryModel>> getHistories(String id) async {
    try {
      setState(() => _isLoading = true);
      final response = await _apiService.get('api/histories/$id/all');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => HistoryModel.fromMap(e)).toList();
      } else {
        throw Exception('Failed to load histories');
      }
    } catch (e) {
      throw Exception('Failed to load histories: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<List<HistoryDetailModel>> getHistoryDetail(String historyId) async {
    try {
      final response =
          await _apiService.get('api/histories/details/$historyId');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => HistoryDetailModel.fromMap(e)).toList();
      } else {
        throw Exception('Failed to load history details');
      }
    } catch (e) {
      throw Exception('Failed to load history details: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _historiesFuture = getHistories(widget.eventId);
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
          iconTheme: const IconThemeData(),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            setState(() => _historiesFuture = getHistories(widget.eventId));
          },
          child: FutureBuilder<List<HistoryModel>>(
            future: _historiesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData) {
                final histories = snapshot.data!;
                if (histories.isEmpty) {
                  return const Center(child: Text('No history available'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  itemCount: histories.length,
                  itemBuilder: (context, index) {
                    final history = histories[index];
                    final isExpanded = _expandedHistories.contains(history.id);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      child: Column(
                        children: [
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            title: Text(
                              'History ${index + 1}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${FormatUtils.formatDateTime(history.startTime)} - ${FormatUtils.formatDateTime(history.endTime)}',
                                  style: TextStyle(color: Colors.grey[700], fontSize: 14),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildInfoChip(Icons.people, history.totalCount ?? 0),
                                    _buildInfoChip(Icons.check_circle, history.presentCount ?? 0, Colors.green),
                                    _buildInfoChip(Icons.timer, history.lateCount ?? 0, Colors.orange),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.access_time, color: Colors.blue, size: 18),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Attendance Times: ${history.attendanceTimes}',
                                      style: const TextStyle(fontSize: 14, color: Colors.blue),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: Icon(
                              isExpanded ? Icons.expand_less : Icons.expand_more,
                              color: Colors.blueAccent,
                            ),
                            onTap: () {
                              setState(() {
                                if (isExpanded) {
                                  _expandedHistories.remove(history.id);
                                } else {
                                  _expandedHistories.add(history.id ?? '');
                                  _historyDetailsMap[history.id!] = getHistoryDetail(history.id!);
                                }
                              });
                            },
                          ),

                          /// Phần chi tiết mở rộng
                          if (isExpanded)
                            FutureBuilder<List<HistoryDetailModel>>(
                              future: _historyDetailsMap[history.id!],
                              builder: (context, detailSnapshot) {
                                if (detailSnapshot.connectionState == ConnectionState.waiting) {
                                  return const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: CircularProgressIndicator(),
                                  );
                                } else if (detailSnapshot.hasError) {
                                  return Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Text('Error: ${detailSnapshot.error}'),
                                  );
                                } else if (detailSnapshot.hasData) {
                                  final details = detailSnapshot.data!;
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    child: Column(
                                      children: details.map((detail) {
                                        final attendanceStatus = getRoleFromValue(detail.attendanceStatus ?? -1);
                                        return ListTile(
                                          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                          leading: CircleAvatar(
                                            backgroundImage: NetworkImage(detail.userAvatar ?? ''),
                                            radius: 25,
                                          ),
                                          title: Text(
                                            detail.userName ?? 'Unknown',
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('Email: ${detail.userEmail}', style: const TextStyle(fontSize: 14)),
                                              Text('Absent: ${FormatUtils.formatDateTime(detail.absentTime)}', style: const TextStyle(fontSize: 14)),
                                              Text('Leave: ${FormatUtils.formatDateTime(detail.leaveTime)}', style: const TextStyle(fontSize: 14)),
                                              Text('Count: ${detail.attendanceCount}', style: const TextStyle(fontSize: 14)),
                                              Text(
                                                'Status: ${attendanceStatus['text']}',
                                                style: TextStyle(fontSize: 14, color: attendanceStatus['color']),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  );
                                } else {
                                  return const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Text('No details available'),
                                  );
                                }
                              },
                            ),
                        ],
                      ),
                    );
                  },
                );
              } else {
                return const Center(child: Text('No data found'));
              }
            },
          ),
        ),
      ),
    );
  }

  /// Widget hiển thị thông tin số liệu (Total, Present, Late)
  Widget _buildInfoChip(IconData icon, int count, [Color? color]) {
    return Chip(
      backgroundColor: color?.withOpacity(0.15) ?? Colors.grey.shade200,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color ?? Colors.black87),
          const SizedBox(width: 4),
          Text(
            ' $count',
            style: TextStyle(color: color ?? Colors.black87, fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
