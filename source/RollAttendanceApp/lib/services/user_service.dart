import 'package:itproject/services/api_service.dart';

class UserService {
  final ApiService _apiService = ApiService();

  Future<String?> createProfile(String? email, String? uid) async {
    try {
      final data = {
        'Email': email,
        'Uid': uid,
      };

      final response = await _apiService.post('api/Auth/new-profile', data);

      if (response.statusCode == 200) {
        return 'Profile created successfully.';
      } else {
        return response.body;
      }
    } catch (e) {
      return 'Error in createProfile: $e';
    }
  }
}
