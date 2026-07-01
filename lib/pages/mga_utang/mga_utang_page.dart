import 'package:flutter/material.dart';
import 'package:sari_scan/l10n/app_localizations.dart';
import 'package:sari_scan/core/currency.dart';
import 'package:sari_scan/db.dart';
import 'package:sari_scan/models.dart';
import 'package:sari_scan/pages/mga_utang/customer_ledger_page.dart';
import 'package:sari_scan/pages/mga_utang/edit_customer_page.dart';

class MgaUtangPage extends StatefulWidget {
  const MgaUtangPage({super.key});

  @override
  State<MgaUtangPage> createState() => _MgaUtangPageState();
}

class _MgaUtangPageState extends State<MgaUtangPage> {
  List<CustomerWithBalance>? _customers;
  double _total = 0;
  bool _showArchived = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final customers = await queryCustomers(archived: _showArchived);
    final total = await totalOutstanding();
    if (!mounted) return;
    setState(() {
      _customers = customers;
      _total = total;
    });
  }

  List<CustomerWithBalance> get _filtered {
    if (_customers == null) return [];
    if (_searchQuery.isEmpty) return _customers!;
    final q = _searchQuery.toLowerCase();
    return _customers!
        .where((c) => c.customer.name.toLowerCase().contains(q))
        .toList();
  }

  Future<void> _addCustomer() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => const EditCustomerPage()),
    );
    if (result == true) _load();
  }

  Future<void> _openLedger(int customerId) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => CustomerLedgerPage(customerId: customerId),
      ),
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final filtered = _filtered;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.mgaUtang),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(112),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: l10n.searchCustomers,
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: SegmentedButton<bool>(
                  segments: [
                    ButtonSegment(value: false, label: Text(l10n.active)),
                    ButtonSegment(value: true, label: Text(l10n.archived)),
                  ],
                  selected: {_showArchived},
                  onSelectionChanged: (selection) {
                    setState(() => _showArchived = selection.first);
                    _load();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addCustomer,
        icon: const Icon(Icons.person_add),
        label: Text(l10n.addCustomer),
      ),
      body: _customers == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(l10n.totalOutstanding,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                          )),
                      const SizedBox(height: 4),
                      Text(
                        phpFormat.format(_total),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _customers!.isEmpty
                      ? _EmptyState(archived: _showArchived)
                      : filtered.isEmpty
                          ? Center(
                              child: Text(l10n.noMatchingCustomers,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  )))
                          : ListView.builder(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final item = filtered[index];
                                final owing = item.balance > 0;
                                return Card(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor:
                                          colorScheme.secondaryContainer,
                                      child: Text(
                                        item.customer.name.isNotEmpty
                                            ? item.customer.name[0]
                                                .toUpperCase()
                                            : '?',
                                      ),
                                    ),
                                    title: Text(item.customer.name),
                                    subtitle: item.customer.phone != null
                                        ? Text(item.customer.phone!)
                                        : null,
                                    trailing: Text(
                                      owing
                                          ? phpFormat.format(item.balance)
                                          : l10n.settled,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: owing
                                            ? colorScheme.error
                                            : colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    onTap: () =>
                                        _openLedger(item.customer.id!),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.archived});

  final bool archived;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.people_outline,
              size: 64, color: colorScheme.onSurfaceVariant),
          const SizedBox(height: 16),
          Text(
            archived ? l10n.noMatchingCustomers : l10n.noCustomersYet,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          if (!archived) ...[
            const SizedBox(height: 4),
            Text(l10n.addFirstCustomer,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                )),
          ],
        ],
      ),
    );
  }
}
