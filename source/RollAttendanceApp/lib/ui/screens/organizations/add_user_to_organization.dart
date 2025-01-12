import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:itproject/enums/user_role.dart';
import 'package:itproject/models/requests/invited_list_request.dart';
import 'package:itproject/models/requests/invited_users_request.dart';
import 'package:itproject/models/user_model.dart';
import 'package:itproject/services/api_service.dart';
import 'package:itproject/services/user_service.dart';
import 'package:csv/csv.dart';

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
  Map<UserModel, UserRole> _userRoles = {};

  // Hàm tìm kiếm người dùng theo email
  Future<void> _searchUserByEmail() async {
    setState(() {
      _isLoading = true;
    });

    try {
<<<<<<< HEAD
      final user = await _userService
          .getUserByEmail(_emailController.text);
=======
      final user = await _userService.getUserByEmail(_emailController.text);
>>>>>>> 0c771df7b3fe15117f81e104759bca473418922f
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
        _userRoles.remove(user);
      } else {
        _selectedUsers.add(user);
        _selectRoleForUser(user);
      }
    });
  }

  Future<void> _selectRoleForUser(UserModel user) async {
    UserRole selectedRole = _userRoles[user] ?? UserRole.USER;

    final UserRole? newRole = await showDialog<UserRole>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Role for User',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  DropdownButton<UserRole>(
                    value: selectedRole,
                    onChanged: (UserRole? role) {
                      if (role != null) {
                        setState(() {
                          selectedRole = role;
                        });
                      }
                    },
                    items: UserRole.values.map((UserRole role) {
                      return DropdownMenuItem<UserRole>(
                        value: role,
                        child: Text(getRoleName(role)),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, selectedRole);
                    },
                    child: const Text('Set Role'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (newRole != null) {
      setState(() {
        _userRoles[user] = newRole;
      });
    }
  }

  // Hàm xử lý Import file CSV
  Future<void> _importCsv() async {
    // Chọn tệp CSV
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null) {
      String filePath = result.files.single.path!;
      final input = await File(filePath).readAsString();

      List<List<dynamic>> csvTable =
          const CsvToListConverter().convert(input, eol: '\n');

      csvTable.removeAt(0);

      for (var row in csvTable) {
        if (row.length == 2) {
          String email = row[0];
          String roleString = row[1].toString();

          try {
            final user = await _userService.getUserByEmail(email);

            UserRole role = UserRole.values.firstWhere(
              (e) => e.toString().split('.').last == roleString,
              orElse: () => UserRole.USER,
            );

            setState(() {
              _selectedUsers.add(user);
              _userRoles[user] = role;
            });

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Role updated for $email')),
              );
            }
          } catch (e) {
            // Xử lý khi người dùng không tồn tại
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('User not found for email: $email')),
              );
            }
          }
        } else {
          // Thông báo nếu dòng không có đủ dữ liệu
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Invalid data in CSV row: $row')),
            );
            print('Invalid data in CSV row: $row');
          }
        }
      }
    } else {
      // Thông báo nếu không chọn tệp
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No file selected')),
        );
      }
    }
  }

  // Hàm mời người dùng vào tổ chức
  Future<void> _addToOrganization() async {
    setState(() {
      _isLoading = true;
    });

    bool allUsersAddedSuccessfully = true;
    String failedUsers = "";

    try {
      final invitedList = InvitedList(
        users: _selectedUsers.map((user) {
          return InvitedUsers(
            userId: user.uid,
            role: getRoleValue(_userRoles[user] ?? UserRole.USER),
          );
        }).toList(),
      );

      final response = await _apiService.post(
        'api/organization/invite/${widget.organizationId}',
        invitedList.toMap(),
      );

      if (response.statusCode != 200) {
        allUsersAddedSuccessfully = false;
        failedUsers = _selectedUsers.map((user) => user.displayName).join(', ');
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
<<<<<<< HEAD
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
=======
        title: const Text("Add Users"),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: _importCsv,
          ),
>>>>>>> 0c771df7b3fe15117f81e104759bca473418922f
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
                        onTap: () => _selectRoleForUser(user),
                      ),
                    );
                  }).toList(),
                ),
              ],

<<<<<<< HEAD
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
=======
>>>>>>> 0c771df7b3fe15117f81e104759bca473418922f
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
                        subtitle: Text(
                            '${user.email} - ${getRoleName(_userRoles[user] ?? UserRole.USER)}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove_circle_outline,
                              color: Colors.red),
                          onPressed: () => _toggleSelectUser(user),
                        ),
                        onTap: () => _selectRoleForUser(user),
                      ),
                    );
                  }).toList(),
                ),
              ],
<<<<<<< HEAD
=======

              const SizedBox(height: 24),

              // Nút thêm người dùng
              Center(
                child: ElevatedButton(
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
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                  ),
                  child: const Text('Invite User(s)'),
                ),
              ),
>>>>>>> 0c771df7b3fe15117f81e104759bca473418922f
            ],
          ),
        ),
      ),
    );
  }
}
