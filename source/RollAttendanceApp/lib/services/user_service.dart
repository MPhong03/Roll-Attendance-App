import 'dart:convert';

import 'package:itproject/models/profile_model.dart';
import 'package:itproject/models/user_model.dart';
import 'package:itproject/services/api_service.dart';

class UserService {
  final ApiService _apiService = ApiService();

  final Map<int, String> roleMap = {
    1: "User",
    2: "Organizart",
    3: "Representative",
    0: "Unknown"
  };

  Future<String?> createProfile(String? email, String? uid) async {
    try {
      final data = {
        'Email': email,
        'Uid': uid,
      };

      final response = await _apiService.post('api/Auth/new-profile', data);

      if (response.statusCode == 200) {
        return "Create profile successfully";
      } else {
        return response.body;
      }
    } catch (e) {
      return 'Error in createProfile: $e';
    }
  }

  Future<ProfileModel?> getProfile() async {
    try {
      final response = await _apiService.get('api/Auth/profile');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        ProfileModel profile = ProfileModel(
          uid: body['uid'] ?? '',
          name: body['displayName'] ?? '',
          email: body['email'] ?? '',
          profileImageUrl: body['photoUrl'] ?? '',
        );

        return profile;
      } else {
        return null;
      }
    } catch (e) {
      throw Exception('Error in getProfile: $e');
    }
  }

  Future<String?> testProfile() async {
    try {
      final response = await _apiService.get('api/Auth/test-authorization');

      if (response.statusCode == 200) {
        return response.body;
      } else {
        return null;
      }
    } catch (e) {
      return 'Error in createProfile: $e';
    }
  }

  Future<UserModel> getUserByEmail(String email) async {
    final response = await _apiService.get('api/users/$email');
    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load user');
    }
  }

  Future<Map<int, String>> getUserRoleInOrganization(
      String organizationId) async {
    try {
      final response =
          await _apiService.get('api/Organization/get-role/$organizationId');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        int roleNumber = body['role'];

        return {roleNumber: roleMap[roleNumber] ?? "UNKNOWN"};
      } else {
        return {0: "UNKNOWN"};
      }
    } catch (e) {
      throw Exception('Error in getUserRoleInOrganization: $e');
    }
  }
}
