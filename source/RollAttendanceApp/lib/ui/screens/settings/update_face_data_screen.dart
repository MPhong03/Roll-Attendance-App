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
import 'package:itproject/services/api_service.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_mediapipe_face_detection/google_mediapipe_face_detection.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

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
  late GoogleMediapipeFaceDetection _faceDetectorForWeb;
  late Interpreter _interpreter;
  bool _isDetecting = false;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _loadModel();
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

  Future<void> _loadModel() async {
    try {
      _interpreter =
          await Interpreter.fromAsset('assets/models/facenet.tflite');
      print('Model loaded successfully');
    } catch (e) {
      if (mounted) {
        print('Error loading model: $e');
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          title: 'Error',
          desc: 'Failed to load model: $e',
          btnOkOnPress: () {},
        ).show();
      }
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
      final inputShape = [1, 160, 160, 3];
      final input = await _preprocessImage(image);

      final reshapedInput =
          input.shape == inputShape ? input : input.reshape([1, 160, 160, 3]);

      // Allocate output buffer (đảm bảo kích thước đầu ra khớp với yêu cầu của mô hình)
      final output = List.generate(1, (_) => List.filled(128, 0.0));

      _interpreter.run(reshapedInput, output);

      final faceData = json.encode(output);
      await _updateFaceData(faceData);
    } catch (e) {
      print('Error during face detection: $e');
      throw Exception('Face detection error: $e');
    }
  }

  Future<List<List<List<double>>>> _preprocessImage(CameraImage image) async {
    if (image.format.group == ImageFormatGroup.yuv420) {
      final List<int> rgbData = _yuv420ToRgb(image);

      final ByteBuffer byteBuffer = Uint8List.fromList(rgbData).buffer;

      // Tạo đối tượng Image từ dữ liệu RGB
      final img.Image convertedImage = img.Image.fromBytes(
        width: image.width,
        height: image.height,
        bytes: byteBuffer,
        format: img.Format.uint8,
      );

      final WriteBuffer allBytes = WriteBuffer();
      for (Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();
      final inputImage =
          InputImage.fromBytes(bytes: bytes, metadata: _buildMetaData(image));

      final faces = await _faceDetector.processImage(inputImage);

      // Nếu phát hiện khuôn mặt
      if (faces.isNotEmpty) {
        final face = faces.first; // Chọn khuôn mặt đầu tiên

        final faceImage = img.copyCrop(
          convertedImage,
          x: face.boundingBox.left.toInt(),
          y: face.boundingBox.top.toInt(),
          width: face.boundingBox.width.toInt(),
          height: face.boundingBox.height.toInt(),
        );

        final img.Image resizedImage = img.copyResize(
          faceImage,
          width: 160,
          height: 160,
        );

        final Float32List input = Float32List(160 * 160 * 3);
        for (int y = 0; y < 160; y++) {
          for (int x = 0; x < 160; x++) {
            final pixel = resizedImage.getPixel(x, y);
            final r = pixel.r;
            final g = pixel.g;
            final b = pixel.b;

            final index = (y * 160 + x) * 3;
            input[index] = (r - 127.5) / 128.0;
            input[index + 1] = (g - 127.5) / 128.0;
            input[index + 2] = (b - 127.5) / 128.0;
          }
        }

        return [
          [input.toList()],
        ];
      } else {
        throw Exception('No face detected in image');
      }
    } else {
      throw Exception('Unsupported image format');
    }
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

  InputImageMetadata _buildMetaData(CameraImage image) {
    final size = Size(image.width.toDouble(), image.height.toDouble());
    const rotation = InputImageRotation.rotation0deg;
    const format = InputImageFormat.yuv_420_888;
    print("Image Size: $size");
    return InputImageMetadata(
        size: size, rotation: rotation, format: format, bytesPerRow: 8);
  }

  String _extractFaceDataFromRect(List<Rect> faces) {
    final faceData = faces.map((rect) {
      return {
        "boundingBox": rect.toString(),
        "left": rect.left,
        "top": rect.top,
        "right": rect.right,
        "bottom": rect.bottom,
      };
    }).toList();

    return json.encode(faceData);
  }

  Future<void> _takePictureAndDetectFace() async {
    try {
      setState(() {
        _isDetecting = true; // Tạm dừng nhận diện trước khi gọi API
        _isLoading = true;
      });

      final XFile imageFile = await _cameraController.takePicture();

      final inputImage = InputImage.fromFilePath(imageFile.path);

      // Phát hiện khuôn mặt
      dynamic faces = await _faceDetectorForWeb.processImage(inputImage);

      if (faces != null && faces.isNotEmpty) {
        final faceData = _extractFaceDataFromRect(faces);
        await _updateFaceData(faceData);
      } else {
        if (mounted) {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.error,
            title: 'Error',
            desc: 'No face detected.',
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
          desc: 'Error detecting faces: $e.',
          btnOkOnPress: () {},
        ).show();
      }
    } finally {
      setState(() {
        _isDetecting = false;
        _isLoading = false;
      });
    }
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
