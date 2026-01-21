import 'package:flutter/cupertino.dart';
import 'privacy_policy_screen.dart';

/// Settings screen with app configuration and information.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Settings'),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            const SizedBox(height: 20),
            
            // App Info Section
            _buildSectionHeader(context, 'APP INFO'),
            _buildSettingsGroup(
              context,
              isDark,
              children: [
                _buildInfoRow(context, 'Version', '1.3.0'),
                _buildInfoRow(context, 'Build', '4'),
              ],
            ),
            const SizedBox(height: 20),

            // Data Section
            _buildSectionHeader(context, 'DATA'),
            _buildSettingsGroup(
              context,
              isDark,
              children: [
                _buildNavigationRow(
                  context,
                  icon: CupertinoIcons.doc_text,
                  iconColor: CupertinoColors.systemBlue,
                  title: 'Privacy Policy',
                  onTap: () => _openPrivacyPolicy(context),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Footer
            Center(
              child: Column(
                children: [
                  const Text(
                    '🎣',
                    style: TextStyle(fontSize: 40),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Big Bass Angler Log',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.label.resolveFrom(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Made with ❤️ for fishermen',
                    style: TextStyle(
                      fontSize: 13,
                      color: CupertinoColors.secondaryLabel.resolveFrom(context),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  /// Builds a section header.
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: CupertinoColors.secondaryLabel.resolveFrom(context),
        ),
      ),
    );
  }

  /// Builds a settings group container.
  Widget _buildSettingsGroup(
    BuildContext context,
    bool isDark, {
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark
            ? CupertinoColors.systemGrey6.darkColor
            : CupertinoColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              Padding(
                padding: const EdgeInsets.only(left: 52),
                child: Container(
                  height: 0.5,
                  color: CupertinoColors.separator.resolveFrom(context),
                ),
              ),
          ],
        ],
      ),
    );
  }

  /// Builds an info row (non-interactive).
  Widget _buildInfoRow(BuildContext context, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: CupertinoColors.secondaryLabel.resolveFrom(context),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a navigation row with icon and chevron.
  Widget _buildNavigationRow(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: iconColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                icon,
                size: 18,
                color: CupertinoColors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: CupertinoColors.label.resolveFrom(context),
                ),
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              size: 18,
              color: CupertinoColors.tertiaryLabel.resolveFrom(context),
            ),
          ],
        ),
      ),
    );
  }

  /// Opens Privacy Policy screen.
  void _openPrivacyPolicy(BuildContext context) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => const PrivacyPolicyScreen(),
      ),
    );
  }

  }
