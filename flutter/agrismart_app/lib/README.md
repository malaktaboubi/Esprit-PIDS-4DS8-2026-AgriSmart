# AgriSmart Flutter App - Clean Architecture

This Flutter application follows a feature-based clean architecture pattern, mirroring the backend microservices structure.

## Project Structure

```
lib/
├── main.dart                      # App entry point
├── core/                          # Shared code across features
│   ├── constants/                 # App-wide constants
│   ├── theme/                     # UI theming
│   ├── utils/                     # Utility functions
│   └── widgets/                   # Reusable widgets
│
└── features/                      # Feature modules (pillars)
    ├── crop_health/               # Crop Disease Detection 🌱
    │   ├── screens/               # UI screens
    │   │   └── home_screen.dart   # Main crop disease detection screen
    │   ├── services/              # Business logic
    │   │   └── classifier.dart    # TFLite ML model service
    │   └── models/                # Data models
    │
    ├── irrigation/                # Autonomous Irrigation 💧
    │   ├── screens/               # Irrigation monitoring UI
    │   ├── services/              # MQTT, AI agent, weather services
    │   └── models/                # Irrigation data models
    │
    ├── livestock/                 # Livestock Management 🐄
    │   ├── screens/               # Livestock tracking UI
    │   ├── services/              # Voice assistant, LLM services
    │   └── models/                # Livestock data models
    │
    └── satellite/                 # Satellite Crop Analysis 🛰️
        ├── screens/               # Satellite imagery UI
        ├── services/              # Sentinel-2 API, NDVI processing
        └── models/                # Spatial data models
```

## Architecture Principles

Each feature module is self-contained with:
- **Screens**: UI presentation layer
- **Services**: Business logic and external integrations
- **Models**: Data structures and entities

The `core` module contains shared functionality used across multiple features.

## Corresponding Backend Services

- `crop_health` ↔ `crop_health_service`
- `irrigation` ↔ `irrigation_service`
- `livestock` ↔ `livestock_service`
- `satellite` ↔ `satellite_service`
