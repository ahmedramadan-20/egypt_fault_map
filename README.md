# Egypt Fault Map 🚨🗺️  
A Flutter mobile application that helps users report, track, and visualize public infrastructure issues across Egypt — including water leaks, road damage, street light outages, and electricity faults.

The system allows citizens to submit fault reports with images, descriptions, and auto-detected location, while admins can manage, track, and update issue statuses in real-time.

---

## 📱 Features

### 🧭 User Features
- **Interactive Google Map** with real-time fault markers  
- **Auto-location detection** using GPS  
- **Submit new faults** with:
  - Fault type  
  - Description  
  - Automatic lat/lng  
  - Image (Camera/Gallery)  
- **View fault details** including image, status, and location  
- **Track your reported issues** in “My Reports”  
- **Real-time updates** from Firestore streams  

### 👨‍🔧 Admin Features
- View all reported faults  
- Filter by type and status  
- Update fault status:  
  - `Pending`  
  - `In Progress`  
  - `Completed`  
- Admin dashboard overview (mobile)

---

## 🏗️ Architecture

This project follows a **clean and scalable architecture** with separation of concerns:

lib
├── core
│ ├── di/ → Service Locator (GetIt)
│ ├── networking/ → Firebase Config
│ ├── helpers/ → Permissions, Logging, Utilities
│ ├── routing/ → App Router
│ ├── theming/ → App Theme
│ └── widgets/ → Shared UI Components
│
└── features
└── faults
├── data/
│ ├── models → FaultModel
│ ├── datasources → RemoteDataSource (Firestore)
│ └── repos → Repo + Impl
├── logic/
│ └── faults_cubit → Business Logic
└── ui/
├── screens → Map, Report, Details, MyReports
└── widgets


- State Management: **Cubit (flutter_bloc)**
- Dependency Injection: **GetIt**
- Data storage: **Firebase Firestore + Storage**
- Maps: **Google Maps Flutter**

---

## 🧩 Tech Stack

- **Flutter 3.x**
- **Dart**
- **Firebase Auth**
- **Firebase Firestore**
- **Firebase Storage**
- **Google Maps**
- **Geolocator**
- **GetIt**
- **flutter_bloc**

---

## 🌍 Screens Overview

- **Splash Screen**  
- **Onboarding (3 screens)**  
- **Login / Register**  
- **Home Map Screen**  
- **Report Fault Screen**  
- **Fault Details Screen**  
- **My Reports**  
- **Profile**  
- **Admin Dashboard**

---

## 📐 Database Structure (Firestore)

### Collection: `faults`
| Field        | Type     | Description                      |
|--------------|----------|----------------------------------|
| id           | string   | Unique fault ID                  |
| type         | string   | Fault category                   |
| description  | string   | User description                 |
| imageUrl     | string   | Uploaded image URL               |
| lat          | double   | Latitude                         |
| lng          | double   | Longitude                        |
| status       | string   | pending / in-progress / completed |
| userId       | string   | Reporter user ID                 |
| createdAt    | timestamp| Time of reporting                |

---

## ▶️ Getting Started

### 1. Clone the repo
```bash
git clone https://github.com/your-username/egypt-fault-map.git
cd egypt-fault-map
```
3. Add Firebase

Add your google-services.json (Android)

Add your GoogleService-Info.plist (iOS)

Enable:

Firestore

Auth (Email/Password)

Storage

4. Add Google Maps Key

Update:

AndroidManifest.xml

AppDelegate.swift

💡 Future Enhancements

Push notifications for status updates

AI auto-categorization of fault images

Web dashboard for government administrators

Offline mode with cached markers

Multi-language support (Arabic + English)

🧑‍💻 Author

Ahmed — Flutter Developer
Open to full-time opportunities in Mobile Development.

⭐️ If you like this project

Give it a star ⭐ on GitHub — it helps a lot!
