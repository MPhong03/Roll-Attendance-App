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

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _getProfile,
        child: Stack(
          children: [
            Container(
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            Positioned(
              top: screenHeight * 0.05,
              left: 0,
              right: 0,
              child: Container(
                width: screenWidth,
                height: screenHeight * 0.9,
                decoration: BoxDecoration(
                  color: Colors.white,
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
                child: Padding(
                  padding: EdgeInsets.only(
                    top: screenHeight * 0.1,
                    left: 16.0,
                    right: 16.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Thông tin người dùng
                      Stack(
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
                                context.push('/editprofile');
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        name.isNotEmpty ? name : noName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        email.isNotEmpty ? email : 'Unable to load email!',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Divider
                      const Divider(),

                      // Danh sách các cài đặt
                      ListTile(
                        leading: const Icon(Icons.account_circle),
                        title: const Text('Account'),
                        onTap: () {},
                      ),
                      ListTile(
                        leading: const Icon(Icons.lock),
                        title: const Text('Privacy'),
                        onTap: () {
                          context.push("/update-face-data");
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.markunread_mailbox_rounded),
                        title: const Text('Requests'),
                        onTap: () {
                          context.push("/my-requests");
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.notifications),
                        title: const Text('Notifications'),
                        onTap: () {},
                      ),
                      ListTile(
                        leading: const Icon(Icons.language),
                        title: const Text('Language'),
                        onTap: () {},
                      ),
                      ListTile(
                        leading: const Icon(Icons.help),
                        title: const Text('Help & Support'),
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
