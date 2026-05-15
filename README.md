# 🕌 Mosques App

<p align="center">
  <a href="https://flutter.dev/">
    <img src="https://img.shields.io/badge/Flutter-3.22+-02569B?logo=flutter&logoColor=white" alt="Flutter Version">
  </a>
  <a href="https://dart.dev/">
    <img src="https://img.shields.io/badge/Dart-3.8+-0175C2?logo=dart&logoColor=white" alt="Dart Version">
  </a>
  <a href="LICENSE">
    <img src="https://img.shields.io/badge/License-MIT-green.svg" alt="License">
  </a>
  <a href="https://github.com/aaldawsari/mosques_app/releases">
    <img src="https://img.shields.io/badge/Platform-Android%20|%20iOS%20|%20Web-lightgrey" alt="Platform">
  </a>
</p>

---

## 📱 Description

**Mosques App** is a feature-rich Flutter mobile application that helps Muslims find nearby mosques, calculate accurate prayer times (Salah), and stay connected to Islamic prayer schedules. The app provides real-time Azan (call to prayer) notifications, supports bilingual interface (Arabic & English), and includes location-based mosque discovery.

Whether you're traveling or at home, this app ensures you never miss a prayer time with accurate calculations based on your location and Islamic calculation methods.

---

## ✨ Key Features

