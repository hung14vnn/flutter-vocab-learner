# Vocabulary
A Flutter vocabulary learning application with Firebase backend integration that helps users learn and memorize vocabulary using spaced repetition techniques.

## Features

- **User Authentication**: Secure login and registration using Firebase Auth
- **Vocabulary Management**: Browse and search vocabulary words
- **Spaced Repetition**: Intelligent review system based on user performance
- **Progress Tracking**: Monitor learning progress and statistics
- **Material Design 3**: Modern and responsive UI

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── app_user.dart
│   ├── vocab_word.dart
│   └── user_progress.dart
├── services/                 # Firebase services
│   ├── auth_service.dart
│   ├── vocab_service.dart
│   └── progress_service.dart
├── providers/                # State management
│   ├── auth_provider.dart
│   ├── vocab_provider.dart
│   └── progress_provider.dart
├── screens/                  # UI screens
│   ├── auth/
│   ├── home/
│   ├── vocab/
│   ├── practice/
│   └── profile/
└── widgets/                  # Reusable components
```

## Technologies Used

- **Flutter**: Cross-platform mobile development framework
- **Firebase Core**: Firebase SDK initialization
- **Firebase Authentication**: User authentication and management
- **Cloud Firestore**: NoSQL database for storing vocabulary and progress data
- **Firebase Storage**: File storage for media assets
- **Provider**: State management pattern
- **Google Fonts**: Beautiful typography

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK
- Firebase project setup
- Android Studio or VS Code with Flutter extensions

### Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd vocab_learner
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Set up Firebase:
   - Create a new Firebase project
   - Enable Authentication (Email/Password)
   - Enable Cloud Firestore
   - Enable Firebase Storage
   - Download and add configuration files:
     - `android/app/google-services.json` for Android
     - `ios/Runner/GoogleService-Info.plist` for iOS

4. Run the app:
   ```bash
   flutter run
   ```

## Firebase Setup

### Authentication
- Enable Email/Password authentication in Firebase Console

### Firestore Database
Create the following collections:
- `users`: User profile data
- `vocab_words`: Vocabulary database
- `user_progress`: Individual progress tracking

## OpenAI API Setup

This app uses OpenAI's GPT model for intelligent word analysis. To enable AI features:

1. Get an API key from [OpenAI Platform](https://platform.openai.com/account/api-keys)
2. Set up the API key using one of these methods:

### Security Rules
Example Firestore security rules:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Vocabulary words are read-only for all authenticated users
    match /vocab_words/{wordId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null; // Add admin check in production
    }
    
    // User progress is private to each user
    match /user_progress/{progressId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
  }
}
```

### Testing
```bash
flutter test
```

### Building for Production
```bash
# Android
flutter build apk --release
flutter build appbundle --release

# iOS
flutter build ios --release
```

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions, please open an issue in the repository.
