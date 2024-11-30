import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:blurry_modal_progress_hud/blurry_modal_progress_hud.dart';
import 'package:itproject/models/organization_model.dart';
import 'package:itproject/services/api_service.dart';
import 'package:itproject/ui/layouts/main_layout.dart';

class OrganizationDetailScreen extends StatefulWidget {
  final String organizationId;

  const OrganizationDetailScreen({super.key, required this.organizationId});

  @override
  State<OrganizationDetailScreen> createState() =>
      _OrganizationDetailScreenState();
}

class _OrganizationDetailScreenState extends State<OrganizationDetailScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  late Future<OrganizationModel> _organizationFuture;

  Future<OrganizationModel> getDetail(id) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final response = await _apiService.get('api/organization/detail/$id');

      if (response.statusCode == 200) {
        return OrganizationModel.fromMap(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load organization');
      }
    } catch (e) {
      throw Exception('Failed to load organization: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _organizationFuture = getDetail(widget.organizationId);
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      child: BlurryModalProgressHUD(
        inAsyncCall: _isLoading,
        opacity: 0.3,
        blurEffectIntensity: 5,
        child: FutureBuilder<OrganizationModel>(
          future: _organizationFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const BlurryModalProgressHUD(
                inAsyncCall: true,
                opacity: 0.3,
                blurEffectIntensity: 5,
                child: Center(child: CircularProgressIndicator()),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red)),
              );
            } else if (!snapshot.hasData) {
              return const Center(
                child: Text('No data available'),
              );
            } else {
              final organization = snapshot.data!;
              return Scaffold(
                appBar: null, // Remove app bar for full-screen layout
                body: ListView(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Container(
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            clipBehavior: Clip.none,
                            children: <Widget>[
                              Container(
                                height: 200.0,
                                decoration: const BoxDecoration(
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: NetworkImage(
                                        'https://th.bing.com/th/id/OIP.agLNnNJWhgFjK8D7AO1VdAHaDt?rs=1&pid=ImgDetMain'),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 100.0,
                                child: Container(
                                  height: 190.0,
                                  width: 190.0,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: const DecorationImage(
                                      fit: BoxFit.cover,
                                      image: NetworkImage(
                                          'https://yt3.ggpht.com/a/AGF-l78urB8ASkb0JO2a6AB0UAXeEHe6-pc9UJqxUw=s900-mo-c-c0xffffffff-rj-k-no'),
                                    ),
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 6.0,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 130.0),
                        Container(
                          alignment: Alignment.bottomCenter,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                organization.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 28.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12.0),
                        Container(
                          child: Text(
                            organization.description,
                            style: const TextStyle(fontSize: 18.0),
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                'Address: ${organization.address.isEmpty ? 'No address provided' : organization.address}',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        Chip(
                          label: Text(
                              organization.isPrivate ? 'Private' : 'Public'),
                          backgroundColor: organization.isPrivate
                              ? Colors.red
                              : Colors.green,
                          labelStyle: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 10.0),
                        // Add More Info Here
                        // Container(
                        //   padding:
                        //       const EdgeInsets.only(left: 10.0, right: 10.0),
                        //   child: Column(
                        //     children: <Widget>[
                        //       Row(
                        //         children: <Widget>[
                        //           const Icon(Icons.work),
                        //           const SizedBox(width: 5.0),
                        //           Text(
                        //             'Works at ${organization.name}',
                        //             style: const TextStyle(fontSize: 18.0),
                        //           ),
                        //         ],
                        //       ),
                        //       const SizedBox(height: 10.0),
                        //       Row(
                        //         children: <Widget>[
                        //           const Icon(Icons.location_on),
                        //           const SizedBox(width: 5.0),
                        //           Text(
                        //             'Location: ${organization.address}',
                        //             style: const TextStyle(fontSize: 18.0),
                        //           ),
                        //         ],
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        // const SizedBox(height: 20.0),
                        // Container(
                        //   height: 10.0,
                        //   child: const Divider(
                        //     color: Colors.grey,
                        //   ),
                        // ),
                      ],
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
