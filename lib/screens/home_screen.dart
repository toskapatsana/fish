import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/fishing_provider.dart';
import 'fishing_log_screen.dart';
import 'settings_screen.dart';

/// Home screen displaying current conditions and fishing index.
/// 
/// Shows real weather and moon data from APIs, and a calculated
/// fishing index to help fishermen decide if it's a good day to fish.
/// Pull down to refresh data.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Big Bass'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.settings),
          onPressed: () {
            Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (context) => const SettingsScreen(),
              ),
            );
          },
        ),
      ),
      child: SafeArea(
        child: Consumer<FishingProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(
                child: CupertinoActivityIndicator(radius: 20),
              );
            }

            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Pull-to-refresh
                CupertinoSliverRefreshControl(
                  onRefresh: () => provider.refreshConditions(),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Fishing Log button at TOP for immediate visibility
                        _buildLogButton(context),
                        const SizedBox(height: 16),
                        
                        // Fishing Index (compact)
                        _buildFishingIndexCard(context, provider),
                        const SizedBox(height: 12),
                        
                        // Weather and Moon row
                        Row(
                          children: [
                            Expanded(
                              child: _buildWeatherCard(context, provider),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildMoonCard(context, provider),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        // Wind and Humidity row
                        _buildConditionsCard(context, provider),
                        const SizedBox(height: 12),
                        
                        // Quick stats
                        _buildStatsCard(context, provider),
                        const SizedBox(height: 12),
                        
                        // Date at bottom
                        _buildDateCard(context),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Builds the button to navigate to the fishing log - NOW AT TOP.
  Widget _buildLogButton(BuildContext context) {
    return CupertinoButton.filled(
      padding: const EdgeInsets.symmetric(vertical: 14),
      borderRadius: BorderRadius.circular(14),
      onPressed: () {
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (context) => const FishingLogScreen(),
          ),
        );
      },
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(CupertinoIcons.book, size: 22),
          SizedBox(width: 10),
          Text(
            'View Fishing Log',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the main fishing index display (compact version).
  Widget _buildFishingIndexCard(BuildContext context, FishingProvider provider) {
    final index = provider.fishingIndex;
    final description = provider.fishingIndexDescription;
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    
    Color indexColor;
    if (index >= 80) {
      indexColor = CupertinoColors.systemGreen;
    } else if (index >= 60) {
      indexColor = CupertinoColors.systemBlue;
    } else if (index >= 40) {
      indexColor = CupertinoColors.systemYellow;
    } else if (index >= 20) {
      indexColor = CupertinoColors.systemOrange;
    } else {
      indexColor = CupertinoColors.systemRed;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  CupertinoColors.systemIndigo.darkColor.withValues(alpha: 0.3),
                  CupertinoColors.systemBlue.darkColor.withValues(alpha: 0.3),
                ]
              : [
                  CupertinoColors.systemIndigo.color.withValues(alpha: 0.15),
                  CupertinoColors.systemBlue.color.withValues(alpha: 0.15),
                ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: indexColor.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          // Index number
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Fishing Index',
                style: TextStyle(
                  fontSize: 14,
                  color: CupertinoColors.secondaryLabel.resolveFrom(context),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '$index',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: indexColor,
                    ),
                  ),
                  Text(
                    '/100',
                    style: TextStyle(
                      fontSize: 18,
                      color: CupertinoColors.secondaryLabel.resolveFrom(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          // Description badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: indexColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              description,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: indexColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the weather conditions card.
  Widget _buildWeatherCard(BuildContext context, FishingProvider provider) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark 
            ? CupertinoColors.systemGrey6.darkColor 
            : CupertinoColors.systemGrey6.color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            provider.weatherIcon,
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(height: 6),
          Text(
            '${provider.temperature}°C',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            provider.weatherCondition,
            style: TextStyle(
              fontSize: 12,
              color: CupertinoColors.secondaryLabel.resolveFrom(context),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// Builds the moon phase card.
  Widget _buildMoonCard(BuildContext context, FishingProvider provider) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark 
            ? CupertinoColors.systemGrey6.darkColor 
            : CupertinoColors.systemGrey6.color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            provider.moonPhaseIcon,
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(height: 6),
          const Text(
            'Moon',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            provider.moonPhaseName,
            style: TextStyle(
              fontSize: 12,
              color: CupertinoColors.secondaryLabel.resolveFrom(context),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// Builds the wind and humidity conditions card.
  Widget _buildConditionsCard(BuildContext context, FishingProvider provider) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    
    return Row(
      children: [
        // Wind
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark 
                  ? CupertinoColors.systemGrey6.darkColor 
                  : CupertinoColors.systemGrey6.color,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                const Icon(
                  CupertinoIcons.wind,
                  size: 24,
                  color: CupertinoColors.systemTeal,
                ),
                const SizedBox(height: 8),
                Text(
                  provider.windSpeed.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'km/h',
                  style: TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.secondaryLabel.resolveFrom(context),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Humidity
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark 
                  ? CupertinoColors.systemGrey6.darkColor 
                  : CupertinoColors.systemGrey6.color,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                const Icon(
                  CupertinoIcons.drop,
                  size: 24,
                  color: CupertinoColors.systemBlue,
                ),
                const SizedBox(height: 8),
                Text(
                  '${provider.humidity}%',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Humidity',
                  style: TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.secondaryLabel.resolveFrom(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the quick stats card.
  Widget _buildStatsCard(BuildContext context, FishingProvider provider) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    
    return Row(
      children: [
        // Catches
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark 
                  ? CupertinoColors.systemGrey6.darkColor 
                  : CupertinoColors.systemGrey6.color,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                const Icon(
                  CupertinoIcons.doc_text,
                  size: 24,
                  color: CupertinoColors.systemGreen,
                ),
                const SizedBox(height: 8),
                Text(
                  '${provider.entryCount}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Catches',
                  style: TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.secondaryLabel.resolveFrom(context),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Total Weight
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark 
                  ? CupertinoColors.systemGrey6.darkColor 
                  : CupertinoColors.systemGrey6.color,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                const Icon(
                  CupertinoIcons.chart_bar,
                  size: 24,
                  color: CupertinoColors.systemOrange,
                ),
                const SizedBox(height: 8),
                Text(
                  provider.totalWeight.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'kg total',
                  style: TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.secondaryLabel.resolveFrom(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the current date display card.
  Widget _buildDateCard(BuildContext context) {
    final now = DateTime.now();
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: isDark 
            ? CupertinoColors.systemGrey6.darkColor 
            : CupertinoColors.systemGrey6.color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.calendar,
            size: 18,
            color: CupertinoColors.secondaryLabel.resolveFrom(context),
          ),
          const SizedBox(width: 8),
          Text(
            dateFormat.format(now),
            style: TextStyle(
              fontSize: 15,
              color: CupertinoColors.secondaryLabel.resolveFrom(context),
            ),
          ),
        ],
      ),
    );
  }
}
