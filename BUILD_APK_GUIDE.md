# Building APK for Katha Ledger

This guide will help you build an APK file that you can install on Android devices.

## Prerequisites

Before building the APK, ensure you have:
- ✅ Flutter SDK installed
- ✅ Android SDK installed
- ✅ All dependencies installed (`flutter pub get`)

## Quick Build (For Testing)

### Option 1: Debug APK (Fastest - For Testing Only)

```bash
# Navigate to project directory
cd C:\Users\sures\Desktop\KATHA

# Build debug APK
flutter build apk --debug
```

**Output Location**: `build\app\outputs\flutter-apk\app-debug.apk`

⚠️ **Note**: Debug APKs are larger and slower. Use only for testing.

---

### Option 2: Release APK (Recommended)

```bash
# Build release APK
flutter build apk --release
```

**Output Location**: `build\app\outputs\flutter-apk\app-release.apk`

✅ **This is the APK you should use for distribution**

---

### Option 3: Split APKs (Smaller Size)

Build separate APKs for different CPU architectures:

```bash
flutter build apk --split-per-abi
```

**Output Location**: `build\app\outputs\flutter-apk\`
- `app-armeabi-v7a-release.apk` (32-bit ARM)
- `app-arm64-v8a-release.apk` (64-bit ARM - Most modern phones)
- `app-x86_64-release.apk` (64-bit x86 - Emulators)

✅ **Recommended**: Use split APKs to reduce file size

---

## Step-by-Step Build Process

### Step 1: Prepare the Project

```bash
# Navigate to project
cd C:\Users\sures\Desktop\KATHA

# Clean previous builds
flutter clean

# Get dependencies
flutter pub get
```

### Step 2: Check for Issues

```bash
# Run flutter doctor to check setup
flutter doctor

# Analyze code for issues
flutter analyze
```

### Step 3: Build the APK

#### For Testing (Debug):
```bash
flutter build apk --debug
```

#### For Production (Release):
```bash
flutter build apk --release
```

#### For Smaller Size (Split):
```bash
flutter build apk --split-per-abi --release
```

### Step 4: Locate the APK

After successful build, find your APK at:

**Windows**:
```
C:\Users\sures\Desktop\KATHA\build\app\outputs\flutter-apk\
```

**Files**:
- `app-release.apk` (single APK)
- OR `app-arm64-v8a-release.apk`, `app-armeabi-v7a-release.apk`, etc. (split APKs)

---

## Installing APK on Your Phone

### Method 1: Direct Transfer

1. **Connect phone via USB**
2. **Copy APK to phone**:
   - Copy from: `build\app\outputs\flutter-apk\app-release.apk`
   - Paste to: Phone's Download folder
3. **Install**:
   - Open file manager on phone
   - Navigate to Downloads
   - Tap the APK file
   - Allow "Install from unknown sources" if prompted
   - Tap "Install"

### Method 2: Using ADB

```bash
# Install directly via ADB
flutter install

# OR manually with adb
adb install build\app\outputs\flutter-apk\app-release.apk
```

### Method 3: Share via Cloud

1. Upload APK to Google Drive / Dropbox
2. Download on phone
3. Install from Downloads folder

---

## Important Notes

### Firebase Configuration Required

⚠️ **Before building, you MUST add Firebase configuration**:

1. **Create Firebase Project**:
   - Go to https://console.firebase.google.com/
   - Create new project: "Katha Ledger"

2. **Add Android App**:
   - Package name: `com.katha.ledger`
   - Download `google-services.json`

3. **Place Configuration File**:
   - Copy `google-services.json` to:
   ```
   C:\Users\sures\Desktop\KATHA\android\app\google-services.json
   ```

4. **Enable Firebase Services**:
   - Authentication (Email/Password, Phone)
   - Cloud Firestore (optional)
   - Cloud Storage (optional)

### Without Firebase

If you want to build without Firebase (limited functionality):

1. Comment out Firebase dependencies in `pubspec.yaml`:
```yaml
# firebase_core: ^2.24.2
# firebase_auth: ^4.15.3
# firebase_messaging: ^14.7.9
# firebase_storage: ^11.5.6
```

2. Remove Firebase initialization from `lib/main.dart`:
```dart
// await Firebase.initializeApp();
```

3. Rebuild:
```bash
flutter pub get
flutter build apk --release
```

---

## Build Sizes

Typical APK sizes:
- **Debug APK**: ~50-80 MB (includes debugging tools)
- **Release APK**: ~20-30 MB (optimized)
- **Split APK (arm64-v8a)**: ~15-20 MB (smallest)

---

## Troubleshooting

### Error: "Gradle build failed"

```bash
# Solution 1: Clean and rebuild
flutter clean
flutter pub get
flutter build apk --release

# Solution 2: Update Gradle
cd android
.\gradlew clean
cd ..
flutter build apk --release
```

### Error: "SDK location not found"

Create `android/local.properties`:
```properties
sdk.dir=C:\\Users\\sures\\AppData\\Local\\Android\\Sdk
flutter.sdk=C:\\src\\flutter
```

### Error: "google-services.json missing"

Either:
1. Add Firebase configuration (recommended)
2. OR remove Firebase dependencies (limited features)

### Error: "Execution failed for task ':app:lintVitalRelease'"

Add to `android/app/build.gradle`:
```gradle
android {
    lintOptions {
        checkReleaseBuilds false
        abortOnError false
    }
}
```

### Error: "Insufficient storage"

```bash
# Clear Flutter cache
flutter clean

# Clear Gradle cache
cd android
.\gradlew clean
cd ..
```

---

## Build Commands Reference

```bash
# Debug APK (testing)
flutter build apk --debug

# Release APK (production)
flutter build apk --release

# Split APKs (smaller size)
flutter build apk --split-per-abi --release

# App Bundle (for Play Store)
flutter build appbundle --release

# Install on connected device
flutter install

# Build and install
flutter run --release
```

---

## File Sizes Comparison

| Build Type | Size | Use Case |
|------------|------|----------|
| Debug APK | ~60 MB | Development/Testing |
| Release APK | ~25 MB | Distribution |
| Split APK (arm64) | ~18 MB | Most phones |
| Split APK (armeabi) | ~17 MB | Older phones |
| App Bundle | ~22 MB | Play Store |

---

## Next Steps After Building

1. **Test the APK**:
   - Install on your phone
   - Test all features
   - Check for crashes

2. **Share with Others**:
   - Upload to Google Drive
   - Share download link
   - OR publish to Play Store

3. **Publish to Play Store** (Optional):
   - Create Developer account ($25 one-time)
   - Build App Bundle: `flutter build appbundle --release`
   - Upload to Play Console
   - Fill store listing
   - Submit for review

---

## Quick Command Summary

```bash
# Complete build process
cd C:\Users\sures\Desktop\KATHA
flutter clean
flutter pub get
flutter build apk --release

# Find APK at:
# build\app\outputs\flutter-apk\app-release.apk

# Install on phone:
# Copy APK to phone and install
# OR use: flutter install
```

---

## Support

If you encounter issues:
1. Check error messages carefully
2. Run `flutter doctor -v`
3. Ensure all dependencies are installed
4. Check Firebase configuration
5. Try cleaning and rebuilding

**Happy Building! 🚀**
