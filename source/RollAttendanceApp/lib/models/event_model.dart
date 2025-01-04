import 'package:itproject/enums/event_status.dart';

class EventModel {
  final String id;
  final String name;
  final DateTime? startTime;
  final DateTime? endTime;
  final String description;
  final String organizationId;
  final bool isPrivate;
  final EventStatus eventStatus;
  final String? currentLocation;
  final double? currentLocationRadius;
  final String? currentQR;

  EventModel({
    required this.id,
    required this.name,
    this.startTime,
    this.endTime,
    required this.description,
    required this.organizationId,
    required this.isPrivate,
    required this.eventStatus,
    this.currentLocation,
    this.currentLocationRadius,
    this.currentQR,
  });

  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      startTime:
          map['startTime'] != null ? DateTime.parse(map['startTime']) : null,
      endTime: map['endTime'] != null ? DateTime.parse(map['endTime']) : null,
      description: map['description'] ?? '',
      organizationId: map['organizationId'] ?? '',
      eventStatus: _mapEventStatus(map['eventStatus']),
      isPrivate: map['isPrivate'] ?? false,
      currentLocation: map['currentLocation'],
      currentLocationRadius: map['currentLocationRadius']?.toDouble(),
      currentQR: map['currentQR'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'description': description,
      'organizationId': organizationId,
      'isPrivate': isPrivate,
      'eventStatus': eventStatus.index,
      'currentLocation': currentLocation,
      'currentLocationRadius': currentLocationRadius,
      'currentQR': currentQR,
    };
  }

  static EventStatus _mapEventStatus(int? status) {
    switch (status) {
      case 0:
        return EventStatus.notStarted;
      case 1:
        return EventStatus.inProgress;
      case 2:
        return EventStatus.completed;
      case 3:
        return EventStatus.cancelled;
      case 4:
        return EventStatus.postponed;
      default:
        return EventStatus.notStarted; // Default to 'not started'
    }
  }
}
