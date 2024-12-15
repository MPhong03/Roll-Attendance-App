import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:blurry_modal_progress_hud/blurry_modal_progress_hud.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:itproject/models/organization_model.dart';
import 'package:itproject/services/api_service.dart';
import 'package:itproject/ui/layouts/main_layout.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;
  List<OrganizationModel> organizations = [];
  final ApiService _apiService = ApiService();
  int pageIndex = 0;
  int pageSize = 10;
  bool hasMoreData = true;

  Future<void> shareProfile() async {
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
    try {
      setState(() {
        _isLoading = true;
      });

      final response = await _apiService.get(
        'api/organization/getall/${FirebaseAuth.instance.currentUser?.uid}?pageIndex=$pageIndex&pageSize=$pageSize',
      );

      if (response.statusCode == 200) {
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

  void _loadMore() {
    pageIndex++;
    fetchUserOrganizations(pageIndex: pageIndex, pageSize: pageSize);
  }

  @override
  void initState() {
    super.initState();
    fetchUserOrganizations();
    shareProfile();
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      child: BlurryModalProgressHUD(
        inAsyncCall: _isLoading,
        opacity: 0.3,
        blurEffectIntensity: 5,
        child: Scaffold(
          body: RefreshIndicator(
            onRefresh: () async {
              setState(() {
                pageIndex = 0;
                hasMoreData = true;
              });
              await fetchUserOrganizations(pageIndex: pageIndex);
            },
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                const Center(
                  child: Text(
                    'Welcome to the ITP!',
                    style: TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(height: 20),
                if (organizations.isEmpty)
                  const Center(child: Text('No organizations available.')),
                ...organizations.map((org) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 5,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16.0),
                      title: Text(
                        org.name,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            org.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            org.address,
                            style: const TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                      trailing: Icon(
                        org.isPrivate ? Icons.lock : Icons.lock_open,
                        color: org.isPrivate ? Colors.red : Colors.blue,
                      ),
                      onTap: () {
                        context.push('/organization-detail/${org.id}');
                      },
                    ),
                  );
                }),
                if (hasMoreData)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Center(
                      child: ElevatedButton(
                        onPressed: () {
                          if (!_isLoading) {
                            setState(() {
                              _isLoading = true;
                            });
                            pageIndex++;
                            fetchUserOrganizations(pageIndex: pageIndex);
                          }
                        },
                        child: const Text('Load More'),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
