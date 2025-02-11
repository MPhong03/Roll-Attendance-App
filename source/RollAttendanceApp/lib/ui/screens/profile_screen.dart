import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:itproject/services/api_service.dart';
import 'package:itproject/services/user_service.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  OverlayEntry? _overlayEntry;
  final UserService _userService = UserService();
  final ApiService _apiService = ApiService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String uid = "";
  String name = "";
  String email = "";
  String profileImageUrl = "";
  String noName = "";

  void _showLoadingOverlay() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_overlayEntry != null) return;
      _overlayEntry = OverlayEntry(
        builder: (context) => Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      );
      Overlay.of(context).insert(_overlayEntry!);
    });
  }

  void _hideLoadingOverlay() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_overlayEntry != null) {
        _overlayEntry!.remove();
        _overlayEntry = null;
      }
    });
  }

  Future<void> _logout() async {
    _showLoadingOverlay();

    try {
      await FirebaseAuth.instance.signOut();

      if (mounted) {
        Fluttertoast.showToast(
          msg: "You have been logged out",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0,
        );

        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.bottomSlide,
          title: 'Error',
          desc: 'Error, $e',
          btnCancelOnPress: () {},
        ).show();
      }
    } finally {
      _hideLoadingOverlay();
    }
  }

  @override
  void initState() {
    super.initState();
    _getProfile();
  }

  Future<void> _getProfile() async {
    try {
      _showLoadingOverlay();

      final result = await _userService.getProfile();

      if (result != null) {
        setState(() {
          uid = result.uid;
          name = result.name;
          email = result.email;
          profileImageUrl = result.profileImageUrl;
          noName = 'user_${result.uid}';
        });
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Authorized failed, $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 5,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } finally {
      _hideLoadingOverlay();
    }
  }

  Future<void> _showEditProfileBottomSheet() {
    TextEditingController nameController = TextEditingController(text: name);
    dynamic selectedImageFile;

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    selectedImageFile != null
                        ? Column(
                            children: [
                              kIsWeb
                                  ? Image.memory(
                                      selectedImageFile,
                                      height: 100,
                                      width: 100,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.file(
                                      selectedImageFile,
                                      height: 100,
                                      width: 100,
                                      fit: BoxFit.cover,
                                    ),
                              const SizedBox(height: 10),
                            ],
                          )
                        : const SizedBox(),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        try {
                          final XFile? image = await picker.pickImage(
                              source: ImageSource.gallery);

                          if (image != null) {
                            if (kIsWeb) {
                              final Uint8List imageBytes =
                                  await image.readAsBytes();
                              setModalState(() {
                                selectedImageFile = imageBytes;
                              });
                            } else {
                              setModalState(() {
                                selectedImageFile = File(image.path);
                              });
                            }
                          } else {
                            Fluttertoast.showToast(
                              msg: "No file selected!",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: Colors.orange,
                              textColor: Colors.white,
                            );
                          }
                        } catch (e) {
                          Fluttertoast.showToast(
                            msg: "Error selecting image: $e",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                          );
                        }
                      },
                      icon: const Icon(Icons.image),
                      label: const Text('Choose Image'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            _updateProfile(
                                nameController.text, selectedImageFile);
                          },
                          child: const Text('Update'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                          ),
                          child: const Text('Cancel'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _updateProfile(
      String updatedName, dynamic selectedImageFile) async {
    _showLoadingOverlay();

    try {
      String? newProfileImageUrl;

      if (selectedImageFile != null) {
        if (selectedImageFile is Uint8List) {
          final response = await _apiService.postFile(
            'api/auth/upload-profile-image',
            selectedImageFile,
          );

          if (response.statusCode == 200) {
            newProfileImageUrl = jsonDecode(response.body)['url'];
          } else {
            throw Exception('Failed to upload image');
          }
        } else if (selectedImageFile is File) {
          final response = await _apiService.postFile(
            'api/auth/upload-profile-image',
            selectedImageFile,
          );

          if (response.statusCode == 200) {
            newProfileImageUrl = jsonDecode(response.body)['url'];
          } else {
            throw Exception('Failed to upload image');
          }
        }
      }

      final user = _auth.currentUser;
      if (updatedName != name || newProfileImageUrl != null) {
        await user?.updateDisplayName(updatedName);
        if (newProfileImageUrl != null) {
          await user?.updatePhotoURL(newProfileImageUrl);
          setState(() {
            profileImageUrl = newProfileImageUrl as String;
          });
        }
        setState(() {
          name = updatedName;
        });
      }

      await _apiService.put('api/auth/shareProfile', {});

      if (mounted) {
        Fluttertoast.showToast(
          msg: "Profile updated successfully!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 5,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(
          msg: "Error updating profile: $e",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 5,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } finally {
      _hideLoadingOverlay();
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    double getResponsiveFontSize(double baseFontSize) {
      return screenWidth > 480 ? baseFontSize * 1.2 : baseFontSize;
    }

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE9FCe9), Colors.green],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Positioned(
            top: screenHeight * 0.2,
            left: 0,
            right: 0,
            child: Container(
              height: screenHeight * 0.78,
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.black : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(75),
                  topRight: Radius.circular(75),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 125),
                      _buildListTile(context, Icons.account_circle, 'Account',
                          '/editprofile'),
                      _buildListTile(context, Icons.sensor_occupied_rounded,
                          'Biometrics', '/update-face-data'),
                      _buildListTile(context, Icons.mail_rounded, 'Invitations',
                          '/my-invitations'),
                      _buildListTile(
                          context, Icons.notifications, 'Notifications', '/my-notifications'),
                      _buildListTile(context, Icons.settings, 'Settings', '/settings'),
                      _buildListTile(context, Icons.help, 'Help & Support', ''),
                      Divider(),
                      ListTile(
                        leading: Icon(Icons.logout, color: Colors.red),
                        title: Text(
                          'Logout',
                          style: TextStyle(
                              fontSize: getResponsiveFontSize(16),
                              color: Colors.red),
                        ),
                        onTap: _logout,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: screenHeight * 0.1,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: NetworkImage(profileImageUrl),
                  backgroundColor: Colors.grey.shade200,
                ),
                const SizedBox(height: 16),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: getResponsiveFontSize(24),
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: getResponsiveFontSize(14),
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(
      BuildContext context, IconData icon, String title, String route) {
    return ListTile(
      leading: Icon(icon, color: Colors.green), // Đổi màu icon thành xanh lá
      title: Text(
        title,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: route.isNotEmpty ? () => context.push(route) : null,
    );
  }
}
