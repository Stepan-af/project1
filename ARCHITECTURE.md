# Journey Focus - Architecture & Folder Structure

## Architecture Overview

This app follows a **Feature-First Architecture** with clear separation of concerns. The architecture is designed to be:
- Simple and maintainable (MVP level)
- Modular and testable
- Deterministic and predictable
- No external dependencies beyond open-source libraries

## Architecture Layers

### 1. **Presentation Layer** (`lib/presentation/`)
Responsible for UI and user interactions.
- **Screens**: Full-screen UI components
- **Widgets**: Reusable UI components
- **State Management**: Using Provider/Riverpod for state (to be decided)

### 2. **Domain Layer** (`lib/domain/`)
Core business logic and entities.
- **Models**: Data models (Route, Session, Statistics)
- **Repositories**: Abstract interfaces for data access
- **Services**: Business logic (SessionEngine, PolylineCalculator)

### 3. **Data Layer** (`lib/data/`)
Data persistence and external data sources.
- **Repositories**: Concrete implementations
- **Local Storage**: SQLite/Hive for persistence
- **Data Sources**: Route data (JSON assets)

### 4. **Core Layer** (`lib/core/`)
Shared utilities and constants.
- **Constants**: App-wide constants
- **Utils**: Helper functions
- **Theme**: App theme and styling
- **Extensions**: Dart extensions

## Folder Structure

```
lib/
├── main.dart                          # App entry point
│
├── core/                              # Core utilities
│   ├── constants/
│   │   ├── app_constants.dart        # App-wide constants
│   │   └── storage_keys.dart         # Storage key constants
│   ├── theme/
│   │   ├── app_theme.dart            # Theme configuration
│   │   ├── app_colors.dart           # Color palette
│   │   └── app_text_styles.dart      # Typography styles
│   ├── utils/
│   │   ├── date_utils.dart           # Date/time utilities
│   │   ├── polyline_utils.dart       # Polyline calculations
│   │   └── time_utils.dart           # Time formatting utilities
│   └── extensions/
│       └── datetime_extensions.dart   # DateTime extensions
│
├── data/                              # Data layer
│   ├── models/
│   │   ├── route_model.dart          # Route data model
│   │   ├── session_model.dart        # Session data model
│   │   └── statistics_model.dart     # Statistics data model
│   ├── repositories/
│   │   ├── route_repository.dart     # Route data access
│   │   ├── session_repository.dart   # Session persistence
│   │   └── statistics_repository.dart # Statistics calculations
│   ├── local_storage/
│   │   ├── storage_service.dart      # Abstract storage interface
│   │   └── sqlite_storage.dart       # SQLite implementation
│   └── data_sources/
│       └── routes_data_source.dart   # Predefined routes (JSON)
│
├── domain/                            # Domain layer
│   ├── models/
│   │   ├── route.dart                # Route entity
│   │   ├── session.dart              # Session entity
│   │   ├── transport_type.dart       # Transport enum
│   │   └── statistics.dart           # Statistics entity
│   ├── repositories/
│   │   ├── route_repository_interface.dart
│   │   ├── session_repository_interface.dart
│   │   └── statistics_repository_interface.dart
│   └── services/
│       ├── session_engine.dart        # Session timer logic
│       └── polyline_calculator.dart  # Polyline interpolation
│
├── presentation/                      # Presentation layer
│   ├── screens/
│   │   ├── routes_list/
│   │   │   ├── routes_list_screen.dart
│   │   │   └── routes_list_provider.dart
│   │   ├── route_details/
│   │   │   ├── route_details_screen.dart
│   │   │   └── route_details_provider.dart
│   │   ├── session/
│   │   │   ├── session_screen.dart
│   │   │   └── session_provider.dart
│   │   ├── arrival/
│   │   │   ├── arrival_screen.dart
│   │   │   └── arrival_provider.dart
│   │   └── statistics/
│   │       ├── statistics_screen.dart
│   │       └── statistics_provider.dart
│   ├── widgets/
│   │   ├── common/
│   │   │   ├── app_button.dart       # Reusable button
│   │   │   ├── route_card.dart       # Route list item
│   │   │   ├── transport_icon.dart   # Transport type icon
│   │   │   └── progress_bar.dart     # Progress indicator
│   │   ├── map/
│   │   │   ├── journey_map.dart      # MapLibre map widget
│   │   │   ├── route_polyline.dart   # Polyline renderer
│   │   │   └── journey_marker.dart   # Animated marker
│   │   └── session/
│   │       ├── countdown_timer.dart  # Timer display
│   │       └── session_controls.dart # Pause/Resume buttons
│   └── providers/
│       └── app_providers.dart        # Provider setup
│
└── services/                          # App-level services
    ├── share_service.dart             # PNG generation & sharing
    └── app_lifecycle_service.dart     # Lifecycle handling

assets/
├── routes/
│   └── routes.json                   # Predefined routes data
└── images/
    └── (icons if needed)

test/                                  # Tests (to be added later)
├── unit/
├── widget/
└── integration/
```

