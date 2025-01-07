class HistoryDetailModel {
  String? id;
  String? userId;
  String? userName;
  String? userEmail;
  String? userAvatar;
  DateTime? absentTime;
  DateTime? leaveTime;
  int? attendanceCount;
  int? attendanceStatus;

  HistoryDetailModel({
    this.id,
    this.userId,
    this.userName,
    this.userEmail,
    this.userAvatar,
    this.absentTime,
    this.leaveTime,
    this.attendanceCount,
    this.attendanceStatus,
  });

  // From JSON
  factory HistoryDetailModel.fromJson(Map<String, dynamic> json) {
    return HistoryDetailModel(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'],
      userEmail: json['userEmail'],
      userAvatar: json['userAvatar'],
      absentTime: json['absentTime'] != null
          ? DateTime.parse(json['absentTime'])
          : null,
      leaveTime:
          json['leaveTime'] != null ? DateTime.parse(json['leaveTime']) : null,
      attendanceCount: json['attendanceCount'],
      attendanceStatus: json['attendanceStatus'],
    );
  }

  // From Map
  factory HistoryDetailModel.fromMap(Map<String, dynamic> map) {
    return HistoryDetailModel(
      id: map['id'],
      userId: map['userId'],
      userName: map['userName'],
      userEmail: map['userEmail'],
      userAvatar: map['userAvatar'],
      absentTime:
          map['absentTime'] != null ? DateTime.parse(map['absentTime']) : null,
      leaveTime:
          map['leaveTime'] != null ? DateTime.parse(map['leaveTime']) : null,
      attendanceCount: map['attendanceCount'],
      attendanceStatus: map['attendanceStatus'],
    );
  }

  // To Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'userAvatar': userAvatar,
      'absentTime': absentTime?.toIso8601String(),
      'leaveTime': leaveTime?.toIso8601String(),
      'attendanceCount': attendanceCount,
      'attendanceStatus': attendanceStatus,
    };
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return toMap();
  }
}
