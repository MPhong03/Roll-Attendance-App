import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:blurry_modal_progress_hud/blurry_modal_progress_hud.dart';
import 'package:go_router/go_router.dart';
import 'package:itproject/models/organization_model.dart';
import 'package:itproject/services/api_service.dart';

class PublicOrganizationDetailScreen extends StatefulWidget {
  final String organizationId;

  const PublicOrganizationDetailScreen(
      {super.key, required this.organizationId});

  @override
  State<PublicOrganizationDetailScreen> createState() =>
      _PublicOrganizationDetailScreenState();
}

class _PublicOrganizationDetailScreenState
    extends State<PublicOrganizationDetailScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  late Future<OrganizationModel> _organizationFuture;

  String bannerPlaceHolder =
      'https://th.bing.com/th/id/OIP.agLNnNJWhgFjK8D7AO1VdAHaDt?rs=1&pid=ImgDetMain';
  String imagePlaceHolder =
      'https://yt3.ggpht.com/a/AGF-l78urB8ASkb0JO2a6AB0UAXeEHe6-pc9UJqxUw=s900-mo-c-c0xffffffff-rj-k-no';

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

  Future<void> createRequest(String notes) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final response = await _apiService.post(
        'api/ParticipationRequests/create',
        {
          'organizationId': widget.organizationId,
          'notes': notes,
        },
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Request has been sent!")),
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
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _openJoinModal() {
    final TextEditingController notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Notes'),
          content: TextField(
            controller: notesController,
            decoration: const InputDecoration(hintText: "Enter your notes..."),
            maxLines: 3,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String notes = notesController.text;
                if (notes.isNotEmpty) {
                  createRequest(notes);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Notes cannot be empty")),
                  );
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _onRefresh() async {
    setState(() {
      _organizationFuture = getDetail(widget.organizationId);
    });
  }

  @override
  void initState() {
    super.initState();
    _organizationFuture = getDetail(widget.organizationId);
  }

  @override
  Widget build(BuildContext context) {
    return BlurryModalProgressHUD(
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
              appBar: AppBar(
                title: const Text('Organization Details'),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.pop(),
                ),
              ),
              body: RefreshIndicator(
                onRefresh: _onRefresh,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          clipBehavior: Clip.none,
                          children: <Widget>[
                            Container(
                              height: 200.0,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(
                                      organization.banner.isNotEmpty
                                          ? organization.banner
                                          : bannerPlaceHolder),
                                ),
                              ),
                              child: Container(
                                color: Colors.black.withOpacity(0.3),
                              ),
                            ),
                            Positioned(
                              top: 100.0,
                              child: Container(
                                height: 150.0,
                                width: 150.0,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: NetworkImage(
                                        organization.image.isNotEmpty
                                            ? organization.image
                                            : imagePlaceHolder),
                                  ),
                                  border: Border.all(
                                    color: Colors.transparent,
                                    width: 5.0,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 50),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(
                              organization.name,
                              style: Theme.of(context).textTheme.headlineLarge,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              organization.description,
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.location_on,
                                    color: Colors.grey),
                                const SizedBox(width: 5),
                                Text(
                                  organization.address.isNotEmpty
                                      ? organization.address
                                      : 'No address provided',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Chip(
                              label: Text(organization.isPrivate
                                  ? 'Private'
                                  : 'Public'),
                              backgroundColor: organization.isPrivate
                                  ? Colors.red
                                  : Colors.green,
                              labelStyle: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: _openJoinModal,
                                  icon: const Icon(Icons.pan_tool_rounded),
                                  label: const Text('Join'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
