class UserModel {
  final String id;
  final String uid;
  final String email;
  final String displayName;
  final String phoneNumber;
  final String avatar;
  final int? role;

  UserModel({
    required this.id,
    required this.uid,
    required this.email,
    required this.displayName,
    required this.phoneNumber,
    required this.avatar,
    this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      uid: json['uid'],
      email: json['email'],
      displayName: json['displayName'],
      phoneNumber: json['phoneNumber'],
      avatar: json['avatar'],
      role: json['role'],
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      uid: map['uid'],
      email: map['email'],
      displayName: map['displayName'],
      phoneNumber: map['phoneNumber'],
      avatar: map['avatar'],
      role: map['role'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'avatar': avatar,
      if (role != null) 'role': role,
    };
  }
}
