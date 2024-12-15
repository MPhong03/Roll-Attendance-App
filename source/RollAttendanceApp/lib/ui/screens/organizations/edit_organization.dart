import 'dart:convert';
import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:blurry_modal_progress_hud/blurry_modal_progress_hud.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:itproject/models/organization_model.dart';
import 'package:itproject/services/api_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';

class EditOrganizationScreen extends StatefulWidget {
  final String organizationId;

  const EditOrganizationScreen({super.key, required this.organizationId});

  @override
  State<EditOrganizationScreen> createState() => _EditOrganizationScreenState();
}

class _EditOrganizationScreenState extends State<EditOrganizationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  dynamic selectedBannerFile;
  dynamic selectedImageFile;
  String? selectedImageUrl;
  String? selectedBannerUrl;
  bool _isPrivate = false;
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  Widget displayImage(dynamic fileOrUrl) {
    if (fileOrUrl is String && Uri.tryParse(fileOrUrl)?.isAbsolute == true) {
      // If it's a URL
      return Image.network(
        fileOrUrl,
        height: 100,
        width: 100,
        fit: BoxFit.cover,
      );
    } else if (fileOrUrl is Uint8List) {
      // If it's data for web
      return Image.memory(
        fileOrUrl,
        height: 100,
        width: 100,
        fit: BoxFit.cover,
      );
    } else if (fileOrUrl is File) {
      // If it's a file (mobile)
      return Image.file(
        fileOrUrl,
        height: 100,
        width: 100,
        fit: BoxFit.cover,
      );
    } else {
      return const SizedBox();
    }
  }

  Future<OrganizationModel> getDetail(id) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final response = await _apiService.get('api/organization/detail/$id');

      if (response.statusCode == 200) {
        return OrganizationModel.fromMap(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load organization');
      }
    } catch (e) {
      throw Exception('Failed to load organization: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadOrganizationDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final organization = await getDetail(widget.organizationId);
      _nameController.text = organization.name;
      _descriptionController.text = organization.description;
      _addressController.text = organization.address;
      _isPrivate = organization.isPrivate;
      selectedImageUrl = organization.image;
      selectedBannerUrl = organization.banner;
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error loading organization: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _uploadImageFromGallery(bool isBanner) async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        if (kIsWeb) {
          final Uint8List imageBytes = await image.readAsBytes();
          setState(() {
            if (isBanner) {
              selectedBannerFile = imageBytes;
              selectedBannerUrl = null;
            } else {
              selectedImageFile = imageBytes;
              selectedImageUrl = null;
            }
          });
        } else {
          setState(() {
            if (isBanner) {
              selectedBannerFile = File(image.path);
              selectedBannerUrl = null;
            } else {
              selectedImageFile = File(image.path);
              selectedImageUrl = null;
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

  Future<void> _editOrganization() async {
    if (!_formKey.currentState!.validate()) return;

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

      final response = await _apiService.putFiles(
          'api/organization/${widget.organizationId}', images,
          additionalData: data);

      if (response.statusCode == 200) {
        final orgId = jsonDecode(response.body)['id'];

        if (mounted) {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.success,
            animType: AnimType.scale,
            title: 'Success',
            desc: 'Organization created successfully',
            btnOkOnPress: () {
              context.push('/organization-detail/$orgId');
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
            desc: 'Failed to update organization',
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

  @override
  void initState() {
    super.initState();
    _loadOrganizationDetails();
  }

  @override
  Widget build(BuildContext context) {
    return BlurryModalProgressHUD(
      inAsyncCall: _isLoading,
      opacity: 0.3,
      blurEffectIntensity: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create Organization'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 16),
                  selectedImageFile != null || selectedImageUrl != null
                      ? displayImage(selectedImageFile ?? selectedImageUrl)
                      : const SizedBox(),
                  ElevatedButton.icon(
                    onPressed: () => _uploadImageFromGallery(false),
                    icon: const Icon(Icons.image),
                    label: const Text('Choose Image'),
                  ),
                  const SizedBox(height: 16),
                  selectedBannerFile != null || selectedBannerUrl != null
                      ? displayImage(selectedBannerFile ?? selectedBannerUrl)
                      : const SizedBox(),
                  ElevatedButton.icon(
                    onPressed: () => _uploadImageFromGallery(true),
                    icon: const Icon(Icons.image),
                    label: const Text('Choose Banner'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Organization Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter organization name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: 'Address (Optional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  SwitchListTile(
                    title: const Text('Private'),
                    value: _isPrivate,
                    onChanged: (bool value) {
                      setState(() {
                        _isPrivate = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _editOrganization,
                    child: const Text('Update'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
