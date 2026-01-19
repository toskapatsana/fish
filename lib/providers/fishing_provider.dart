import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/catch_entry.dart';
import '../services/storage_service.dart';
import '../services/weather_service.dart';

/// Provider for managing fishing data and state.
/// 
/// Handles all catch entries and provides real weather data from Open-Meteo API
/// for the home screen fishing index calculation.
class FishingProvider extends ChangeNotifier {
  final StorageService _storageService;
  final WeatherService _weatherService;
  final Uuid _uuid = const Uuid();

  List<CatchEntry> _entries = [];
  bool _isLoading = false;
  bool _isLoadingWeather = false;
  String? _error;

  // Weather data from API
  WeatherData? _weatherData;

  // Moon phase data (0-7: New, Waxing Crescent, First Quarter, 
  // Waxing Gibbous, Full, Waning Gibbous, Last Quarter, Waning Crescent)
  int _moonPhase = 0;

  FishingProvider({
    StorageService? storageService,
    WeatherService? weatherService,
  })  : _storageService = storageService ?? StorageService(),
        _weatherService = weatherService ?? WeatherService();

  // ============ Getters ============

  /// All catch entries, sorted by date (newest first).
  List<CatchEntry> get entries => List.unmodifiable(
    _entries..sort((a, b) => b.date.compareTo(a.date)),
  );

  /// Total number of entries.
  int get entryCount => _entries.length;

  /// Whether data is currently loading.
  bool get isLoading => _isLoading;

  /// Whether weather is currently loading.
  bool get isLoadingWeather => _isLoadingWeather;

  /// Current error message, if any.
  String? get error => _error;

  /// Whether we have weather data.
  bool get hasWeatherData => _weatherData != null;

  /// Weather condition string from API.
  String get weatherCondition => _weatherData?.condition ?? 'Loading...';

  /// Weather icon emoji.
  String get weatherIcon => _weatherData?.icon ?? '🌤️';

  /// Temperature in Celsius.
  int get temperature => _weatherData?.temperature.round() ?? 0;

  /// Humidity percentage.
  int get humidity => _weatherData?.humidity ?? 0;

  /// Wind speed in km/h.
  double get windSpeed => _weatherData?.windSpeed ?? 0;

  /// Current moon phase (0-7).
  int get moonPhase => _moonPhase;

  /// Moon phase name based on current phase.
  String get moonPhaseName {
    const phases = [
      'New Moon',
      'Waxing Crescent',
      'First Quarter',
      'Waxing Gibbous',
      'Full Moon',
      'Waning Gibbous',
      'Last Quarter',
      'Waning Crescent',
    ];
    return phases[_moonPhase % 8];
  }

  /// Moon phase icon (emoji for simplicity).
  String get moonPhaseIcon {
    const icons = ['🌑', '🌒', '🌓', '🌔', '🌕', '🌖', '🌗', '🌘'];
    return icons[_moonPhase % 8];
  }

  /// Calculates the "Fishing Index" (0-100).
  /// 
  /// This is a simplified calculation based on:
  /// - Moon phase (full moon and new moon are best)
  /// - Weather conditions (mild weather is better)
  /// - Wind speed
  int get fishingIndex {
    // Moon phase score (0-40 points)
    // Full moon (4) and New moon (0) are best for fishing
    int moonScore;
    if (_moonPhase == 0 || _moonPhase == 4) {
      moonScore = 40; // Best: New or Full moon
    } else if (_moonPhase == 2 || _moonPhase == 6) {
      moonScore = 25; // Moderate: Quarter moons
    } else {
      moonScore = 15; // Lower: Crescent/Gibbous
    }

    // Weather score (0-40 points) based on real API data
    int weatherScore = 30; // Default moderate score
    if (_weatherData != null) {
      final code = _weatherData!.weatherCode;
      if (code <= 3) {
        // Clear to overcast - good conditions
        weatherScore = code == 3 ? 38 : 32; // Overcast is slightly better
      } else if (code <= 48) {
        // Foggy - moderate
        weatherScore = 28;
      } else if (code <= 67) {
        // Rain/drizzle - can be good for some fish
        weatherScore = 25;
      } else if (code <= 77) {
        // Snow - poor conditions
        weatherScore = 15;
      } else if (code <= 82) {
        // Rain showers - variable
        weatherScore = 22;
      } else {
        // Thunderstorm - dangerous
        weatherScore = 10;
      }
    }

    // Wind score (0-20 points)
    // Light wind (5-15 km/h) is ideal
    final wind = _weatherData?.windSpeed ?? 10;
    int windScore;
    if (wind >= 5 && wind <= 15) {
      windScore = 20; // Ideal
    } else if (wind < 5) {
      windScore = 15; // Too calm
    } else if (wind <= 25) {
      windScore = 10; // A bit windy
    } else {
      windScore = 5; // Too windy
    }

    return (moonScore + weatherScore + windScore).clamp(0, 100);
  }

