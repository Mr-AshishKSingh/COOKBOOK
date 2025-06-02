# Cookbook

Cookbook is a Flutter-based mobile application that connects users seeking home-cooked meals with local cooks. The app allows users to post their cooking needs, browse and book cooks, while cooks can register, manage their profiles, and accept job requests.

## Features

- **Role Selection:** Sign up as a user or a cook.
- **User Module:**
  - Sign up/login with email, phone, and address (Google Places integration).
  - Post cooking needs and view available cooks.
  - Book cooks and manage requests.
  - Notifications and profile management.
- **Cook Module:**
  - Sign up/login with detailed profile (speciality, wage, working hours, locations).
  - View and manage job requests.
  - Attendance and notifications.
  - Profile management.
- **Google Places Integration:** Accurate address selection for users.
- **Firebase Integration:** Authentication and Firestore database.
- **Material Design:** Modern, clean UI.

## Technologies Used

- Flutter (Dart)
- Firebase Auth & Firestore
- Google Places API
- Material Design
- Razorpay (for payments, if enabled)

## Folder Structure

```
lib/
  ├── main.dart
  ├── screens/
  │     ├── user_signup_screen.dart
  │     ├── cook_signup_screen.dart
  │     ├── profile_screen.dart
  │     └── ...
  ├── services/
  │     └── auth_service.dart
  └── assets/
        └── images/
```

## Getting Started

1. **Clone the repository:**
   ```sh
   git clone https://github.com/yourusername/cookbook.git
   cd cookbook
   ```

2. **Install dependencies:**
   ```sh
   flutter pub get
   ```

3. **Set up Firebase:**
   - Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) to the respective folders.
   - Enable Authentication and Firestore in your Firebase project.

4. **Set up Google Places API:**
   - Get your API key from [Google Cloud Console](https://console.cloud.google.com/).
   - Enable the Places API.
   - Add your API key in the app code.

5. **Run the app:**
   ```sh
   flutter run
   ```

## ProGuard

If you are building for release on Android, ensure your `android/app/proguard-rules.pro` includes:

```
# Please add these rules to your existing keep rules in order to suppress warnings.
# This is generated automatically by the Android Gradle plugin.
-dontwarn proguard.annotation.Keep
-dontwarn proguard.annotation.KeepClassMembers
```

## License

This project is licensed under the MIT License.

---

**Cookbook** makes finding and hiring home cooks easy, secure, and efficient for everyone!
