# 🚗 CazzCar

**CazzCar** is a car marketplace application built with Flutter. It facilitates buying and selling vehicles with features like real-time chat, geolocation tagging, and **AI-powered** descriptiom generation using Google Gemini.

## 🏗️ Architecture

This project follows a **Clean Architecture** approach using the **MVVM (Model-View-ViewModel)** pattern. This structure ensures a clear separation of concerns, making the app scalable and testable.

* **View (`_screen.dart`):** The UI layer. It displays data and captures user input, observing the ViewModel for state changes.
* **ViewModel (`_vm.dart`):** The business logic layer using `Provider`. It manages state (loading, data, errors) and communicates with Repositories.
* **Repository (`_repo.dart`):** The data layer. It handles direct interactions with the backend (Firebase Firestore, Auth, Storage).
* **Services:** specialized classes for external device features or APIs (AI, Location).

## 📂 Project Structure

Here is an overview of the `lib` folder and the purpose of each file:

```text
lib
├── core                           // Core utilities and shared resources
│   ├── app_theme.dart             // Centralized theme configuration (colors, fonts)
│   └── widgets.dart               // Reusable UI components (Buttons, TextFields)
│  
├── features                      
│   ├── auth                      
│   │   ├── auth_vm.dart           // Logic for login, registration, and logout
│   │   ├── auth_wrapper.dart      // Decides which screen to show (Login vs Home) based on auth state
│   │   ├── login_screen.dart      // UI for existing users to sign in
│   │   └── register_screen.dart   // UI for new users to create an account
│   ├── buyer                      // Features for users looking to buy cars
│   │   ├── buyer_vm.dart          // Logic for fetching car feeds and filtering
│   │   ├── car_detail_screen.dart // Full display of a specific car's data
│   │   └── home_screen.dart       // Main feed showing available cars
│   ├── chat      
│   │   ├── chat_list_screen.dart  // List of all active conversations
│   │   ├── chat_screen.dart       // The actual messaging interface
│   │   └── chat_vm.dart           // Logic for sending/receiving messages
│   ├── main_nav.dart              // Bottom navigation bar controller (Scaffold wrapper)
│   ├── profile  
│   │   ├── profile_screen.dart    // UI for viewing and editing user details
│   │   └── profile_vm.dart        // Logic for updating user data
│   └── seller       
│       ├── add_car_screen.dart    // Form to post a new car (includes AI & Image picker)
│       ├── my_ads_screen.dart     // List of ads posted by the current user
│       └── seller_vm.dart         // Logic for uploading images and saving car data
├── firebase_options.dart          // Auto-generated Firebase configuration file
├── main.dart                     
├── models                         // Data blueprints (plain Dart classes)
│   ├── car_model.dart             // Structure for vehicle data
│   ├── chat_model.dart            // Structure for message data
│   └── user_model.dart            // Structure for user profile data
│  
├── repositories                   // Data handling layer (Talks to Firebase)
│   ├── auth_repo.dart             // Handles FirebaseAuth methods
│   ├── car_repo.dart              // Handles Firestore CRUD operations for cars
│   └── chat_repo.dart             // Handles message streams and Firestore chat storage
│  
└── services                       // External API and Device services
    ├── ai_service.dart            // Connects to Gemini API to generate car descriptions
    └── location_service.dart      // Handles device GPS to get current coordinates
