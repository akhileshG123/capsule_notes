<div align="center">

<h1>📦 CapsuleNotes</h1>
<p><em>A smart, modern notes app — capture thoughts, voices, and scanned documents, and lock them in time capsules.</em></p>

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-Firestore%20%7C%20Auth%20%7C%20Storage-FFCA28?logo=firebase&logoColor=black)
![Node.js](https://img.shields.io/badge/Node.js-Backend-339933?logo=node.js&logoColor=white)
![Google Cloud](https://img.shields.io/badge/Google%20Cloud-Speech%20%7C%20Vision-4285F4?logo=google-cloud&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green)

</div>

---

## 🌟 About the App

**CapsuleNotes** is a next-generation personal notes application that goes beyond simple text capture. It lets users:

- 📝 **Write** rich text notes with beautiful formatting
- 🎙️ **Record** voice memos and auto-transcribe them using Google Cloud Speech-to-Text
- 📸 **Scan** documents and extract text with Google Cloud Vision OCR
- ⏰ **Lock notes as Time Capsules** — set a future unlock date and the note stays hidden until then
- 🔔 **Receive push notifications** when a capsule note is unlocked
- 🔐 **Authenticate securely** via Email/Password or Google Sign-In

The app is built with a **dark mode-first aesthetic**, staggered grid layouts, and smooth animations to deliver a premium user experience.

---

## 🛠️ Tech Stack

### 📱 Frontend — Flutter

| Package                         | Purpose                       |
| ------------------------------- | ----------------------------- |
| `flutter` + `dart`          | Core framework & language     |
| `firebase_core`               | Firebase initialization       |
| `firebase_auth`               | User authentication           |
| `cloud_firestore`             | Real-time NoSQL database      |
| `firebase_storage`            | Media file storage            |
| `firebase_messaging`          | Push notifications (FCM)      |
| `google_sign_in`              | Google OAuth authentication   |
| `flutter_sound`               | Voice recording               |
| `image_picker`                | Camera / gallery access       |
| `provider`                    | State management              |
| `http`                        | REST API calls to backend     |
| `flutter_staggered_grid_view` | Masonry / staggered note grid |
| `cached_network_image`        | Efficient image loading       |
| `flutter_local_notifications` | Local capsule unlock alerts   |
| `lottie`                      | Animated illustrations        |
| `intl`                        | Date & time formatting        |
| `uuid`                        | Unique ID generation          |

### 🖥️ Backend — Node.js (Express)

| Tech                     | Purpose                         |
| ------------------------ | ------------------------------- |
| `express`              | REST API server                 |
| `firebase-admin`       | Server-side Firebase SDK        |
| `@google-cloud/speech` | Voice-to-text transcription     |
| `@google-cloud/vision` | OCR for scanned documents       |
| `multer`               | File upload handling            |
| `node-cron`            | Scheduled jobs (capsule unlock) |
| `dotenv`               | Environment variable management |

### ☁️ Cloud & Infrastructure

| Service                               | Role                            |
| ------------------------------------- | ------------------------------- |
| **Firebase Auth**               | Secure user authentication      |
| **Cloud Firestore**             | Notes, capsule metadata storage |
| **Firebase Storage**            | Voice and image file storage    |
| **Firebase Cloud Messaging**    | Push notifications              |
| **Google Cloud Speech-to-Text** | Voice note transcription        |
| **Google Cloud Vision API**     | Document scanning / OCR         |

---

## 📁 Project Structure

```
capsule_notes_app/
├── lib/
│   ├── main.dart               # App entry point
│   ├── firebase_options.dart   # Firebase config
│   ├── models/                 # Data models (User, Note, etc.)
│   ├── providers/              # State management (Provider)
│   ├── screens/                # All UI screens
│   │   ├── splash_screen.dart
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   ├── home_screen.dart
│   │   ├── create_note_screen.dart
│   │   ├── capsule_note_screen.dart
│   │   ├── voice_note_screen.dart
│   │   └── scan_note_screen.dart
│   ├── services/               # Firebase & API service classes
│   ├── utils/                  # Helpers, theme, constants
│   └── widgets/                # Reusable UI components
│
└── backend/
    ├── server.js               # Express server entry point
    ├── routes/                 # API route definitions
    ├── middleware/             # Auth middleware
    ├── services/               # Business logic (Speech, Vision)
    └── jobs/                   # Cron jobs (capsule unlocking)
```

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) `>=3.x`
- [Node.js](https://nodejs.org/) `>=18.x`
- A [Firebase project](https://console.firebase.google.com/) with **Auth**, **Firestore**, **Storage**, and **FCM** enabled
- Google Cloud project with **Speech-to-Text** and **Vision API** enabled
- A `serviceAccountKey.json` from your Firebase project (for the backend)

---

### 🔧 1. Clone the Repository

```bash
git clone https://github.com/your-username/capsule_notes_app.git
cd capsule_notes_app
```

---

### 📱 2. Run the Flutter App

```bash
# Install dependencies
flutter pub get

# Run on a connected device or emulator
flutter run
```

> **Note:** Make sure your `lib/firebase_options.dart` is configured for your Firebase project. You can regenerate it using the [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/).

---

### 🖥️ 3. Run the Backend Server

```bash
cd backend

# Install Node dependencies
npm install

# Create your .env file (see below)
cp .env.example .env

# Start the server
node server.js
```

#### Backend `.env` Configuration

Create a `backend/.env` file with the following variables:

```env
PORT=3000
GOOGLE_APPLICATION_CREDENTIALS=./serviceAccountKey.json
FIREBASE_PROJECT_ID=your-firebase-project-id
```

> Place your `serviceAccountKey.json` (downloaded from Firebase Console → Project Settings → Service Accounts) inside the `backend/` folder.

---

### 🔒 4. Firestore Security Rules

Deploy the provided Firestore rules to your Firebase project:

```bash
firebase deploy --only firestore:rules
```

---

## ✨ Key Features

| Feature           | Description                                |
| ----------------- | ------------------------------------------ |
| 🔐 Auth           | Email/Password & Google Sign-In            |
| 📝 Rich Notes     | Create and manage text notes               |
| 🎙️ Voice Notes  | Record audio and transcribe to text        |
| 📷 Scan Notes     | Capture documents and extract text via OCR |
| ⏰ Time Capsules  | Lock notes until a future date             |
| 🔔 Notifications  | Get alerted when capsules unlock           |
| 🌙 Dark Mode      | Sleek dark-mode-first design               |
| 📐 Staggered Grid | Pinterest-style note layout                |

---

## 📄 License

This project is licensed under the **MIT License**.

---

<div align="center">
  <sub>Built with ❤️ using Flutter & Firebase</sub>
</div>
