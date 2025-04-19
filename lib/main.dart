import 'package:gotransfer/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:flutter/widgets.dart';
import 'package:sqflite/sqflite.dart';

// Variables globales
// ThemeNotifier themeNotifier = ThemeNotifier();

late Future<Database> database;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  database = openDatabase(
    // Set the path to the database. Note: Using the `join` function from the
    // `path` package is best practice to ensure the path is correctly
    // constructed for each platform.
    join(await getDatabasesPath(), 'go_transfer.db'),
    onCreate: (db, version) {
      print("requete executed");
      // Run the CREATE TABLE statement on the database.
      return db.execute(
        'CREATE TABLE reference('
            'id INTEGER PRIMARY KEY, '
            'accessToken TEXT, '
            'refreshToken TEXT'
        ');'
        ''
        ''
        'CREATE TABLE usr('
            'id INTGR PRIMARY KY, '
            'first_nam',
      );
    },
    version: 1
  );
  print("hello : ${getDatabasesPath()}");
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  runApp(ChangeNotifierProvider(
    create: (context) => ThemeNotifier(),
      child: const MyApp(),
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeNotifier.themeMode,
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
    );
  }
}

class ThemeNotifier with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeNotifier() {
    _loadThemePref();
  }

  Future<void> _loadThemePref() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('themeMode') ?? ThemeMode.system.index;
    _themeMode = ThemeMode.values[themeIndex];
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index);
    notifyListeners();
  }
}

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: const Color(0xFF284389), // Primary clair (#284389)
  scaffoldBackgroundColor: const Color(0xFFF5F7FA), // Background clair
  colorScheme: ColorScheme.light(
    primary: const Color(0xFF284389), // Primary
    secondary: const Color(0xFF4A6FBA), // Secondary clair
    background: const Color(0xFFF5F7FA), // Background clair
    onBackground: const Color(0xFF333333), // Texte sur fond clair
  ),
);

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: const Color(0xFF6B8CD9), // Primary sombre (#6B8CD9)
  scaffoldBackgroundColor: const Color(0xFF121212), // Background sombre
  colorScheme: ColorScheme.dark(
    primary: const Color(0xFF6B8CD9), // Primary sombre
    secondary: const Color(0xFF8EABF0), // Secondary sombre
    background: const Color(0xFF121212), // Background sombre
    onBackground: const Color(0xFFE0E0E0), // Texte sur fond sombre
  ),
);