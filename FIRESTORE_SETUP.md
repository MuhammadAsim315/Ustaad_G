# Firestore Database Setup ✅

## Overview
Firestore has been integrated into your project to store:
- **User Data**: Profile information, preferences
- **History**: Service bookings and history
- **Icons**: Icon paths and configurations (for easier mobile loading)
- **Bookings**: Active and completed bookings

## Database Structure

### Collections:

1. **`users`** - User profile data
   ```
   {
     userId: {
       name: string,
       email: string,
       phone: string,
       profileImageUrl: string,
       createdAt: timestamp,
       updatedAt: timestamp
     }
   }
   ```

2. **`history`** - Service history
   ```
   {
     historyId: {
       userId: string,
       serviceName: string,
       serviceSvgPath: string,
       serviceColor: string (color value),
       providerName: string,
       date: timestamp,
       time: string,
       address: string,
       amount: number,
       status: string,
       createdAt: timestamp
     }
   }
   ```

3. **`icons`** - Icon configurations
   ```
   {
     categoryName (lowercase): {
       categoryName: string,
       svgPath: string,
       colorHex: string,
       updatedAt: timestamp
     }
   }
   ```

4. **`bookings`** - Active bookings
   ```
   {
     bookingId: {
       userId: string,
       serviceName: string,
       serviceSvgPath: string,
       serviceColor: string,
       providerName: string,
       date: timestamp,
       time: string,
       address: string,
       amount: number,
       status: string (upcoming/ongoing/completed),
       createdAt: timestamp,
       updatedAt: timestamp
     }
   }
   ```

## Features Implemented:

### ✅ FirestoreService (`lib/app/services/firestore_service.dart`)
- User data management (save, get, update)
- History management (save, get by status)
- Icon configuration management
- Booking management (save, get, update status, delete)

### ✅ IconHelper Updated (`lib/app/utils/icon_helper.dart`)
- Loads icon paths from Firestore at app start
- Falls back to local assets if Firestore fails
- Caches icons for fast access
- Synchronous getter for easy use in widgets

### ✅ Auto-Initialization
- Icons are automatically initialized in Firestore on first app run
- Icons are loaded from Firestore on every app start
- Falls back to local assets if Firestore is unavailable

### ✅ User Data Integration
- User data saved to Firestore on signup
- User data loaded from Firestore on login
- Profile updates sync to Firestore

## Usage Examples:

### Save User Data:
```dart
await FirestoreService.saveUserData(
  userId: 'user123',
  name: 'John Doe',
  email: 'john@example.com',
  phone: '+1234567890',
);
```

### Save Booking:
```dart
final bookingId = await FirestoreService.saveBooking(
  userId: 'user123',
  serviceName: 'Plumber',
  serviceSvgPath: 'icon/plumber.svg',
  serviceColorValue: Colors.blue.value,
  providerName: 'Ahmed Ali',
  date: DateTime.now(),
  time: '10:00 AM',
  address: '123 Main St',
  amount: 2500.0,
  status: 'upcoming',
);
```

### Get User History:
```dart
Stream<QuerySnapshot> historyStream = FirestoreService.getUserHistory('user123');
```

### Get Icon Path:
```dart
String? iconPath = IconHelper.getSvgIconPath('Plumber');
// Returns: 'icon/plumber.svg' (from Firestore or local)
```

## Next Steps:

1. **Enable Firestore in Firebase Console:**
   - Go to Firebase Console → Firestore Database
   - Click "Create Database"
   - Start in test mode (you can add security rules later)

2. **Set up Security Rules** (Important for production):
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /users/{userId} {
         allow read, write: if request.auth != null && request.auth.uid == userId;
       }
       match /history/{historyId} {
         allow read, write: if request.auth != null && request.auth.uid == resource.data.userId;
       }
       match /bookings/{bookingId} {
         allow read, write: if request.auth != null && request.auth.uid == resource.data.userId;
       }
       match /icons/{iconId} {
         allow read: if true;
         allow write: if request.auth != null;
       }
     }
   }
   ```

3. **Test the Integration:**
   - Run the app
   - Create a new account
   - Check Firebase Console → Firestore Database to see the data

## Benefits:

- ✅ Icons load from database (easier to update without app update)
- ✅ User data persists across devices
- ✅ History is stored in the cloud
- ✅ Bookings are synced across devices
- ✅ Real-time updates possible with Streams
- ✅ Scalable database solution

Your Firestore database is ready to use! 🎉

