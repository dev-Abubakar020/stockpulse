import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScannerController extends GetxController {
  late final MobileScannerController scannerController;
  bool _isProcessing = false;

  @override
  void onInit() {
    super.onInit();
    scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      formats: [
        BarcodeFormat.code128,
        BarcodeFormat.ean13,
        BarcodeFormat.ean8,
        BarcodeFormat.upcA,
        BarcodeFormat.upcE,
      ],
    );
  }

  void onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;
    if (capture.barcodes.isEmpty) return;

    final String? rawValue = capture.barcodes.first.rawValue;
    if (rawValue == null || rawValue.trim().isEmpty) return;

    _isProcessing = true;
    final code = rawValue.trim().toUpperCase();
    debugPrint('SCANNED BARCODE: $code');

    scannerController.stop();
    Get.back(result: code);
  }

  @override
  void onClose() {
    scannerController.dispose();
    super.onClose();
  }
}

class BarcodeScannerView extends GetView<BarcodeScannerController> {
  const BarcodeScannerView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(BarcodeScannerController());
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: MobileScanner(
              controller: controller.scannerController,
              onDetect: controller.onDetect,
            ),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: _ScannerOverlayPainter(),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _ScannerButton(
                    icon: Icons.close_rounded,
                    onTap: () => Get.back(),
                  ),
                  const Text(
                    'Scan Barcode',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  _ScannerButton(
                    icon: Icons.flash_on_rounded,
                    onTap: () {
                      controller.scannerController.toggleTorch();
                    },
                  ),
                ],
              ),
            ),
          ),
          const Align(
            alignment: Alignment(0, 0.38),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                'Place the product barcode inside the frame',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannerButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ScannerButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            icon,
            color: Colors.white,
            size: 22,
          ),
        ),
      ),
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final overlayPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.50);

    final scanWidth = size.width * 0.78;
    const scanHeight = 180.0;

    final left = (size.width - scanWidth) / 2;
    final top = (size.height - scanHeight) / 2;

    final scanRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, top, scanWidth, scanHeight),
      const Radius.circular(18),
    );

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(scanRect)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, overlayPaint);

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawRRect(scanRect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
