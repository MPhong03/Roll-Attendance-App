import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:itproject/models/event_model.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart'
    as mlkit;
import 'package:mobile_scanner/mobile_scanner.dart' as mobile;

class QRScannerModal extends StatefulWidget {
  final EventModel event;

  const QRScannerModal({super.key, required this.event});

  @override
  State<QRScannerModal> createState() => _QRScannerModalState();
}

class _QRScannerModalState extends State<QRScannerModal> {
  final mobile.MobileScannerController _controller =
      mobile.MobileScannerController();
  final ImagePicker _picker = ImagePicker();
  File? selectedImageFile;
  String qrResult = '';

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
          qrResult = qrData;
        });

        Fluttertoast.showToast(
          msg: "Scanned QR Code: $qrResult",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
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

  // Hàm quét mã QR từ camera
  void _onBarcodeScanned(List<mobile.Barcode> barcodes) {
    if (barcodes.isNotEmpty) {
      final String qrData = barcodes.first.rawValue ?? 'Unknown QR code';
      setState(() {
        qrResult = qrData;
      });

      Fluttertoast.showToast(
        msg: "Scanned QR Code: $qrResult",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
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
        ],
      ),
    );
  }
}
