import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart';
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
          .getUserByEmail(_emailController.text); // API tìm kiếm
      setState(() {
        _searchResults = [user]; // Cập nhật kết quả tìm kiếm
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
    return Scaffold(
      appBar: AppBar(title: const Text("Add User")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter email to search',
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _searchUserByEmail, // Tìm kiếm khi nhấn nút
                child: _isLoading
                    ? const CircularProgressIndicator() // Hiển thị loading khi tìm kiếm
                    : const Text("Search"),
              ),
              const SizedBox(height: 10),

              // Hiển thị kết quả tìm kiếm
              if (_searchResults.isNotEmpty) ...[
                Column(
                  children: _searchResults.map((user) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(user.avatar),
                        radius: 20,
                      ),
                      title: Text(user.displayName),
                      subtitle: Text(user.email),
                      trailing: _selectedUsers.contains(user)
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : const Icon(Icons.check_circle_outline),
                      onTap: () => _toggleSelectUser(user),
                    );
                  }).toList(),
                ),
              ],

              // Hiển thị thông báo nếu không tìm thấy người dùng
              if (_searchResults.isEmpty && !_isLoading) ...[
                const Text("No user found."),
              ],
              const SizedBox(height: 10),

              // Dropdown để chọn vai trò người dùng
              if (_selectedUsers.isNotEmpty) ...[
                const Text('Select Role:'),
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

              // Hiển thị danh sách người dùng đã chọn
              if (_selectedUsers.isNotEmpty) ...[
                const Text('Selected Users:'),
                Column(
                  children: _selectedUsers.map((user) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(user.avatar),
                        radius: 20,
                      ),
                      title: Text(user.displayName),
                      subtitle: Text(user.email),
                    );
                  }).toList(),
                ),
              ],

              const SizedBox(height: 20),
              // Nút thêm người dùng
              ElevatedButton(
                onPressed: () {
                  if (_selectedUsers.isNotEmpty) {
                    _addToOrganization();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Please select at least one user')),
                    );
                  }
                },
                child: const Text('Add User(s)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
