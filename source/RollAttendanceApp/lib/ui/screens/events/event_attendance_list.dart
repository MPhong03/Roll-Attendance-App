import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:blurry_modal_progress_hud/blurry_modal_progress_hud.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:itproject/enums/user_attendance_status.dart';
import 'package:itproject/models/event_history_detail_model.dart';
import 'package:itproject/models/event_history_model.dart';
import 'package:itproject/services/api_service.dart';

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

  late Future<HistoryModel> _historyFuture;
  late Future<List<HistoryDetailModel>> _historyDetailModels;

  // Hàm gọi getHistory và lấy historyId từ kết quả
  Future<HistoryModel> getHistory(id) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final response = await _apiService.get('api/histories/$id');

      if (response.statusCode == 200) {
        final history = HistoryModel.fromMap(jsonDecode(response.body));
        // Sau khi lấy được history, gọi getHistoryDetail với id của history
        _historyDetailModels = getHistoryDetail(
            history.id!); // Lưu _historyDetailModels với danh sách detail
        return history;
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

  // Lấy danh sách chi tiết từ id của history
  Future<List<HistoryDetailModel>> getHistoryDetail(String id) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final response = await _apiService.get('api/histories/details/$id');

      if (response.statusCode == 200) {
        final List<dynamic> historyList = jsonDecode(response.body);
        final List<HistoryDetailModel> historyDetails =
            List<HistoryDetailModel>.from(
                historyList.map((item) => HistoryDetailModel.fromMap(item)));
        return historyDetails;
      } else {
        throw Exception('Failed to load history');
      }
    } catch (e) {
      throw Exception('Failed to load history: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
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

  String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) {
      return 'N/A';
    }
    final DateFormat formatter = DateFormat('dd-MM-yyyy HH:mm:ss');
    return formatter.format(dateTime);
  }

  Future<void> _onRefresh() async {
    setState(() {
      _historyFuture = getHistory(widget.eventId);
    });
  }

  @override
  void initState() {
    super.initState();
    // _eventFuture = getDetail(widget.eventId);
    _historyFuture = getHistory(widget.eventId);
  }

  @override
  Widget build(BuildContext context) {
    return BlurryModalProgressHUD(
      inAsyncCall: _isLoading,
      opacity: 0.3,
      blurEffectIntensity: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('History'),
        ),
        body: RefreshIndicator(
          onRefresh: _onRefresh,
          child: FutureBuilder<HistoryModel>(
            future: _historyFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Text(
                    'Loading',
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              } else if (snapshot.hasData) {
                final history = snapshot.data!;

                return Column(
                  children: [
                    // Display history summary
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Event History Summary',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('Total Count: ${history.totalCount}'),
                          Text('Present Count: ${history.presentCount}'),
                          Text('Late Count: ${history.lateCount}'),
                          Text('Attendance Times: ${history.attendanceTimes}'),
                        ],
                      ),
                    ),
                    // List of history details
                    Expanded(
                      child: FutureBuilder<List<HistoryDetailModel>>(
                        future: _historyDetailModels,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
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
                            final histories = snapshot.data!;
                            if (histories.isEmpty) {
                              return const Center(
                                child: Text('No details available.'),
                              );
                            }

                            return ListView.builder(
                              padding: const EdgeInsets.all(8.0),
                              itemCount: histories.length,
                              itemBuilder: (context, index) {
                                final item = histories[index];
                                final attendanceStatus = getRoleFromValue(
                                    item.attendanceStatus ?? -1);

                                return Card(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundImage:
                                          NetworkImage(item.userAvatar ?? ''),
                                    ),
                                    title: Text(item.userName ?? 'No Name'),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Email: ${item.userEmail}'),
                                        Text(
                                            'Absent Time: ${item.absentTime != null ? formatDateTime(item.absentTime) : 'N/A'}'),
                                        Text(
                                            'Leave Time: ${item.leaveTime != null ? formatDateTime(item.leaveTime) : 'N/A'}'),
                                        Text(
                                            'Attendance Count: ${item.attendanceCount}'),
                                        Text(
                                          'Status: ${attendanceStatus['text']}',
                                          style: TextStyle(
                                              color: attendanceStatus['color']),
                                        ),
                                      ],
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
                  ],
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
