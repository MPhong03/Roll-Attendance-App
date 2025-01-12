import 'package:itproject/models/requests/invited_users_request.dart';

class InvitedList {
  final List<InvitedUsers> users;
  final String? notes;

  InvitedList({
    required this.users,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'users': users.map((user) => user.toMap()).toList(),
      'notes': notes,
    };
  }
}
