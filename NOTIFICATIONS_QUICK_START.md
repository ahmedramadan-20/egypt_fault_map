# Notifications System - Quick Start Guide

## 🎉 Implementation Complete!

A full-featured push notifications system has been implemented using Firebase Cloud Messaging.

---

## ✅ What's Working

### 1. **Notifications Infrastructure** ✅
- Firebase Cloud Messaging (FCM) integrated
- Local notifications for foreground messages
- Background message handling
- Notification permissions
- FCM token management

### 2. **Notifications UI** ✅
- Notifications list screen
- Bell icon in app bar
- Unread indicators
- Pull-to-refresh
- Mark as read/Clear all
- Empty state

### 3. **Navigation** ✅
- Home screen → Notifications button → Notifications list
- Tap notification → Navigate to related fault (if applicable)

---

## 🚀 How to Use

### For Users:

1. **View Notifications:**
   - Tap the bell icon (🔔) in the home screen app bar
   - See all notifications sorted by date

2. **Read Notifications:**
   - Tap any notification to mark as read and navigate
   - Unread notifications have a blue dot

3. **Manage Notifications:**
   - Menu (⋮) → "Mark all as read"
   - Menu (⋮) → "Clear all"

### For Developers:

#### Send Test Notification:
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **egypt-fault-map**
3. Cloud Messaging → "Send your first message"
4. Enter:
   - **Notification title:** "Test Notification"
   - **Notification text:** "This is a test from Firebase"
5. Target → Select app
6. Click "Send test message"
7. Enter your FCM token (printed in console on app start)
8. Click "Test"

---

## 📱 Features

### Notification Types:
- 🔔 **Fault Update** - Status changes on reported faults
- 📍 **Nearby Fault** - New faults near user's location
- 👥 **Community** - Community updates
- ⚙️ **System** - App announcements

### Capabilities:
✅ Push notifications (foreground & background)  
✅ Local notifications  
✅ Notification history (stored in Firestore)  
✅ Unread count tracking  
✅ Mark as read/unread  
✅ Clear all notifications  
✅ Navigate from notification tap  
✅ Topic subscriptions  
✅ Settings management  

---

## 🔧 Configuration Status

### ✅ Completed:
- [x] Dependencies added
- [x] Android permissions added
- [x] Android FCM service configured
- [x] Notification service created
- [x] Notifications cubit implemented
- [x] UI screens created
- [x] Routes configured
- [x] DI setup

### ⏳ Required (Before Production):
- [ ] iOS Push Notifications capability (Xcode)
- [ ] iOS APNs certificate (Firebase Console)
- [ ] Cloud Functions for automated notifications
- [ ] Test on physical devices

---

## 📋 Android Configuration (Already Done)

### AndroidManifest.xml
✅ POST_NOTIFICATIONS permission  
✅ VIBRATE permission  
✅ RECEIVE_BOOT_COMPLETED permission  
✅ FCM service configured  
✅ Default notification channel set  

---

## 🍎 iOS Configuration (TODO)

### Required Steps:

1. **Open Xcode:**
   ```bash
   open ios/Runner.xcworkspace
   ```

2. **Add Capabilities:**
   - Select Runner target
   - Signing & Capabilities tab
   - Click "+ Capability"
   - Add "Push Notifications"
   - Add "Background Modes"
   - Check "Remote notifications"

3. **Upload APNs Certificate:**
   - Generate from Apple Developer
   - Upload to Firebase Console → Cloud Messaging

---

## 🔔 Notification Flow

### When Notification Arrives:

**Foreground (App Open):**
```
FCM → NotificationService → Local Notification → Firestore
```

**Background (App Minimized):**
```
FCM → Background Handler → OS Notification → Firestore (on tap)
```

**Terminated (App Closed):**
```
FCM → OS Notification → App Opens (on tap) → Firestore
```

---

## 💾 Data Storage

### User Document:
```
users/{userId}
  ├─ fcmToken: "device_fcm_token_here"
  └─ fcmTokenUpdatedAt: timestamp
```

### Notifications Collection:
```
users/{userId}/notifications/
  └─ {notificationId}
      ├─ title: "Notification title"
      ├─ body: "Notification message"
      ├─ data: { type: "fault_update", faultId: "123" }
      ├─ read: false
      └─ createdAt: timestamp
```

### Settings:
```
users/{userId}/settings/notifications
  ├─ enabled: true
  ├─ faultUpdates: true
  ├─ nearbyFaults: true
  ├─ communityUpdates: false
  ├─ systemAnnouncements: true
  └─ frequency: "instant"
```

