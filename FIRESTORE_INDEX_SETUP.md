# Firestore Index Setup Guide

## 🔥 Missing Index Error

You're seeing this error because Firestore requires a composite index for the "My Reports History" query.

```
The query requires an index. You can create it here: https://console.firebase.google.com/...
```

---

## ✅ Quick Fix - Option 1: Click the Link (Easiest)

1. **Click the URL in the error message** - It will take you directly to Firebase Console
2. **Click "Create Index"** button
3. **Wait 2-5 minutes** for the index to build
4. **Try again** - The query will work!

---

## ✅ Option 2: Manual Creation via Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **egypt-fault-map**
3. Click **Firestore Database** in the left menu
4. Click **Indexes** tab
5. Click **Create Index**
6. Configure the index:
   - **Collection ID:** `faults`
   - **Fields to index:**
     - Field: `createdBy` | Order: `Ascending`
     - Field: `createdAt` | Order: `Descending`
   - **Query scope:** `Collection`
7. Click **Create**
8. Wait for the index to build (2-5 minutes)

---

## ✅ Option 3: Deploy via Firebase CLI (Automated)

If you have Firebase CLI installed:

```bash
# Make sure you're logged in
firebase login

# Deploy the indexes
firebase deploy --only firestore:indexes
```

The `firestore.indexes.json` file has been created in your project root with the required index configuration.

---

## 📋 Required Index Details

**Collection:** `faults`

**Fields:**
1. `createdBy` (Ascending)
2. `createdAt` (Descending)

**Why this index is needed:**
- The "My Reports History" screen queries faults by `createdBy` (to get user's faults)
- Then orders them by `createdAt` (to show newest first)
- Firestore requires a composite index for queries with multiple fields

---

## 🎯 What This Index Does

This index allows the query in `MyReportsCubit`:

```dart
await firestore
    .collection('faults')
    .where('createdBy', isEqualTo: userId)  // Filter by user
    .orderBy('createdAt', descending: true)  // Sort by date
    .get();
```

---

## ⏱️ Index Build Time

- **Small datasets:** 1-2 minutes
- **Medium datasets:** 3-5 minutes
- **Large datasets:** 5-10 minutes

You'll receive an email when the index is ready, or you can check the status in Firebase Console.

---

## 🚨 Temporary Workaround (Until Index is Ready)

If you need the feature to work immediately before the index is ready, you can temporarily simplify the query:

### Option A: Remove ordering (show in any order)
```dart
// In my_reports_cubit.dart
final snapshot = await firestore
    .collection('faults')
    .where('createdBy', isEqualTo: userId)
    .get();
```

### Option B: Fetch all and sort in memory
```dart
final snapshot = await firestore
    .collection('faults')
    .where('createdBy', isEqualTo: userId)
    .get();

final faults = snapshot.docs.map((doc) => FaultModel.fromDoc(doc)).toList();
faults.sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Sort in memory
```

**Note:** These workarounds are less efficient. Use them only temporarily!

---

## ✅ Verification

After creating the index, verify it works:

1. Go to Profile → My Reports History
2. If faults load without errors, the index is working! ✅
3. If you still see errors, wait a few more minutes for the index to fully build

---

## 📝 Index Status Check

Check index status in Firebase Console:
- **Building** 🔨 - Index is being created (wait)
- **Enabled** ✅ - Index is ready to use
- **Error** ❌ - Check configuration and retry

---

## 🎉 After Index is Created

Once the index is ready:
- ✅ My Reports History will load instantly
- ✅ No more errors
- ✅ Query will be super fast
- ✅ Real-time updates will work

---

## 🔮 Future Indexes You Might Need

As you add more features, you might need indexes for:

1. **Filter faults by status and date:**
   ```
   Fields: status (Asc), createdAt (Desc)
   ```

2. **Search nearby faults by location:**
   ```
   Fields: location (Geohash), createdAt (Desc)
   ```

3. **Filter by severity and date:**
   ```
   Fields: severity (Asc), createdAt (Desc)
   ```

Add these to `firestore.indexes.json` when needed!

---

**Current Status:** Index configuration file created ✅  
**Next Step:** Deploy the index or click the Firebase Console link in the error message  
**Time Required:** 2-5 minutes for index to build
