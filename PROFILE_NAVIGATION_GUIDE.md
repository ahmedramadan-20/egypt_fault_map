# Profile Features - Navigation Guide

## 🗺️ Complete Navigation Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│                          HOME SCREEN                                │
│                                                                     │
│  [Profile Icon] ───────────────────────────────────────────────┐   │
└────────────────────────────────────────────────────────────────│───┘
                                                                  │
                                                                  ▼
┌─────────────────────────────────────────────────────────────────────┐
│                       PROFILE SCREEN                                │
│  ┌───────────────────────────────────────────────────────────┐     │
│  │  👤  John Doe                                             │     │
│  │  📧  john.doe@example.com                                 │     │
│  └───────────────────────────────────────────────────────────┘     │
│                                                                     │
│  ┌──────────────┐  ┌──────────────┐                               │
│  │ My Reports   │  │ Total Faults │                               │
│  │     15       │  │     1,234    │                               │
│  └──────────────┘  └──────────────┘                               │
│                                                                     │
│  📋 Options Menu:                                                  │
│  ├─ 👤 Account Information ─────────────────────────┐             │
│  ├─ 📜 My Reports History ──────────────────────────┼─────┐       │
│  ├─ 🔔 Notifications ───────────────────────────────┼─────┼───┐   │
│  ├─ ⚙️  Settings ──────────────────────────────────┼─────┼───┼──┐│
│  ├─ ❓ Help & Support ─────────────────────────────┼─────┼───┼──┼┤
│  ├─ ℹ️  About                                       │     │   │  ││
│  └─ 🚪 Logout                                       │     │   │  ││
└──────────────────────────────────────────────────────┼─────┼───┼──┼┘
                                                       │     │   │  │
                           ┌───────────────────────────┘     │   │  │
                           │                                 │   │  │
                           ▼                                 │   │  │
┌─────────────────────────────────────────────────────────┐ │   │  │
│              EDIT PROFILE SCREEN                        │ │   │  │
│  ┌───────────────────────────────────────────────────┐  │ │   │  │
│  │  📷 [Profile Picture]                             │  │ │   │  │
│  │     [Camera Icon]                                 │  │ │   │  │
│  └───────────────────────────────────────────────────┘  │ │   │  │
│                                                          │ │   │  │
│  ✏️  Name: [John Doe        ]                           │ │   │  │
│  📧  Email: [john@example.com] 🔒 (read-only)           │ │   │  │
│  📱  Phone: [+20 123 456 7890]                          │ │   │  │
│                                                          │ │   │  │
│  ┌────────────────────────────────────────────────────┐ │ │   │  │
│  │           [Save Changes]                           │ │ │   │  │
│  └────────────────────────────────────────────────────┘ │ │   │  │
│                                                          │ │   │  │
│  Features:                                               │ │   │  │
│  ✅ Take photo with camera                              │ │   │  │
│  ✅ Choose from gallery                                 │ │   │  │
│  ✅ Remove existing photo                               │ │   │  │
│  ✅ Upload to Firebase Storage                          │ │   │  │
│  ✅ Form validation                                      │ │   │  │
│  ✅ Auto-refresh profile after save                     │ │   │  │
└──────────────────────────────────────────────────────────┘ │   │  │
                                                             │   │  │
                           ┌─────────────────────────────────┘   │  │
                           │                                     │  │
                           ▼                                     │  │
┌─────────────────────────────────────────────────────────────┐ │  │
│           MY REPORTS HISTORY SCREEN                         │ │  │
│  ┌───────────────────────────────────────────────────────┐  │ │  │
│  │  📊 Your Impact                                       │  │ │  │
│  │  Pending: 5  │  In Progress: 3  │  Resolved: 7       │  │ │  │
│  └───────────────────────────────────────────────────────┘  │ │  │
│                                              [Filter 🔽]     │ │  │
│  ┌───────────────────────────────────────────────────────┐  │ │  │
│  │ 🔴 Pothole on Main Street                            │  │ │  │
│  │ Status: Pending  │  Dec 15, 2024                     │  │ │  │
│  └───────────────────────────────────────────────────────┘  │ │  │
│  ┌───────────────────────────────────────────────────────┐  │ │  │
│  │ 💡 Broken Street Light                               │  │ │  │
│  │ Status: In Progress  │  Dec 14, 2024                 │  │ │  │
│  └───────────────────────────────────────────────────────┘  │ │  │
│  ┌───────────────────────────────────────────────────────┐  │ │  │
│  │ 💧 Water Leak                                         │  │ │  │
│  │ Status: Resolved  │  Dec 13, 2024                    │  │ │  │
│  └───────────────────────────────────────────────────────┘  │ │  │
│                                                              │ │  │
│  Features:                                                   │ │  │
│  ✅ View all user's reports                                 │ │  │
│  ✅ Status breakdown dashboard                              │ │  │
│  ✅ Filter by status (All/Pending/In Progress/Resolved)     │ │  │
│  ✅ Pull-to-refresh                                          │ │  │
│  ✅ Tap to view fault details                               │ │  │
│  ✅ Empty state with action                                 │ │  │
└──────────────────────────────────────────────────────────────┘ │  │
                                                                 │  │
                           ┌─────────────────────────────────────┘  │
                           │                                        │
                           ▼                                        │
