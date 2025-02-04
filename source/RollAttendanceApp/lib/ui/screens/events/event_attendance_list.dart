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
    return BlurryModalProgressHUD(
      inAsyncCall: _isLoading,
      opacity: 0.3,
      blurEffectIntensity: 5,
      child: Scaffold(
        appBar: AppBar(title: const Text('Histories')),
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
                if (histories.isEmpty)
                  return const Center(child: Text('No history available'));

                return ListView.builder(
                  itemCount: histories.length,
                  itemBuilder: (context, index) {
                    final history = histories[index];
                    final isExpanded = _expandedHistories.contains(history.id);

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                      child: Column(
                        children: [
                          ListTile(
                            title: Text(
                              'History ${index + 1}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${FormatUtils.formatDateTime(history.startTime)} - ${FormatUtils.formatDateTime(history.endTime)}',
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  children: [
                                    InfoChip(
                                        icon: Icons.people,
                                        label: 'Total',
                                        count: history.totalCount ?? 0),
                                    InfoChip(
                                        icon: Icons.check_circle,
                                        label: 'Present',
                                        count: history.presentCount ?? 0,
                                        color: Colors.green),
                                    InfoChip(
                                        icon: Icons.timer,
                                        label: 'Late',
                                        count: history.lateCount ?? 0,
                                        color: Colors.orange),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(Icons.access_time,
                                        color: Colors.blue, size: 18),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Attendance Times: ${history.attendanceTimes}',
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.blue),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: Icon(
                              isExpanded
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                              color: Colors.blueAccent,
                            ),
                            onTap: () {
                              setState(() {
                                if (isExpanded) {
                                  _expandedHistories.remove(history.id);
                                } else {
                                  _expandedHistories.add(history.id ?? '');
                                  _historyDetailsMap[history.id!] =
                                      getHistoryDetail(history.id!);
                                }
                              });
                            },
                          ),
                          if (isExpanded)
                            FutureBuilder<List<HistoryDetailModel>>(
                              future: _historyDetailsMap[history.id!],
                              builder: (context, detailSnapshot) {
                                if (detailSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: CircularProgressIndicator(),
                                  );
                                } else if (detailSnapshot.hasError) {
                                  return Padding(
                                    padding: const EdgeInsets.all(16),
                                    child:
                                        Text('Error: ${detailSnapshot.error}'),
                                  );
                                } else if (detailSnapshot.hasData) {
                                  final details = detailSnapshot.data!;
                                  return Column(
                                    children: details.map((detail) {
                                      final attendanceStatus = getRoleFromValue(
                                          detail.attendanceStatus ?? -1);
                                      return ListTile(
                                        leading: CircleAvatar(
                                            backgroundImage: NetworkImage(
                                                detail.userAvatar ?? '')),
                                        title:
                                            Text(detail.userName ?? 'Unknown'),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('Email: ${detail.userEmail}'),
                                            Text(
                                                'Absent: ${FormatUtils.formatDateTime(detail.absentTime)}'),
                                            Text(
                                                'Leave: ${FormatUtils.formatDateTime(detail.leaveTime)}'),
                                            Text(
                                                'Count: ${detail.attendanceCount}'),
                                            Text(
                                              'Status: ${attendanceStatus['text']}',
                                              style: TextStyle(
                                                  color: attendanceStatus[
                                                      'color']),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
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
}
