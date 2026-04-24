# SnapBuy

SnapBuy is a Flutter-based e-commerce mobile app with Firebase authentication, Google sign-in, product browsing, cart management, checkout flow, and order history.

## Overview

SnapBuy is designed as a multi-feature shopping app for Android and iOS using:

- Flutter (UI + app logic)
- Provider (state management)
- Firebase Core (project initialization)
- Firebase Auth (email/password + Google sign-in)
- Cloud Firestore (user and order-related data)

## Features

- User authentication
- Email and password sign-up/login
- Google sign-in
- Profile view and sign-out
- Product catalog and product details
- Cart add/remove/update quantity
- Checkout and order success flow
- Order history screen
- Bottom navigation for main sections

## Tech Stack

- Flutter SDK
- Dart SDK (>= 3.11.1)
- Provider
- Firebase Core
- Firebase Auth
- Cloud Firestore
- Google Sign-In

## Project Structure

```text
lib/
	core/
		constants.dart
		theme.dart
		widgets/
	features/
		auth/
			data/
			presentation/
			provider/
		catalog/
			presentation/
		cart/
			presentation/
			provider/
		checkout/
			presentation/
		orders/
			presentation/
			provider/
	models/
	firebase_options.dart
	main.dart
```

## Prerequisites

Before running the app, make sure you have:

1. Flutter SDK installed
2. Dart SDK installed (bundled with Flutter)
3. Android Studio or Xcode configured
4. A Firebase project
5. Device/emulator set up

Check installation:

```bash
flutter doctor
```

## Installation

1. Clone the repository

```bash
git clone <your-repo-url>
cd e_commerce_cse464
```

2. Install dependencies

```bash
flutter pub get
```

3. Configure Firebase files

- Android: place Google config in `android/app/google-services.json`
- iOS: place Google config in `ios/Runner/GoogleService-Info.plist`

4. Run the app

```bash
flutter run
```

## Firebase Setup

### 1. Create and register apps

- Create a Firebase project
- Register Android app with package name:
	- `com.example.e_commerce_cse464`
- Register iOS app with bundle id matching your iOS config

### 2. Enable Authentication methods

In Firebase Console -> Authentication -> Sign-in method:

- Enable Email/Password
- Enable Google

### 3. Add SHA fingerprints (important for Google sign-in on Android)

For Android Google sign-in, add SHA-1 and SHA-256 for the keystore you build with:

- Debug keystore (for local/debug APK)
- Release keystore (for release APK)

If SHA is missing, Google sign-in can fail with messages like:

- "Unable to sign in with Google right now"

After adding SHA:

1. Download a fresh `google-services.json`
2. Replace `android/app/google-services.json`
3. Rebuild app:

```bash
flutter clean
flutter pub get
flutter run
```

## Build Commands

### Debug APK

```bash
flutter build apk --debug
```

### Release APK

```bash
flutter build apk --release
```

### App Bundle (Play Store)

```bash
flutter build appbundle --release
```

## Launcher Icon

This project uses `flutter_launcher_icons`.

Configured in `pubspec.yaml`:

- `image_path: assets/logo.png`

Generate icons:

```bash
dart run flutter_launcher_icons
```

## Main Navigation and Routes

Core routes are defined in `lib/core/constants.dart` and wired in `lib/main.dart`.

Primary flow:

- Auth (Login/Signup/OTP)
- Home (Catalog)
- Cart
- Checkout
- Order Success
- Orders
- Profile

## State Management

Provider-based architecture with `ChangeNotifier`:

- `AuthProvider`
- `CartProvider`
- `OrdersProvider`

These are registered at app root via `MultiProvider` in `main.dart`.

## Troubleshooting

### Google sign-in not working on installed APK

Check these in order:

1. Correct Android package name in Firebase app registration
2. SHA-1 and SHA-256 added in Firebase project settings
3. Google sign-in method enabled in Firebase Authentication
4. Updated `google-services.json` copied to `android/app/`
5. Rebuild after `flutter clean`

### Firebase init or auth issues

- Verify internet connection
- Verify `firebase_options.dart` exists and is consistent with Firebase project
- Make sure Android and iOS config files belong to the same Firebase project

## Dependencies (from pubspec)

- `google_sign_in`
- `firebase_core`
- `cloud_firestore`
- `firebase_auth`
- `provider`
- `intl`

## Development Notes

- App title is set to `SnapBuy` in `main.dart`
- Current Android application id is `com.example.e_commerce_cse464`
- Update application ids/package names before production release

## Future Improvements

- Add robust backend product and inventory integration
- Add payment gateway integration
- Add unit/widget/integration tests
- Add CI/CD pipeline for build and release
- Add localization and accessibility improvements

## License

This project is for academic and learning purposes unless otherwise specified.
