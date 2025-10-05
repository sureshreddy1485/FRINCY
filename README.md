# Katha Ledger - Digital Ledger Application

A comprehensive cross-platform mobile application similar to Khatabook for managing customer transactions, built with Flutter.

## Features

### 🔐 User Authentication
- Email/Password authentication
- Phone number authentication with OTP
- PIN-based local authentication
- Biometric authentication (Fingerprint/Face ID)

### 👥 Customer Management
- Add, edit, and delete customers
- View customer transaction history
- Search, sort, and filter customer records
- Customer balance tracking

### 📊 Digital Ledger Features
- Record credit/debit transactions
- Automatic balance calculation
- Add transaction notes and attachments
- Daily, weekly, and monthly summaries
- Payment mode tracking

### 🔔 Reminders & Notifications
- Payment reminders via WhatsApp
- SMS notifications
- Push notifications
- Due date alerts

### 📈 Reports & Analytics
- Customer-wise balance summary
- Total credits/debits overview
- Period-based reports (daily, weekly, monthly, yearly)
- Export to PDF
- Share reports

### 💾 Data Storage & Sharing
- Local storage with SQLite
- AES encryption for data security
- Backup and restore functionality
- Share data via encrypted files
- Optional cloud backup (Firebase)

### 🎨 UI/UX
- Modern Material Design
- Dark and light mode support
- Clean and intuitive navigation
- Responsive design

### 🌍 Multi-language Support
- English
- Hindi (हिंदी)
- Tamil (தமிழ்)
- Telugu (తెలుగు)
- Kannada (ಕನ್ನಡ)
- Malayalam (മലയാളം)

### ⚡ Additional Features
- Offline-first architecture
- WhatsApp/SMS integration
- QR code sharing
- Business profile management

## Technical Stack

- **Framework**: Flutter 3.0+
- **State Management**: Provider
- **Local Database**: SQLite
- **Authentication**: Firebase Auth
- **Cloud Storage**: Firebase Storage
- **Notifications**: Firebase Cloud Messaging + Flutter Local Notifications
- **Encryption**: AES encryption
- **PDF Generation**: pdf & printing packages

## Prerequisites

- Flutter SDK (3.0 or higher)
- Dart SDK (3.0 or higher)
- Android Studio / Xcode
- Firebase account (for authentication and cloud features)

## Setup Instructions

### 1. Clone the Repository

```bash
git clone <repository-url>
cd KATHA
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Firebase Setup

#### Android:
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or use an existing one
3. Add an Android app with package name: `com.katha.ledger`
4. Download `google-services.json`
5. Place it in `android/app/` directory

#### iOS:
1. In Firebase Console, add an iOS app
2. Download `GoogleService-Info.plist`
3. Place it in `ios/Runner/` directory

### 4. Enable Firebase Services

In Firebase Console, enable:
- Authentication (Email/Password, Phone)
- Cloud Firestore (optional for cloud sync)
- Cloud Storage (optional for cloud backup)
- Cloud Messaging (for push notifications)

### 5. Update Firebase Configuration

Create a file `lib/firebase_options.dart` with your Firebase configuration:

```dart
// This file should be generated using FlutterFire CLI
// Run: flutterfire configure
```

Or use FlutterFire CLI:

```bash
npm install -g firebase-tools
dart pub global activate flutterfire_cli
flutterfire configure
```

### 6. Run the App

#### Android:
```bash
flutter run
```

#### iOS:
```bash
cd ios
pod install
cd ..
flutter run
```

## Building for Production

### Android APK:
```bash
flutter build apk --release
```

### Android App Bundle:
```bash
flutter build appbundle --release
```

### iOS:
```bash
flutter build ios --release
```

## Project Structure

```
lib/
├── core/
│   ├── models/          # Data models
│   ├── providers/       # State management
│   ├── services/        # Business logic services
│   └── utils/           # Utility functions
├── ui/
│   ├── screens/         # App screens
│   ├── widgets/         # Reusable widgets
│   └── theme/           # App theming
└── main.dart            # App entry point

assets/
├── lang/                # Localization files
├── images/              # Image assets
└── icons/               # Icon assets
```

## Key Features Implementation

### Local Data Encryption
All sensitive data is encrypted using AES-256 encryption before storing in SQLite database.

### Offline-First Architecture
The app works completely offline. All data is stored locally and can optionally sync to cloud when online.

### Data Sharing
Users can share their ledger data with other devices using:
- Encrypted JSON export
- QR code scanning
- Direct file sharing

### WhatsApp Integration
Send payment reminders directly via WhatsApp using URL schemes.

### Biometric Authentication
Secure app access using fingerprint or Face ID on supported devices.

## Permissions Required

### Android:
- INTERNET
- CAMERA (for receipt capture)
- READ/WRITE_EXTERNAL_STORAGE (for backup/restore)
- USE_BIOMETRIC (for fingerprint)
- POST_NOTIFICATIONS (for reminders)

### iOS:
- Camera access
- Photo library access
- Face ID usage

## Security Features

1. **Local Authentication**: PIN and biometric authentication
2. **Data Encryption**: AES-256 encryption for local data
3. **Secure Communication**: HTTPS for all network requests
4. **Firebase Security Rules**: Properly configured for user data isolation

## Troubleshooting

### Firebase Authentication Issues
- Ensure `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) are properly placed
- Enable required authentication methods in Firebase Console

### Build Issues
- Run `flutter clean` and `flutter pub get`
- For iOS: `cd ios && pod install && cd ..`
- Check Flutter and Dart SDK versions

### Permission Issues
- Ensure all required permissions are declared in AndroidManifest.xml and Info.plist
- Request runtime permissions for Android 6.0+

## Contributing

Contributions are welcome! Please follow these steps:
1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License.

## Support

For issues and questions:
- Create an issue in the repository
- Email: support@kathaledger.com

## Roadmap

- [ ] Cloud sync across devices
- [ ] Multi-business support
- [ ] Advanced analytics and charts
- [ ] Expense tracking
- [ ] Invoice generation
- [ ] Payment gateway integration
- [ ] Web dashboard

## Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- All open-source package contributors

---

**Version**: 1.0.0  
**Last Updated**: 2025-10-04
