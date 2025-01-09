class PublicOrganizationModel {
  String? id;
  String? name;
  String? description;
  String? address;
  bool isPrivate = false;
  String? banner;
  String? image;
  int users = 0;
  int events = 0;

  PublicOrganizationModel({
    this.id,
    this.name,
    this.description,
    this.address,
    this.isPrivate = false,
    this.banner,
    this.image,
    this.users = 0,
    this.events = 0,
  });

  // From JSON
  factory PublicOrganizationModel.fromJson(Map<String, dynamic> json) {
    return PublicOrganizationModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      address: json['address'],
      isPrivate: json['isPrivate'] ?? false,
      banner: json['banner'],
      image: json['image'],
      users: json['users'] ?? 0,
      events: json['events'] ?? 0,
    );
  }

  // From Map
  factory PublicOrganizationModel.fromMap(Map<String, dynamic> map) {
    return PublicOrganizationModel(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      address: map['address'],
      isPrivate: map['isPrivate'] ?? false,
      banner: map['banner'],
      image: map['image'],
      users: map['users'] ?? 0,
      events: map['events'] ?? 0,
    );
  }

  // To Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'address': address,
      'isPrivate': isPrivate,
      'banner': banner,
      'image': image,
      'users': users,
      'events': events,
    };
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return toMap();
  }
}
