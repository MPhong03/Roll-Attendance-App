class ParticipationRequestModel {
  String? id;
  String? userId;
  String? userName;
  String? userEmail;
  String? organizationId;
  String? organizationName;
  String? participationMethod;
  String? notes;
  int? requestStatus;

  ParticipationRequestModel({
    this.id,
    this.userId,
    this.userName,
    this.userEmail,
    this.organizationId,
    this.organizationName,
    this.participationMethod,
    this.notes,
    this.requestStatus,
  });

  // From JSON
  factory ParticipationRequestModel.fromJson(Map<String, dynamic> json) {
    return ParticipationRequestModel(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'],
      userEmail: json['userEmail'],
      organizationId: json['organizationId'],
      organizationName: json['organizationName'],
      participationMethod: json['participationMethod'],
      notes: json['notes'],
      requestStatus: json['requestStatus'],
    );
  }

  // From Map
  factory ParticipationRequestModel.fromMap(Map<String, dynamic> map) {
    return ParticipationRequestModel(
      id: map['id'],
      userId: map['userId'],
      userName: map['userName'],
      userEmail: map['userEmail'],
      organizationId: map['organizationId'],
      organizationName: map['organizationName'],
      participationMethod: map['participationMethod'],
      notes: map['notes'],
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
      'participationMethod': participationMethod,
      'notes': notes,
      'requestStatus': requestStatus,
    };
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return toMap();
  }
}
