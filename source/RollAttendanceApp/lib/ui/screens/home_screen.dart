import 'dart:convert';
import 'package:intl/intl.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:blurry_modal_progress_hud/blurry_modal_progress_hud.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:itproject/models/available_event_model.dart';
import 'package:itproject/models/organization_model.dart';
import 'package:itproject/services/api_service.dart';
import 'package:itproject/ui/components/events/event_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;
  List<OrganizationModel> organizations = [];
  List<AvailableEventModel> events = [];
  final ApiService _apiService = ApiService();
  int pageIndex = 0;
  int pageSize = 10;
  bool hasMoreData = true;

  int pageEventIndex = 1;
  int pageEventSize = 10;
  bool hasMoreEventData = true;

  DateTime selectedDate = DateTime.now();
  String filterType = 'Today';

  String imagePlaceHolder =
      'https://yt3.ggpht.com/a/AGF-l78urB8ASkb0JO2a6AB0UAXeEHe6-pc9UJqxUw=s900-mo-c-c0xffffffff-rj-k-no';

  Future<void> shareProfile() async {
    if (_isLoading) return;
    try {
      await _apiService.put('api/auth/shareProfile', {});
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to share profile, $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  Future<void> fetchUserOrganizations(
      {int pageIndex = 0, int pageSize = 10}) async {
    if (_isLoading) return;
    try {
      setState(() {
        _isLoading = true;
      });

      final response = await _apiService.get(
        'api/organization/getall/${FirebaseAuth.instance.currentUser?.uid}?pageIndex=$pageIndex&pageSize=$pageSize',
      );

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            List<dynamic> responseBody = jsonDecode(response.body);
            if (pageIndex == 0) {
              organizations = responseBody
                  .map((orgData) => OrganizationModel.fromMap(orgData))
                  .toList();
            } else {
              organizations.addAll(responseBody
                  .map((orgData) => OrganizationModel.fromMap(orgData))
                  .toList());
            }

            if (responseBody.length < pageSize) {
              hasMoreData = false;
            }
          });
        }
      } else {
        Fluttertoast.showToast(
          msg: "No organizations found",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to fetch organizations, $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> fetchUserAvailableEvents(
      {int pageEventIndex = 1, int pageEventSize = 10, int status = 1}) async {
    if (_isLoading) return;
    try {
      setState(() {
        _isLoading = true;
      });

      DateTime now = DateTime.now();
      DateTime startDate, endDate;

      if (filterType == 'Today') {
        startDate = DateTime(now.year, now.month, now.day, 0, 0, 0);
        endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
      } else if (filterType == 'Week') {
        int currentWeekday = now.weekday; // Monday = 1, Sunday = 7
        startDate = now.subtract(Duration(days: currentWeekday - 1));
        startDate =
            DateTime(startDate.year, startDate.month, startDate.day, 0, 0, 0);

        endDate = startDate.add(const Duration(days: 6));
        endDate =
            DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
      } else if (filterType == 'Month') {
        startDate = DateTime(now.year, now.month, 1, 0, 0, 0);

        endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
      } else {
        throw Exception("Invalid filter type");
      }

      final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

      final response = await _apiService.get(
        'api/events/available-events?pageIndex=$pageEventIndex&pageSize=$pageEventSize&status=$status'
        '&startDate=${dateFormat.format(startDate)}&endDate=${dateFormat.format(endDate)}',
      );

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            List<dynamic> responseBody = jsonDecode(response.body);
            if (pageEventIndex == 1) {
              events = responseBody
                  .map((eventData) => AvailableEventModel.fromMap(eventData))
                  .toList();
            } else {
              events.addAll(responseBody
                  .map((eventData) => AvailableEventModel.fromMap(eventData))
                  .toList());
            }

            if (responseBody.length < pageEventSize) {
              hasMoreEventData = false;
            }
          });
        }
      } else {
        Fluttertoast.showToast(
          msg: "No events found",
          backgroundColor: Colors.black,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to fetch events, $e",
        backgroundColor: Colors.black,
        textColor: Colors.white,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> initializeData() async {
    await fetchUserOrganizations();
    await fetchUserAvailableEvents();
    await shareProfile();
  }

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDarkMode ? Colors.white70 : Colors.black54;
    final Color backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    double getResponsiveFontSize(double baseFontSize) {
      if (screenWidth > 480) {
        return baseFontSize * 1.2;
      } else {
        return baseFontSize;
      }
    }

    return BlurryModalProgressHUD(
      inAsyncCall: _isLoading,
      opacity: 0.3,
      blurEffectIntensity: 5,
      child: SafeArea(
        // Đảm bảo nội dung không bị che bởi status bar
        child: Scaffold(
          backgroundColor: backgroundColor,
          body: RefreshIndicator(
            onRefresh: () async {
              setState(() {
                pageIndex = 0;
                pageEventIndex = 1;
                hasMoreData = true;
                hasMoreEventData = true;
              });
              await fetchUserAvailableEvents();
            },
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // const SizedBox(height: 30),
                Align(
                  alignment: Alignment.centerRight,
                  child: DropdownButton<String>(
                    value: filterType,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          filterType = newValue;
                          pageEventIndex = 1;
                          hasMoreEventData = true;
                        });
                        fetchUserAvailableEvents();
                      }
                    },
                    items: <String>['Today', 'Week', 'Month']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 10),
                if (events.isEmpty)
                  Center(
                    child: Text(
                      'No available events.',
                      style: TextStyle(
                        fontSize: getResponsiveFontSize(16),
                        color: textColor,
                      ),
                    ),
                  ),
                ...events.map((event) => Container(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      width: screenWidth * 0.8,
                      child: EventCard(event: event),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
