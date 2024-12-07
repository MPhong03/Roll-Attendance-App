import 'dart:convert';
import 'dart:math';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:blurry_modal_progress_hud/blurry_modal_progress_hud.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:itproject/services/api_service.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:permission_handler/permission_handler.dart';

class UpdateFaceDataScreen extends StatefulWidget {
  const UpdateFaceDataScreen({super.key});

  @override
  State<UpdateFaceDataScreen> createState() => _UpdateFaceDataScreenState();
}

class _UpdateFaceDataScreenState extends State<UpdateFaceDataScreen> {
  bool _isLoading = false;
  final ApiService _apiService = ApiService();
  late CameraController _cameraController;
  late FaceDetector _faceDetector;
  bool _isDetecting = false;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _faceDetector = FaceDetector(
        options: FaceDetectorOptions(
      enableLandmarks: false,
      enableContours: false,
      enableTracking: false,
    ));
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
          await _detectFaces(image);
          setState(() {});
        }
      });
    } catch (e) {
      setState(() {
        _isDetecting = false; // Tạm dừng việc nhận diện
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
    final WriteBuffer allBytes = WriteBuffer();
    for (Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();
    final inputImage =
        InputImage.fromBytes(bytes: bytes, metadata: _buildMetaData(image));

    try {
      final faces = await _faceDetector.processImage(inputImage);
      if (faces.isNotEmpty) {
        print("Faces detected: ${faces.length}");
        final faceData = _extractFaceData(faces);
        await _updateFaceData(faceData);
      } else {
        print("No faces detected");
      }
    } catch (e) {
      setState(() {
        _isDetecting = false; // Tạm dừng việc nhận diện
      });
      if (mounted) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          title: 'Error',
          desc: 'Error detecting faces: $e.',
          btnOkOnPress: () {},
        ).show();
      }
    } finally {
      _isDetecting = false;
    }
  }

  InputImageMetadata _buildMetaData(CameraImage image) {
    final size = Size(image.width.toDouble(), image.height.toDouble());
    const rotation = InputImageRotation.rotation0deg;
    const format = InputImageFormat.yuv_420_888;
    print("Image Size: $size");
    return InputImageMetadata(
        size: size, rotation: rotation, format: format, bytesPerRow: 8);
  }

  String _extractFaceData(List<Face> faces) {
    // Trích xuất dữ liệu từ khuôn mặt
    final faceData = faces.map((face) {
      return {
        "boundingBox": face.boundingBox.toString(),
        "headEulerAngleY": face.headEulerAngleY,
        "headEulerAngleZ": face.headEulerAngleZ,
        "smilingProbability": face.smilingProbability,
        "leftEyeOpenProbability": face.leftEyeOpenProbability,
        "rightEyeOpenProbability": face.rightEyeOpenProbability,
        "trackingId": face.trackingId,
        // ....
      };
    }).toList();

    // Chuyển thành chuỗi JSON để dễ dàng gửi qua API
    return json.encode(faceData);
  }

  Future<void> _updateFaceData(String faceData) async {
    try {
      setState(() {
        _isDetecting = true; // Tạm dừng nhận diện trước khi gọi API
        _isLoading = true;
      });

      final response = await _apiService.put(
        'api/Auth/facedata',
        {'FaceData': faceData},
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
            desc: 'Update face data successfully.',
            btnOkOnPress: () {
              context.pop(); // Quay về trang trước
            },
          ).show();
        }
      } else {
        if (mounted) {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.error,
            title: 'Error',
            desc: '${response.body}',
            btnOkOnPress: () {},
          ).show();
        }
      }
    } catch (e) {
      if (mounted) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          title: 'Error',
          desc: 'An error occurred while updating face data.',
          btnOkOnPress: () {},
        ).show();
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
          title: const Text('Update Face Data'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _isCameraInitialized
                  ? Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.rotationY(pi),
                      child: CameraPreview(_cameraController),
                    )
                  : const Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }
}
