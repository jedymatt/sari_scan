import 'package:flutter/material.dart';
import 'package:sari_scan/l10n/app_localizations.dart';
import 'package:sari_scan/main.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentMode = MyApp.themeMode(context);
    final currentLocale = MyApp.locale(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        children: [
          // Language section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              l10n.language,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          RadioGroup<Locale?>(
            groupValue: currentLocale,
            onChanged: (locale) {
              MyApp.setLocale(context, locale);
            },
            child: Column(
              children: [
                RadioListTile<Locale?>(
                  title: Text(l10n.systemDefault),
                  value: null,
                ),
                RadioListTile<Locale?>(
                  title: Text(l10n.english),
                  value: const Locale('en'),
                ),
                RadioListTile<Locale?>(
                  title: Text(l10n.cebuano),
                  value: const Locale('ceb'),
                ),
              ],
            ),
          ),
          const Divider(height: 32),
          // Appearance section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              l10n.appearance,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          RadioGroup<ThemeMode>(
            groupValue: currentMode,
            onChanged: (mode) {
              if (mode != null) MyApp.setThemeMode(context, mode);
            },
            child: Column(
              children: [
                RadioListTile<ThemeMode>(
                  title: Text(l10n.systemDefault),
                  value: ThemeMode.system,
                ),
                RadioListTile<ThemeMode>(
                  title: Text(l10n.light),
                  value: ThemeMode.light,
                ),
                RadioListTile<ThemeMode>(
                  title: Text(l10n.dark),
                  value: ThemeMode.dark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
