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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    double getResponsiveFontSize(double baseFontSize) =>
        screenWidth > 480 ? baseFontSize * 1.2 : baseFontSize;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Container(color: Theme.of(context).scaffoldBackgroundColor),
          Positioned(
            top: screenHeight * 0.05,
            left: 16,
            right: 16,
            child: FocusScope(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: MediaQuery.of(context).viewInsets.bottom > 0
                    ? screenHeight * 0.5
                    : screenHeight * 0.9,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
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
                  children: [
                    _buildHeader(context, getResponsiveFontSize, isDarkMode),
                    const SizedBox(height: 20),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            _buildBannerAndAvatar(),
                            const SizedBox(height: 120),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildTextField("Organization Name", _nameController,
                                    getResponsiveFontSize, isDarkMode),
                                const SizedBox(height: 20),
                                _buildTextField("Description", _descriptionController,
                                    getResponsiveFontSize, isDarkMode, maxLines: 3),
                                const SizedBox(height: 20),
                                _buildTextField("Address", _addressController,
                                    getResponsiveFontSize, isDarkMode),
                                const SizedBox(height: 30),
                                _buildSwitch(
                                  "Private",
                                  _isPrivate,
                                  (value) => setState(() => _isPrivate = value),
                                  getResponsiveFontSize,
                                ),
                                const SizedBox(height: 70),
                                _buildCreateButton(getResponsiveFontSize),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, double Function(double) fontSize, bool isDarkMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDarkMode ? Colors.white : Colors.black,
            size: fontSize(30.0),
          ),
          onPressed: () => context.pop(),
        ),
        Expanded(
          child: Center(
            child: Text(
              "CREATE ORGANIZATION",
              style: TextStyle(
                fontSize: fontSize(18),
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),
        ),
        const SizedBox(width: 48),
      ],
    );
  }

  Widget _buildBannerAndAvatar() {
    return Stack(
      alignment: Alignment.bottomCenter,
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: () => _uploadImageFromGallery(true),
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: selectedBannerFile != null
                    ? (kIsWeb
                        ? MemoryImage(selectedBannerFile!)
                        : FileImage(selectedBannerFile!) as ImageProvider)
                    : const AssetImage('assets/images/banner_placeholder.jpg')
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
        Positioned(
          top: 140,
          child: GestureDetector(
            onTap: () => _uploadImageFromGallery(false),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: selectedImageFile != null
                          ? (kIsWeb
                              ? MemoryImage(selectedImageFile!)
                              : FileImage(selectedImageFile!) as ImageProvider)
                          : const AssetImage(
                                  'assets/images/avatar_placeholder.jpg')
                              as ImageProvider,
                    ),
                    border: Border.all(color: Colors.grey, width: 2.0),
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
    );
  }

  ImageProvider _getImageProvider(dynamic file, String? url, String placeholder) {
    if (file != null) {
      return kIsWeb ? MemoryImage(file) : FileImage(file) as ImageProvider;
    }
    if (url != null) return NetworkImage(url);
    return AssetImage(placeholder);
  }

  Widget _buildTextField(String label, TextEditingController controller,
      double Function(double) fontSize, bool isDarkMode,
      {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize(16),
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0),
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
              borderSide: const BorderSide(color: Colors.green, width: 2.0),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 12.0,
            ),
          ),
          onTap: () => setState(() {}),
          validator: (value) =>
              (value == null || value.isEmpty) ? 'Please enter $label' : null,
        ),
      ],
    );
  }

  Widget _buildSwitch(String label, bool value, ValueChanged<bool> onChanged,
      double Function(double) fontSize) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize(16),
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        Switch(value: value, onChanged: onChanged, activeColor: Colors.green),
      ],
    );
  }

  Widget _buildCreateButton(double Function(double) fontSize) {
    return ElevatedButton(
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
          fontSize: fontSize(18),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
