import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:blurry_modal_progress_hud/blurry_modal_progress_hud.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:itproject/models/available_event_model.dart';
import 'package:itproject/models/organization_model.dart';
import 'package:itproject/services/api_service.dart';
import 'package:itproject/ui/components/organizations/organization_card.dart';

class OrganizationScreen extends StatefulWidget {
  const OrganizationScreen({super.key});

  @override
  State<OrganizationScreen> createState() => _OrganizationScreenState();
}

class _OrganizationScreenState extends State<OrganizationScreen> {
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
      {int pageEventIndex = 1,
      int pageEventSize = 10,
      int status = 1,
      DateTime? date}) async {
    if (_isLoading) return;
    try {
      setState(() {
        _isLoading = true;
      });

      date ??= DateTime.now();

      final response = await _apiService.get(
        'api/events/available-events?pageIndex=$pageEventIndex&pageSize=$pageEventSize&date=$date&status=$status',
      );

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            List<dynamic> responseBody = jsonDecode(response.body);
            if (pageIndex == 0) {
              events = responseBody
                  .map((orgData) => AvailableEventModel.fromMap(orgData))
                  .toList();
            } else {
              events.addAll(responseBody
                  .map((orgData) => AvailableEventModel.fromMap(orgData))
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
        msg: "Failed to fetch events, $e",
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
    final screenHeight = MediaQuery.of(context).size.height;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDarkMode ? Colors.white : Colors.black;
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
      child: Scaffold(
        backgroundColor: backgroundColor,
        // appBar: AppBar(
        //   automaticallyImplyLeading: false,
        //   backgroundColor: backgroundColor,
        //   actions: [
        //     IconButton(
        //       icon: Icon(
        //         Icons.search,
        //         color: textColor,
        //         size: getResponsiveFontSize(24),
        //       ),
        //       onPressed: () {
        //         context.push("/search-organization");
        //       },
        //     ),
        //   ],
        // ),
        body: SafeArea(
          // Đảm bảo nội dung không bị che bởi status bar
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 100.0),
                child: RefreshIndicator(
                  onRefresh: () async {
                    setState(() {
                      pageIndex = 0;
                      pageEventIndex = 1;
                      hasMoreData = true;
                      hasMoreEventData = true;
                    });
                    await fetchUserOrganizations();
                    await fetchUserAvailableEvents();
                  },
                  child: ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      if (organizations.isEmpty)
                        Center(
                          child: Text(
                            'No organizations available.',
                            style: TextStyle(
                              fontSize: getResponsiveFontSize(16),
                              color: textColor,
                            ),
                          ),
                        ),
                      ...organizations.map(
                        (org) => OrganizationCard(organization: org),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 0.0,
                left: 0.0,
                right: 0.0,
                child: Container(
                  height: 100.0,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 16.0),
                  color: backgroundColor,
                  child: ElevatedButton(
                    onPressed: () {
                      context.push("/create-organization");
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Create New Organization",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: getResponsiveFontSize(16),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
