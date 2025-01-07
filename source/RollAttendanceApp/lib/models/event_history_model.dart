class HistoryModel {
  String? id;
  DateTime? occurDate;
  DateTime? startTime;
  DateTime? endTime;
  int? totalCount;
  int? presentCount;
  int? lateCount;
  int? attendanceTimes;
  String? eventId;

  HistoryModel({
    this.id,
    this.occurDate,
    this.startTime,
    this.endTime,
    this.totalCount,
    this.presentCount,
    this.lateCount,
    this.attendanceTimes,
    this.eventId,
  });

  // From JSON
  factory HistoryModel.fromJson(Map<String, dynamic> json) {
    return HistoryModel(
      id: json['id'],
      occurDate:
          json['occurDate'] != null ? DateTime.parse(json['occurDate']) : null,
      startTime:
          json['startTime'] != null ? DateTime.parse(json['startTime']) : null,
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      totalCount: json['totalCount'],
      presentCount: json['presentCount'],
      lateCount: json['lateCount'],
      attendanceTimes: json['attendanceTimes'],
      eventId: json['eventId'],
    );
  }

  // From Map
  factory HistoryModel.fromMap(Map<String, dynamic> map) {
    return HistoryModel(
      id: map['id'],
      occurDate:
          map['occurDate'] != null ? DateTime.parse(map['occurDate']) : null,
      startTime:
          map['startTime'] != null ? DateTime.parse(map['startTime']) : null,
      endTime: map['endTime'] != null ? DateTime.parse(map['endTime']) : null,
      totalCount: map['totalCount'],
      presentCount: map['presentCount'],
      lateCount: map['lateCount'],
      attendanceTimes: map['attendanceTimes'],
      eventId: map['eventId'],
    );
  }

  // To Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'occurDate': occurDate?.toIso8601String(),
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'totalCount': totalCount,
      'presentCount': presentCount,
      'lateCount': lateCount,
      'attendanceTimes': attendanceTimes,
      'eventId': eventId,
    };
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return toMap();
  }
}
