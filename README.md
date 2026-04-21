# Dopply V2

A Flutter-based mobile health monitoring application that enables patients to monitor their vital signs and share health data with doctors.

## Features

- **User Authentication** - Login, registration, and profile creation
- **Health Monitoring** - Real-time vital signs monitoring via Bluetooth Low Energy (BLE)
- **Dashboard** - Overview for patients, doctors, and administrators
- **Medical Records** - View and manage health records with PDF export
- **Notifications** - Push notifications via Firebase Cloud Messaging
- **Multi-language Support** - English and Indonesian localization
- **Offline Support** - Local data storage with Hive
- **OTA Updates** - In-app updates

## Tech Stack

- **Framework**: Flutter 3.10+
- **State Management**: Riverpod
- **Navigation**: Go Router
- **Backend**: Supabase
- **Push Notifications**: Firebase Cloud Messaging (FCM)
- **Bluetooth**: flutter_blue_plus
- **Local Storage**: Hive
- **Charts**: fl_chart

## Prerequisites

- Flutter SDK 3.10+
- Android SDK / Xcode (for iOS)
- Supabase project
- Firebase project (for push notifications)

## Installation

```bash
# Clone the repository
git clone <repository-url>
cd dopply-v2

# Install dependencies
flutter pub get

# Run the app
flutter run
```

## Architecture

This project follows a **Clean Architecture** pattern with separation of concerns:

```
lib/
├── main.dart                              # App entry point
├── app.dart                               # App configuration
├── src/
│   ├── core/                              # Core utilities (shared across app)
│   │   ├── error/                         # Error handling (exceptions, failures)
│   │   ├── providers/                     # Global providers (Riverpod)
│   │   ├── router.dart                    # Navigation (Go Router)
│   │   ├── services/                      # Core services (FCM, updates, offline)
│   │   ├── theme/                         # App theming (colors, typography, styles)
│   │   └── utils/                         # Utilities (BPM classifier, etc.)
│   ├── features/                          # Feature modules (Clean Architecture)
│   │   ├── auth/
│   │   │   ├── data/                      # Data layer (repositories)
│   │   │   └── presentation/              # UI layer (screens, widgets)
│   │   ├── dashboard/
│   │   │   ├── data/
│   │   │   └── presentation/              # Includes sub-views (admin_views, doctor_views)
│   │   ├── monitoring/
│   │   │   ├── data/                      # BLE repository
│   │   │   └── presentation/              # Screens, controllers, state
│   │   ├── notifications/
│   │   │   ├── data/
│   │   │   └── presentation/
│   │   ├── onboarding/
│   │   │   ├── data/
│   │   │   └── presentation/
│   │   ├── profile/
│   │   │   ├── data/
│   │   │   └── presentation/
│   │   ├── records/
│   │   │   ├── data/
│   │   │   └── presentation/              # Includes application layer (pdf_service)
│   │   └── settings/
│   │       ├── data/
│   │       └── presentation/
│   └── shared/                            # Shared widgets
│       └── widgets/                       # Reusable components (medical, feedback, animations)
└── generated/                             # Generated code (localization)
```

### Architecture Layers

Each feature module follows a layered structure:

- **`data/`** - Contains repositories that handle data operations (API calls, local storage)
- **`presentation/`** - Contains UI components (screens, widgets, controllers)
- **`application/`** (optional) - Contains business logic services (e.g., PDF generation in records)

## Configuration

### Environment Variables

Create a `.env` file in the root directory:

```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

### Firebase Setup

1. Add `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
2. Configure Firebase Cloud Messaging in Firebase Console

## Build

```bash
# Debug build
flutter build apk --debug

# Release build
flutter build apk --release
```

## Dependencies

- `supabase_flutter` - Backend database and auth
- `flutter_riverpod` - State management
- `go_router` - Declarative routing
- `flutter_blue_plus` - BLE communication
- `firebase_messaging` - Push notifications
- `hive_flutter` - Local storage
- `fl_chart` - Data visualization
- `pdf` & `printing` - PDF generation

## License

Private - All rights reserved
