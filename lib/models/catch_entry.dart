import 'dart:convert';

/// Represents a single fishing catch entry.
/// 
/// Contains all the information about a catch including
/// when, where, what species, and weight.
class CatchEntry {
  final String id;
  final DateTime date;
  final String location;
  final String species;
  final double weight; // in kilograms

  CatchEntry({
    required this.id,
    required this.date,
    required this.location,
    required this.species,
    required this.weight,
  });

  /// Creates a CatchEntry from a JSON map.
  factory CatchEntry.fromJson(Map<String, dynamic> json) {
    return CatchEntry(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      location: json['location'] as String,
      species: json['species'] as String,
      weight: (json['weight'] as num).toDouble(),
    );
  }

  /// Converts this CatchEntry to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'location': location,
      'species': species,
      'weight': weight,
    };
  }

  /// Creates a copy of this entry with optional field overrides.
  CatchEntry copyWith({
    String? id,
    DateTime? date,
    String? location,
    String? species,
    double? weight,
  }) {
    return CatchEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      location: location ?? this.location,
      species: species ?? this.species,
      weight: weight ?? this.weight,
    );
  }

  @override
  String toString() {
    return 'CatchEntry(id: $id, date: $date, location: $location, species: $species, weight: ${weight}kg)';
  }
}

/// Helper extension for encoding/decoding lists of CatchEntry.
extension CatchEntryListExtension on List<CatchEntry> {
  /// Converts list to JSON string for storage.
  String toJsonString() {
    return jsonEncode(map((e) => e.toJson()).toList());
  }

  /// Creates a list from JSON string.
  static List<CatchEntry> fromJsonString(String jsonString) {
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => CatchEntry.fromJson(json)).toList();
  }
}
