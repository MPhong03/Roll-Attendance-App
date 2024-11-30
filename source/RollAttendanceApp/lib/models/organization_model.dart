class OrganizationModel {
  String _id;
  String _name;
  String _description;
  String _address;
  bool _isPrivate;

  // Constructor
  OrganizationModel({
    String id = '',
    String name = '',
    String description = '',
    String address = '',
    bool isPrivate = false,
  })  : _id = id,
        _name = name,
        _description = description,
        _address = address,
        _isPrivate = isPrivate;

  // Getter for id
  String get id => _id;

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

  // Getter for description
  String get description => _description;

  // Setter for description
  set description(String value) {
    if (value.isNotEmpty) {
      _description = value;
    } else {
      throw Exception("Description cannot be empty");
    }
  }

  // Getter for address
  String get address => _address;

  // Setter for address
  set address(String value) {
    _address = value;
  }

  // Getter for isPrivate
  bool get isPrivate => _isPrivate;

  // Setter for isPrivate
  set isPrivate(bool value) {
    _isPrivate = value;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': _id,
      'name': _name,
      'description': _description,
      'address': _address,
      'isPrivate': _isPrivate,
    };
  }

  factory OrganizationModel.fromMap(Map<String, dynamic> map) {
    return OrganizationModel(
      id: map['id'] ?? "",
      name: map['name'] ?? "",
      description: map['description'] ?? "",
      address: map['address'] ?? "",
      isPrivate: map['isPrivate'] ?? false,
    );
  }
}
