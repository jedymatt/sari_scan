import 'package:flutter/material.dart';
import 'package:sari_scan/l10n/app_localizations.dart';
import 'package:sari_scan/db.dart';
import 'package:sari_scan/models.dart';

class EditCustomerPage extends StatefulWidget {
  const EditCustomerPage({super.key, this.customer});

  final Customer? customer;

  @override
  State<EditCustomerPage> createState() => _EditCustomerPageState();
}

class _EditCustomerPageState extends State<EditCustomerPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  bool _saving = false;

  /// Names of existing active customers, lowercased and trimmed, used to
  /// softly warn about duplicates. Excludes this customer when editing.
  Set<String> _existingNames = {};
  bool _duplicateName = false;

  bool get _isEditing => widget.customer != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.customer?.name ?? '');
    _phoneController =
        TextEditingController(text: widget.customer?.phone ?? '');
    _loadExistingNames();
  }

  Future<void> _loadExistingNames() async {
    final names = await activeCustomerNames(excludeId: widget.customer?.id);
    if (!mounted) return;
    setState(() {
      _existingNames = names.map((n) => n.trim().toLowerCase()).toSet();
    });
  }

  void _onNameChanged(String value) {
    final duplicate = _existingNames.contains(value.trim().toLowerCase());
    if (duplicate != _duplicateName) {
      setState(() => _duplicateName = duplicate);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final phoneValue = phone.isEmpty ? null : phone;

    if (_isEditing) {
      await updateCustomer(widget.customer!.copyWith(
        name: name,
        phone: phoneValue,
        clearPhone: phoneValue == null,
      ));
    } else {
      await insertCustomer(Customer(name: name, phone: phoneValue));
    }

    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.editCustomer : l10n.addCustomer),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: l10n.customerName,
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: _onNameChanged,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.pleaseEnterCustomerName;
                    }
                    return null;
                  },
                ),
                if (_duplicateName) ...[
                  const SizedBox(height: 8),
                  _DuplicateNameHint(name: _nameController.text.trim()),
                ],
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: l10n.phoneOptional,
                    prefixIcon: const Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
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
                        strokeWidth: 2, color: Colors.white),
                  )
                : Text(l10n.saveCustomer),
          ),
        ],
      ),
    );
  }
}

/// Non-blocking hint shown when the entered name matches an existing customer.
/// Suggests a distinguishing nickname; it never prevents saving.
class _DuplicateNameHint extends StatelessWidget {
  const _DuplicateNameHint({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline,
              size: 20, color: colorScheme.onTertiaryContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.duplicateNameHint(name),
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onTertiaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
