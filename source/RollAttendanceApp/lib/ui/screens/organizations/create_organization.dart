import 'dart:convert';
import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:blurry_modal_progress_hud/blurry_modal_progress_hud.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:itproject/services/api_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class CreateOrganizationScreen extends StatefulWidget {
  const CreateOrganizationScreen({super.key});

  @override
  State<CreateOrganizationScreen> createState() =>
      _CreateOrganizationScreenState();
}

class _CreateOrganizationScreenState extends State<CreateOrganizationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  dynamic selectedBannerFile;
  dynamic selectedImageFile;
  bool _isPrivate = false;
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  Future<void> _uploadImageFromGallery(bool isBanner) async {
    if (kIsWeb == false) {
      final status = await Permission.photos.status;
      if (!status.isGranted) {
        final permissionStatus = await Permission.photos.request();
        if (!permissionStatus.isGranted) {
          Fluttertoast.showToast(
            msg: "Permission to access photos denied!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
          return;
        }
      }
    }

    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        if (kIsWeb) {
          final Uint8List imageBytes = await image.readAsBytes();
          setState(() {
            if (isBanner) {
              selectedBannerFile = imageBytes;
            } else {
              selectedImageFile = imageBytes;
            }
          });
        } else {
          setState(() {
            if (isBanner) {
              selectedBannerFile = File(image.path);
            } else {
              selectedImageFile = File(image.path);
            }
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
  }

  Future<void> _createOrganization() async {
    //if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final data = {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'address': _addressController.text,
        'isPrivate': _isPrivate.toString(),
        'userId': FirebaseAuth.instance.currentUser?.uid ?? '',
      };

      Map<String, dynamic> images = {};

      if (selectedImageFile != null) {
        images['imageFile'] = selectedImageFile;
      }
      if (selectedBannerFile != null) {
        images['bannerFile'] = selectedBannerFile;
      }

      final response = await _apiService.postFiles('api/organization', images,
          additionalData: data);

      if (response.statusCode == 201) {
        final organizationId = jsonDecode(response.body)['id'];

        if (mounted) {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.success,
            animType: AnimType.scale,
            title: 'Success',
            desc: 'Organization created successfully',
            btnOkOnPress: () {
              context.push('/organization-detail/$organizationId');
            },
          ).show();
        }
      } else {
        if (mounted) {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.error,
            animType: AnimType.scale,
            title: 'Error',
            desc: 'Failed to create organization',
            btnCancelOnPress: () {},
          ).show();
        }
      }
    } catch (e) {
      if (mounted) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.bottomSlide,
          title: 'Error',
          desc: e.toString(),
          btnCancelOnPress: () {},
        ).show();
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void previewImage(dynamic imageFile) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: PhotoViewGallery.builder(
            itemCount: 1,
            builder: (context, index) {
              return PhotoViewGalleryPageOptions(
                imageProvider:
                    kIsWeb ? MemoryImage(imageFile) : FileImage(imageFile),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered,
              );
            },
            scrollPhysics: const BouncingScrollPhysics(),
            backgroundDecoration: const BoxDecoration(color: Colors.black),
          ),
        );
      },
    );
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

    return BlurryModalProgressHUD(
      inAsyncCall: _isLoading,
      opacity: 0.3,
      blurEffectIntensity: 5,
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            Positioned(
              top: screenHeight * 0.05,
              left: 16,
              right: 16,
              child: Container(
                height: screenHeight * 0.9,
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            color: isDarkMode ? Colors.white : Colors.black,
                            size: getResponsiveFontSize(30.0),
                          ),
                          onPressed: () => context.pop(),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              "CREATE ORGANIZATION",
                              style: TextStyle(
                                fontSize: getResponsiveFontSize(22),
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Banner và Avatar
                    Stack(
                      alignment: Alignment.bottomCenter,
                      clipBehavior: Clip.none,
                      children: [
                        // Banner
                        GestureDetector(
                          onTap: () => _uploadImageFromGallery(true),
                          child: Container(
                            height: 200.0,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: selectedBannerFile != null
                                    ? (kIsWeb
                                        ? MemoryImage(selectedBannerFile!)
                                        : FileImage(selectedBannerFile!)
                                            as ImageProvider)
                                    : const AssetImage(
                                            'assets/images/banner_placeholder.jpg')
                                        as ImageProvider,
                              ),
                            ),
                            child: selectedBannerFile == null
                                ? Container(
                                    color: Colors.black.withOpacity(0.3),
                                    child: const Center(
                                      child: Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                        ),

                        // Avatar
                        Positioned(
                          top: 140.0,
                          child: GestureDetector(
                            onTap: () => _uploadImageFromGallery(false),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  height: 120.0,
                                  width: 120.0,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: selectedImageFile != null
                                          ? (kIsWeb
                                              ? MemoryImage(selectedImageFile!)
                                              : FileImage(selectedImageFile!)
                                                  as ImageProvider)
                                          : const AssetImage(
                                                  'assets/images/avatar_placeholder.jpg')
                                              as ImageProvider,
                                    ),
                                    border: Border.all(
                                      color: Colors.grey,
                                      width: 2.0,
                                    ),
                                  ),
                                ),
                                if (selectedImageFile == null)
                                  const Positioned(
                                    child: Icon(
                                      Icons.camera_alt,
                                      color: Colors.black54,
                                      size: 24,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 120),

                    // Form fields
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Organization Name",
                              style: TextStyle(
                                fontSize: getResponsiveFontSize(16),
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  borderSide: const BorderSide(
                                    color: Colors.black,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  borderSide: BorderSide(
                                    color: isDarkMode ? Colors.white : Colors.black,
                                    width: 1.0,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  borderSide: const BorderSide(
                                    color: Colors.green,
                                    width: 2.0,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10.0,
                                  vertical: 12.0,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter organization name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            Text(
                              "Description",
                              style: TextStyle(
                                fontSize: getResponsiveFontSize(16),
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _descriptionController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  borderSide: const BorderSide(
                                    color: Colors.black,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  borderSide: BorderSide(
                                    color: isDarkMode ? Colors.white : Colors.black,
                                    width: 1.0,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  borderSide: const BorderSide(
                                    color: Colors.green,
                                    width: 2.0,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10.0,
                                  vertical: 12.0,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter description';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            Text(
                              "Address",
                              style: TextStyle(
                                fontSize: getResponsiveFontSize(16),
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _addressController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  borderSide: const BorderSide(
                                    color: Colors.black,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  borderSide: BorderSide(
                                    color: isDarkMode ? Colors.white : Colors.black,
                                    width: 1.0,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  borderSide: const BorderSide(
                                    color: Colors.green,
                                    width: 2.0,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10.0,
                                  vertical: 12.0,
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Private",
                                  style: TextStyle(
                                    fontSize: getResponsiveFontSize(16),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                Switch(
                                  value: _isPrivate,
                                  onChanged: (bool value) {
                                    setState(() {
                                      _isPrivate = value;
                                    });
                                  },
                                  activeColor: Colors.green,
                                ),
                              ],
                            ),
                            const SizedBox(height: 70),

                            // Save Button
                            Container(
                              margin: const EdgeInsets.only(bottom: 25),
                              alignment: Alignment.bottomCenter,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _createOrganization,
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 50),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  backgroundColor: Colors.green,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  "CREATE",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: getResponsiveFontSize(18),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
