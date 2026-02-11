import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sari_scan/pages/home_page.dart';

const _themeModeKey = 'theme_mode';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static void setThemeMode(BuildContext context, ThemeMode mode) {
    context.findAncestorStateOfType<_MyAppState>()!._setThemeMode(mode);
  }

  static ThemeMode themeMode(BuildContext context) {
    return context.findAncestorStateOfType<_MyAppState>()!._themeMode;
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_themeModeKey);
    if (index != null && mounted) {
      setState(() {
        _themeMode = ThemeMode.values[index];
      });
    }
  }

  void _setThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
    SharedPreferences.getInstance().then((prefs) {
      prefs.setInt(_themeModeKey, mode.index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sari Scan',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF8C42),
          secondary: const Color(0xFFFFA726),
          surface: const Color(0xFFFFFBF5),
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF8C42),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: _themeMode,
      home: const HomePage(),
    );
  }
}
