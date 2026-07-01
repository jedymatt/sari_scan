import 'package:flutter/material.dart';
import 'package:sari_scan/l10n/app_localizations.dart';
import 'package:sari_scan/core/currency.dart';
import 'package:sari_scan/core/date_format.dart';
import 'package:sari_scan/db.dart';
import 'package:sari_scan/models.dart';
import 'package:sari_scan/pages/mga_utang/add_entry_sheet.dart';
import 'package:sari_scan/pages/mga_utang/edit_customer_page.dart';

class CustomerLedgerPage extends StatefulWidget {
  const CustomerLedgerPage({super.key, required this.customerId});

  final int customerId;

  @override
  State<CustomerLedgerPage> createState() => _CustomerLedgerPageState();
}

class _CustomerLedgerPageState extends State<CustomerLedgerPage> {
  Customer? _customer;
  List<UtangEntry>? _entries;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    // A customer is in exactly one of the active/archived lists.
    final active = await queryCustomers();
    final archived = await queryCustomers(trashed: true);
    final match = [...active, ...archived]
        .where((c) => c.customer.id == widget.customerId)
        .toList();
    final entries = await queryEntries(widget.customerId);
    if (!mounted) return;
    setState(() {
      _customer = match.isEmpty ? null : match.first.customer;
      _entries = entries;
    });
  }

  double get _balance => balanceOf(_entries ?? const []);

  Future<void> _addEntry(UtangType type) async {
    final result = await showAddEntrySheet(context, type: type);
    if (result == null) return;
    await insertEntry(
      customerId: widget.customerId,
      type: type,
      amount: result.amount,
      note: result.note,
    );
    await _load();
  }

  Future<void> _toggleArchive() async {
    final customer = _customer!;
    await setCustomerTrashed(customer.id!, !customer.isTrashed);
    await _load();
  }

  Future<void> _edit() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => EditCustomerPage(customer: _customer),
      ),
    );
    if (result == true) await _load();
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final customer = _customer!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteCustomer),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.confirmDeleteCustomer(customer.name)),
            if (_balance > 0) ...[
              const SizedBox(height: 8),
              Text(l10n.outstandingBalanceWarning(phpFormat.format(_balance))),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await deleteCustomer(customer.id!);
    if (!mounted) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(l10n.customerDeleted(customer.name)),
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final customer = _customer;

    return Scaffold(
      appBar: AppBar(
        title: Text(customer?.name ?? ''),
        actions: [
          if (customer != null)
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    _edit();
                  case 'archive':
                    _toggleArchive();
                  case 'delete':
                    _delete();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(value: 'edit', child: Text(l10n.editCustomer)),
                PopupMenuItem(
                  value: 'archive',
                  child: Text(
                      customer.isTrashed ? l10n.restore : l10n.moveToTrash),
                ),
                PopupMenuItem(
                    value: 'delete', child: Text(l10n.deleteCustomer)),
              ],
            ),
        ],
      ),
      body: customer == null || _entries == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text(l10n.balance,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              )),
                          const SizedBox(height: 4),
                          Text(
                            _balance <= 0
                                ? l10n.settled
                                : phpFormat.format(_balance),
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _balance > 0
                                  ? colorScheme.error
                                  : colorScheme.onSurfaceVariant,
                            ),
                          ),
                          if (customer.phone != null) ...[
                            const SizedBox(height: 8),
                            Text(customer.phone!,
                                style: theme.textTheme.bodySmall),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _addEntry(UtangType.debt),
                          icon: const Icon(Icons.add),
                          label: Text(l10n.addUtang),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => _addEntry(UtangType.payment),
                          icon: const Icon(Icons.payments_outlined),
                          label: Text(l10n.addBayad),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: _entries!.isEmpty
                      ? Center(
                          child: Text(l10n.noEntriesYet,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              )))
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          itemCount: _entries!.length,
                          separatorBuilder: (context, index) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final entry = _entries![index];
                            final isDebt = entry.type == UtangType.debt;
                            return ListTile(
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 8),
                              leading: CircleAvatar(
                                backgroundColor: isDebt
                                    ? colorScheme.errorContainer
                                    : colorScheme.primaryContainer,
                                child: Icon(
                                  isDebt
                                      ? Icons.arrow_upward
                                      : Icons.arrow_downward,
                                  color: isDebt
                                      ? colorScheme.onErrorContainer
                                      : colorScheme.onPrimaryContainer,
                                ),
                              ),
                              title: Text(
                                '${isDebt ? '+' : '-'} '
                                '${phpFormat.format(entry.amount)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: isDebt
                                      ? colorScheme.error
                                      : colorScheme.primary,
                                ),
                              ),
                              subtitle:
                                  entry.note != null ? Text(entry.note!) : null,
                              trailing: entry.createdAt != null
                                  ? Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          entryDateFormat
                                              .format(entry.createdAt!),
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                        Text(
                                          entryTimeFormat
                                              .format(entry.createdAt!),
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    )
                                  : null,
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
