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

qq

## Author

Karthik R

Flutter Developer

---

**Recent Push Summary (commit: 1aff571)**

- **What changed:** Added the Phase 2 AI Financial OS architecture, service scaffolding, and an implementation guide. Completed and committed core Expense Tracking feature files and multiple new service stubs for parsing and timeline aggregation.
- **Key files added/updated:**
  - `lib/features/expenses/domain/entities/expense.dart`
  - `lib/features/expenses/presentation/expenses_controller.dart`
  - `lib/features/expenses/presentation/expenses_page.dart`
  - `lib/features/expenses/presentation/add_edit_expense_page.dart`
  - `lib/features/wallet/domain/entities/financial_os_models.dart`
  - `lib/features/wallet/domain/entities/advanced_models.dart`
  - `lib/core/services/financial_os_service.dart`
  - `lib/core/services/unified_timeline_service.dart`
  - `lib/core/services/financial_os_permissions_service.dart`
  - `lib/core/services/financial_twin_service.dart`
  - `lib/core/services/receipt_scanner_service.dart`
  - `lib/core/services/price_comparison_service.dart`
  - `lib/core/services/subscription_service.dart`
  - `lib/core/services/bill_reminder_service.dart`
  - `lib/core/services/chat_service.dart`
  - `lib/core/services/family_expense_service.dart`
  - `AI_FINANCIAL_OS_ARCHITECTURE.md`
  - `AI_FINANCIAL_OS_IMPLEMENTATION.md` (implementation guide)
  - `IMPLEMENTATION_ROADMAP.md` (updated roadmap)

- **High-level summary:**
  - Phase 1 (Expense Tracking) is complete and integrated with Firestore.
  - Phase 2 (AI Financial OS) is scaffolded: data models, parsing service stubs, permission helpers, unified timeline service, and design documentation are included.
  - An actionable implementation guide (`AI_FINANCIAL_OS_IMPLEMENTATION.md`) provides step-by-step instructions for the immediate MVP: SMS parser → Gmail parser → Notification listener.

**Next recommended steps (priority):**

- Implement the SMS parser (permission flow, SMS reading, regex extraction, auto-create rules).
- Implement Gmail OAuth and invoice parsing.
- Wire Android `NotificationListenerService` to Flutter and feed notifications into the parsing pipeline.
- Build a `Pending Review` UI for medium-confidence parsed transactions and a `Unified Timeline` UI.

**How to run / test locally:**

1. Install dependencies:

```bash
flutter pub get
```

2. Configure Firebase (if not done):

```bash
flutterfire configure
```

3. Run the app:

```bash
flutter run
```

If you want, I can now implement the SMS parser end-to-end and add tests.
