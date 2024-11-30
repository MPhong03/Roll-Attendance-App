import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:itproject/services/api_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateOrganizationModal extends StatefulWidget {
  final void Function(bool) onLoadingStateChange;
  const CreateOrganizationModal(
      {super.key, required this.onLoadingStateChange});

  @override
  State<CreateOrganizationModal> createState() =>
      _CreateOrganizationModalState();
}

class _CreateOrganizationModalState extends State<CreateOrganizationModal> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  bool _isPrivate = false;
  bool _isSubmitting = false; // To manage the loading state
  final ApiService _apiService = ApiService();

  Future<void> _createOrganization() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true; // Start submitting
    });

    widget.onLoadingStateChange(true); // Start loading state change

    try {
      final data = {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'address': _addressController.text,
        'isPrivate': _isPrivate,
        'userId': FirebaseAuth.instance.currentUser?.uid,
      };

      final response = await _apiService.post('api/organization', data);
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
              Navigator.pop(context);
              Navigator.pushNamed(context, '/organization-detail',
                  arguments: organizationId);
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
            btnCancelOnPress: () => Navigator.pop(context),
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
        _isSubmitting = false; // End submitting
      });
      widget.onLoadingStateChange(false); // End loading state change
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Create Organization',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                enabled: !_isSubmitting, // Disable input while submitting
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
                enabled: !_isSubmitting, // Disable input while submitting
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
                enabled: !_isSubmitting, // Disable input while submitting
              ),
              SwitchListTile(
                title: const Text('Private'),
                value: _isPrivate,
                onChanged: _isSubmitting
                    ? null // Disable switch while submitting
                    : (bool value) {
                        setState(() {
                          _isPrivate = value;
                        });
                      },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _createOrganization,
                child: const Text('Create'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
