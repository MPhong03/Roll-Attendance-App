class NotificationModel {
  String? id;
  String? userId;
  String? fcmToken;
  String? image;
  String? title;
  String? body;
  String? route;
  DateTime? createdAt;
  DateTime? updatedAt;
  bool? isDeleted;

  NotificationModel({
    this.id,
    this.userId,
    this.fcmToken,
    this.image,
    this.title,
    this.body,
    this.route,
    this.createdAt,
    this.updatedAt,
    this.isDeleted,
  });

  // From JSON
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      userId: json['userId'],
      fcmToken: json['fcmToken'],
      image: json['image'],
      title: json['title'],
      body: json['body'],
      route: json['route'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      isDeleted: json['isDeleted'] ?? false,
    );
  }

  // From Map
  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'],
      userId: map['userId'],
      fcmToken: map['fcmToken'],
      image: map['image'],
      title: map['title'],
      body: map['body'],
      route: map['route'],
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
      'fcmToken': fcmToken,
      'image': image,
      'title': title,
      'body': body,
      'route': route,
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