┌─────────────────────────────────────────────────────────────┐    │
│           NOTIFICATIONS SETTINGS SCREEN                     │    │
│  ┌───────────────────────────────────────────────────────┐  │    │
│  │  🔔 Enable Notifications          [Toggle ON/OFF]    │  │    │
│  └───────────────────────────────────────────────────────┘  │    │
│                                                              │    │
│  Notification Types:                                         │    │
│  ├─ 🔄 Fault Updates            [✓]                         │    │
│  ├─ 📍 Nearby Faults            [✓]                         │    │
│  ├─ 👥 Community Updates        [ ]                         │    │
│  └─ 📢 System Announcements     [✓]                         │    │
│                                                              │    │
│  Notification Frequency:                                     │    │
│  ⚪ Instant                                                  │    │
│  ⚪ Hourly Digest                                            │    │
│  ⚪ Daily Digest                                             │    │
│                                                              │    │
│  Quick Actions:                                              │    │
│  ├─ 🗑️  Clear All Notifications                            │    │
│  └─ 📜 Notification History                                 │    │
│                                                              │    │
│  Features:                                                   │    │
│  ✅ Master notification toggle                              │    │
│  ✅ Individual notification types                           │    │
│  ✅ Frequency preferences                                   │    │
│  ✅ Quick action buttons                                    │    │
│  ✅ Visual feedback                                          │    │
└──────────────────────────────────────────────────────────────┘    │
                                                                    │
                           ┌────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                  SETTINGS SCREEN                            │
│                                                              │
│  Notifications:                                              │
│  ├─ 🔔 Push Notifications       [✓]                         │
│  ├─ 📧 Email Notifications      [ ]                         │
│  └─ 📍 Nearby Alerts            [✓]                         │
│                                                              │
│  Appearance:                                                 │
│  ├─ 🌙 Dark Mode                [ ]                         │
│  └─ 🌍 Language                 [English ▼]                 │
│                                                              │
│  Map Settings:                                               │
│  └─ 🗺️  Map Style               [Standard ▼]               │
│                                                              │
│  Privacy & Security:                                         │
│  ├─ 🔒 Privacy Policy                                       │
│  └─ 📜 Terms of Service                                     │
│                                                              │
│  Data:                                                       │
│  ├─ 💾 Download My Data                                     │
│  └─ 🗑️  Delete Account         (Dangerous)                 │
│                                                              │
│  Features:                                                   │
│  ✅ Comprehensive app preferences                           │
│  ✅ Toggle switches for boolean options                     │
│  ✅ Dialog selections for choices                           │
│  ✅ Confirmation for dangerous actions                      │
│  ✅ Organized into logical sections                         │
└──────────────────────────────────────────────────────────────┘

                           ┌────────────────────────────────────────┐
                           │                                        │
                           ▼                                        │
┌─────────────────────────────────────────────────────────────┐    │
│            HELP & SUPPORT SCREEN                            │    │
│  ┌───────────────────────────────────────────────────────┐  │    │
│  │  💬 We're Here to Help                                │  │    │
│  │  Get in touch with our support team                   │  │    │
│  └───────────────────────────────────────────────────────┘  │    │
│                                                              │    │
│  Frequently Asked Questions:                                 │    │
│  ▼ How do I report a fault?                                 │    │
│     Tap the "Report Fault" button on the home screen...     │    │
│                                                              │    │
│  ▶ Can I edit my reported faults?                           │    │
│  ▶ How do I update my profile?                              │    │
│  ▶ What types of faults can I report?                       │    │
│                                                              │    │
│  Contact Us:                                                 │    │
│  ├─ 📧 Email Support                                        │    │
│  ├─ 📞 Phone Support                                        │    │
│  └─ 💬 Live Chat                                            │    │
│                                                              │    │
│  Resources:                                                  │    │
│  ├─ 📖 User Guide                                           │    │
│  ├─ 🎥 Video Tutorials                                      │    │
│  └─ 🐛 Report a Bug                                         │    │
│                                                              │    │
│  Features:                                                   │    │
│  ✅ Expandable FAQ items                                    │    │
│  ✅ Multiple contact methods                                │    │
│  ✅ Resource links                                           │    │
│  ✅ Bug report dialog                                        │    │
│  ✅ Clear, helpful content                                   │    │
└──────────────────────────────────────────────────────────────┘    │
                                                                    │
