import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/catch_entry.dart';
import '../services/storage_service.dart';
import '../services/weather_service.dart';
import '../services/moon_service.dart';

/// Provider for managing fishing data and state.
/// 
/// Handles all catch entries and provides real weather and moon data
/// for the home screen fishing index calculation.
class FishingProvider extends ChangeNotifier {
  final StorageService _storageService;
  final WeatherService _weatherService;
  final MoonService _moonService;
  final Uuid _uuid = const Uuid();

  List<CatchEntry> _entries = [];
  bool _isLoading = false;
  bool _isRefreshing = false;
  String? _error;

  // Weather data from API
  WeatherData? _weatherData;
  
  // Moon data from API
  MoonData? _moonData;

  // Fallback moon phase (calculated locally if API fails)
  int _fallbackMoonPhase = 0;

  FishingProvider({
    StorageService? storageService,
    WeatherService? weatherService,
    MoonService? moonService,
  })  : _storageService = storageService ?? StorageService(),
        _weatherService = weatherService ?? WeatherService(),
        _moonService = moonService ?? MoonService();

  // ============ Getters ============

  /// All catch entries, sorted by date (newest first).
  List<CatchEntry> get entries => List.unmodifiable(
    _entries..sort((a, b) => b.date.compareTo(a.date)),
  );

  /// Total number of entries.
  int get entryCount => _entries.length;

  /// Whether data is currently loading.
  bool get isLoading => _isLoading;

  /// Whether data is refreshing (pull-to-refresh).
  bool get isRefreshing => _isRefreshing;

  /// Current error message, if any.
  String? get error => _error;

  /// Whether we have weather data.
  bool get hasWeatherData => _weatherData != null;

  /// Whether we have moon data from API.
  bool get hasMoonData => _moonData != null;

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
  int get moonPhase => _moonData?.moonPhase ?? _fallbackMoonPhase;

  /// Moon phase name.
  String get moonPhaseName {
    if (_moonData != null) {
      return _moonData!.moonPhaseName;
    }
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
    return phases[_fallbackMoonPhase % 8];
  }

  /// Moon phase icon.
  String get moonPhaseIcon {
    if (_moonData != null) {
      return _moonData!.icon;
    }
    const icons = ['🌑', '🌒', '🌓', '🌔', '🌕', '🌖', '🌗', '🌘'];
    return icons[_fallbackMoonPhase % 8];
  }

  /// Moon illumination percentage (if available).
  double get moonIllumination => _moonData?.moonIllumination ?? 0;

  /// Calculates the "Fishing Index" (0-100).
  int get fishingIndex {
    // Moon phase score (0-40 points)
    final phase = moonPhase;
    int moonScore;
    if (phase == 0 || phase == 4) {
      moonScore = 40; // Best: New or Full moon
    } else if (phase == 2 || phase == 6) {
      moonScore = 25; // Moderate: Quarter moons
    } else {
      moonScore = 15; // Lower: Crescent/Gibbous
    }

    // Weather score (0-40 points)
    int weatherScore = 30;
    if (_weatherData != null) {
      final code = _weatherData!.weatherCode;
      if (code <= 3) {
        weatherScore = code == 3 ? 38 : 32;
      } else if (code <= 48) {
        weatherScore = 28;
      } else if (code <= 67) {
        weatherScore = 25;
      } else if (code <= 77) {
        weatherScore = 15;
      } else if (code <= 82) {
        weatherScore = 22;
      } else {
        weatherScore = 10;
      }
    }

    // Wind score (0-20 points)
    final wind = _weatherData?.windSpeed ?? 10;
    int windScore;
    if (wind >= 5 && wind <= 15) {
      windScore = 20;
    } else if (wind < 5) {
      windScore = 15;
    } else if (wind <= 25) {
      windScore = 10;
    } else {
      windScore = 5;
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

  /// Initializes the provider by loading stored entries and fetching data.
  Future<void> init() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _storageService.init();
      _entries = await _storageService.loadEntries();
      _calculateFallbackMoonPhase();
      
      // Load weather and moon in parallel (background)
      _loadAllData();
    } catch (e) {
      _error = 'Failed to load data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Loads all external data (weather and moon).
  Future<void> _loadAllData() async {
    // Fetch weather and moon data in parallel
    final results = await Future.wait([
      _weatherService.getCurrentWeather(),
      _moonService.getMoonDataDefault(),
    ]);

    _weatherData = results[0] as WeatherData?;
    _moonData = results[1] as MoonData?;
    
    notifyListeners();
  }

  /// Refreshes all data (called by pull-to-refresh).
  Future<void> refreshConditions() async {
    _isRefreshing = true;
    notifyListeners();

    try {
      _calculateFallbackMoonPhase();
      await _loadAllData();
    } finally {
      _isRefreshing = false;
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
      _entries.insert(index, removed);
      _error = 'Failed to delete entry';
      notifyListeners();
    }
    return success;
  }

  /// Calculates fallback moon phase locally.
  void _calculateFallbackMoonPhase() {
    final referenceDate = DateTime(2024, 1, 11);
    final daysSinceReference = DateTime.now().difference(referenceDate).inDays;
    const lunarCycle = 29.53;
    final daysIntoCycle = daysSinceReference % lunarCycle;
    _fallbackMoonPhase = ((daysIntoCycle / lunarCycle) * 8).floor() % 8;
  }

  /// Clears the current error.
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
