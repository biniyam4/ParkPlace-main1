# ParkPlace

A Flutter-based parking app where users can either find and book parking spaces or rent out their own property for parking.

## Project Overview

**Framework:** Flutter (compiled to web)  
**Language:** Dart  
**Backend:** Firebase (Firestore + Auth)  
**Served by:** Node.js static file server (`serve.js`)

## Architecture

- `lib/` — Flutter Dart source code
  - `screens/` — UI screens (login, dashboard, booking, etc.)
  - `models/` — Data models
  - `services/` — Firebase service logic
  - `widgets/` — Reusable UI widgets
  - `shared/` — Shared components (loading spinner, etc.)
  - `utilities/` — Helper utilities
  - `Location/` — Google Maps / location logic
- `web/` — Flutter web template (index.html)
- `build/web/` — Compiled Flutter web output (served at runtime)
- `serve.js` — Node.js HTTP server to serve the built Flutter web app
- `android/` — Android-specific config (including google-services.json)
- `assets/` — Static assets (images)

## How to Run

```bash
# Build the Flutter web app
flutter build web --release

# Start the web server (serves build/web on port 5000)
node serve.js
```

The workflow runs `node serve.js` which serves the pre-built Flutter web output on port 5000.

## Build Notes

- Flutter 3.32.0 is installed via Nix
- The app uses Firebase (project: `car-parking-system-42fc0`)
- Firebase web auth is configured via `webFirebaseOptions` in `lib/main.dart`
- The `primary:` ElevatedButton parameter was updated to `backgroundColor:` for Flutter 3.32 compatibility
- Packages updated to be compatible with Flutter 3.32: `carousel_slider ^5.0.0`, `url_launcher ^6.3.0`, `image_picker ^1.1.2`
- `flutter_google_places` was removed (unused + incompatible with newer http package)

## User Preferences

- Keep code structure consistent with existing Flutter conventions