└───────────────────────────────────────────────────────────────────┘
```

---

## 🎯 Quick Access Paths

### From Home Screen:
```
Home → Profile Icon → Profile Screen
```

### Edit Your Profile:
```
Profile → Account Information → Edit Profile → Save → Auto Refresh
```

### View Your Reports:
```
Profile → My Reports History → [Filter Optional] → Tap Fault → Details
```

### Configure Notifications:
```
Profile → Notifications → Toggle Settings → Auto Save
```

### Change App Settings:
```
Profile → Settings → Adjust Preferences → Auto Save
```

### Get Help:
```
Profile → Help & Support → Browse FAQ / Contact Support
```

---

## 🔄 Data Flow

### Profile Updates:
```
Edit Profile → Update Data → Upload Image (if changed) → Firestore Update → Return → Profile Refresh
```

### Reports Loading:
```
My Reports → Fetch User Faults → Calculate Stats → Apply Filter → Display List
```

### Settings Changes:
```
Settings → Toggle/Select → State Update → UI Refresh
```

---

## 💡 User Journey Examples

### **Scenario 1: Change Profile Picture**
1. Tap Profile icon in Home
2. Tap "Account Information"
3. Tap camera icon on profile picture
4. Choose "Take Photo" or "Choose from Gallery"
5. Select/capture image
6. Tap "Save Changes"
7. ✅ Profile updates automatically

### **Scenario 2: Check My Contribution**
1. Tap Profile icon in Home
2. See statistics: "My Reports: 15"
3. Tap "My Reports History"
4. See breakdown: Pending: 5, In Progress: 3, Resolved: 7
5. Tap filter icon
6. Select "Resolved" to see only resolved faults
7. ✅ View all successful contributions

### **Scenario 3: Disable Email Notifications**
1. Tap Profile icon in Home
2. Tap "Notifications"
3. Scroll to "Email Notifications"
4. Toggle OFF
5. ✅ Email notifications disabled

### **Scenario 4: Change App Language**
1. Tap Profile icon in Home
2. Tap "Settings"
3. Under "Appearance", tap "Language"
4. Select "العربية"
5. ✅ App language changes to Arabic

### **Scenario 5: Get Help with Feature**
1. Tap Profile icon in Home
2. Tap "Help & Support"
3. Tap "How do I report a fault?" in FAQ
4. Read the expanded answer
5. ✅ Learn how to use the feature

---

## 🎨 Screen Features Matrix

| Screen | Pull-to-Refresh | Loading State | Error State | Empty State | Filter |
|--------|----------------|---------------|-------------|-------------|---------|
| Profile | ✅ | ✅ | ✅ | ❌ | ❌ |
| Edit Profile | ❌ | ✅ | ✅ | ❌ | ❌ |
| My Reports | ✅ | ✅ | ✅ | ✅ | ✅ |
| Notifications | ❌ | ❌ | ❌ | ❌ | ❌ |
| Settings | ❌ | ❌ | ❌ | ❌ | ❌ |
| Help & Support | ❌ | ❌ | ❌ | ❌ | ❌ |

---

## 🚀 Performance Notes

- **Profile Screen:** Loads 3 data sources in parallel (~500ms)
- **Edit Profile:** Image compression before upload (85% quality)
- **My Reports:** Efficient Firestore query with indexing
- **Notifications:** State-based, instant updates
- **Settings:** In-memory state management
- **Help & Support:** Static content, instant load

---

## 📱 Responsive Design

All screens are fully responsive using `flutter_screenutil`:
- ✅ Works on all phone sizes
- ✅ Proper scaling for tablets
- ✅ Maintains proportions
- ✅ Readable text on all devices
- ✅ Touch targets are appropriate size

---

**Navigation is intuitive and user-friendly!** 🎉
