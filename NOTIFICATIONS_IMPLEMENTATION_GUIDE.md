# Notifications System - Complete Implementation Guide

## 🎉 Overview

A comprehensive push notifications system using Firebase Cloud Messaging (FCM) has been implemented for the Egypt Fault Map application.

---

## ✅ What Was Implemented

### 1. **Notification Service** (Core Backend)
**Location:** `lib/core/services/notification_service.dart`

**Features:**
- ✅ Firebase Cloud Messaging integration
- ✅ Local notifications for foreground messages
- ✅ Background message handling
- ✅ Notification permission requests
- ✅ FCM token management (saved to Firestore)
- ✅ Notification history in Firestore
- ✅ Topic subscription/unsubscription
- ✅ Notification settings management
- ✅ Unread count tracking
- ✅ Mark as read functionality
- ✅ Clear all notifications

**Key Methods:**
```dart
// Initialize notifications
await NotificationService().initialize();

// Subscribe to topic
await NotificationService().subscribeToTopic('all_users');

// Get unread count
int count = await NotificationService().getUnreadCount();

// Mark as read
await NotificationService().markAsRead(notificationId);

// Clear all
await NotificationService().clearAllNotifications();
```

---

### 2. **Notification Model**
**Location:** `lib/features/notifications/data/models/notification_model.dart`

**Properties:**
- `id` - Unique notification ID
- `title` - Notification title
- `body` - Notification body
- `data` - Custom payload data
- `read` - Read status
- `createdAt` - Timestamp
- `type` - Notification type (fault_update, nearby_fault, community, system)

---

### 3. **Notifications Cubit** (State Management)
**Location:** `lib/features/notifications/logic/notifications_cubit.dart`

**Features:**
- ✅ Load notifications from Firestore
- ✅ Real-time notifications updates
- ✅ Mark as read functionality
- ✅ Mark all as read
- ✅ Clear all notifications
- ✅ Unread count tracking

**States:**
- `NotificationsInitial`
- `NotificationsLoading`
- `NotificationsLoaded` (with notifications list and unread count)
- `NotificationsError`

---

### 4. **Notifications List Screen**
**Location:** `lib/features/notifications/ui/notifications_list_screen.dart`

**Features:**
- ✅ List of all notifications
- ✅ Unread indicator (blue dot)
- ✅ Color-coded by type
- ✅ Time formatting (Just now, 5m ago, 3h ago, etc.)
- ✅ Pull-to-refresh
- ✅ Mark all as read action
- ✅ Clear all action
- ✅ Tap to navigate to related fault
- ✅ Empty state
- ✅ Error handling

**Notification Types:**
- 🔔 **Fault Update** - Updates on your reported faults
- 📍 **Nearby Fault** - New faults near your location
- 👥 **Community** - Community updates
- ⚙️ **System** - App announcements

---

### 5. **UI Integration**

#### Home Screen App Bar
Added notifications button:
```
[Profile] [App Title]  [🔔 Notifications] [Sync] [Map/List]
```

#### Navigation
Added route: `Routes.notificationsScreen`

---

## 🏗️ Architecture

### Data Flow

```
Firebase Cloud Messaging
        ↓
NotificationService (receives message)
        ↓
        ├─→ Foreground: Show local notification
        ├─→ Background: Handle in background
        └─→ Save to Firestore
        ↓
NotificationsCubit (loads from Firestore)
        ↓
NotificationsListScreen (displays to user)
```

### Firestore Structure

```
users/{userId}/
  ├─ fcmToken: "device_token"
  ├─ fcmTokenUpdatedAt: timestamp
  └─ notifications/
      └─ {notificationId}/
          ├─ title: "Fault Updated"
          ├─ body: "Your reported fault has been resolved"
          ├─ data: { type: "fault_update", faultId: "123" }
          ├─ read: false
          └─ createdAt: timestamp
```

---

## 📦 Dependencies Added

### pubspec.yaml
```yaml
firebase_messaging: ^16.0.4         # FCM for push notifications
flutter_local_notifications: ^18.0.1 # Local notifications
```

---

## 🔧 Configuration Required

### 1. Android Configuration

#### `android/app/build.gradle.kts`
Already configured with google-services.

#### `android/app/src/main/AndroidManifest.xml`
Add inside `<application>` tag:

