import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:blurry_modal_progress_hud/blurry_modal_progress_hud.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:itproject/models/event_model.dart';
import 'package:itproject/services/api_service.dart';

class EditEventScreen extends StatefulWidget {
  final String eventId;

  const EditEventScreen({super.key, required this.eventId});

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  bool _isPrivate = false;

  String _organizationId = "";

  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _eventDescriptionController =
      TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();

  late Future<EventModel> _eventFuture;

  Future<EventModel> getDetail(id) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final response = await _apiService.get('api/events/$id');

      if (response.statusCode == 200) {
        final event = EventModel.fromMap(jsonDecode(response.body));
        _populateFields(event);
        return event;
      } else {
        throw Exception('Failed to load event');
      }
    } catch (e) {
      throw Exception('Failed to load event: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _populateFields(EventModel event) {
    _eventNameController.text = event.name;
    _eventDescriptionController.text = event.description;
    _startTimeController.text =
        event.startTime?.toLocal().toIso8601String() ?? '';
    _endTimeController.text = event.endTime?.toLocal().toIso8601String() ?? '';
    _isPrivate = event.isPrivate;
    _organizationId = event.organizationId;
  }

  Future<void> _editEvent() async {
    if (!_validateTime()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response =
          await _apiService.put('api/events/update/${widget.eventId}', {
        'name': _eventNameController.text,
        'description': _eventDescriptionController.text,
        'startTime': _startTimeController.text,
        'endTime': _endTimeController.text,
        'isPrivate': _isPrivate,
        'organizationId': _organizationId
      });
      if (response.statusCode == 200) {
        if (mounted) {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.success,
            animType: AnimType.scale,
            title: 'Success',
            desc: 'Event updated successfully',
            btnOkOnPress: () {
              context.pop();
            },
          ).show();
        }
      } else {
        _showErrorDialog('Failed to update event: ${response.body}');
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

  Future<void> _onRefresh() async {
    setState(() {
      _eventFuture = getDetail(widget.eventId);
    });
  }

  @override
  void initState() {
    super.initState();
    _eventFuture = getDetail(widget.eventId);
  }

  @override
  Widget build(BuildContext context) {
    return BlurryModalProgressHUD(
      inAsyncCall: _isLoading,
      opacity: 0.3,
      blurEffectIntensity: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Event'),
          centerTitle: true,
        ),
        body: RefreshIndicator(
          onRefresh: _onRefresh,
          child: FutureBuilder<EventModel>(
            future: _eventFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              } else if (snapshot.hasData) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _eventNameController,
                            decoration: InputDecoration(
                              labelText: 'Event Name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              prefixIcon: const Icon(Icons.event),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter event name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _eventDescriptionController,
                            decoration: InputDecoration(
                              labelText: 'Event Description',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              prefixIcon: const Icon(Icons.description),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter event description';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () =>
                                _selectTime(context, _startTimeController),
                            child: AbsorbPointer(
                              child: TextFormField(
                                controller: _startTimeController,
                                decoration: InputDecoration(
                                  labelText: 'Start Time',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  hintText: 'Select start time',
                                  prefixIcon: const Icon(Icons.access_time),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () =>
                                _selectTime(context, _endTimeController),
                            child: AbsorbPointer(
                              child: TextFormField(
                                controller: _endTimeController,
                                decoration: InputDecoration(
                                  labelText: 'End Time',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  hintText: 'Select end time',
                                  prefixIcon: const Icon(Icons.access_time),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Private Event',
                                style: TextStyle(fontSize: 16),
                              ),
                              Switch(
                                value: _isPrivate,
                                onChanged: (value) {
                                  setState(() {
                                    _isPrivate = value;
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () {
                              if (_formKey.currentState?.validate() ?? false) {
                                _editEvent();
                              }
                            },
                            icon: const Icon(Icons.save),
                            label: const Text('Edit Event'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              } else {
                return const Center(
                  child: Text('No data found'),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
