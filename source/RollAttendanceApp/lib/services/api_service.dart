import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  final String baseUrl = dotenv.env['SERVER_URL'] ?? "https://api.mphong.com";

  ApiService() {
    // setupLogging();
  }

  /// GET ACCESS TOKEN FOR HEADERS ///
  Future<String?> _getAccessToken() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      return await user?.getIdToken();
    } catch (e) {
      print('Error fetching access token: $e');
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
      _logResponse(
          response: response,
          url: Uri.parse('$baseUrl/$endpoint').toString(),
          method: 'GET',
          requestBody: null);
      return response;
    } catch (e) {
      print('Error during GET request to $endpoint: $e');
      throw Exception('Failed to load data');
    }
  }

  // POST METHOD
  Future<http.Response> post(String endpoint, [dynamic data]) async {
    try {
      final accessToken = await _getAccessToken();
      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: data != null ? json.encode(data) : null, // mã hóa dữ liệu
      );
      _logResponse(
        response: response,
        url: Uri.parse('$baseUrl/$endpoint').toString(),
        method: 'POST',
        requestBody: data ?? {},
      );
      return response;
    } catch (e) {
      print('Error during POST request to $endpoint: $e');
      throw Exception('Failed to post data');
    }
  }

  // PUT METHOD
  Future<http.Response> put(String endpoint,
      [Map<String, dynamic>? data]) async {
    try {
      final accessToken = await _getAccessToken();
      final response = await http.put(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: data != null
            ? json.encode(data)
            : null, // Xử lý nếu data không được truyền
      );
      _logResponse(
        response: response,
        url: Uri.parse('$baseUrl/$endpoint').toString(),
        method: 'PUT',
        requestBody: data ?? {}, // Log dữ liệu nếu có, ngược lại log Map rỗng
      );
      return response;
    } catch (e) {
      print('Error during PUT request to $endpoint: $e');
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
      _logResponse(
          response: response,
          url: Uri.parse('$baseUrl/$endpoint').toString(),
          method: 'DELETE',
          requestBody: null);
      return response;
    } catch (e) {
      print('Error during DELETE request to $endpoint: $e');
      throw Exception('Failed to delete data');
    }
  }

  Future<http.Response> postFile(String endpoint, dynamic selectedImageFile,
      {Map<String, String>? additionalData}) async {
    try {
      final accessToken = await _getAccessToken();
      final uri = Uri.parse('$baseUrl/$endpoint');
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $accessToken'
        ..headers['Content-Type'] = 'multipart/form-data';

      // For Web: selectedImageFile is a Uint8List (file bytes)
      if (selectedImageFile is Uint8List) {
        // Convert Uint8List to MultipartFile
        request.files.add(http.MultipartFile.fromBytes(
            'file', selectedImageFile,
            filename: 'profile_image.jpg'));
      }
      // For Mobile: selectedImageFile is a File (file path)
      else if (selectedImageFile is File) {
        request.files.add(
            await http.MultipartFile.fromPath('file', selectedImageFile.path));
      }

      if (additionalData != null) {
        additionalData.forEach((key, value) {
          request.fields[key] = value;
        });
      }

      final response = await request.send();
      final responseData = await http.Response.fromStream(response);
      _logResponse(
          response: responseData,
          url: Uri.parse('$baseUrl/$endpoint').toString(),
          method: 'POST',
          requestBody: additionalData);
      return responseData;
    } catch (e) {
      print('Error during POST request with file to $endpoint: $e');
      throw Exception('Failed to upload file');
    }
  }

  Future<http.Response> postFiles(
    String endpoint,
    Map<String, dynamic> files, {
    Map<String, String>? additionalData,
  }) async {
    try {
      final accessToken = await _getAccessToken();
      final uri = Uri.parse('$baseUrl/$endpoint');
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $accessToken'
        ..headers['Content-Type'] = 'multipart/form-data';

      for (var entry in files.entries) {
        final key = entry.key;
        final value = entry.value;

        if (value is List<dynamic>) {
          for (int i = 0; i < value.length; i++) {
            final file = value[i];
            if (file is Uint8List) {
              request.files.add(http.MultipartFile.fromBytes('$key[$i]', file,
                  filename: 'file_$i.jpg'));
            } else if (file is File) {
              request.files.add(
                  await http.MultipartFile.fromPath('$key[$i]', file.path));
            }
          }
        }

        if (value is Uint8List) {
          request.files.add(
              http.MultipartFile.fromBytes(key, value, filename: 'file.jpg'));
        }

        if (value is File) {
          request.files.add(await http.MultipartFile.fromPath(key, value.path));
        }
      }

      if (additionalData != null) {
        additionalData.forEach((key, value) {
          request.fields[key] = value;
        });
      }

      final response = await request.send();
      final responseData = await http.Response.fromStream(response);

      _logResponse(
        response: responseData,
        url: Uri.parse('$baseUrl/$endpoint').toString(),
        method: 'POST',
        requestBody: additionalData,
      );

      return responseData;
    } catch (e) {
      print('Error during POST request with files to $endpoint: $e');
      throw Exception('Failed to upload files');
    }
  }

  Future<http.Response> putFiles(
    String endpoint,
    Map<String, dynamic> files, {
    Map<String, String>? additionalData,
  }) async {
    try {
      final accessToken = await _getAccessToken();
      final uri = Uri.parse('$baseUrl/$endpoint');
      final request = http.MultipartRequest('PUT', uri)
        ..headers['Authorization'] = 'Bearer $accessToken'
        ..headers['Content-Type'] = 'multipart/form-data';

      for (var entry in files.entries) {
        final key = entry.key;
        final value = entry.value;

        if (value is List<dynamic>) {
          for (int i = 0; i < value.length; i++) {
            final file = value[i];
            if (file is Uint8List) {
              request.files.add(http.MultipartFile.fromBytes('$key[$i]', file,
                  filename: 'file_$i.jpg'));
            } else if (file is File) {
              request.files.add(
                  await http.MultipartFile.fromPath('$key[$i]', file.path));
            }
          }
        }

        if (value is Uint8List) {
          request.files.add(
              http.MultipartFile.fromBytes(key, value, filename: 'file.jpg'));
        }

        if (value is File) {
          request.files.add(await http.MultipartFile.fromPath(key, value.path));
        }
      }

      if (additionalData != null) {
        additionalData.forEach((key, value) {
          request.fields[key] = value;
        });
      }

      final response = await request.send();
      final responseData = await http.Response.fromStream(response);

      _logResponse(
        response: responseData,
        url: Uri.parse('$baseUrl/$endpoint').toString(),
        method: 'PUT',
        requestBody: additionalData,
      );

      return responseData;
    } catch (e) {
      print('Error during PUT request with files to $endpoint: $e');
      throw Exception('Failed to upload files');
    }
  }

  void _logResponse({
    required http.Response response,
    required String url,
    required String method,
    Map<String, dynamic>? requestBody,
  }) {
    const maxBodyLength = 500;

    final truncatedBody = response.body.length > maxBodyLength
        ? '${response.body.substring(0, maxBodyLength)}... [Truncated]'
        : response.body;

    final logData = {
      'request': {
        'url': url,
        'method': method,
        if (requestBody != null) 'body': requestBody,
      },
      'response': {
        'status_code': response.statusCode,
        'headers': response.headers,
        'body': truncatedBody,
      }
    };

    final prettyJson = const JsonEncoder.withIndent('  ').convert(logData);
    print(prettyJson);
  }
}