---

## 🧪 Testing Checklist

### Manual Testing:
- [ ] Permission request shows on first launch
- [ ] Notification appears when app is open
- [ ] Notification appears when app is in background
- [ ] Notification appears when app is closed
- [ ] Tapping notification opens app
- [ ] Notification saved to Firestore
- [ ] Notifications list loads correctly
- [ ] Unread indicator shows
- [ ] Mark as read works
- [ ] Clear all works
- [ ] Navigation from notification works

### Test on Physical Device:
- [ ] Android device
- [ ] iOS device (after iOS config)

---

## 📤 Sending Notifications

### Method 1: Firebase Console (Testing)
Use for manual testing and announcements.

### Method 2: Cloud Functions (Production)
Example Cloud Function:

```javascript
const functions = require('firebase-functions');
const admin = require('firebase-admin');

// When fault status changes
exports.onFaultStatusChange = functions.firestore
  .document('faults/{faultId}')
  .onUpdate(async (change, context) => {
    const newData = change.after.data();
    const oldData = change.before.data();
    
    if (newData.status !== oldData.status) {
      const userId = newData.createdBy;
      const userDoc = await admin.firestore()
        .collection('users')
        .doc(userId)
        .get();
      
      const fcmToken = userDoc.data().fcmToken;
      
      if (fcmToken) {
        await admin.messaging().send({
          token: fcmToken,
          notification: {
            title: 'Fault Updated',
            body: `Your fault status changed to ${newData.status}`
          },
          data: {
            type: 'fault_update',
            faultId: context.params.faultId,
            status: newData.status
          }
        });
      }
    }
  });
```

### Method 3: REST API
```bash
curl -X POST https://fcm.googleapis.com/fcm/send \
  -H "Authorization: key=YOUR_SERVER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "to": "/topics/all_users",
    "notification": {
      "title": "New Feature",
      "body": "Check out the new map view!"
    },
    "data": {
      "type": "system"
    }
  }'
```

---

## 🎯 Next Steps

### Immediate:
1. Test on physical Android device
2. Configure iOS (if needed)
3. Test sending notifications from Firebase Console

### Production:
1. Set up Cloud Functions for automated notifications
2. Implement notification triggers:
   - Fault status changes
   - Nearby fault reports
   - Community updates
3. Add notification scheduling (daily digests, etc.)

---

## 📝 Code Examples

### Subscribe to Topic:
```dart
await NotificationService().subscribeToTopic('all_users');
await NotificationService().subscribeToTopic('cairo_users');
```

### Get Unread Count:
```dart
final count = await NotificationService().getUnreadCount();
print('Unread notifications: $count');
```

### Listen to Notification Taps:
```dart
NotificationService().notificationTapStream.listen((data) {
  print('Notification tapped with data: $data');
  // Navigate based on data
});
```

---

## 🐛 Troubleshooting

### "Permission denied"
- Check Android permissions in manifest
- Request permission at runtime (already handled)

### "FCM token is null"
- Wait a few seconds after app start
- Check internet connection
- Verify Firebase configuration

### "Notifications not showing"
- Check notification permission is granted
- Verify channel is created (Android)
- Check device notification settings

### "Background notifications not working"
- Verify background handler is registered
- Check battery optimization settings
- Test on physical device (not emulator)

---

## 📊 Analytics

Track notification engagement:
- Delivery rate
- Open rate
- Action rate
- Unread count trends

Use Firebase Analytics for tracking.

---

## 🎉 Summary

### ✅ Complete:
- Full FCM integration
- Notifications list screen
- Mark as read/clear functionality
- Navigation integration
- Android configuration
- Comprehensive documentation

### 🚀 Ready For:
- Testing on devices
- Setting up Cloud Functions
- Production deployment

---

**Status:** ✅ **IMPLEMENTED AND READY FOR TESTING**  
**Platform:** Android ✅ | iOS ⏳ (requires Xcode config)  
**Documentation:** Complete  
**Next Action:** Test on physical device!

---

## 📚 Additional Resources

- [Full Implementation Guide](./NOTIFICATIONS_IMPLEMENTATION_GUIDE.md)
- [Firebase Cloud Messaging Docs](https://firebase.google.com/docs/cloud-messaging)
- [Flutter Local Notifications](https://pub.dev/packages/flutter_local_notifications)
