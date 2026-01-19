import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/fishing_provider.dart';
import 'fishing_log_screen.dart';

/// Home screen displaying current conditions and fishing index.
/// 
/// Shows real weather data from Open-Meteo API, moon phase, and a calculated
/// fishing index to help fishermen decide if it's a good day to fish.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Big Bass'),
        trailing: Consumer<FishingProvider>(
          builder: (context, provider, child) {
            // Show loading indicator or refresh button
            if (provider.isLoadingWeather) {
              return const CupertinoActivityIndicator();
            }
            return CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(CupertinoIcons.refresh),
              onPressed: () => provider.refreshConditions(),
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
              slivers: [
                CupertinoSliverRefreshControl(
                  onRefresh: () => provider.refreshConditions(),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Current date
                        _buildDateCard(context),
                        const SizedBox(height: 20),
                        
                        // Fishing Index (main feature)
                        _buildFishingIndexCard(context, provider),
                        const SizedBox(height: 20),
                        
                        // Weather and Moon row
                        Row(
                          children: [
                            Expanded(
                              child: _buildWeatherCard(context, provider),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildMoonCard(context, provider),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Wind and Humidity row
                        _buildConditionsCard(context, provider),
                        const SizedBox(height: 20),
                        
                        // Quick stats
                        _buildStatsCard(context, provider),
                        const SizedBox(height: 20),
                        
                        // Navigation to log
                        _buildLogButton(context, provider),
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

  /// Builds the current date display card.
  Widget _buildDateCard(BuildContext context) {
    final now = DateTime.now();
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark 
            ? CupertinoColors.systemGrey6.darkColor 
            : CupertinoColors.systemGrey6.color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            'Today',
            style: TextStyle(
              fontSize: 16,
              color: CupertinoColors.secondaryLabel.resolveFrom(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            dateFormat.format(now),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the main fishing index display.
  Widget _buildFishingIndexCard(BuildContext context, FishingProvider provider) {
    final index = provider.fishingIndex;
    final description = provider.fishingIndexDescription;
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    
    // Color based on index value
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
      padding: const EdgeInsets.all(24),
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
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: indexColor.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(
            'Fishing Index',
            style: TextStyle(
              fontSize: 18,
              color: CupertinoColors.secondaryLabel.resolveFrom(context),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$index',
                style: TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                  color: indexColor,
                ),
              ),
              Text(
                '/100',
                style: TextStyle(
                  fontSize: 24,
                  color: CupertinoColors.secondaryLabel.resolveFrom(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: indexColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              description,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: indexColor,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            provider.hasWeatherData 
                ? 'Based on live weather and moon phase'
                : 'Based on moon phase',
            style: TextStyle(
              fontSize: 14,
              color: CupertinoColors.tertiaryLabel.resolveFrom(context),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the weather conditions card with real API data.
  Widget _buildWeatherCard(BuildContext context, FishingProvider provider) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark 
            ? CupertinoColors.systemGrey6.darkColor 
            : CupertinoColors.systemGrey6.color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Weather icon from API
          Text(
            provider.weatherIcon,
            style: const TextStyle(fontSize: 40),
          ),
          const SizedBox(height: 8),
          Text(
            '${provider.temperature}°C',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            provider.weatherCondition,
            style: TextStyle(
              fontSize: 14,
              color: CupertinoColors.secondaryLabel.resolveFrom(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Builds the moon phase card.
  Widget _buildMoonCard(BuildContext context, FishingProvider provider) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark 
            ? CupertinoColors.systemGrey6.darkColor 
            : CupertinoColors.systemGrey6.color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            provider.moonPhaseIcon,
            style: const TextStyle(fontSize: 40),
          ),
          const SizedBox(height: 8),
          const Text(
            'Moon',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            provider.moonPhaseName,
            style: TextStyle(
              fontSize: 14,
              color: CupertinoColors.secondaryLabel.resolveFrom(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Builds the wind and humidity conditions card.
  Widget _buildConditionsCard(BuildContext context, FishingProvider provider) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark 
            ? CupertinoColors.systemGrey6.darkColor 
            : CupertinoColors.systemGrey6.color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Wind speed
          Column(
            children: [
              const Icon(
                CupertinoIcons.wind,
                size: 28,
                color: CupertinoColors.systemTeal,
              ),
              const SizedBox(height: 8),
              Text(
                '${provider.windSpeed.toStringAsFixed(1)} km/h',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Wind',
                style: TextStyle(
                  fontSize: 13,
                  color: CupertinoColors.secondaryLabel.resolveFrom(context),
                ),
              ),
            ],
          ),
          Container(
            width: 1,
            height: 50,
            color: CupertinoColors.separator.resolveFrom(context),
          ),
          // Humidity
          Column(
            children: [
              const Icon(
                CupertinoIcons.drop,
                size: 28,
                color: CupertinoColors.systemBlue,
              ),
              const SizedBox(height: 8),
              Text(
                '${provider.humidity}%',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Humidity',
                style: TextStyle(
                  fontSize: 13,
                  color: CupertinoColors.secondaryLabel.resolveFrom(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds the quick stats card.
  Widget _buildStatsCard(BuildContext context, FishingProvider provider) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark 
            ? CupertinoColors.systemGrey6.darkColor 
            : CupertinoColors.systemGrey6.color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            context,
            CupertinoIcons.doc_text,
            '${provider.entryCount}',
            'Catches',
          ),
          Container(
            width: 1,
            height: 40,
            color: CupertinoColors.separator.resolveFrom(context),
          ),
          _buildStatItem(
            context,
            CupertinoIcons.chart_bar,
            '${provider.totalWeight.toStringAsFixed(1)} kg',
            'Total Weight',
          ),
        ],
      ),
    );
  }

  /// Builds a single stat item.
  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String value,
    String label,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          size: 28,
          color: CupertinoColors.systemBlue,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: CupertinoColors.secondaryLabel.resolveFrom(context),
          ),
        ),
      ],
    );
  }

  /// Builds the button to navigate to the fishing log.
  Widget _buildLogButton(BuildContext context, FishingProvider provider) {
    return CupertinoButton.filled(
      padding: const EdgeInsets.symmetric(vertical: 16),
      borderRadius: BorderRadius.circular(16),
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
          Icon(CupertinoIcons.book, size: 24),
          SizedBox(width: 12),
          Text(
            'View Fishing Log',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
