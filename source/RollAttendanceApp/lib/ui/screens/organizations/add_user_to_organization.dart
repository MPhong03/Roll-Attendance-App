import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:itproject/enums/user_role.dart';
import 'package:itproject/models/user_model.dart';
import 'package:itproject/services/api_service.dart';
import 'package:itproject/services/user_service.dart';

class AddUserToOrganizationScreen extends StatefulWidget {
  final String organizationId;

  const AddUserToOrganizationScreen({super.key, required this.organizationId});
  @override
  State<AddUserToOrganizationScreen> createState() =>
      _AddUserToOrganizationScreenState();
}

class _AddUserToOrganizationScreenState
    extends State<AddUserToOrganizationScreen> {
  final TextEditingController _emailController = TextEditingController();
  final ApiService _apiService = ApiService();
  final UserService _userService = UserService();
  bool _isLoading = false;
  List<UserModel> _searchResults = [];
  final List<UserModel> _selectedUsers = [];
  UserRole _selectedRole = UserRole.USER; // Default role is User

  // Hàm tìm kiếm người dùng theo email
  Future<void> _searchUserByEmail() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _userService
          .getUserByEmail(_emailController.text);
      setState(() {
        _searchResults = [user];
      });
    } catch (e) {
      setState(() {
        _searchResults = [];
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No user found')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Hàm chọn người dùng từ kết quả tìm kiếm
  void _toggleSelectUser(UserModel user) {
    setState(() {
      if (_selectedUsers.contains(user)) {
        _selectedUsers.remove(user);
      } else {
        _selectedUsers.add(user);
      }
    });
  }

  Future<void> _addToOrganization() async {
    setState(() {
      _isLoading = true;
    });

    bool allUsersAddedSuccessfully = true;
    String failedUsers = "";

    try {
      for (var user in _selectedUsers) {
        final data = {
          'userId': user.uid,
          'role': getRoleValue(_selectedRole),
        };

        // Make the POST request
        final response = await _apiService.post(
          'api/organization/add/${widget.organizationId}',
          data,
        );

        if (response.statusCode != 200) {
          allUsersAddedSuccessfully = false;
          failedUsers += "${user.displayName}, ";
        }
      }
    } catch (e) {
      allUsersAddedSuccessfully = false;
      failedUsers = e.toString();
    } finally {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        if (allUsersAddedSuccessfully) {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.success,
            animType: AnimType.scale,
            title: 'Success',
            desc: 'All users have been successfully added to the organization.',
            btnOkOnPress: () {
              context.push('/organization-detail/${widget.organizationId}');
            },
          ).show();
        } else {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.error,
            animType: AnimType.scale,
            title: 'Error',
            desc: 'Failed to add some users: $failedUsers',
            btnCancelOnPress: () {},
          ).show();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDarkMode ? Color(0xFF121212) : Color(0xFFE9FCe9),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDarkMode ? Colors.white : Colors.black,),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (_selectedUsers.isNotEmpty)
            IconButton(
              icon: Icon(Icons.check, color: isDarkMode ? Colors.white : Colors.black,),
              onPressed: () {
                _addToOrganization();
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: SizedBox(
                  width: screenWidth * 0.8,
                  child: TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: const TextStyle(color: Colors.green),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(color: Colors.green),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide:
                            const BorderSide(color: Colors.green, width: 2),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Search Button
              Center(
                child: SizedBox(
                  width: screenWidth * 0.8,
                  child: ElevatedButton(
                    onPressed: _searchUserByEmail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, 
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          )
                        : const Text(
                            "Search",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Search Results
              if (_searchResults.isNotEmpty) ...[
                const Text(
                  'Search Results:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Column(
                  children: _searchResults.map((user) {
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(user.avatar),
                          radius: 20,
                        ),
                        title: Text(user.displayName),
                        subtitle: Text(user.email),
                        trailing: IconButton(
                          icon: _selectedUsers.contains(user)
                              ? const Icon(Icons.check_circle, color: Colors.green)
                              : const Icon(Icons.add_circle_outline),
                          onPressed: () => _toggleSelectUser(user),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],

              // No User Found
              if (_searchResults.isEmpty && !_isLoading) ...[
                const Text(
                  "No user found.",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
              const SizedBox(height: 16),

              // Role Selection
              if (_selectedUsers.isNotEmpty) ...[
                const Text(
                  'Select Role:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButton<UserRole>(
                  value: _selectedRole,
                  onChanged: (UserRole? newRole) {
                    setState(() {
                      _selectedRole = newRole!;
                    });
                  },
                  items: UserRole.values.map((UserRole role) {
                    return DropdownMenuItem<UserRole>(
                      value: role,
                      child: Text(getRoleName(role)),
                    );
                  }).toList(),
                ),
              ],

              // Selected Users
              if (_selectedUsers.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Selected Users:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Column(
                  children: _selectedUsers.map((user) {
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(user.avatar),
                          radius: 20,
                        ),
                        title: Text(user.displayName),
                        subtitle: Text(user.email),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove_circle_outline,
                              color: Colors.red),
                          onPressed: () => _toggleSelectUser(user),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
