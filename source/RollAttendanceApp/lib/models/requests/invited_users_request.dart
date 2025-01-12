class InvitedUsers {
  final String userId;
  final int role;

  InvitedUsers({
    required this.userId,
    required this.role,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'role': role,
    };
  }
}
