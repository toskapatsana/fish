# Fishing Buddy 🎣

A lightweight, offline-first fishing log app for iOS built with Flutter.

## Features

### Home Screen
- **Current Date** - Displays today's date
- **Weather Info** - Shows mock weather conditions (temperature, conditions)
- **Moon Phase** - Calculates and displays current moon phase
- **Fishing Index** - A 0-100 score based on weather and moon conditions
- **Quick Stats** - Total catches and weight at a glance

### Fishing Log
- **Catch List** - View all your fishing catches, sorted by date
- **Swipe to Delete** - Remove entries with a simple swipe gesture
- **Summary Stats** - Total catches and cumulative weight

### Add New Catch
- **Date Picker** - iOS-style CupertinoDatePicker
- **Location** - Where you caught the fish
- **Species** - Type of fish caught
- **Weight** - Weight in kilograms

### Data Persistence
- All data stored locally using SharedPreferences
- Works completely offline
- Data persists between app launches

## Tech Stack

- **Flutter** (latest stable)
- **Provider** with ChangeNotifier for state management
- **SharedPreferences** for local storage
- **Cupertino Widgets** for iOS-native look and feel

## Project Structure

```
lib/
├── main.dart              # App entry point and configuration
├── models/
│   └── catch_entry.dart   # Data model for catch entries
├── providers/
│   └── fishing_provider.dart  # State management with ChangeNotifier
├── screens/
│   ├── home_screen.dart       # Main dashboard
│   ├── fishing_log_screen.dart # List of catches
│   └── add_entry_screen.dart   # Form to add new catch
└── services/
    └── storage_service.dart   # Local storage abstraction
```

## Getting Started

1. Ensure Flutter is installed
2. Clone this repository
3. Run `flutter pub get` to install dependencies
4. Run `flutter run` to launch the app

```bash
# If using FVM
fvm flutter pub get
fvm flutter run
```

## Requirements

- iOS 12.0 or later
- Flutter 3.x
- Dart 3.x

## Dependencies

- `provider` - State management
- `shared_preferences` - Local data persistence
- `uuid` - Unique ID generation
- `intl` - Date formatting
- `cupertino_icons` - iOS-style icons

## Design Decisions

- **iOS-first**: Uses Cupertino widgets throughout for native iOS feel
- **Offline-first**: No network required, all data stored locally
- **Simple architecture**: No over-engineering, just screens/providers/services
- **Portrait only**: Optimized for iPhone one-handed use
- **Dark mode ready**: Respects system appearance settings

## Mock Data

The weather and moon phase features use mock/calculated data:
- Weather conditions are hardcoded (would connect to API in production)
- Moon phase is calculated based on lunar cycle mathematics

## License

MIT
