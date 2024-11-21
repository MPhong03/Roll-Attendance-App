class ProfileModel {
  String _name;
  String _email;
  String _profileImageUrl;

  // Constructor
  ProfileModel({
    required String name,
    required String email,
    required String profileImageUrl,
  })  : _name = name,
        _email = email,
        _profileImageUrl = profileImageUrl;

  // Getter for name
  String get name => _name;

  // Setter for name
  set name(String value) {
    if (value.isNotEmpty) {
      _name = value;
    } else {
      throw Exception("Name cannot be empty");
    }
  }

  // Getter for email
  String get email => _email;

  // Setter for email
  set email(String value) {
    if (value.contains("@")) {
      _email = value;
    } else {
      throw Exception("Invalid email address");
    }
  }

  // Getter for profileImageUrl
  String get profileImageUrl => _profileImageUrl;

  // Setter for profileImageUrl
  set profileImageUrl(String value) {
    if (value.startsWith("http")) {
      _profileImageUrl = value;
    } else {
      throw Exception("Invalid image URL");
    }
  }

  // Method to convert object to a map (e.g., for API or database)
  Map<String, dynamic> toMap() {
    return {
      'name': _name,
      'email': _email,
      'profileImageUrl': _profileImageUrl,
    };
  }

  // Factory constructor to create object from map (e.g., from API or database)
  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      name: map['name'] ?? "",
      email: map['email'] ?? "",
      profileImageUrl: map['profileImageUrl'] ?? "",
    );
  }
}
