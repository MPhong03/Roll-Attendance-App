import 'package:flutter/material.dart';
import 'package:itproject/enums/user_role.dart';
import 'package:itproject/models/user_model.dart';

class OrgUserCard extends StatelessWidget {
  final UserModel user;

  const OrgUserCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final role = getRoleFromValue(user.role ?? 0);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundImage: NetworkImage(user.avatar),
          radius: 25,
        ),
        title: Text(user.displayName,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email, maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 5),
            Text(
              'Role: $role',
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}
