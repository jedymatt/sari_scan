import 'package:flutter/material.dart';
import 'package:sari_scan/l10n/app_localizations.dart';
import 'package:sari_scan/models.dart';

typedef AddEntryResult = ({double amount, String? note});

Future<AddEntryResult?> showAddEntrySheet(
  BuildContext context, {
  required UtangType type,
}) {
  return showModalBottomSheet<AddEntryResult>(
    context: context,
    isScrollControlled: true,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: AddEntryForm(type: type),
    ),
  );
}

class AddEntryForm extends StatefulWidget {
  const AddEntryForm({super.key, required this.type});

  final UtangType type;

  @override
  State<AddEntryForm> createState() => _AddEntryFormState();
}

class _AddEntryFormState extends State<AddEntryForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final amount = double.parse(_amountController.text.trim());
    final note = _noteController.text.trim();
    Navigator.of(context).pop(
      (amount: amount, note: note.isEmpty ? null : note),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDebt = widget.type == UtangType.debt;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isDebt ? l10n.addUtang : l10n.addBayad,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              autofocus: true,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: l10n.amount,
                prefixText: '₱ ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) return l10n.pleaseEnterAmount;
                final parsed = double.tryParse(text);
                if (parsed == null) return l10n.pleaseEnterValidNumber;
                // NaN/Infinity parse successfully but fail every <= check.
                if (!parsed.isFinite || parsed <= 0) {
                  return l10n.pleaseEnterValidAmount;
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: l10n.noteOptional,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _submit,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }
}