🕌 **Prayer Times Calculation**
- Accurate offline prayer time calculations using the [Adhan Dart](https://pub.dev/packages/adhan_dart) library
- Multiple calculation methods support (Muslim World League, Egyptian General Authority, ISNA, etc.)
- Support for different Madhabs (Islamic schools) - Hanafi and Shafi'i
- Real-time timezone-aware calculations

📍 **Location Services**
- GPS-based location detection
- Search and change mosque location on-demand
- Support for multiple coordinate-based calculations
- Address reverse geocoding and formatting

🔔 **Smart Notifications**
- Push notifications for each prayer time (Azan)
- Background service using WorkManager for reliable notifications
- Timezone-aware notification scheduling
- Customizable notification settings

⭐ **Favorites Management**
- Save favorite mosques locally
- Quick access to frequently visited locations
- Local persistence using Hive database
- Easy add/remove functionality

🌍 **Bilingual Support**
- Full Arabic (العربية) and English interface
- RTL (Right-to-Left) support for Arabic text
- Easy locale switching without app restart
- Translation files for all UI elements

🎨 **Modern UI/UX**
- Responsive design using ScreenUtil for all screen sizes
- Dark and light theme support
- Smooth animations and transitions
- Professional Material Design 3 interface
- Cached network images for better performance

🔄 **State Management**
- BLoC/Cubit pattern for scalable state management
- Proper separation of concerns using Clean Architecture
- Easy testing and debugging with BLoC Observer

🌙 **Background Processing**
- WorkManager for background prayer time updates
- Service integration for continuous operation
- Proper lifecycle management

---

## 🛠️ Tech Stack

### Architecture
- **Clean Architecture** with BLoC/Cubit pattern
- **MVVM** (Model-View-ViewModel) with Cubit
- **Repository Pattern** for data layer abstraction
- **Dependency Injection** ready structure

### Core Dependencies
| Package | Version | Purpose |
|---------|---------|---------|
| **flutter_bloc** | 9.1.1 | State management |
| **adhan_dart** | 1.2.0 | Prayer time calculations |
| **geolocator** | 14.0.2 | Location services |
| **geocoding** | 4.0.0 | Address lookup |
| **flutter_local_notifications** | 18.0.1 | Push notifications |
| **workmanager** | 0.9.0 | Background tasks |
| **hive_flutter** | 1.1.0 | Local data persistence |
| **easy_localization** | 3.0.7 | Multi-language support |
| **supabase_flutter** | 2.12.4 | Backend & authentication |
| **dio** | 5.9.2 | HTTP client |
| **flutter_screenutil** | 5.9.3 | Responsive design |
| **google_nav_bar** | 5.0.7 | Custom navigation |

### Development Tools
- **flutter_launcher_icons** - App icon generation
- **flutter_native_splash** - Splash screen
- **flutter_lints** - Code analysis
- **flutter_test** - Unit & widget testing

---

## 📋 Requirements

- **Flutter SDK**: 3.22 or higher
- **Dart SDK**: 3.8 or higher
- **Minimum Android**: API 21 (Android 5.0)
- **Minimum iOS**: 11.0
- **Device Permissions Required**:
  - Location (for GPS-based prayer times)
  - Notifications (for Azan alerts)
  - Post Notifications (Android 13+)

---

## 🚀 Getting Started

### 1️⃣ Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/mosques_app.git
cd mosques_app

# Get Flutter and activate it
flutter pub get

# Generate code (if needed for Hive, etc.)
flutter pub run build_runner build --delete-conflicting-outputs

# Run on connected device or emulator
flutter run
```

### 2️⃣ Run on Specific Device

```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device_id>
```

### 3️⃣ Run with Flavor (if configured)

```bash
flutter run --flavor development -t lib/main.dart
```

---

## 📦 Building Release APK

### Standard Release APK

```bash
# Build release APK for all ABIs
flutter build apk --release

# Output location: build/app/outputs/flutter-apk/app-release.apk
```

### Split APK Per ABI (Recommended for Smaller Downloads)

```bash
# Build split APKs for different architectures
flutter build apk --release --split-per-abi

# Output location: build/app/outputs/flutter-apk/
# Files:
# - app-armeabi-v7a-release.apk      (32-bit ARM, smallest, older devices)
# - app-arm64-v8a-release.apk         (64-bit ARM, modern Android devices)
# - app-x86_64-release.apk            (64-bit Intel, emulators)
```

### App Bundle (AAB) for Play Store

```bash
# Build app bundle
flutter build appbundle --release

# Output location: build/app/outputs/bundle/release/app-release.aab
```

### Build Flags Explained

| Flag | Purpose |
|------|---------|
| `--release` | Optimized production build, disabled debugging |
| `--split-per-abi` | Separate APK per device architecture |
| `--obfuscate` | Code obfuscation for security |
| `--split-debug-info` | Split debug symbols for smaller build |

---

## 📁 Project Structure

```
mosques_app/
├── lib/
│   ├── main.dart                          # App entry point
│   ├── app.dart                           # App configuration
│   ├── app_bloc_observer.dart             # BLoC observation
│   │
│   ├── core/
│   │   ├── constants/                     # App constants
│   │   ├── cubit/                         # Core cubits (Theme, Time Format)
│   │   ├── data/                          # Hive models, adapters
│   │   ├── errors/                        # Exception handling
│   │   ├── extensions/                    # Dart extensions
│   │   ├── functions/                     # Utility functions
│   │   ├── network/                       # Dio setup, API clients
│   │   ├── routing/                       # Navigation & routes
│   │   ├── services/                      # Prayer calculation, notifications
│   │   ├── theme/                         # App theme & colors
│   │   ├── utils/                         # Geolocation service
│   │   └── widgets/                       # Reusable widgets
│   │
│   └── features/
│       ├── onboarding/                    # User onboarding screens
│       ├── home/                          # Prayer times display
│       │   ├── model/                     # Data models & repositories
│       │   ├── view/cubit/                # State management
│       │   └── view/pages/                # UI screens
│       ├── prayer_times/                  # Prayer details & history
│       ├── mosque_search/                 # Search nearby mosques
│       ├── mosque_details/                # Mosque information
│       ├── favorite/                      # Saved mosques
│       ├── bottom_nav/                    # Navigation management
│       └── more/                          # Settings & preferences
│
├── assets/
│   ├── images/                            # App images & icons
│   ├── fonts/                             # Custom fonts (IBM Plex Sans Arabic)
│   ├── calls/                             # Azan audio files
│   └── translations/
│       ├── en.json                        # English translations
│       └── ar.json                        # Arabic translations
│
├── android/                               # Android native code
├── ios/                                   # iOS native code
├── pubspec.yaml                           # Dependencies
└── analysis_options.yaml                  # Lint rules
```

---

## 🔐 Environment Variables

### Location-Based Services

The app uses **Geolocator** for GPS services (no API key needed for basic functionality).

### Optional: Google Maps Integration

If you plan to add Google Maps features:

1. **Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
```

2. **iOS** (`ios/Runner/GoogleService-Info.plist`):
```plist
<key>API_KEY</key>
<string>YOUR_GOOGLE_MAPS_API_KEY</string>
```

### Supabase Configuration

The app includes Supabase integration. Configure your backend:

```dart
// lib/core/network/supabase_helper.dart or similar
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',
  anonKey: 'YOUR_SUPABASE_ANON_KEY',
);
```

---

## 📝 Contributing

We welcome contributions! Please follow these guidelines:

### 1. Fork & Clone
```bash
git clone https://github.com/yourusername/mosques_app.git
cd mosques_app
```

### 2. Create Feature Branch
```bash
git checkout -b feature/your-feature-name
# or
git checkout -b fix/your-bug-fix
```

### 3. Code Standards
- Follow [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use meaningful variable and function names
- Add comments for complex logic
- Run `flutter analyze` before committing

```bash
# Check code quality
flutter analyze

# Format code
dart format lib/

# Run tests
flutter test
```

### 4. Commit & Push
```bash
git add .
git commit -m "feat: Add your feature description"
git push origin feature/your-feature-name
```

### 5. Create Pull Request
- Provide clear description of changes
- Reference related issues
- Ensure all tests pass

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

**Copyright © 2026 Ahmed A. Alawadhi**

You are free to:
- ✅ Use commercially and privately
- ✅ Modify the code
- ✅ Distribute the code
- ✅ Use for patent purposes

Under the condition of:
- 📋 License and copyright notice included

---

## 🙏 Acknowledgments

### Libraries & Frameworks
- **Flutter** & **Dart** - Amazing mobile development framework
- **BLoC Pattern** - Elegant state management solution
- **Adhan Dart** - Accurate prayer time calculations
- **Supabase** - Open-source backend platform

### Contributors
- Ahmed A. Alawadhi - Project Lead

### Special Thanks
- Islamic scholars for prayer time calculation methodology
- Flutter community for continuous support
- All contributors and testers

---

## 📞 Support

For issues, questions, or suggestions:

1. **repo**: [Ask Questions About](https://github.com/ahmedalaa-sw/mosques_app/)
3. **Email**: ahmedalaa10204@gmail.com

---

## 🔄 Version History

### v1.0.0 (2026-05-15)
- ✅ Initial release
- ✅ Prayer times calculation with Adhan Dart
- ✅ GPS-based location services
- ✅ Push notifications with WorkManager
- ✅ Bilingual support (AR/EN)
- ✅ Dark/Light theme
- ✅ Favorite mosques
- ✅ Offline functionality

---

<p align="center">
  Made with ❤️ for the Muslim community
</p>

<p align="center">
  <a href="#-mosques-app">Back to Top</a>
</p>