## Layer Responsibilities

### Core Layer
- **Constants**: App-wide magic numbers, durations, etc.
- **Theme**: Color palette, typography, spacing
- **Utils**: Pure functions for calculations, formatting
- **Extensions**: Convenience methods on built-in types

### Data Layer
- **Models**: JSON serializable data models
- **Repositories**: Concrete implementations of domain interfaces
- **Local Storage**: SQLite for sessions, JSON for routes
- **Data Sources**: Loading predefined routes from assets

### Domain Layer
- **Models**: Business entities (immutable, no serialization logic)
- **Repositories**: Abstract interfaces (contracts)
- **Services**: Business logic:
  - `SessionEngine`: Timer logic, pause/resume, state restoration
  - `PolylineCalculator`: Interpolate marker position along polyline

### Presentation Layer
- **Screens**: Full-screen UI components
- **Widgets**: Reusable UI components
- **Providers**: State management (using Provider package)

## Key Design Decisions

### 1. **State Management: Provider**
- Simple, built-in Flutter solution
- No external dependencies beyond `provider` package
- Sufficient for MVP scope

### 2. **Local Storage: SQLite (via `sqflite`)**
- Reliable persistence for sessions
- Supports queries for statistics
- Open-source and well-maintained

### 3. **Routes Data: JSON Assets**
- Predefined routes stored as JSON in `assets/routes/`
- Loaded at app startup
- No runtime API calls

### 4. **Map: MapLibre GL**
- Using `maplibre_gl` package (open-source)
- Custom polyline and marker rendering
- No Mapbox/Google Maps dependencies

### 5. **Session Engine: Timestamp-Based**
- Uses `DateTime.now()` for all time calculations
- Stores `startedAt` timestamp
- Calculates remaining time = `plannedDuration - (now - startedAt)`
- Handles app restart by recalculating from stored timestamp

### 6. **Polyline Animation: Precomputed Distances**
- Precompute cumulative distances along polyline
- Progress = `elapsedSeconds / plannedDurationSeconds`
- Interpolate position based on progress
- Smooth marker updates (e.g., every 100ms)

## Data Flow

1. **Routes List**:
   - Load routes from JSON → Display in list → Filter/Search

2. **Route Details**:
   - Show route on map → Draw polyline → User taps "Start Journey"

3. **Session**:
   - Create session with `startedAt` timestamp
   - Timer calculates remaining time from timestamp
   - Marker position updates based on progress
   - State persists to SQLite

4. **Arrival**:
   - Session completes → Calculate statistics → Show arrival screen

5. **Statistics**:
   - Query sessions from SQLite → Calculate metrics → Display

## Dependencies (to be added to `pubspec.yaml`)

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  provider: ^6.1.1

  # Local Storage
  sqflite: ^2.3.0
  path: ^1.8.3

  # Maps
  maplibre_gl: ^0.16.0

  # JSON
  json_annotation: ^4.8.1

  # Share
  share_plus: ^7.2.1
  image: ^4.1.3  # For PNG generation

  # Utils
  intl: ^0.18.1  # Date/time formatting
```

## Next Steps (After Approval)

1. Initialize Flutter project structure
2. Add dependencies to `pubspec.yaml`
3. Create folder structure
4. Implement data models
5. Set up local storage
6. Implement core services

---

**Status**: Architecture proposal ready for review.
**Next**: Wait for approval before proceeding to Step 2 (Data & Storage).
