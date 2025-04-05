import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  final MobileScannerController controller = MobileScannerController();
  bool isFlashOn = false;
  bool isFrontCamera = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
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
              setState(() {
                isFlashOn = !isFlashOn;
              });
              controller.toggleTorch();
            },
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: () {
              setState(() {
                isFrontCamera = !isFrontCamera;
              });
              controller.switchCamera();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  Navigator.pop(context, barcode.rawValue);
                }
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
                Text(
                  'Scannez un code QR pour effectuer un paiement',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    backgroundColor: Colors.black.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Importer depuis la galerie'),
                  onPressed: () async {
                    // Implémentez la logique d'import depuis la galerie
                  },
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

    // Dessiner le cadre coloré
    final Paint borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    const double cornerSize = 30;
    const double cornerWidth = 4;

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