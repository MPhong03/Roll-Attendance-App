import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:blurry_modal_progress_hud/blurry_modal_progress_hud.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:itproject/services/api_service.dart';

class CreateEventScreen extends StatefulWidget {
  final String organizationId;

  const CreateEventScreen({super.key, required this.organizationId});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  bool _isPrivate = false;

  // Controllers for text fields
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _eventDescriptionController =
      TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();

  Future<void> _createEvent() async {
    if (!_validateTime()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiService.post('api/events/create', {
        'name': _eventNameController.text,
        'description': _eventDescriptionController.text,
        'startTime': _startTimeController.text,
        'endTime': _endTimeController.text,
        'organizationId': widget.organizationId,
        'isPrivate': _isPrivate, // Gửi giá trị isPrivate
      });
      if (response.statusCode == 201) {
        final eventId = jsonDecode(response.body)['id'];

        if (mounted) {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.success,
            animType: AnimType.scale,
            title: 'Success',
            desc: 'Event created successfully',
            btnOkOnPress: () {
              // context.pop();
              context.push('/event-detail/$eventId');
            },
          ).show();
        }
      } else {
        _showErrorDialog('Failed to create event: ${response.body}');
      }
    } catch (e) {
      _showErrorDialog('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _validateTime() {
    try {
      final startTime = DateTime.parse(_startTimeController.text);
      final endTime = DateTime.parse(_endTimeController.text);
      if (endTime.isBefore(startTime)) {
        _showErrorDialog('End time must be after start time.');
        return false;
      }
      return true;
    } catch (_) {
      _showErrorDialog('Invalid time format.');
      return false;
    }
  }

  void _showErrorDialog(String message) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.bottomSlide,
      title: 'Error',
      desc: message,
      btnCancelOnPress: () {},
    ).show();
  }

  Future<void> _selectTime(
      BuildContext context, TextEditingController controller) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        final DateTime finalTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        setState(() {
          controller.text = finalTime.toLocal().toIso8601String();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return BlurryModalProgressHUD(
      inAsyncCall: _isLoading,
      opacity: 0.3,
      blurEffectIntensity: 5,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: isDarkMode ? Color(0xFF121212) : Color(0xFFE9FCe9),
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(
          child: Container(
            margin: EdgeInsets.only(top: 0),
            height: screenHeight * 0.8,
            width: screenWidth * 0.9,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 6.0,
                  spreadRadius: 2.0,
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Event Name
                    _buildTextFieldWithTitle(
                      title: "Event Name",
                      controller: _eventNameController,
                    ),
                    const SizedBox(height: 16),

                    // Event Description
                    _buildTextFieldWithTitle(
                      title: "Event Description",
                      controller: _eventDescriptionController,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),

                    // Start Time
                    _buildTextFieldWithTitle(
                      title: "Start Time",
                      controller: _startTimeController,
                      isReadOnly: true,
                      onTap: () => _selectTime(context, _startTimeController),
                    ),
                    const SizedBox(height: 16),

                    // End Time
                    _buildTextFieldWithTitle(
                      title: "End Time",
                      controller: _endTimeController,
                      isReadOnly: true,
                      onTap: () => _selectTime(context, _endTimeController),
                    ),
                    const SizedBox(height: 16),

                    // Private Event Switch
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Private Event',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        Switch(
                          value: _isPrivate,
                          onChanged: (value) {
                            setState(() {
                              _isPrivate = value;
                            });
                          },
                          activeColor: Colors.green,
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Create Button
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            _createEvent();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "CREATE",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFieldWithTitle({
    required String title,
    required TextEditingController controller,
    bool isReadOnly = false,
    int maxLines = 1,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: AbsorbPointer(
            absorbing: isReadOnly,
            child: TextFormField(
              controller: controller,
              readOnly: isReadOnly,
              maxLines: maxLines,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(
                    color: Colors.green,
                    width: 2.0,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter $title';
                }
                return null;
              },
            ),
          ),
        ),
      ],
    );
  }
}
