import 'package:flutter/material.dart';
import 'package:itproject/enums/user_role.dart';
import 'package:itproject/models/user_model.dart';

class OrgUserCard extends StatelessWidget {
  final List<UserModel> users;

  const OrgUserCard({super.key, required this.users});

  @override
  Widget build(BuildContext context) {
    // Phân loại user theo role
    final List<UserModel> representatives = users
        .where((user) => user.role == getRoleValue(UserRole.REPRESENTATIVE))
        .toList();

    final List<UserModel> organizers = users
        .where((user) => user.role == getRoleValue(UserRole.ORGANIZER))
        .toList();

    final List<UserModel> members = users
        .where((user) => user.role == getRoleValue(UserRole.USER))
        .toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Phần Admin (Representative & Organizer)
          if (representatives.isNotEmpty || organizers.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Text(
                'Admin',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
            ...representatives.map((user) => _buildUserCard(user)),
            ...organizers.map((user) => _buildUserCard(user)),
          ],

          // Phần Member (User)
          if (members.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Text(
                'Member',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
            ...members.map((user) => _buildUserCard(user)),
          ],
        ],
      ),
    );
  }

  // Hàm tạo từng card user
  Widget _buildUserCard(UserModel user) {
    final role = getRoleFromValue(user.role ?? 0);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundImage: NetworkImage(user.avatar),
          radius: 25,
        ),
        title: Text(
          user.displayName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email, maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 5),
            Text(
              '$role',
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