  /// Description of the fishing index.
  String get fishingIndexDescription {
    final index = fishingIndex;
    if (index >= 80) return 'Excellent';
    if (index >= 60) return 'Good';
    if (index >= 40) return 'Fair';
    if (index >= 20) return 'Poor';
    return 'Bad';
  }

  /// Total weight of all catches in kg.
  double get totalWeight {
    if (_entries.isEmpty) return 0;
    return _entries.fold(0.0, (sum, entry) => sum + entry.weight);
  }

  // ============ Actions ============

  /// Initializes the provider by loading stored entries and weather.
  Future<void> init() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _storageService.init();
      _entries = await _storageService.loadEntries();
      _updateMoonPhase();
      
      // Load weather in background
      _loadWeather();
    } catch (e) {
      _error = 'Failed to load data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Loads weather data from API.
  Future<void> _loadWeather() async {
    _isLoadingWeather = true;
    notifyListeners();

    try {
      _weatherData = await _weatherService.getCurrentWeather();
    } catch (e) {
      // Weather fetch failed silently - UI will show default values
    } finally {
      _isLoadingWeather = false;
      notifyListeners();
    }
  }

  /// Adds a new catch entry.
  Future<bool> addEntry({
    required DateTime date,
    required String location,
    required String species,
    required double weight,
  }) async {
    final entry = CatchEntry(
      id: _uuid.v4(),
      date: date,
      location: location.trim(),
      species: species.trim(),
      weight: weight,
    );

    _entries.add(entry);
    notifyListeners();

    final success = await _storageService.saveEntries(_entries);
    if (!success) {
      // Rollback on failure
      _entries.remove(entry);
      _error = 'Failed to save entry';
      notifyListeners();
    }
    return success;
  }

  /// Deletes an entry by ID.
  Future<bool> deleteEntry(String id) async {
    final index = _entries.indexWhere((e) => e.id == id);
    if (index == -1) return false;

    final removed = _entries.removeAt(index);
    notifyListeners();

    final success = await _storageService.saveEntries(_entries);
    if (!success) {
      // Rollback on failure
      _entries.insert(index, removed);
      _error = 'Failed to delete entry';
      notifyListeners();
    }
    return success;
  }

  /// Refreshes weather and moon data.
  Future<void> refreshConditions() async {
    _updateMoonPhase();
    await _loadWeather();
  }

  /// Updates the moon phase based on current date.
  /// Uses a simple approximation (lunar cycle ~29.5 days).
  void _updateMoonPhase() {
    // Reference: Jan 11, 2024 was approximately a new moon
    final referenceDate = DateTime(2024, 1, 11);
    final daysSinceReference = DateTime.now().difference(referenceDate).inDays;
    
    // Lunar cycle is approximately 29.53 days
    const lunarCycle = 29.53;
    final daysIntoCycle = daysSinceReference % lunarCycle;
    
    // Divide cycle into 8 phases
    _moonPhase = ((daysIntoCycle / lunarCycle) * 8).floor() % 8;
  }

  /// Clears the current error.
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
