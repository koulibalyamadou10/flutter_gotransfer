import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  final MobileScannerController controller = MobileScannerController(
    formats: [BarcodeFormat.qrCode],
  );
  bool isFlashOn = false;
  bool isFrontCamera = false;
  bool _isPermissionGranted = false;
  bool _isScanning = true;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _checkCameraPermission();
  }

  Future<void> _checkCameraPermission() async {
    final status = await Permission.camera.status;
    if (status.isGranted) {
      setState(() => _isPermissionGranted = true);
    } else {
      final result = await Permission.camera.request();
      setState(() => _isPermissionGranted = result.isGranted);
      if (!_isPermissionGranted) {
        _showPermissionDeniedDialog();
      }
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission requise'),
        content: const Text(
            'L\'application a besoin de l\'accès à la caméra pour scanner les QR codes.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => openAppSettings(),
            child: const Text('Paramètres'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() => _isScanning = false);

        // Utilisation de la méthode correcte pour scanner une image
        final barcodes = await controller.analyzeImage(pickedFile.path);

        print('barcodes : $barcodes');
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Erreur lors de l'import: ${e.toString()}",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      debugPrint("Erreur de scan: $e");
    } finally {
      setState(() => _isScanning = true);
    }
  }

  void _handleScannedValue(String value) {
    Navigator.pop(context, value);
    Fluttertoast.showToast(
      msg: "QR code scanné: $value",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner QR Code'),
        actions: [
          IconButton(
            icon: Icon(isFlashOn ? Icons.flash_on : Icons.flash_off),
            onPressed: () {
              setState(() => isFlashOn = !isFlashOn);
              controller.toggleTorch();
            },
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: () {
              setState(() => isFrontCamera = !isFrontCamera);
              controller.switchCamera();
            },
          ),
        ],
      ),
      body: !_isPermissionGranted
          ? const Center(child: Text('Permission caméra requise'))
          : Stack(
        children: [
          if (_isScanning)
            MobileScanner(
              controller: controller,
              onDetect: (capture) {
                final barcodes = capture.barcodes;
                if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
                  _handleScannedValue(barcodes.first.rawValue!);
                }
              },
            ),
          CustomPaint(
            painter: QrScannerOverlay(
              borderColor: Theme.of(context).colorScheme.primary,
            ),
            size: MediaQuery.of(context).size,
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Scannez un code QR pour effectuer un paiement',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Importer depuis la galerie'),
                  onPressed: _pickImageFromGallery,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }
}

class QrScannerOverlay extends CustomPainter {
  final Color borderColor;

  QrScannerOverlay({required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;
    final double squareSize = width * 0.7;

    // Dessiner le fond semi-transparent
    final Paint backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.5);
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), backgroundPaint);

    // Dessiner le cadre transparent au centre
    final Paint transparentPaint = Paint()
      ..color = Colors.transparent
      ..blendMode = BlendMode.clear;
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(width / 2, height / 2),
        width: squareSize,
        height: squareSize,
      ),
      transparentPaint,
    );

    // Dessiner le cadre coloré avec des coins arrondis
    final Paint borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    const double cornerSize = 30;
    const double cornerWidth = 8;

    // Coins supérieur gauche
    canvas.drawLine(
      Offset(width / 2 - squareSize / 2, height / 2 - squareSize / 2 + cornerSize),
      Offset(width / 2 - squareSize / 2, height / 2 - squareSize / 2),
      borderPaint,
    );
    canvas.drawLine(
      Offset(width / 2 - squareSize / 2, height / 2 - squareSize / 2),
      Offset(width / 2 - squareSize / 2 + cornerSize, height / 2 - squareSize / 2),
      borderPaint,
    );

    // Coins supérieur droit
    canvas.drawLine(
      Offset(width / 2 + squareSize / 2 - cornerSize, height / 2 - squareSize / 2),
      Offset(width / 2 + squareSize / 2, height / 2 - squareSize / 2),
      borderPaint,
    );
    canvas.drawLine(
      Offset(width / 2 + squareSize / 2, height / 2 - squareSize / 2),
      Offset(width / 2 + squareSize / 2, height / 2 - squareSize / 2 + cornerSize),
      borderPaint,
    );

    // Coins inférieur gauche
    canvas.drawLine(
      Offset(width / 2 - squareSize / 2, height / 2 + squareSize / 2 - cornerSize),
      Offset(width / 2 - squareSize / 2, height / 2 + squareSize / 2),
      borderPaint,
    );
    canvas.drawLine(
      Offset(width / 2 - squareSize / 2, height / 2 + squareSize / 2),
      Offset(width / 2 - squareSize / 2 + cornerSize, height / 2 + squareSize / 2),
      borderPaint,
    );

    // Coins inférieur droit
    canvas.drawLine(
      Offset(width / 2 + squareSize / 2 - cornerSize, height / 2 + squareSize / 2),
      Offset(width / 2 + squareSize / 2, height / 2 + squareSize / 2),
      borderPaint,
    );
    canvas.drawLine(
      Offset(width / 2 + squareSize / 2, height / 2 + squareSize / 2),
      Offset(width / 2 + squareSize / 2, height / 2 + squareSize / 2 - cornerSize),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}