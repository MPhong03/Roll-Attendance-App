import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

final Logger _logger = Logger('ApiService');

void setupLogging() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });
}

class ApiService {
  final String baseUrl = dotenv.env['SERVER_URL'] ?? "https://api.mphong.com";

  ApiService() {
    setupLogging();
  }

  /// GET ACCESS TOKEN FOR HEADERS ///
  Future<String?> _getAccessToken() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      return await user?.getIdToken();
    } catch (e) {
      _logger.severe('Error fetching access token: $e');
      return null;
    }
  }

  // GET METHOD
  Future<http.Response> get(String endpoint) async {
    try {
      final accessToken = await _getAccessToken();
      final response = await http.get(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );
      return response;
    } catch (e) {
      _logger.severe('Error during GET request to $endpoint: $e');
      throw Exception('Failed to load data');
    }
  }

  // POST METHOD
  Future<http.Response> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final accessToken = await _getAccessToken();
      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode(data),
      );
      return response;
    } catch (e) {
      _logger.severe('Error during POST request to $endpoint: $e');
      throw Exception('Failed to post data');
    }
  }

  // PUT METHOD
  Future<http.Response> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final accessToken = await _getAccessToken();
      final response = await http.put(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode(data),
      );
      return response;
    } catch (e) {
      _logger.severe('Error during PUT request to $endpoint: $e');
      throw Exception('Failed to update data');
    }
  }

  // DELETE METHOD
  Future<http.Response> delete(String endpoint) async {
    try {
      final accessToken = await _getAccessToken();
      final response = await http.delete(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );
      return response;
    } catch (e) {
      _logger.severe('Error during DELETE request to $endpoint: $e');
      throw Exception('Failed to delete data');
    }
  }
}
