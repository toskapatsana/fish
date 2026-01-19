import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/catch_entry.dart';

/// Service for persisting catch entries to local storage.
/// 
/// Uses SharedPreferences for simple key-value storage.
/// All data is stored as JSON strings.
class StorageService {
  static const String _entriesKey = 'catch_entries';
  
  late SharedPreferences _prefs;
  bool _initialized = false;

  /// Initializes the storage service.
  /// Must be called before any other methods.
  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  /// Loads all catch entries from storage.
  /// Returns an empty list if no entries exist.
  Future<List<CatchEntry>> loadEntries() async {
    await _ensureInitialized();
    
    final String? jsonString = _prefs.getString(_entriesKey);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((json) => CatchEntry.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // If data is corrupted, return empty list
      // Error is silently handled - could add logging service in production
      return [];
    }
  }

  /// Saves all catch entries to storage.
  /// Overwrites any existing data.
  Future<bool> saveEntries(List<CatchEntry> entries) async {
    await _ensureInitialized();
    
    try {
      final String jsonString = jsonEncode(
        entries.map((e) => e.toJson()).toList(),
      );
      return await _prefs.setString(_entriesKey, jsonString);
    } catch (e) {
      // Error is silently handled - could add logging service in production
      return false;
    }
  }

  /// Clears all stored entries.
  Future<bool> clearEntries() async {
    await _ensureInitialized();
    return await _prefs.remove(_entriesKey);
  }

  /// Ensures the service is initialized before operations.
  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await init();
    }
  }
}
