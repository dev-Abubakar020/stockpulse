import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScannerView extends StatefulWidget {
  const BarcodeScannerView({super.key});

  @override
  State<BarcodeScannerView> createState() =>
      _BarcodeScannerViewState();
}

class _BarcodeScannerViewState
    extends State<BarcodeScannerView> {

  final MobileScannerController scannerController =
  MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: [
      BarcodeFormat.code128,
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.upcA,
      BarcodeFormat.upcE,
    ],
  );

  bool _isProcessing = false;

  // =========================================================
  // BARCODE DETECTED
  // =========================================================

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;

    if (capture.barcodes.isEmpty) return;

    final String? rawValue =
        capture.barcodes.first.rawValue;

    if (rawValue == null ||
        rawValue.trim().isEmpty) {
      return;
    }

    _isProcessing = true;

    final code = rawValue.trim().toUpperCase();

    debugPrint('SCANNED BARCODE: $code');

    // Stop camera before closing screen.
    scannerController.stop();

    // Return scanned barcode to Dashboard.
    Get.back(result: code);
  }

  // =========================================================
  // DISPOSE
  // =========================================================

  @override
  void dispose() {
    scannerController.dispose();
    super.dispose();
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      body: Stack(
        children: [
          // ---------------------------------------------------
          // CAMERA
          // ---------------------------------------------------

          Positioned.fill(
            child: MobileScanner(
              controller: scannerController,
              onDetect: _onDetect,
            ),
          ),

          // ---------------------------------------------------
          // DARK OVERLAY + SCAN WINDOW
          // ---------------------------------------------------

          Positioned.fill(
            child: CustomPaint(
              painter: _ScannerOverlayPainter(),
            ),
          ),

          // ---------------------------------------------------
          // TOP BAR
          // ---------------------------------------------------

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              child: Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
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
                      scannerController.toggleTorch();
                    },
                  ),
                ],
              ),
            ),
          ),

          // ---------------------------------------------------
          // CENTER TEXT
          // ---------------------------------------------------

          const Align(
            alignment: Alignment(0, 0.38),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 30,
              ),
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

// ===========================================================
// TOP BUTTON
// ===========================================================

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

// ===========================================================
// SCANNER OVERLAY
// ===========================================================

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
      Rect.fromLTWH(
        left,
        top,
        scanWidth,
        scanHeight,
      ),
      const Radius.circular(18),
    );

    final path = Path()
      ..addRect(
        Rect.fromLTWH(
          0,
          0,
          size.width,
          size.height,
        ),
      )
      ..addRRect(scanRect)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(
      path,
      overlayPaint,
    );

    // Scanner frame
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawRRect(
      scanRect,
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(
      covariant CustomPainter oldDelegate,
      ) {
    return false;
  }
}