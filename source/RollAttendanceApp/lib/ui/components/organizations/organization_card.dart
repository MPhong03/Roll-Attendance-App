import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:itproject/models/organization_model.dart';

class OrganizationCard extends StatelessWidget {
  final OrganizationModel organization;
  final String imagePlaceHolder =
      'https://yt3.ggpht.com/a/AGF-l78urB8ASkb0JO2a6AB0UAXeEHe6-pc9UJqxUw=s900-mo-c-c0xffffffff-rj-k-no';
  const OrganizationCard({super.key, required this.organization});

  @override
Widget build(BuildContext context) {
  final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
  final Color textColor = isDarkMode ? Colors.white70 : Colors.black54;
  final Color titleColor = isDarkMode ? Colors.white : Colors.black;
  final screenWidth = MediaQuery.of(context).size.width;

  // Hàm tính kích thước chữ responsive
  double getResponsiveFontSize(double baseFontSize) {
    if (screenWidth > 480) {
      return baseFontSize * 1.4;
    } else {
      return baseFontSize;
    }
  }

  return Card(
    margin: const EdgeInsets.symmetric(vertical: 8.0),
    elevation: 5,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
    child: InkWell(
      onTap: () {
        context.push('/organization-detail/${organization.id}');
      },
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Ảnh tổ chức
            CircleAvatar(
              radius: screenWidth * 0.06,
              backgroundImage: organization.image.isNotEmpty
                  ? NetworkImage(organization.image)
                  : const AssetImage('images/default-avatar.jpg')
                      as ImageProvider,
              backgroundColor: Colors.grey.shade200,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên tổ chức
                  Text(
                    organization.name,
                    style: TextStyle(
                      fontSize: getResponsiveFontSize(18),
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Mô tả tổ chức
                  Text(
                    organization.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: textColor,
                      fontSize: getResponsiveFontSize(14),
                    ),
                  ),
                ],
              ),
            ),
            // Biểu tượng khóa
            Icon(
              organization.isPrivate ? Icons.lock : Icons.lock_open,
              color: organization.isPrivate ? Colors.red : Colors.blue,
              size: 24.0,
            ),
          ],
        ),
      ),
    ),
  );
}
}
