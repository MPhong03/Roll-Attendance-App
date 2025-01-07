import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:itproject/models/event_history_model.dart';
import 'package:itproject/models/event_model.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart'
    as mlkit;
import 'package:itproject/services/api_service.dart';
import 'package:mobile_scanner/mobile_scanner.dart' as mobile;

class QRScannerModal extends StatefulWidget {
  final EventModel event;
  final HistoryModel history;

  const QRScannerModal({super.key, required this.event, required this.history});

  @override
  State<QRScannerModal> createState() => _QRScannerModalState();
}

class _QRScannerModalState extends State<QRScannerModal> {
  final mobile.MobileScannerController _controller =
      mobile.MobileScannerController();
  final ImagePicker _picker = ImagePicker();
  final ApiService _apiService = ApiService();

  File? selectedImageFile;
  String qrResult = '';
  bool _isLoading = false;

  Future<void> _scanQRCodeFromImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) {
        setState(() {
          qrResult = "No image selected!";
        });
        return;
      }

      final inputImage = mlkit.InputImage.fromFilePath(image.path);
      final barcodeScanner = mlkit.BarcodeScanner();

      final List<mlkit.Barcode> barcodes =
          await barcodeScanner.processImage(inputImage);
      if (barcodes.isNotEmpty) {
        final String qrData = barcodes.first.rawValue ?? 'Unknown QR code';
        setState(() {
          qrResult = jsonDecode(qrData)['qr'];
        });
        _handleCheckIn(jsonDecode(qrData)['qr']);
      } else {
        setState(() {
          qrResult = "No QR code found in the image!";
        });
      }

      barcodeScanner.close();
    } catch (e) {
      setState(() {
        qrResult = "Error: $e";
      });
    }
  }

  void _onBarcodeScanned(List<mobile.Barcode> barcodes) {
    if (barcodes.isNotEmpty) {
      final String qrData = barcodes.first.rawValue ?? 'Unknown QR code';
      setState(() {
        qrResult = jsonDecode(qrData)['qr'];
      });
      _handleCheckIn(jsonDecode(qrData)['qr']);
    }
  }

  // Hàm xử lý check-in
  Future<void> _handleCheckIn(String qrCode) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final response = await _apiService.post(
        'api/events/${widget.event.id}/check-in',
        {
          'userId': 'không cần để ý',
          'qrCode': qrCode,
          'attendanceAttempt': widget.history.attendanceTimes,
        },
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Successfully checked in")),
          );
        }
      } else {
        if (mounted) {
          final message = jsonDecode(response.body)['message'];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("$message")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Scanner'),
      ),
      body: Column(
        children: [
          Expanded(
            child: mobile.MobileScanner(
              controller: _controller,
              onDetect: (mobile.BarcodeCapture capture) {
                final List<mobile.Barcode> barcodes = capture.barcodes;
                _onBarcodeScanned(barcodes);
              },
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _scanQRCodeFromImage,
            child: const Text('Pick Image from Gallery'),
          ),
          if (selectedImageFile != null) Image.file(selectedImageFile!),
          if (_isLoading) const CircularProgressIndicator(),
        ],
      ),
    );
  }
}
