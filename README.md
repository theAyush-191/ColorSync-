ColorSync is an iOS app that enables users to generate random colors, store them offline using Realm, and automatically sync them to Firebase Firestore when the device is online.

—

## 📌 Features

- **Random Color Generation:** Users can create random colors by tapping a button, which displays the color’s HEX code.

- **Offline Data Storage:** All colors are stored locally in Realm when the device is offline.

- **Firebase Firestore Sync:** When the device is online, unsynced colors are uploaded to Firestore. Each color displays a sync status (Cloud ✅ / Cloud ❌).

- **Network Status Indicator:** A Wi-Fi icon in the navigation bar indicates the device’s network status:
    - ✅ **Online:** Green Wi-Fi icon
    - ❌ **Offline:** Red Wi-Fi icon

- **Firebase Authentication:** Secure login/logout with Firebase Auth.

📸 Recoding...

https://github.com/user-attachments/assets/ec25185b-04d7-4fd3-8157-0ba3e4e4a636


## 📂 Project Structure

```plaintext
ColorSync/
│── Models/
│   ├── ColorCard.swift         # Realm model for storing colors
│
│── Views/
│   ├── ColorCardCell.swift     # UICollectionViewCell for displaying colors
│
│── ViewControllers/
│   ├── HomeViewController.swift # Main screen: list of colors
│   ├── LoginViewController.swift # Login screen
│
│── Services/
│   ├── FirebaseManager.swift   # Handles Firestore sync & fetching
│
│── Resources/
│   ├── Assets.xcassets         # App assets (App Icon, colors)
│   ├── Info.plist              # App configuration
│
│── Supporting Files/
│   ├── AppDelegate.swift
│   ├── SceneDelegate.swift

Technologies Used
	•	Swift 5
	•	UIKit
	•	RealmSwift → Offline database
•	Firebase Auth: User authentication
•	Firebase Firestore: Cloud database
•	Network Framework: Monitor network status
•	UICollectionView: Display color cards

⸻

⚙️ Installation
1.	Clone the repository:
git clone https://github.com/YOUR-USERNAME/ColorSync.git
cd ColorSync

2.	Install dependencies:
•	Open the project in Xcode
•	Ensure you have CocoaPods or Swift Package Manager set up for Firebase:
pod install

or add Firebase packages via Swift Package Manager.

3.	Configure Firebase:
•	Create a Firebase project: Firebase Console
•	Add an iOS app in Firebase using your app’s Bundle Identifier
•	Download the GoogleService-Info.plist file
•	Place it inside your Xcode project (in the main target folder)

4.	Run the project:
•	Open ColorSync.xcworkspace
•	Select a simulator or device
•	Press Run ▶️

⸻

🔐 Firebase Security Rules

In Firestore, set rules so each user can only access their own data:
rules_version = ‘2’;
service cloud.firestore {
  match /databases/{database}/documents {
    match /Users/{userId}/colorCards/{cardId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
🚀 Usage
1.	Login: Enter your Firebase Auth credentials.
2.	Generate Colors: Tap + to add a random color.
3.	Offline Mode: Disconnect the internet, and the app will continue generating colors.
4.	Sync: Reconnect to the internet, and unsynced colors will be uploaded automatically.


📝 Commit Message Convention

We follow Conventional Commits:
•	feat: → New feature (feat: add offline sync)
- Fix: → Bug fix (fix: prevent duplicate HEX codes)
- Refactor: → Code change without adding a new feature or fix
- Docs: → Documentation changes
- Style: → Formatting changes

