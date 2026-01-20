import 'dart:convert';
import 'package:http/http.dart' as http;

/// Moon and solunar data from API.
class MoonData {
  final int moonPhase; // 0-7 phase index
  final String moonPhaseName;
  final double moonIllumination;
  final String? moonrise;
  final String? moonset;
  final DateTime timestamp;

  MoonData({
    required this.moonPhase,
    required this.moonPhaseName,
    required this.moonIllumination,
    this.moonrise,
    this.moonset,
    required this.timestamp,
  });

  /// Moon phase icon based on phase.
  String get icon {
    const icons = ['🌑', '🌒', '🌓', '🌔', '🌕', '🌖', '🌗', '🌘'];
    return icons[moonPhase % 8];
  }

  /// Creates MoonData from Solunar API response.
  factory MoonData.fromSolunarJson(Map<String, dynamic> json) {
    // Parse moon phase from API
    final moonPhaseStr = json['moonPhase'] as String? ?? '';
    final illumination = (json['moonIllumination'] as num?)?.toDouble() ?? 0;
    
    // Convert phase name to index
    int phaseIndex = _phaseNameToIndex(moonPhaseStr);
    
    return MoonData(
      moonPhase: phaseIndex,
      moonPhaseName: _formatPhaseName(moonPhaseStr),
      moonIllumination: illumination,
      moonrise: json['moonRise'] as String?,
      moonset: json['moonSet'] as String?,
      timestamp: DateTime.now(),
    );
  }

  /// Converts phase name to index (0-7).
  static int _phaseNameToIndex(String phaseName) {
    final lower = phaseName.toLowerCase();
    if (lower.contains('new')) return 0;
    if (lower.contains('waxing') && lower.contains('crescent')) return 1;
    if (lower.contains('first') || (lower.contains('waxing') && lower.contains('quarter'))) return 2;
    if (lower.contains('waxing') && lower.contains('gibbous')) return 3;
    if (lower.contains('full')) return 4;
    if (lower.contains('waning') && lower.contains('gibbous')) return 5;
    if (lower.contains('last') || lower.contains('third') || (lower.contains('waning') && lower.contains('quarter'))) return 6;
    if (lower.contains('waning') && lower.contains('crescent')) return 7;
    return 0;
  }

  /// Formats phase name for display.
  static String _formatPhaseName(String phaseName) {
    if (phaseName.isEmpty) return 'Unknown';
    // Capitalize first letter of each word
    return phaseName.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}

/// Service for fetching moon phase data from Solunar API.
/// 
/// Solunar.org provides free moon phase and solunar tables
/// specifically designed for fishing and hunting activities.
class MoonService {
  static const String _baseUrl = 'https://api.solunar.org/solunar';

  /// Fetches moon data for given coordinates.
  Future<MoonData?> getMoonData(double lat, double lon) async {
    try {
      final now = DateTime.now();
      final dateStr = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
      
      // Determine timezone offset
      final offset = now.timeZoneOffset.inHours;
      final tzSign = offset >= 0 ? '' : '-';
      final tzAbs = offset.abs();
      
      final uri = Uri.parse('$_baseUrl/$lat,$lon,$dateStr,$tzSign$tzAbs');
      
      final response = await http.get(uri).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return MoonData.fromSolunarJson(json);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Fetches moon data using default location if coordinates not available.
  Future<MoonData?> getMoonDataDefault() async {
    // Default to Tokyo coordinates
    return await getMoonData(35.6762, 139.6503);
  }
}