```xml
<!-- FCM Service -->
<service
    android:name="com.google.firebase.messaging.FirebaseMessagingService"
    android:exported="false">
    <intent-filter>
        <action android:name="com.google.firebase.MESSAGING_EVENT" />
    </intent-filter>
</service>

<!-- Default notification channel -->
<meta-data
    android:name="com.google.android.gms.wallet.api.enabled"
    android:value="true" />
```

Add permissions before `<application>`:

```xml
<!-- Notification permissions -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
```

---

### 2. iOS Configuration

#### `ios/Runner/Info.plist`
Add notification permissions:

```xml
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
```

#### Enable Push Notifications in Xcode:
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select Runner → Signing & Capabilities
3. Click "+ Capability"
4. Add "Push Notifications"
5. Add "Background Modes" and check "Remote notifications"

---

### 3. Firebase Console Setup

#### Enable Cloud Messaging:
1. Go to Firebase Console → Your Project
2. Click Settings (⚙️) → Project settings
3. Go to "Cloud Messaging" tab
4. Note your Server Key (for backend sending)

#### Upload APNs Certificate (iOS):
1. Generate APNs certificate from Apple Developer
2. Upload to Firebase Console → Cloud Messaging → APNs Certificates

---

## 🚀 How It Works

### 1. Initialization
When app starts:
```dart
await NotificationService().initialize();
```

This:
- Requests notification permission
- Gets FCM token
- Saves token to Firestore user document
- Sets up message handlers
- Creates notification channels

---

### 2. Receiving Notifications

#### Foreground (App Open)
- Message received by `onMessage` listener
- Local notification shown
- Saved to Firestore

#### Background (App Closed/Background)
- Message handled by background handler
- OS shows notification
- Saved to Firestore when app opens

#### Terminated (App Killed)
- OS shows notification
- When tapped, app opens
- Handled by `getInitialMessage`

---

### 3. Notification Taps

When user taps a notification:
```dart
NotificationService().notificationTapStream.listen((data) {
  // Navigate based on data
  if (data['faultId'] != null) {
    // Navigate to fault details
  }
});
```

---

### 4. Viewing Notifications

Users can:
1. Tap notifications bell icon in app bar
2. See all notifications sorted by date
3. Unread notifications have blue dot
4. Tap notification to mark as read and navigate
5. Use menu to mark all as read or clear all

---

## 📱 Notification Types

### 1. Fault Update Notifications
Sent when a fault status changes:
```json
{
  "notification": {
    "title": "Fault Updated",
    "body": "Your reported fault has been marked as resolved"
  },
  "data": {
    "type": "fault_update",
    "faultId": "fault_123",
    "status": "resolved"
  }
}
```

### 2. Nearby Fault Notifications
Sent when a fault is reported nearby:
```json
{
  "notification": {
    "title": "New Fault Nearby",
    "body": "A pothole was reported 0.5 km from you"
  },
  "data": {
    "type": "nearby_fault",
    "faultId": "fault_456",
    "distance": "0.5"
  }
}
```

### 3. Community Notifications
Sent for community updates:
```json
{
  "notification": {
    "title": "Community Update",
    "body": "10 faults were resolved in your area this week"
  },
  "data": {
    "type": "community",
    "count": "10"
  }
}
```

### 4. System Notifications
Sent for app announcements:
```json
{
  "notification": {
    "title": "App Update",
    "body": "New features available! Update now."
  },
  "data": {
    "type": "system",
    "action": "update"
  }
}
```

---

## 🔔 Sending Notifications (Backend)

### Option 1: Firebase Console (Manual)
1. Go to Firebase Console → Cloud Messaging
2. Click "Send your first message"
3. Enter notification details
4. Target: Topic "all_users" or specific devices
5. Click "Send"

### Option 2: Cloud Functions (Automated)
Create Firebase Cloud Function to send notifications:

```javascript
const admin = require('firebase-admin');

// Send to specific user
async function sendToUser(userId, title, body, data) {
  const userDoc = await admin.firestore()
    .collection('users')
    .doc(userId)
    .get();
  
  const fcmToken = userDoc.data().fcmToken;
  
  if (fcmToken) {
    await admin.messaging().send({
      token: fcmToken,
      notification: { title, body },
      data: data
    });
  }
}

// Send to topic
async function sendToTopic(topic, title, body, data) {
  await admin.messaging().send({
    topic: topic,
    notification: { title, body },
    data: data
  });
}
```

