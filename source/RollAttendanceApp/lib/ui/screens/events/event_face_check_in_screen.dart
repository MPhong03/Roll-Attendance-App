import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:blurry_modal_progress_hud/blurry_modal_progress_hud.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:http/http.dart';
import 'package:itproject/services/api_service.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_mediapipe_face_detection/google_mediapipe_face_detection.dart';
import 'package:image/image.dart' as img;

class EventFaceCheckInScreen extends StatefulWidget {
  final String eventId;
  final int attempt;

  const EventFaceCheckInScreen(
      {super.key, required this.eventId, required this.attempt});

  @override
  State<EventFaceCheckInScreen> createState() => _EventFaceCheckInScreenState();
}

class _EventFaceCheckInScreenState extends State<EventFaceCheckInScreen> {
  bool _isLoading = false;
  final ApiService _apiService = ApiService();
  late CameraController _cameraController;
  late FaceDetector _faceDetector;
  late GoogleMediapipeFaceDetection _faceDetectorForWeb;
  bool _isDetecting = false;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    if (kIsWeb) {
      // Sử dụng Google MediaPipe cho web
      _faceDetectorForWeb = GoogleMediapipeFaceDetection();
    } else {
      _faceDetector = FaceDetector(
          options: FaceDetectorOptions(
        enableLandmarks: false,
        enableContours: false,
        enableTracking: false,
      ));
    }
  }

  Future<void> _initializeCamera() async {
    // Request permissions
    await _requestPermissions();

    final cameras = await availableCameras();

    // Chọn camera trước nếu có, nếu không thì chọn camera sau
    final camera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _cameraController = CameraController(camera, ResolutionPreset.high);

    try {
      await _cameraController.initialize();
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
      _cameraController.startImageStream((image) async {
        if (!_isDetecting) {
          _isDetecting = true;
          try {
            await _detectFaces(image);
          } catch (e) {
            print('Error in face detection: $e');
            setState(() {
              _isDetecting = false;
            });
          } finally {
            setState(() {
              _isDetecting = false;
            });
          }
        }
      });
    } catch (e) {
      setState(() {
        _isDetecting = false;
      });
      if (mounted) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          title: 'Error',
          desc: 'Error initializing camera: $e',
          btnOkOnPress: () {},
        ).show();
      }
    }
  }

  Future<void> _requestPermissions() async {
    // Request permission for camera
    final status = await Permission.camera.request();
    if (status.isDenied) {
      if (mounted) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          title: 'Permission Denied',
          desc: 'Camera permission is required to detect faces.',
          btnOkOnPress: () {},
        ).show();
      }
    }
  }

  Future<void> _detectFaces(CameraImage image) async {
    try {
      final input = await _convertImageToBytes(image);

      final faceVector = await _extractFaceFeatures(input);
      if (faceVector != null) {
        await _checkIn(faceVector);
      }
    } catch (e) {
      print('Error during face detection: $e');
      throw Exception('Face detection error: $e');
    }
  }

  Future<Uint8List> _convertImageToBytes(CameraImage image) async {
    final img.Image convertedImage = img.Image.fromBytes(
      width: image.width,
      height: image.height,
      bytes: Uint8List.fromList(_yuv420ToRgb(image)).buffer,
      format: img.Format.uint8,
    );

    final img.Image resizedImage =
        img.copyResize(convertedImage, width: 160, height: 160);

    return Uint8List.fromList(img.encodeJpg(resizedImage));
  }

  List<int> _yuv420ToRgb(CameraImage image) {
    final yPlane = image.planes[0].bytes;
    final uPlane = image.planes[1].bytes;
    final vPlane = image.planes[2].bytes;

    final int width = image.width;
    final int height = image.height;

    final List<int> rgbData = List.filled(width * height * 3, 0);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final yIndex = y * width + x;
        final uIndex = (y >> 1) * (width >> 1) + (x >> 1);
        final vIndex = uIndex;

        final yValue = yPlane[yIndex];
        final uValue = uPlane[uIndex] - 128;
        final vValue = vPlane[vIndex] - 128;

        final r = (yValue + 1.402 * vValue).clamp(0, 255).toInt();
        final g = (yValue - 0.344136 * uValue - 0.714136 * vValue)
            .clamp(0, 255)
            .toInt();
        final b = (yValue + 1.772 * uValue).clamp(0, 255).toInt();

        final pixelIndex = yIndex * 3;
        rgbData[pixelIndex] = r;
        rgbData[pixelIndex + 1] = g;
        rgbData[pixelIndex + 2] = b;
      }
    }

    return rgbData;
  }

  Future<String?> _extractFaceFeatures(Uint8List imageBytes) async {
    try {
      final response = await _apiService.postFiles(
        'api/Recognitions/extract',
        {'image': imageBytes},
      );

      if (response.statusCode == 200) {
        final extractedData = json.decode(response.body);
        return json.encode(extractedData['features']);
      } else {
        print('Error extracting face features: ${response.body}');
        return null;
      }
    } catch (e) {
      print('API Error: $e');
      return null;
    }
  }

  Future<void> _checkIn(String faceData) async {
    try {
      setState(() {
        _isDetecting = true; // Tạm dừng nhận diện trước khi gọi API
        _isLoading = true;
      });

      final response = await _apiService.post(
        'api/Events/${widget.eventId}/check-in-by-face',
        {
          'FaceData': faceData,
          'AttendanceAttempt': widget.attempt,
          'UserId': 'temp'
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _isDetecting = true; // Tạm dừng nhận diện sau khi cập nhật thành công
        });
        _cameraController.stopImageStream();
        if (mounted) {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.success,
            title: 'Success',
            desc: 'Successfully checkin!',
            btnOkOnPress: () {
              context.pop(); // Quay về trang trước
            },
          ).show();
        }
      } else {
        if (mounted) {
          setState(() {
            _isDetecting =
                true; // Tạm dừng nhận diện sau khi cập nhật thành công
          });
          final message = jsonDecode(response.body)['message'];
          AwesomeDialog(
            context: context,
            dialogType: DialogType.error,
            title: 'Error',
            desc: '$message',
            btnOkOnPress: () {
              setState(() {
                _isDetecting =
                    false; // Tạm dừng nhận diện sau khi cập nhật thành công
              });
            },
          ).show();
        }
      }
    } catch (e) {
      setState(() {
        _isDetecting = true; // Tạm dừng nhận diện sau khi cập nhật thành công
      });
      if (mounted) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          title: 'Error',
          desc: 'An error occurred while updating face data.',
          btnOkOnPress: () {
            setState(() {
              _isDetecting =
                  false; // Tạm dừng nhận diện sau khi cập nhật thành công
            });
          },
        ).show();
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _takePictureAndDetectFace() {
    // TODO: Implement taking picture and detecting face
  }

  @override
  void dispose() {
    if (_cameraController.value.isInitialized) {
      _cameraController.dispose();
    }
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlurryModalProgressHUD(
      inAsyncCall: _isLoading,
      opacity: 0.3,
      blurEffectIntensity: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Check In'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Căn giữa nội dung
            children: [
              if (_isCameraInitialized)
                Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(pi),
                  child: CameraPreview(_cameraController),
                ),
              const SizedBox(height: 16), // Khoảng cách giữa camera và nút
              if (_isCameraInitialized && kIsWeb)
                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : _takePictureAndDetectFace, // Disable nếu đang tải
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white, // Màu loading
                          ),
                        )
                      : const Text("Take Picture"),
                ),
              if (!_isCameraInitialized)
                const Center(
                  child: CircularProgressIndicator(),
                ), // Hiển thị loading khi camera chưa khởi tạo
            ],
          ),
        ),
      ),
    );
  }
}
