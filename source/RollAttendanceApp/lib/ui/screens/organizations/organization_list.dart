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
  List<OrganizationModel> joinedOrganizations = [];
  final ApiService _apiService = ApiService();

  int pageIndex = 0;
  int pageSize = 10;
  bool hasMoreData = true;

  int pageJoinedIndex = 0;
  int pageJoinedSize = 10;
  bool hasMoreJoinedData = true;

  bool isExpandedOrganizations = false;
  bool isExpandedJoinedOrganizations = false;

  Future<void> fetchUserOrganizations({bool isLoadMore = false}) async {
    if (_isLoading) return;

    try {
      setState(() {
        _isLoading = true;
      });

      final response = await _apiService.get(
        'api/organization/getall/${FirebaseAuth.instance.currentUser?.uid}?pageIndex=$pageIndex&pageSize=$pageSize',
      );

      if (response.statusCode == 200) {
        List<dynamic> responseBody = jsonDecode(response.body);
        setState(() {
          if (isLoadMore) {
            organizations.addAll(responseBody
                .map((orgData) => OrganizationModel.fromMap(orgData))
                .toList());
          } else {
            organizations = responseBody
                .map((orgData) => OrganizationModel.fromMap(orgData))
                .toList();
          }

          if (responseBody.length < pageSize) {
            hasMoreData = false;
          } else {
            pageIndex++;
          }
        });
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to fetch organizations, $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> fetchUserJoinedOrganizations({bool isLoadMore = false}) async {
    if (_isLoading) return;

    try {
      setState(() {
        _isLoading = true;
      });

      final response = await _apiService.get(
        'api/organization/getjoined/${FirebaseAuth.instance.currentUser?.uid}?pageIndex=$pageJoinedIndex&pageSize=$pageJoinedSize',
      );

      if (response.statusCode == 200) {
        List<dynamic> responseBody = jsonDecode(response.body);
        setState(() {
          if (isLoadMore) {
            joinedOrganizations.addAll(responseBody
                .map((orgData) => OrganizationModel.fromMap(orgData))
                .toList());
          } else {
            joinedOrganizations = responseBody
                .map((orgData) => OrganizationModel.fromMap(orgData))
                .toList();
          }

          if (responseBody.length < pageJoinedSize) {
            hasMoreJoinedData = false;
          } else {
            pageJoinedIndex++;
          }
        });
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to fetch joined organizations, $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> initializeData() async {
    await fetchUserOrganizations();
    await fetchUserJoinedOrganizations();
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
    final Color textColor = isDarkMode ? Colors.white : Colors.black;
    final Color backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    double getResponsiveFontSize(double baseFontSize) {
      return screenWidth > 480 ? baseFontSize * 1.2 : baseFontSize;
    }

    Widget buildLoadMoreButton(
        {required bool hasMore, required VoidCallback onPressed}) {
      return hasMore
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: GestureDetector(
                onTap: _isLoading ? null : onPressed,
                child: Center(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: _isLoading ? 0.5 : 1.0,
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : Text(
                            "Load More",
                            style: TextStyle(
                              fontSize: getResponsiveFontSize(16),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  ),
                ),
              ),
            )
          : const SizedBox.shrink();
    }

    return BlurryModalProgressHUD(
      inAsyncCall: _isLoading,
      opacity: 0.3,
      blurEffectIntensity: 5,
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 100.0),
                child: RefreshIndicator(
                  onRefresh: () async {
                    setState(() {
                      pageIndex = 0;
                      pageJoinedIndex = 0;
                      hasMoreData = true;
                      hasMoreJoinedData = true;
                    });
                    await initializeData();
                  },
                  child: ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      Text(
                        'My Organizations',
                        style: TextStyle(
                            fontSize: getResponsiveFontSize(18),
                            fontWeight: FontWeight.bold,
                            color: textColor),
                      ),
                      const SizedBox(height: 10),
                      if (organizations.isEmpty)
                        Center(
                          child: Text(
                            'No organizations available.',
                            style: TextStyle(
                                fontSize: getResponsiveFontSize(16),
                                color: textColor),
                          ),
                        ),
                      ...organizations
                          .map((org) => OrganizationCard(organization: org)),
                      buildLoadMoreButton(
                        hasMore: hasMoreData,
                        onPressed: () =>
                            fetchUserOrganizations(isLoadMore: true),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Joined Organizations',
                        style: TextStyle(
                            fontSize: getResponsiveFontSize(18),
                            fontWeight: FontWeight.bold,
                            color: textColor),
                      ),
                      const SizedBox(height: 10),
                      if (joinedOrganizations.isEmpty)
                        Center(
                          child: Text(
                            'You have not joined any organizations.',
                            style: TextStyle(
                                fontSize: getResponsiveFontSize(16),
                                color: textColor),
                          ),
                        ),
                      ...joinedOrganizations
                          .map((org) => OrganizationCard(organization: org)),
                      buildLoadMoreButton(
                        hasMore: hasMoreJoinedData,
                        onPressed: () =>
                            fetchUserJoinedOrganizations(isLoadMore: true),
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
                    onPressed: () => context.push("/create-organization"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text("Create New Organization",
                        style: TextStyle(
                            fontSize: getResponsiveFontSize(16),
                            color: Colors.white)),
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
