# Katha Ledger - Complete Setup Guide

This guide will walk you through setting up and running the Katha Ledger application.

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Installation Steps](#installation-steps)
3. [Firebase Configuration](#firebase-configuration)
4. [Running the Application](#running-the-application)
5. [Building for Production](#building-for-production)
6. [Data Sharing & Permissions](#data-sharing--permissions)
7. [Troubleshooting](#troubleshooting)

## Prerequisites

### Required Software
- **Flutter SDK**: Version 3.0 or higher
  - Download from: https://flutter.dev/docs/get-started/install
- **Dart SDK**: Version 3.0 or higher (comes with Flutter)
- **Android Studio** (for Android development)
  - Download from: https://developer.android.com/studio
- **Xcode** (for iOS development, macOS only)
  - Download from Mac App Store
- **Git**: For version control
- **Firebase Account**: Free tier is sufficient

### System Requirements
- **Windows**: Windows 10 or later (64-bit)
- **macOS**: macOS 10.14 or later (for iOS development)
- **Linux**: 64-bit distribution
- **Disk Space**: At least 2.5 GB (excluding IDE)
- **RAM**: Minimum 8 GB recommended

## Installation Steps

### Step 1: Install Flutter

#### Windows:
```bash
# Download Flutter SDK from flutter.dev
# Extract to C:\src\flutter
# Add to PATH: C:\src\flutter\bin

# Verify installation
flutter doctor
```

#### macOS/Linux:
```bash
# Download Flutter SDK
cd ~/development
git clone https://github.com/flutter/flutter.git -b stable

# Add to PATH in ~/.bashrc or ~/.zshrc
export PATH="$PATH:$HOME/development/flutter/bin"

# Verify installation
flutter doctor
```

### Step 2: Set Up Development Environment

#### Android Studio:
1. Install Android Studio
2. Install Flutter and Dart plugins
3. Configure Android SDK (API level 21 or higher)
4. Set up Android Emulator or connect physical device

#### Xcode (macOS only):
1. Install Xcode from App Store
2. Install Xcode Command Line Tools:
   ```bash
   sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
   sudo xcodebuild -runFirstLaunch
   ```
3. Accept licenses:
   ```bash
   sudo xcodebuild -license accept
   ```

### Step 3: Clone and Setup Project

```bash
# Navigate to your projects directory
cd Desktop

# The project is already in KATHA folder
cd KATHA

# Install dependencies
flutter pub get
```

## Firebase Configuration

### Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add Project"
3. Enter project name: "Katha Ledger"
4. Disable Google Analytics (optional)
5. Click "Create Project"

### Step 2: Configure Android App

1. In Firebase Console, click "Add app" → Android icon
2. Enter package name: `com.katha.ledger`
3. Enter app nickname: "Katha Ledger Android"
4. Download `google-services.json`
5. Place file in: `android/app/google-services.json`

### Step 3: Configure iOS App

1. In Firebase Console, click "Add app" → iOS icon
2. Enter bundle ID: `com.katha.ledger`
3. Enter app nickname: "Katha Ledger iOS"
4. Download `GoogleService-Info.plist`
5. Place file in: `ios/Runner/GoogleService-Info.plist`

### Step 4: Enable Firebase Services

In Firebase Console, enable these services:

#### Authentication:
1. Go to Authentication → Sign-in method
2. Enable "Email/Password"
3. Enable "Phone" (requires billing account for SMS)

#### Cloud Firestore (Optional):
1. Go to Firestore Database
2. Click "Create database"
3. Start in test mode
4. Choose location

#### Cloud Storage (Optional):
1. Go to Storage
2. Click "Get started"
3. Start in test mode

#### Cloud Messaging:
1. Go to Cloud Messaging
2. Note the Server Key for push notifications

### Step 5: Install FlutterFire CLI (Recommended)

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase for Flutter
flutterfire configure
```

This will automatically generate `lib/firebase_options.dart` with your configuration.

## Running the Application

### Development Mode

#### Android:
```bash
# List available devices
flutter devices

# Run on connected device/emulator
flutter run

# Run with hot reload
flutter run --debug
```

#### iOS (macOS only):
```bash
# Install CocoaPods dependencies
cd ios
pod install
cd ..

# Run on simulator
flutter run

# Run on physical device (requires Apple Developer account)
flutter run --release
```

### Debug on Physical Device

#### Android:
1. Enable Developer Options on device
2. Enable USB Debugging
3. Connect device via USB
4. Run: `flutter run`

#### iOS:
1. Connect iPhone/iPad via USB
2. Trust computer on device
3. In Xcode, sign the app with your Apple ID
4. Run: `flutter run`

## Building for Production

### Android APK (for testing):
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle (for Play Store):
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

### iOS (macOS only):
```bash
flutter build ios --release
# Then open ios/Runner.xcworkspace in Xcode
# Archive and upload to App Store Connect
```

### Signing the App

#### Android:
1. Create keystore:
```bash
keytool -genkey -v -keystore ~/katha-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias katha
```

2. Create `android/key.properties`:
```properties
storePassword=<password>
keyPassword=<password>
keyAlias=katha
storeFile=<path-to-keystore>
```

3. Update `android/app/build.gradle`:
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

#### iOS:
1. Enroll in Apple Developer Program ($99/year)
2. Create App ID in Apple Developer Portal
3. Create Provisioning Profile
4. Configure signing in Xcode

## Data Sharing & Permissions

### Secure Data Sharing

The app supports multiple ways to share data:

1. **Encrypted Backup File**:
   - Go to Settings → Backup Data
   - Save encrypted JSON file
   - Share via any method

2. **QR Code** (Future feature):
   - Generate QR code with encrypted data
   - Scan on another device

3. **Cloud Sync** (Optional):
   - Enable in Settings
   - Data syncs via Firebase

### Permission Setup

#### Android Permissions:
All required permissions are already configured in `AndroidManifest.xml`:
- Internet access
- Camera (for receipts)
- Storage (for backup/restore)
- Biometric authentication
- Notifications

#### iOS Permissions:
All required permissions are configured in `Info.plist`:
- Camera usage
- Photo library access
- Face ID usage

### Granting Access to Another Device

1. **Export Method**:
   - Settings → Backup Data
   - Share the backup file securely
   - On new device: Settings → Restore Data

2. **Cloud Method** (if enabled):
   - Login with same account on new device
   - Data automatically syncs

## Troubleshooting

### Common Issues

#### 1. Flutter Doctor Issues
```bash
flutter doctor -v
# Fix any issues shown
```

#### 2. Gradle Build Failed (Android)
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

#### 3. CocoaPods Issues (iOS)
```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter run
```

#### 4. Firebase Authentication Not Working
- Verify `google-services.json` is in `android/app/`
- Verify `GoogleService-Info.plist` is in `ios/Runner/`
- Check Firebase Console for enabled auth methods
- Ensure SHA-1 fingerprint is added (Android)

#### 5. Permission Denied Errors
- Check AndroidManifest.xml has all permissions
- Request runtime permissions in app
- For iOS, check Info.plist descriptions

#### 6. Database Errors
```bash
# Clear app data and reinstall
flutter clean
flutter run
```

#### 7. Build Errors
```bash
# Update dependencies
flutter pub upgrade

# Clear cache
flutter clean

# Rebuild
flutter run
```

### Getting SHA-1 Fingerprint (Android)

For Firebase Authentication:
```bash
# Debug key
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# Release key
keytool -list -v -keystore ~/katha-release-key.jks -alias katha
```

Add the SHA-1 to Firebase Console → Project Settings → Your Android App

### Performance Optimization

1. **Enable R8/ProGuard** (Android):
   Already configured in `build.gradle`

2. **Optimize Images**:
   Use compressed images in `assets/images/`

3. **Reduce App Size**:
   ```bash
   flutter build apk --split-per-abi
   ```

## Testing

### Run Tests
```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

### Integration Testing
```bash
# Run integration tests
flutter drive --target=test_driver/app.dart
```

## Deployment Checklist

### Before Release:
- [ ] Test on multiple devices
- [ ] Test all authentication methods
- [ ] Test backup and restore
- [ ] Test offline functionality
- [ ] Verify all permissions work
- [ ] Test WhatsApp integration
- [ ] Test PDF export
- [ ] Update version in `pubspec.yaml`
- [ ] Create release notes
- [ ] Generate signed APK/AAB
- [ ] Test signed build

### Play Store Submission:
- [ ] Create Play Store listing
- [ ] Upload screenshots
- [ ] Write app description
- [ ] Set pricing and distribution
- [ ] Upload signed AAB
- [ ] Submit for review

### App Store Submission:
- [ ] Create App Store Connect listing
- [ ] Upload screenshots
- [ ] Write app description
- [ ] Set pricing and availability
- [ ] Archive and upload build
- [ ] Submit for review

## Support & Resources

- **Flutter Documentation**: https://flutter.dev/docs
- **Firebase Documentation**: https://firebase.google.com/docs
- **Stack Overflow**: Tag questions with `flutter` and `firebase`
- **GitHub Issues**: Report bugs in the repository

## Next Steps

After successful setup:
1. Customize app branding (colors, logo)
2. Add your Firebase configuration
3. Test all features thoroughly
4. Build and test release version
5. Submit to app stores

---

**Need Help?**
- Check the main README.md for feature documentation
- Review code comments for implementation details
- Open an issue for bugs or questions
