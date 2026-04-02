# QR Scanner Pro Max

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Android](https://img.shields.io/badge/Android-API%2021+-3DDC84?style=for-the-badge&logo=android&logoColor=white)
![iOS](https://img.shields.io/badge/iOS-12+-000000?style=for-the-badge&logo=apple&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

**A production-grade QR code generator and scanner app built with Flutter.**

*Developed by: THE GREAT*
*Made with ❤️ in India*

</div>

---

## Overview

**QR Scanner Pro Max** is a fully featured, production-ready Flutter mobile application for Android and iOS. It allows users to scan any QR code instantly using the device camera, generate custom QR codes from text or URLs, manage scan history, save generated codes, and customize the app experience through settings — all in a clean, minimal, dark-themed UI.

---

## Features

### Scanner
- Real-time QR code detection using the device camera
- Auto-detection with continuous scanning support
- Flashlight / torch toggle
- Frame alignment overlay with corner accents
- Content-type detection: URL, Email, Phone, Wi-Fi, Text
- Action handler: Open URL, Copy, Scan Again
- Conditional history saving based on user preference
- Full camera permission handling with graceful fallbacks

### Generator
- Input text or URL to generate QR codes instantly
- Live QR preview with content-type badge
- Save to My QRs (in-app storage)
- Share QR image via any app (WhatsApp, Email, etc.)
- Save QR image to device gallery
- Copy data to clipboard
- Duplicate detection

### History
- Full list of all scanned QR codes
- Scanned / Favorites tab toggle
- Live search and filter
- Item count display
- Mark items as favorites
- Delete individual items
- Clear all scanned history

### My QRs
- All user-generated QR codes in one place
- Tap any item to view full QR with share and save options
- Delete and favorite management
- Empty state with Create QR shortcut

### Settings
- Light / Dark / System theme toggle
- Save Scan History on/off toggle
- All preferences persisted across sessions

### Splash Screen
- Indian flag tricolor gradient background
- Animated fade-in with smooth progress bar
- Auto-navigation after loading completes

---

## Screenshots

> Screenshots coming soon.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter / Dart |
| State Management | Provider |
| QR Scanning | mobile_scanner |
| QR Generation | qr_flutter |
| Local Storage | shared_preferences |
| Permissions | permission_handler |
| Connectivity | connectivity_plus |
| Sharing | share_plus |
| File System | path_provider |
| URL Handling | url_launcher |

---

## Project Structure

The project follows a **feature-based clean architecture** with three top-level layers:

```
lib/
├── core/          # App-wide services, constants, and utilities
├── features/      # One folder per screen, fully isolated
│   ├── home/
│   ├── scanner/
│   ├── generator/
│   ├── history/
│   ├── my_qr/
│   ├── settings/
│   └── splash/
└── shared/        # Reusable widgets and data models
```

---

## Getting Started

### Prerequisites

- Flutter SDK (latest stable)
- Dart SDK (latest stable)
- Android Studio or VS Code
- Android device or emulator (API 21+)
- iOS device or simulator (iOS 12+)

### Installation

```bash
# 1. Clone the repository
git clone <your-repo-url>

# 2. Navigate to the project directory
cd qr_generator_scanner

# 3. Install dependencies
flutter pub get

# 4. Run the app
flutter run
```

### Build for Release

```bash
# Android APK
flutter build apk --release

# Android App Bundle (Play Store)
flutter build appbundle --release

# iOS
flutter build ios --release
```

---

## Permissions

The app requests only the permissions it needs:

### Android
| Permission | Purpose |
|---|---|
| Camera | QR code scanning |
| Internet | Opening scanned URLs |
| Network State | Offline detection |
| Storage / Media | Save QR images to gallery |
| Vibrate | Scan feedback |

### iOS
| Permission | Purpose |
|---|---|
| Camera | QR code scanning |
| Photo Library | Save QR images to Photos |

---

## Architecture

The app follows a **feature-based clean architecture**:

- **`core/`** — app-wide constants, services, and utilities shared across all features
- **`features/`** — each screen is fully isolated in its own folder
- **`shared/`** — reusable widgets and data models used across multiple features
- **State management** — Provider with ChangeNotifier for reactive UI updates
- **Persistence** — local storage for QR records and settings, with corrupted-data recovery

---

## Key Design Decisions

- **Camera lifecycle management** — the scanner screen remounts fresh on every visit so the camera initialises correctly
- **Single animation timeline** — the theme toggle drives all animated values from one controller, ensuring zero frame drift
- **Optimistic UI updates** — theme changes are reflected instantly before being persisted to disk
- **QR image capture** — generated QR codes are rendered to PNG for share and gallery save
- **Reusable permission flow** — a shared mixin handles the full storage permission lifecycle across all screens that need gallery access
- **Theme-safe QR rendering** — QR codes always render with correct contrast regardless of the active theme

---

## Removing the Splash Screen

The splash screen is fully modular and can be removed in 3 steps:

1. Delete `lib/features/splash/splash_screen.dart`
2. In `main.dart`, update the initial `home` widget to `MainShell`
3. Remove the splash screen import

---

## Security

- No API keys, tokens, or credentials are stored in this repository
- All data is stored locally on the device only
- No analytics, tracking, or third-party data collection
- Camera and storage permissions are requested only when needed, with clear user-facing rationale

---

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

---

## License

This project is licensed under the MIT License.

---

<div align="center">

**QR Scanner Pro Max** — Built with Flutter

*Developed by: THE GREAT*
*Made with ❤️ in India*

</div>
