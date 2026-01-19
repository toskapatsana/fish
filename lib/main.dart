import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/fishing_provider.dart';
import 'screens/home_screen.dart';

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

  runApp(const FishingBuddyApp());
}

/// Root widget that sets up providers and theming.
class FishingBuddyApp extends StatelessWidget {
  const FishingBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // Create and initialize the fishing provider
      create: (context) => FishingProvider()..init(),
      child: const _AppRoot(),
    );
  }
}

/// App root with theme configuration.
/// 
/// Separated to allow access to provider if needed during build.
class _AppRoot extends StatelessWidget {
  const _AppRoot();

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Big Bass Angler Log',
      debugShowCheckedModeBanner: false,
      
      // Light theme
      theme: const CupertinoThemeData(
        brightness: Brightness.light,
        primaryColor: CupertinoColors.systemBlue,
        scaffoldBackgroundColor: CupertinoColors.systemGroupedBackground,
        textTheme: CupertinoTextThemeData(
          textStyle: TextStyle(
            fontFamily: '.SF Pro Text',
            fontSize: 17,
            color: CupertinoColors.label,
          ),
        ),
      ),

      // Uncomment to use system theme (light/dark based on device settings)
      // This respects iOS appearance settings automatically
      
      home: const HomeScreen(),
      
      // Localization settings (English only)
      localizationsDelegates: const [
        DefaultCupertinoLocalizations.delegate,
      ],
    );
  }
}
