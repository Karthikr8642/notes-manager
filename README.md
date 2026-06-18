# Notes Manager – Flutter Developer Assessment

## Overview

Notes Manager is a Flutter application built using Firebase Authentication and Cloud Firestore. The application allows users to register, log in, and manage their personal notes with real-time synchronization.

This project was developed as part of the Flutter Developer Assessment.

---

## Features

### Authentication

- User Registration
- User Login
- User Logout
- Form Validation
- Firebase Authentication Integration

### Notes Management

- Create Notes
- View Notes
- Edit Notes
- Delete Notes
- User-Specific Notes
- Real-Time Firestore Updates

### Dashboard

- Welcome Message
- Total Notes Count
- Notes Listing
- Logout Functionality

---

## Tech Stack

- Flutter 3.x
- Dart (Null Safety)
- Firebase Authentication
- Cloud Firestore
- GetX State Management
- Clean Architecture

---

## Project Structure

```text
lib/
├── core/
│   ├── constants/
│   ├── services/
│   └── utils/
│
├── features/
│   ├── auth/
│   │   └── presentation/
│   │
│   └── notes/
│       ├── domain/
│       └── presentation/
│
├── injection.dart
├── firebase_options.dart
└── main.dart
```

---

## Firebase Configuration

### Authentication

Enable:

- Email/Password Authentication

### Firestore Collections

#### users

```json
{
  "name": "User Name",
  "email": "user@example.com"
}
```

#### notes

```json
{
  "userId": "USER_ID",
  "title": "Sample Note",
  "description": "Sample Description",
  "createdAt": "Timestamp",
  "updatedAt": "Timestamp"
}
```

---

## Setup Instructions

### Clone Repository

```bash
git clone https://github.com/Karthikr8642/notes-manager.git
cd notes-manager
```

### Install Dependencies

```bash
flutter pub get
```

### Configure Firebase

```bash
flutterfire configure
```

### Run Application

```bash
flutter run
```

---

## Build APK

```bash
flutter build apk --release
```

Generated APK:

```text
build/app/outputs/flutter-apk/app-release.apk
```

---

## Implemented Requirements

| Requirement             | Status |
| ----------------------- | ------ |
| Signup                  | ✅     |
| Login                   | ✅     |
| Logout                  | ✅     |
| Create Note             | ✅     |
| View Notes              | ✅     |
| Edit Note               | ✅     |
| Delete Note             | ✅     |
| Firebase Authentication | ✅     |
| Cloud Firestore         | ✅     |
| User Specific Notes     | ✅     |
| Real-Time Updates       | ✅     |
| Responsive UI           | ✅     |
| Clean Architecture      | ✅     |

---

## Author

Karthik R

Flutter Developer
