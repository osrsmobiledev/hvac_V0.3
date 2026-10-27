import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app/localization/app_dictionary.dart';
import 'app/shell/app_shell_screen.dart';
import 'app/splash/app_splash_screen.dart';
import 'app/theme/app_theme.dart';
import 'core/database/app_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SQLite database on startup for offline draft safety
  await AppDatabase.instance.database;

  // Enforce portrait orientation app-wide across all devices (phones & tablets)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Configure edge-to-edge transparent status bar & OLED navigation bar with light icons
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xFF121212),
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

  runApp(const HvacFieldServiceApp());
}

/// Root widget for the HVAC Field Service application.
///
/// Keeps initialization minimal: loads dark BO2 theme, runs splash HUD boot,
/// and transitions into AppShellScreen.
class HvacFieldServiceApp extends StatelessWidget {
  final bool skipSplash;

  const HvacFieldServiceApp({
    super.key,
    this.skipSplash = false,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppDictionary.appTitle,
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: child,
        );
      },
      home: skipSplash ? const AppShellScreen() : const AppSplashScreen(),
    );
  }
}
