import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:blurry_modal_progress_hud/blurry_modal_progress_hud.dart';
import 'package:go_router/go_router.dart';
import 'package:itproject/models/event_model.dart';
import 'package:itproject/models/organization_model.dart';
import 'package:itproject/services/api_service.dart';

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
  late Future<List<EventModel>> _eventListFuture;
  int _page = 1;
  final int _limit = 10;

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

  Future<List<EventModel>> getEvents(id) async {
    try {
      final response = await _apiService
          .get('api/events/organization/$id?page=$_page&limit=$_limit');
      if (response.statusCode == 200) {
        final List eventsData = jsonDecode(response.body);
        return eventsData.map((event) => EventModel.fromMap(event)).toList();
      } else {
        throw Exception('Failed to load events');
      }
    } catch (e) {
      throw Exception('Failed to load events: $e');
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      _organizationFuture =
          getDetail(widget.organizationId); // Refresh organization data
      _eventListFuture =
          getEvents(widget.organizationId); // Refresh events data
    });
  }

  @override
  void initState() {
    super.initState();
    _organizationFuture = getDetail(widget.organizationId);
    _eventListFuture = getEvents(widget.organizationId);
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
                title: const Text('Organization'),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    context.pop();
                  },
                ),
              ),
              body: RefreshIndicator(
                onRefresh: _onRefresh,
                child: ListView(
                  children: <Widget>[
                    // Hiển thị chi tiết tổ chức
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
                        ElevatedButton(
                          onPressed: () {
                            context
                                .push('/create-event/${widget.organizationId}');
                          },
                          child: const Text('Add Event'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    FutureBuilder<List<EventModel>>(
                      future: _eventListFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}',
                                style: const TextStyle(color: Colors.red)),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Center(
                              child: Text('No events available'));
                        } else {
                          final events = snapshot.data!;
                          return ListView.builder(
                            shrinkWrap: true,
                            itemCount: events.length,
                            itemBuilder: (context, index) {
                              final event = events[index];
                              return ListTile(
                                title: Text(event.name),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(event.description),
                                    const SizedBox(height: 5),
                                    Text(
                                      'Start: ${event.startTime != null ? event.startTime!.toLocal().toString() : 'No Start Time'}',
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                    ),
                                    Text(
                                      'End: ${event.endTime != null ? event.endTime!.toLocal().toString() : 'No End Time'}',
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
