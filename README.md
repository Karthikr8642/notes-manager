# Notes Manager (Ipopiads Assignment)

## Project overview

Simple notes app built with Flutter demonstrating Clean Architecture, Firebase Authentication, Cloud Firestore CRUD (real-time), and GetX state management. The project implements signup/login, notes CRUD, and a minimal responsive UI suitable for the assignment.

## Architecture & State Management

- Clean Architecture: `presentation`, `domain`, and `data` layers under each feature.
- State management: `GetX` for simple controllers, navigation, and reactivity.
- Dependency injection: `Get.put` (GetX) for simple controllers and services.

Core structure (partial):

lib/
├── core/
├── features/
│ ├── auth/
│ └── notes/
├── injection.dart
├── firebase_options.dart (generated)
└── main.dart

## Dependencies

See `pubspec.yaml`. Key packages used:

- firebase_core, firebase_auth, cloud_firestore
- get
- get_it

## Prerequisites

- Flutter SDK (stable) installed
- `firebase` CLI (optional but recommended) — used by `flutterfire`
- `dart` and `flutter` on PATH

## Firebase setup (recommended steps)

1. Create a Firebase project named `Ipopiads Notes App` at https://console.firebase.google.com/.
2. Enable Authentication -> Sign-in method -> Email/Password (enable).
3. Create a Firestore database (Native mode). You may start in test mode for development.
4. Add Android and/or iOS apps to the Firebase project.
   - Android `applicationId` (package name) commonly `com.example.notes_manager` — confirm in `android/app/build.gradle` or `android/app/src/main/AndroidManifest.xml`.
   - Download `google-services.json` into `android/app/`.
   - For iOS, add the iOS bundle id (Runner) and download `GoogleService-Info.plist` into `ios/Runner/`.

### Generate `firebase_options.dart` (recommended)

Install and run the FlutterFire CLI to generate platform config and `lib/firebase_options.dart`:

```bash
flutter pub get
dart pub global activate flutterfire_cli
firebase login
flutterfire configure --project <YOUR_FIREBASE_PROJECT_ID>
```

The `flutterfire configure` command will detect platforms and generate `lib/firebase_options.dart`. Replace `<YOUR_FIREBASE_PROJECT_ID>` with the project id from the Firebase console if you prefer to pass it explicitly.

If you don't run `flutterfire configure`, the app contains a placeholder `lib/firebase_options.dart` and Firebase initialization will silently skip on environments without generated options.

## Run the app (development)

1. Install packages:

```bash
flutter pub get
```

2. Run on a connected device/emulator:

```bash
flutter run
```

## Testing & analysis

Run unit/widget tests (if any):

```bash
flutter test
```

Static analysis:

```bash
flutter analyze
```

## Build release APK

Build a release APK (unsigned debug signing by default):

```bash
flutter build apk --release
```

Release APK path: `build/app/outputs/flutter-apk/app-release.apk` (or `app-release.aab` for app bundle builds).

To publish a signed APK, follow Android signing instructions: create a keystore, add signing config to `android/app/build.gradle`, and build.

## Notes on Firestore structure (as required)

- `users` collection: stores user profiles created at signup.
- `notes` collection: each document contains `{ userId, title, description, createdAt, updatedAt }`.

Example add note:

```dart
FirebaseFirestore.instance.collection('notes').add({
  'title': title,
  'description': description,
  'userId': uid,
  'createdAt': FieldValue.serverTimestamp(),
  'updatedAt': FieldValue.serverTimestamp(),
});
```

## Assumptions

- Default Android package id is `com.example.notes_manager` unless changed by the developer.
- Firestore rules are permissive during development (test mode); secure rules should be applied for production.
- The generated `firebase_options.dart` will be created by `flutterfire configure` — developer must run this step locally.

## Submission / APK

- Provide the GitHub repository link and the release APK located at `build/app/outputs/flutter-apk/app-release.apk` after building.

## Interview talking points

- Why GetX: lightweight controllers, simple dependency injection, and built-in navigation and reactivity.
- Why StreamBuilder: real-time Firestore updates, efficient UI updates.
- Clean Architecture: easier to maintain and scale.

## Next steps I can help with

- Wire remaining UI with `NotesController` and add Add/Edit note screens.
- Add unit and widget tests for controllers and repositories.
- Create CI scripts or workspace-specific setup instructions.

---

File locations to inspect:

- [lib/main.dart](lib/main.dart#L1)
- [lib/firebase_options.dart](lib/firebase_options.dart#L1)
- [lib/features/auth/presentation/signup_page.dart](lib/features/auth/presentation/signup_page.dart#L1)
- [lib/features/notes/presentation/notes_page.dart](lib/features/notes/presentation/notes_page.dart#L1)

# notes_manager

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
