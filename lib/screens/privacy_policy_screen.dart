import 'package:flutter/cupertino.dart';

/// Privacy Policy screen displaying app's data practices.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Privacy Policy'),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLastUpdated(context),
              const SizedBox(height: 24),
              
              _buildSection(
                context,
                isDark,
                title: 'Overview',
                content: 'Big Bass Angler Log ("we", "our", or "the app") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, and safeguard your information when you use our mobile application.',
              ),
              
              _buildSection(
                context,
                isDark,
                title: 'Data Collection',
                content: '''We collect the following types of data:

• Fishing Log Entries: Species, weight, location names, and dates you manually enter.

• Location Data: With your permission, we access your device's location to provide local weather information. This data is sent to Open-Meteo (weather) and Solunar.org (moon phases) APIs.

• No Personal Information: We do not collect your name, email, phone number, or any other personally identifiable information.''',
              ),
              
              _buildSection(
                context,
                isDark,
                title: 'Data Storage',
                content: '''• All your fishing log data is stored locally on your device only.

• We do not have servers that store your data.

• Your data never leaves your device except for API requests to fetch weather and moon data.

• If you delete the app, all your data will be permanently deleted.''',
              ),
              
              _buildSection(
                context,
                isDark,
                title: 'Third-Party Services',
                content: '''We use the following third-party services:

• Open-Meteo API: To fetch weather data based on your location. Their privacy policy: https://open-meteo.com/en/terms

• Solunar.org API: To fetch moon phase and solunar data. This service receives your approximate coordinates.

These services may collect anonymous usage data according to their own privacy policies.''',
              ),
              
              _buildSection(
                context,
                isDark,
                title: 'Location Permission',
                content: '''We request location access to:

• Provide accurate local weather conditions
• Calculate fishing index based on your area

You can deny location permission, and the app will use a default location for weather data. Location is only accessed when you open the app or refresh data — we do not track your location in the background.''',
              ),
              
              _buildSection(
                context,
                isDark,
                title: 'Data Sharing',
                content: '''We do NOT:

• Sell your data to third parties
• Share your personal information with advertisers
• Use analytics or tracking services
• Store your data on external servers

Your fishing log entries remain completely private on your device.''',
              ),
              
              _buildSection(
                context,
                isDark,
                title: 'Children\'s Privacy',
                content: 'Our app does not knowingly collect information from children under 13. The app is intended for general audiences interested in fishing.',
              ),
              
              _buildSection(
                context,
                isDark,
                title: 'Changes to This Policy',
                content: 'We may update this Privacy Policy from time to time. We will notify you of any changes by updating the "Last Updated" date at the top of this page.',
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the last updated date header.
  Widget _buildLastUpdated(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            CupertinoIcons.calendar,
            size: 16,
            color: CupertinoColors.systemBlue,
          ),
          const SizedBox(width: 8),
          Text(
            'Last Updated: January 19, 2026',
            style: TextStyle(
              fontSize: 14,
              color: CupertinoColors.systemBlue.resolveFrom(context),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a section with title and content.
  Widget _buildSection(
    BuildContext context,
    bool isDark, {
    required String title,
    required String content,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? CupertinoColors.systemGrey6.darkColor
                  : CupertinoColors.systemGrey6.color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              content,
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: CupertinoColors.label.resolveFrom(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
