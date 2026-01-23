import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'screens/splash_screen.dart';

/// Main entry point for the Fishing Buddy app.
/// 
/// A lightweight fishing log app designed for iOS that works fully offline.
/// Features include:
/// - Home screen with fishing conditions (weather, moon phase, fishing index)
/// - Fishing log with catch entries
/// - Local storage for offline persistence
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Lock to portrait orientation (iPhone-optimized)
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const SplashScreen());
}
