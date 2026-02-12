import 'package:flutter/material.dart';
import 'package:sari_scan/l10n/app_localizations.dart';
import 'package:mobile_scanner/mobile_scanner.dart' hide Barcode;
import 'package:barcode_widget/barcode_widget.dart';
import 'package:sari_scan/core/mobile_scanner_format_to_barcode_widget.dart';
import 'package:sari_scan/db.dart';
import 'package:sari_scan/models.dart';

class RegisterProductPage extends StatefulWidget {
  const RegisterProductPage({
    super.key,
    required this.barcode,
    required this.format,
  });
  final String barcode;
  final BarcodeFormat format;

  @override
  State<RegisterProductPage> createState() => _RegisterProductPageState();
}

class _RegisterProductPageState extends State<RegisterProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    await insertProduct(Product(
      name: _nameController.text.trim(),
      price: num.parse(_priceController.text.trim()),
      barcode: widget.barcode,
    ));

    if (!mounted) return;

    Navigator.of(context)
      ..pop()
      ..pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.registerProduct),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  BarcodeWidget(
                    data: widget.barcode,
                    barcode:
                        mobileScannerFormatToBarcodeWidget(widget.format),
                    width: 200,
                    height: 80,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.barcode,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: l10n.productName,
                    prefixIcon: const Icon(Icons.inventory_2_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.pleaseEnterProductName;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _priceController,
                  decoration: InputDecoration(
                    labelText: l10n.price,
                    prefixIcon: const Icon(Icons.payments_outlined),
                    prefixText: '₱ ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.pleaseEnterPrice;
                    }
                    if (num.tryParse(value.trim()) == null) {
                      return l10n.pleaseEnterValidNumber;
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: _saving ? null : _save,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(l10n.saveProduct),
          ),
        ],
      ),
    );
  }
}
