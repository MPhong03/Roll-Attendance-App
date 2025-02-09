class PermissionRequestModel {
  String? id;
  String? userId;
  String? userName;
  String? userEmail;
  String? userAvatar;
  String? organizationId;
  String? organizationName;
  String? eventId;
  String? eventName;
  String? notes;
  bool? isUsed;
  int? requestType;
  int? requestStatus;
  DateTime? createdAt;
  DateTime? updatedAt;
  bool? isDeleted;

  PermissionRequestModel({
    this.id,
    this.userId,
    this.userName,
    this.userEmail,
    this.userAvatar,
    this.organizationId,
    this.organizationName,
    this.eventId,
    this.eventName,
    this.notes,
    this.isUsed,
    this.requestType,
    this.requestStatus,
    this.createdAt,
    this.updatedAt,
    this.isDeleted,
  });

  // From JSON
  factory PermissionRequestModel.fromJson(Map<String, dynamic> json) {
    return PermissionRequestModel(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'],
      userEmail: json['userEmail'],
      userAvatar: json['userAvatar'],
      organizationId: json['organizationId'],
      organizationName: json['organizationName'],
      eventId: json['eventId'],
      eventName: json['eventName'],
      notes: json['notes'],
      isUsed: json['isUsed'] ?? false,
      requestType: json['requestType'],
      requestStatus: json['requestStatus'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      isDeleted: json['isDeleted'] ?? false,
    );
  }

  // From Map
  factory PermissionRequestModel.fromMap(Map<String, dynamic> map) {
    return PermissionRequestModel(
      id: map['id'],
      userId: map['userId'],
      userName: map['userName'],
      userEmail: map['userEmail'],
      userAvatar: map['userAvatar'],
      organizationId: map['organizationId'],
      organizationName: map['organizationName'],
      eventId: map['eventId'],
      eventName: map['eventName'],
      notes: map['notes'],
      isUsed: map['isUsed'] ?? false,
      requestType: map['requestType'],
      requestStatus: map['requestStatus'],
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
      isDeleted: map['isDeleted'] ?? false,
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
      'organizationId': organizationId,
      'organizationName': organizationName,
      'eventId': eventId,
      'eventName': eventName,
      'notes': notes,
      'isUsed': isUsed,
      'requestType': requestType,
      'requestStatus': requestStatus,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isDeleted': isDeleted,
    };
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return toMap();
  }
}
