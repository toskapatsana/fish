import 'package:flutter/cupertino.dart';
import 'home_screen.dart';
import 'package:provider/provider.dart';
import '../providers/fishing_provider.dart';

/// Splash screen that shows the app.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
}
