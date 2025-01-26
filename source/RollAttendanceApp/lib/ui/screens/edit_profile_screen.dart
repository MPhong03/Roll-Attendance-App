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

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  OverlayEntry? _overlayEntry;
  final UserService _userService = UserService();
  final ApiService _apiService = ApiService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String uid = "";
  String name = "";
  String phoneNumber = "";
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
    TextEditingController phoneController =
        TextEditingController(text: phoneNumber);
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
                    // const SizedBox(height: 10),
                    // TextField(
                    //   controller: phoneController,
                    //   decoration: const InputDecoration(labelText: 'Phone'),
                    // ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            _updateProfile(nameController.text,
                                phoneController.text, selectedImageFile);
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

  Future<void> _updateProfile(String updatedName, String updatedPhone,
      dynamic selectedImageFile) async {
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
      if (updatedName != name ||
          updatedPhone != phoneNumber ||
          newProfileImageUrl != null) {
        await user?.updateDisplayName(updatedName);
        // await user?.updatePhoneNumber(phoneCredential);
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
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    double getResponsiveFontSize(double baseFontSize) {
      if (screenWidth > 480) {
        return baseFontSize * 1.2;
      } else {
        return baseFontSize;
      }
    }

    return Scaffold(
      body: Stack(
        children: [
          Container(color: Theme.of(context).scaffoldBackgroundColor),
          Positioned(
            top: screenHeight * 0.05,
            left: 0,
            right: 0,
            child: Container(
              width: screenWidth,
              height: screenHeight * 1,
              decoration: BoxDecoration(
                color: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    spreadRadius: 2,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 16,
                    left: 16,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        context.pop();
                      },
                    ),
                  ),
                  Positioned(
                    top: 16,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Text(
                        "ACCOUNT",
                        style: TextStyle(
                          fontSize: getResponsiveFontSize(25),
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                  // Avatar
                  Positioned(
                    top: screenHeight * 0.10,
                    left: screenWidth / 2 - 60,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: profileImageUrl.isNotEmpty
                              ? NetworkImage(profileImageUrl)
                              : const AssetImage('images/default-avatar.jpg')
                                  as ImageProvider,
                          backgroundColor: Colors.grey.shade200,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 2,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              // Thay đổi ảnh avatar
                              _showEditProfileBottomSheet();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Thông tin người dùng
                  Positioned(
                    top: screenHeight * 0.3,
                    left: 16,
                    right: 16,
                    child: Column(
                      children: [
                        _buildInfoRow("Username", name, screenWidth),
                        _buildInfoRow("Email", email, screenWidth),
                        // _buildInfoRow("Phone", "SDT đâu Ponie?", screenWidth),
                      ],
                    ),
                  ),
                  Positioned(
                    top: screenHeight * 0.5,
                    left: screenWidth * 0.1,
                    right: screenWidth * 0.1,
                    child: ElevatedButton(
                      onPressed: () {
                        context.push('/forgot-password');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        minimumSize: const Size(0, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Change Password",
                        style: TextStyle(
                            fontSize: getResponsiveFontSize(16),
                            color: Colors.white),
                      ),
                    ),
                  ),

                  // Nút Save
                  Positioned(
                    top: screenHeight * 0.7,
                    left: screenWidth * 0.1,
                    right: screenWidth * 0.1,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        minimumSize: const Size(0, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Save",
                        style: TextStyle(
                            fontSize: getResponsiveFontSize(16),
                            color: isDarkMode ? Colors.white : Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, double screenWidth) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    double getResponsiveFontSize(double baseFontSize) {
      if (screenWidth > 480) {
        return baseFontSize * 1.2;
      } else {
        return baseFontSize;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: getResponsiveFontSize(16),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            width: screenWidth * 0.5,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: getResponsiveFontSize(16)),
            ),
          ),
        ],
      ),
    );
  }
}
