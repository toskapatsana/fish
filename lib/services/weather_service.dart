import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

/// Weather data model from Open-Meteo API.
class WeatherData {
  final double temperature;
  final int weatherCode;
  final String condition;
  final int humidity;
  final double windSpeed;
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  WeatherData({
    required this.temperature,
    required this.weatherCode,
    required this.condition,
    required this.humidity,
    required this.windSpeed,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  /// Creates WeatherData from Open-Meteo API response.
  factory WeatherData.fromJson(Map<String, dynamic> json, double lat, double lon) {
    final current = json['current'] as Map<String, dynamic>;
    final weatherCode = current['weather_code'] as int;
    
    return WeatherData(
      temperature: (current['temperature_2m'] as num).toDouble(),
      weatherCode: weatherCode,
      condition: _getConditionFromCode(weatherCode),
      humidity: (current['relative_humidity_2m'] as num).toInt(),
      windSpeed: (current['wind_speed_10m'] as num).toDouble(),
      latitude: lat,
      longitude: lon,
      timestamp: DateTime.now(),
    );
  }

  /// Converts WMO weather code to human-readable condition.
  /// https://open-meteo.com/en/docs#weathervariables
  static String _getConditionFromCode(int code) {
    switch (code) {
      case 0:
        return 'Clear Sky';
      case 1:
        return 'Mainly Clear';
      case 2:
        return 'Partly Cloudy';
      case 3:
        return 'Overcast';
      case 45:
      case 48:
        return 'Foggy';
      case 51:
      case 53:
      case 55:
        return 'Drizzle';
      case 56:
      case 57:
        return 'Freezing Drizzle';
      case 61:
      case 63:
      case 65:
        return 'Rain';
      case 66:
      case 67:
        return 'Freezing Rain';
      case 71:
      case 73:
      case 75:
        return 'Snow';
      case 77:
        return 'Snow Grains';
      case 80:
      case 81:
      case 82:
        return 'Rain Showers';
      case 85:
      case 86:
        return 'Snow Showers';
      case 95:
        return 'Thunderstorm';
      case 96:
      case 99:
        return 'Thunderstorm with Hail';
      default:
        return 'Unknown';
    }
  }

  /// Gets weather icon based on weather code.
  String get icon {
    if (weatherCode == 0) return '☀️';
    if (weatherCode <= 3) return '⛅';
    if (weatherCode <= 48) return '🌫️';
    if (weatherCode <= 57) return '🌧️';
    if (weatherCode <= 67) return '🌧️';
    if (weatherCode <= 77) return '❄️';
    if (weatherCode <= 82) return '🌦️';
    if (weatherCode <= 86) return '🌨️';
    if (weatherCode >= 95) return '⛈️';
    return '🌤️';
  }
}

/// Service for fetching weather data from Open-Meteo API.
/// 
/// Open-Meteo is a free, open-source weather API that doesn't require
/// an API key. It provides accurate weather data worldwide.
class WeatherService {
  static const String _baseUrl = 'https://api.open-meteo.com/v1/forecast';
  
  // Default location (Tokyo, Japan) - used when location permission denied
  static const double _defaultLat = 35.6762;
  static const double _defaultLon = 139.6503;

  /// Fetches current weather data.
  /// 
  /// First tries to get user's location, falls back to default if denied.
  Future<WeatherData?> getCurrentWeather() async {
    try {
      // Try to get current position
      final position = await _getCurrentPosition();
      final lat = position?.latitude ?? _defaultLat;
      final lon = position?.longitude ?? _defaultLon;

      return await _fetchWeather(lat, lon);
    } catch (e) {
      // If location fails, use default
      return await _fetchWeather(_defaultLat, _defaultLon);
    }
  }

  /// Fetches weather for specific coordinates.
  Future<WeatherData?> getWeatherForLocation(double lat, double lon) async {
    return await _fetchWeather(lat, lon);
  }

  /// Gets current device position.
  Future<Position?> _getCurrentPosition() async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    // Check permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    // Get position
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.low, // Low accuracy is fine for weather
        timeLimit: Duration(seconds: 10),
      ),
    );
  }

  /// Fetches weather data from Open-Meteo API.
  Future<WeatherData?> _fetchWeather(double lat, double lon) async {
    try {
      final uri = Uri.parse(_baseUrl).replace(
        queryParameters: {
          'latitude': lat.toString(),
          'longitude': lon.toString(),
          'current': 'temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m',
          'timezone': 'auto',
        },
      );

      final response = await http.get(uri).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return WeatherData.fromJson(json, lat, lon);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
