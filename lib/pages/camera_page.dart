import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sari_scan/l10n/app_localizations.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:sari_scan/components/product_detail_overlay_content.dart';
import 'package:sari_scan/db.dart';
import 'package:sari_scan/pages/product_management/edit_product_page.dart';
import 'package:sari_scan/pages/product_management/register_product_page.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  MobileScannerController cameraController = MobileScannerController(
    facing: CameraFacing.back,
    autoStart: false,
  );
  Barcode? barcode;
  StreamSubscription<Object?>? _subscription;
  Timer? _clearTimer;

  @override
  void initState() {
    _subscription = cameraController.barcodes.listen(_handleBarcodes);
    super.initState();
    unawaited(cameraController.start());
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    _subscription = null;
    super.dispose();
    cameraController.dispose();
    _clearTimer?.cancel();
  }

  void _handleBarcodes(BarcodeCapture barcodeCapture) {
    if (barcodeCapture.barcodes.isEmpty) {
      return;
    }
    barcode = barcodeCapture.barcodes.first;

    _clearTimer?.cancel();
    _clearTimer = Timer(const Duration(seconds: 1), () {
      setState(() {
        barcode = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    late final scanWindow = Rect.fromCenter(
      center: MediaQuery.sizeOf(context).center(const Offset(0, -100)),
      width: MediaQuery.sizeOf(context).width,
      height: 400,
    );

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: cameraController,
            fit: BoxFit.cover,
            scanWindow: scanWindow,
          ),
          ScanWindowOverlay(
            controller: cameraController,
            scanWindow: scanWindow,
          ),
          BarcodeOverlay(
            boxFit: BoxFit.cover,
            controller: cameraController,
          ),
          // Top bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.6),
                    Colors.transparent,
                  ],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.scanBarcode,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Bottom panel
          Column(
            children: [
              const Spacer(),
              FutureBuilder(
                future: queryProducts(),
                builder: (context, asyncSnapshot) {
                  final data = asyncSnapshot.data ?? [];

                  return StreamBuilder<BarcodeCapture>(
                    stream: cameraController.barcodes,
                    builder: (context, snapshot) {
                      final code = barcode?.rawValue;
                      if (code == null) {
                        // Idle hint
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.qr_code_scanner,
                                    color: Colors.white70, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  l10n.pointCameraAtBarcode,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      final product =
                          data.where((p) => p.barcode == code).firstOrNull;
                      if (product == null) {
                        // Product not found
                        return _BottomCard(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: colorScheme.errorContainer,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.search_off,
                                    color: colorScheme.onErrorContainer),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                l10n.productNotFound,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.barcodeWithValue(code),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 16),
                              FilledButton.icon(
                                onPressed: () {
                                  cameraController.stop();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          RegisterProductPage(
                                        barcode: code,
                                        format: barcode!.format,
                                      ),
                                    ),
                                  );
                                  cameraController.start();
                                },
                                icon: const Icon(Icons.add),
                                label: Text(l10n.registerProduct),
                              ),
                            ],
                          ),
                        );
                      }

                      return ProductDetailOverlayContent(
                        productName: product.name,
                        price: product.price,
                        onEdit: () async {
                          await cameraController.stop();
                          if (context.mounted) {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EditProductPage(product: product),
                              ),
                            );
                          }
                          if (mounted) setState(() {});
                          await cameraController.start();
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BottomCard extends StatelessWidget {
  final Widget child;

  const _BottomCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: child,
    );
  }
}
