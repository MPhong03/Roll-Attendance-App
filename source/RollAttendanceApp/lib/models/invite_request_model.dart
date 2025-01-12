class InviteRequestModel {
  String? id;
  String? userId;
  String? userName;
  String? userEmail;
  String? organizationId;
  String? organizationName;
  String? notes;
  int? role;
  int? requestStatus;

  InviteRequestModel({
    this.id,
    this.userId,
    this.userName,
    this.userEmail,
    this.organizationId,
    this.organizationName,
    this.notes,
    this.role,
    this.requestStatus,
  });

  // From JSON
  factory InviteRequestModel.fromJson(Map<String, dynamic> json) {
    return InviteRequestModel(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'],
      userEmail: json['userEmail'],
      organizationId: json['organizationId'],
      organizationName: json['organizationName'],
      notes: json['notes'],
      role: json['role'],
      requestStatus: json['requestStatus'],
    );
  }

  // From Map
  factory InviteRequestModel.fromMap(Map<String, dynamic> map) {
    return InviteRequestModel(
      id: map['id'],
      userId: map['userId'],
      userName: map['userName'],
      userEmail: map['userEmail'],
      organizationId: map['organizationId'],
      organizationName: map['organizationName'],
      notes: map['notes'],
      role: map['role'],
      requestStatus: map['requestStatus'],
    );
  }

  // To Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'organizationId': organizationId,
      'organizationName': organizationName,
      'notes': notes,
      'role': role,
      'requestStatus': requestStatus,
    };
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return toMap();
  }
}
