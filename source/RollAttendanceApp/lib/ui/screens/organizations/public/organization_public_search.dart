import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDarkMode ? const Color(0xFF121212) : const Color(0xFFE9FCE9),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: TextField(
            controller: _searchController,
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            cursorColor: Colors.green,
            decoration: InputDecoration(
              hintText: 'Search organizations...',
              hintStyle: TextStyle(color: isDarkMode ? Colors.grey : Colors.black54),
              filled: true,
              fillColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              prefixIcon: Icon(Icons.search, color: isDarkMode ? Colors.white : Colors.black),
            ),
            selectionControls: materialTextSelectionControls,
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
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                Expanded(
                  child: FutureBuilder<List<PublicOrganizationModel>>(
                    future: _publicOrganizationFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
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
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text('No organizations found.'),
                        );
                      }

                      final organizations = snapshot.data!;
                      return ListView.builder(
                        itemCount: organizations.length,
                        itemBuilder: (context, index) {
                          final org = organizations[index];
                          return GestureDetector(
                            onTap: () {
                              context.push(
                                  '/public-organization-detail/${org.id}');
                            },
                            child: Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    org.image ?? 'https://via.placeholder.com/150',
                                    fit: BoxFit.cover,
                                    width: 50,
                                    height: 50,
                                  ),
                                ),
                                title: Text(
                                  org.name ?? 'N/A',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Row(
                                  children: [
                                    const Icon(Icons.person, size: 16, color: Colors.grey),
                                    const SizedBox(width: 5),
                                    Text(
                                      '${org.users}',
                                      style: const TextStyle(color: Colors.grey),
                                    ),
                                    const SizedBox(width: 10),
                                    const Icon(Icons.event, size: 16, color: Colors.grey),
                                    const SizedBox(width: 5),
                                    Text(
                                      '${org.events}',
                                      style: const TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          if (_suggestions.isNotEmpty)
            Positioned(
              top: kToolbarHeight,
              left: 16,
              right: 16,
              child: Material(
                elevation: 4,
                child: ListView.builder(
                  shrinkWrap: true,
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
        ],
      ),
    );
  }
}
