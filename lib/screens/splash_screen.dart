import 'package:flutter/cupertino.dart';
import '../services/url_checker_service.dart';
import 'webview_screen.dart';
import 'home_screen.dart';
import 'package:provider/provider.dart';
import '../providers/fishing_provider.dart';

/// Splash screen with URL check to determine which screen to show.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with WidgetsBindingObserver {
  bool _isChecking = true;
  bool _shouldShowWebView = false;
  bool _checkCompleted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAndNavigate();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Handles app lifecycle state changes (background/foreground).
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Re-check when app returns to foreground
      _checkAndNavigate();
    }
  }

  Future<void> _checkAndNavigate() async {
    if (!mounted) return;

    setState(() {
      _isChecking = true;
    });

    final shouldShowWebView = await UrlCheckerService.shouldShowWebView();

    if (!mounted) return;

    setState(() {
      _isChecking = false;
      _shouldShowWebView = shouldShowWebView;
      _checkCompleted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show loading while checking
    if (_isChecking || !_checkCompleted) {
      return CupertinoApp(
        title: 'Big Bass Angler Log',
        debugShowCheckedModeBanner: false,
        theme: const CupertinoThemeData(
          brightness: Brightness.light,
          primaryColor: CupertinoColors.systemBlue,
          scaffoldBackgroundColor: CupertinoColors.systemGroupedBackground,
        ),
        home: _buildLoadingScreen(),
      );
    }

    // WebView if URL is available
    if (_shouldShowWebView) {
      return CupertinoApp(
        title: 'Big Bass Angler Log',
        debugShowCheckedModeBanner: false,
        theme: const CupertinoThemeData(
          brightness: Brightness.light,
          primaryColor: CupertinoColors.systemBlue,
          scaffoldBackgroundColor: CupertinoColors.systemGroupedBackground,
        ),
        home: const WebViewScreen(),
      );
    }

    // Native app if URL is not available
    return ChangeNotifierProvider(
      create: (context) => FishingProvider()..init(),
      child: CupertinoApp(
        title: 'Big Bass Angler Log',
        debugShowCheckedModeBanner: false,
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
        home: const HomeScreen(),
        localizationsDelegates: const [
          DefaultCupertinoLocalizations.delegate,
        ],
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Fish icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: CupertinoColors.systemBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Text(
                '🎣',
                style: TextStyle(fontSize: 64),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Big Bass Angler Log',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.label,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading...',
              style: TextStyle(
                fontSize: 16,
                color: CupertinoColors.secondaryLabel.darkColor,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 32),
            const CupertinoActivityIndicator(
              radius: 16,
            ),
          ],
        ),
      ),
    );
  }
}
