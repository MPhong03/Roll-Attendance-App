// import 'dart:ffi';

class AvailableEventModel {
  String? id;
  String? name;
  String? description;
  DateTime? startTime;
  DateTime? endTime;
  String? currentLocation;
  double? currentLocationRadius;
  String? currentQR;
  int? eventStatus;

  // ORGANIZER
  String? organizerId;
  String? organizerName;
  String? organizerEmail;
  String? organizerAvatar;

  // ORGANIZATION
  String? organizationId;
  String? organizationName;
  String? organizationImage;

  // ATTENDANCE
  bool? isCheckInYet;
  int? attendanceStatus;
  int? attendanceTimes;

  bool? isPrivate;

  AvailableEventModel(
      {this.id,
      this.name,
      this.description,
      this.startTime,
      this.endTime,
      this.currentLocation,
      this.currentLocationRadius,
      this.currentQR,
      this.eventStatus,
      this.organizerId,
      this.organizerName,
      this.organizerEmail,
      this.organizerAvatar,
      this.organizationId,
      this.organizationName,
      this.organizationImage,
      this.isPrivate,
      this.attendanceStatus,
      this.attendanceTimes,
      this.isCheckInYet});

  // From JSON
  factory AvailableEventModel.fromJson(Map<String, dynamic> json) {
    return AvailableEventModel(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        startTime: json['startTime'] != null
            ? DateTime.parse(json['startTime'])
            : null,
        endTime:
            json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
        currentLocation: json['currentLocation'],
        currentLocationRadius:
            (json['currentLocationRadius'] as num?)?.toDouble(),
        currentQR: json['currentQR'],
        eventStatus: json['eventStatus'],
        organizerId: json['organizerId'],
        organizerName: json['organizerName'],
        organizerEmail: json['organizerEmail'],
        organizerAvatar: json['organizerAvatar'],
        organizationId: json['organizationId'],
        organizationName: json['organizationName'],
        organizationImage: json['organizationImage'],
        isPrivate: json['isPrivate'],
        attendanceStatus: json['attendanceStatus'],
        attendanceTimes: json['attendanceTimes'],
        isCheckInYet: json['isCheckInYet']);
  }

  // From Map
  factory AvailableEventModel.fromMap(Map<String, dynamic> map) {
    return AvailableEventModel(
        id: map['id'],
        name: map['name'],
        description: map['description'],
        startTime:
            map['startTime'] != null ? DateTime.parse(map['startTime']) : null,
        endTime: map['endTime'] != null ? DateTime.parse(map['endTime']) : null,
        currentLocation: map['currentLocation'],
        currentLocationRadius:
            (map['currentLocationRadius'] as num?)?.toDouble(),
        currentQR: map['currentQR'],
        eventStatus: map['eventStatus'],
        organizerId: map['organizerId'],
        organizerName: map['organizerName'],
        organizerEmail: map['organizerEmail'],
        organizerAvatar: map['organizerAvatar'],
        organizationId: map['organizationId'],
        organizationName: map['organizationName'],
        organizationImage: map['organizationImage'],
        isPrivate: map['isPrivate'],
        attendanceStatus: map['attendanceStatus'],
        attendanceTimes: map['attendanceTimes'],
        isCheckInYet: map['isCheckInYet']);
  }

  // To Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'currentLocation': currentLocation,
      'currentLocationRadius': currentLocationRadius,
      'currentQR': currentQR,
      'eventStatus': eventStatus,
      'organizerId': organizerId,
      'organizerName': organizerName,
      'organizerEmail': organizerEmail,
      'organizerAvatar': organizerAvatar,
      'organizationId': organizationId,
      'organizationName': organizationName,
      'organizationImage': organizationImage,
      'isPrivate': isPrivate,
      'attendanceStatus': attendanceStatus,
      'attendanceTimes': attendanceTimes,
      'isCheckInYet': isCheckInYet
    };
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return toMap();
  }
}
