import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:itproject/models/public_organization_model.dart';
import 'package:itproject/services/api_service.dart';

class OrganizationPublicSearchScreen extends StatefulWidget {
  const OrganizationPublicSearchScreen({super.key});

  @override
  State<OrganizationPublicSearchScreen> createState() =>
      _OrganizationPublicSearchScreenState();
}

class _OrganizationPublicSearchScreenState
    extends State<OrganizationPublicSearchScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  late Future<List<PublicOrganizationModel>> _publicOrganizationFuture;

  int _page = 0;
  final int _limit = 10;
  String _keyword = "";

  TextEditingController _searchController = TextEditingController();
  List<String> _suggestions = [];

  Future<List<PublicOrganizationModel>> getPublicOrganization() async {
    try {
      final response = await _apiService.get(
          'api/organization?pageIndex=$_page&pageSize=$_limit&keyword=$_keyword');
      if (response.statusCode == 200) {
        final List orgsData = jsonDecode(response.body);
        return orgsData
            .map((org) => PublicOrganizationModel.fromMap(org))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Failed to load organizations: $e');
    }
  }

  // Function to get suggestions based on keyword
  Future<void> getSuggestions(String keyword) async {
    try {
      final response = await _apiService
          .get('api/organization/suggestions?keyword=$keyword');
      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        setState(() {
          _suggestions = List<String>.from(responseData);
        });
      } else {
        setState(() {
          _suggestions = [];
        });
      }
    } catch (e) {
      throw Exception('Failed to load suggestions: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _publicOrganizationFuture = Future.value([]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      setState(() {
                        _keyword = _searchController.text;
                        _publicOrganizationFuture = getPublicOrganization();
                      });
                    },
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    getSuggestions(value);
                  });
                },
                onSubmitted: (value) {
                  setState(() {
                    _keyword = value;
                    _publicOrganizationFuture = getPublicOrganization();
                  });
                },
              ),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: FutureBuilder<List<PublicOrganizationModel>>(
                    future: _publicOrganizationFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                            child: Text('No organizations found.'));
                      }

                      final organizations = snapshot.data!;
                      return ListView.builder(
                        itemCount: organizations.length,
                        itemBuilder: (context, index) {
                          final org = organizations[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                            child: ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  org.image ??
                                      'https://via.placeholder.com/150',
                                  fit: BoxFit.cover,
                                  width: 50,
                                  height: 50,
                                ),
                              ),
                              title: Text(org.name ?? 'N/A'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(org.description ?? 'No description'),
                                  const SizedBox(height: 5),
                                  Text('Address: ${org.address ?? 'N/A'}'),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Text('Users: ${org.users}'),
                                      const SizedBox(width: 10),
                                      Text('Events: ${org.events}'),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: _page > 0
                          ? () {
                              setState(() {
                                _page--;
                              });
                            }
                          : null,
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: () {
                        setState(() {
                          _page++;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_suggestions.isNotEmpty)
            Positioned(
              top: 3,
              left: 16,
              right: 16,
              child: Material(
                elevation: 4,
                child: Container(
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _suggestions.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: const Icon(Icons.search),
                        title: Text(_suggestions[index]),
                        onTap: () {
                          _searchController.text = _suggestions[index];
                          setState(() {
                            _keyword = _suggestions[index];
                            _publicOrganizationFuture = getPublicOrganization();
                            _suggestions.clear();
                          });
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
