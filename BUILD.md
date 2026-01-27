# Building and Testing Morning On Time

## Overview
Morning On Time is a Flutter mobile app that helps families arrive at school on time through voice-driven encouragement and notifications.

## Prerequisites
- Flutter SDK (latest version)
- Android Studio (for Android development)
- Xcode (for iOS development, macOS only)
- A physical Android or iOS device (recommended for testing notifications)

## Setup Instructions

### 1. Get Dependencies
```bash
cd /Users/ESLalaguSe/Repos/morning_on_time
flutter pub get
```

### 2. Android Setup

#### Update AndroidManifest.xml
The AndroidManifest.xml should already be configured, but verify it contains these permissions:

- `android.permission.RECEIVE_BOOT_COMPLETED` - Start notifications after device boot
- `android.permission.SCHEDULE_EXACT_ALARM` - Schedule precise wake-up notifications  
- `android.permission.WAKE_LOCK` - Keep device awake for notifications
- `android.permission.VIBRATE` - Vibrate on notifications
- `android.permission.POST_NOTIFICATIONS` - Show notifications (Android 13+)

#### Build for Android
```bash
# Debug build
flutter build apk --debug

# Release build
flutter build apk --release

# Build and install to connected device
flutter run
```

#### Install on Your Android Device

**Option 1: Direct Install (Easiest for tomorrow morning!)**
```bash
# Make sure your Android device is connected via USB with USB debugging enabled
# Enable Developer Options: Settings > About Phone > tap Build Number 7 times
# Enable USB Debugging: Settings > Developer Options > USB Debugging

flutter install
```

**Option 2: Transfer APK File**
```bash
# Build the APK
flutter build apk --release

# The APK will be at: build/app/outputs/flutter-apk/app-release.apk
# Transfer this file to your Android device and install it
```

### 3. iOS Setup (if applicable)

The Info.plist needs these permissions:
- `NSUserNotificationsUsageDescription` - For push notifications

#### Build for iOS
```bash
flutter build ios

# Or run directly on connected iPhone
flutter run
```

## Testing the App on Your Android Device

### Before Tomorrow Morning:

1. **Install the App**
   ```bash
   cd /Users/ESLalaguSe/Repos/morning_on_time
   flutter install
   ```

2. **Grant Permissions**
   - When you first open the app, grant notification permissions
   - On Android 12+, also grant "Alarms & Reminders" permission in Settings

3. **Complete Setup**
   - Set your wake-up time (e.g., 6:30 AM)
   - Set when you need to leave home (e.g., 7:45 AM)
   - Set latest arrival time at school (e.g., 8:00 AM)

4. **Optional: Add Rewards**
   - Tap "Rewards" from home screen
   - Add rewards like "Movie night after 7 days streak"

### Testing Tomorrow Morning:

The app will automatically:
- Play a wake-up message at your set wake-up time
- Send check-in notification 15 minutes before leaving
- Send countdown notifications before departure
- Prompt for arrival confirmation

When you arrive:
- Tap "Arrived at School" button
- Confirm arrival time
- App will track if you were on time and update your streak

## App Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── app_settings.dart
│   ├── day_record.dart
│   ├── reward.dart
│   └── check_in_status.dart
├── services/                 # Business logic
│   ├── storage_service.dart
│   ├── notification_service.dart
│   ├── voice_service.dart
│   └── streak_service.dart
├── providers/                # State management
│   └── app_state.dart
└── screens/                  # UI screens
    ├── home_screen.dart
    ├── setup_screen.dart
    ├── monthly_view_screen.dart
    └── rewards_screen.dart
```

## Troubleshooting

### Notifications Not Working
1. Check app notification permissions in device Settings
2. Ensure "Alarms & Reminders" permission is granted (Android 12+)
3. Check that battery optimization is disabled for the app
4. Verify the app isn't force-stopped

### App Crashes
```bash
# Check logs
flutter logs

# Rebuild
flutter clean
flutter pub get
flutter run
```

### Voice Messages Not Playing
- Voice messages are logged to console in MVP
- For production, integrate `flutter_tts` package

## Quick Start for Tomorrow Morning

```bash
# 1. Navigate to project
cd /Users/ESLalaguSe/Repos/morning_on_time

# 2. Connect your Android phone via USB

# 3. Enable USB Debugging on your phone
#    Settings > About Phone > tap "Build Number" 7 times
#    Settings > Developer Options > USB Debugging ON

# 4. Install the app
flutter run --release

# 5. On the phone:
#    - Grant all permissions when prompted
#    - Set your morning times
#    - Go to Settings > Apps > Morning On Time > Battery > Unrestricted

# 6. Done! The app will work automatically tomorrow morning
```

## Data Storage
- All data is stored locally using SharedPreferences
- No internet connection required
- Data persists across app restarts

## Features Implemented
✅ Initial setup with morning schedule
✅ Automatic wake-up notifications
✅ Check-in system (Going Well / Running Tight)
✅ Arrival confirmation
✅ Streak tracking
✅ Monthly view calendar
✅ Rewards system
✅ Offline-first design

## Next Steps for Enhancement
- Integrate Text-to-Speech for actual voice playback
- Add background service for more reliable notifications
- Add celebration animations
- Add customizable notification sounds
- Add family member profiles