### Option 3: HTTP API (Backend Server)
```bash
curl -X POST https://fcm.googleapis.com/fcm/send \
  -H "Authorization: key=YOUR_SERVER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "to": "/topics/all_users",
    "notification": {
      "title": "New Fault",
      "body": "A fault was reported nearby"
    },
    "data": {
      "type": "nearby_fault",
      "faultId": "123"
    }
  }'
```

---

## 🎯 Use Cases

### 1. Fault Status Update
When admin changes fault status:
```dart
// In Cloud Function or Backend
await sendToUser(
  faultCreatorId,
  "Fault Updated",
  "Your reported fault has been resolved",
  {
    "type": "fault_update",
    "faultId": faultId,
    "status": "resolved"
  }
);
```

### 2. Nearby Fault Alert
When new fault is reported:
```dart
// Find nearby users (within radius)
// Send notification to each
await sendToUser(
  userId,
  "New Fault Nearby",
  "A pothole was reported 0.5 km from you",
  {
    "type": "nearby_fault",
    "faultId": faultId,
    "distance": "0.5"
  }
);
```

### 3. Broadcast Announcement
Send to all users:
```dart
await sendToTopic(
  "all_users",
  "Maintenance Notice",
  "The app will be down for maintenance tonight",
  {
    "type": "system",
    "action": "info"
  }
);
```

---

## 🧪 Testing

### 1. Test Notification Permission
```dart
// Check if permission is granted
final settings = await FirebaseMessaging.instance.getNotificationSettings();
print('Permission: ${settings.authorizationStatus}');
```

### 2. Test FCM Token
```dart
final token = await FirebaseMessaging.instance.getToken();
print('FCM Token: $token');
```

### 3. Test Manual Notification
Use Firebase Console to send a test notification to your device.

### 4. Test Notification Tap
Send notification and verify navigation works.

---

## 📊 Firestore Security Rules

Add to `firestore.rules`:

```javascript
match /users/{userId}/notifications/{notificationId} {
  allow read: if request.auth.uid == userId;
  allow write: if request.auth.uid == userId || 
                  request.auth.token.admin == true;
}

match /users/{userId}/settings/notifications {
  allow read, write: if request.auth.uid == userId;
}
```

---

## 🎨 UI Features

### Notifications List
- ✅ Sorted by date (newest first)
- ✅ Unread indicator (blue dot)
- ✅ Color-coded icons by type
- ✅ Relative time (5m ago, 3h ago)
- ✅ Pull-to-refresh
- ✅ Empty state
- ✅ Error handling

### Actions
- ✅ Tap notification → Mark as read + Navigate
- ✅ Menu → Mark all as read
- ✅ Menu → Clear all (with confirmation)

---

## ⚙️ Notification Settings

Users can configure preferences in Profile → Notifications:
- Enable/disable notifications
- Choose notification types
- Set frequency (instant/hourly/daily)

Settings are saved to Firestore:
```
users/{userId}/settings/notifications
```

---

## 🔮 Future Enhancements

1. **Rich Notifications**
   - Images in notifications
   - Action buttons
   - Progress indicators

2. **Scheduled Notifications**
   - Daily digests
   - Weekly summaries
   - Reminder notifications

3. **Smart Notifications**
   - ML-based relevance
   - User behavior patterns
   - Optimal timing

4. **Advanced Filtering**
   - Filter by type
   - Filter by date range
   - Search notifications

---

## 📝 Summary

### Features Delivered:
✅ Complete FCM integration  
✅ Local notifications for foreground  
✅ Background message handling  
✅ Notification history in Firestore  
✅ Notifications list screen  
✅ Mark as read functionality  
✅ Clear all functionality  
✅ Navigation from notifications  
✅ Unread count tracking  
✅ Topic subscription support  
✅ Settings management  
✅ Permission handling  
✅ Token management  

### Next Steps:
1. Configure Android `AndroidManifest.xml`
2. Configure iOS Push Notifications in Xcode
3. Set up Firebase Cloud Functions for automated notifications
4. Test on physical devices
5. Implement notification sending logic

---

**Status:** ✅ **COMPLETE AND READY FOR TESTING**  
**Version:** 1.0  
**Last Updated:** 2024
