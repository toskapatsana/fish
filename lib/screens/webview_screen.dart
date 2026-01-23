import 'package:flutter/cupertino.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../services/url_checker_service.dart';

/// WebView screen with Cupertino design.
class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    final isDark =
        WidgetsBinding.instance.platformDispatcher.platformBrightness ==
            Brightness.dark;

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(
        isDark
            ? const Color(0xFF000000)
            : const Color(0xFFF2F2F7),
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(UrlCheckerService.targetUrl));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? CupertinoColors.black
        : CupertinoColors.systemGroupedBackground;

    return CupertinoPageScaffold(
      backgroundColor: backgroundColor,
      child: SafeArea(
        child: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading)
              Container(
                color: isDark
                    ? CupertinoColors.black
                    : CupertinoColors.systemGroupedBackground.resolveFrom(context),
                child: const Center(
                  child: CupertinoActivityIndicator(
                    radius: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
