# Testing the Countdown Timer

## Test Button

A **science icon (🧪)** has been added to the app bar for easy testing of the countdown timer feature.

### How to Use

1. Tap the **orange science icon** in the top right of the home screen
2. Select a test duration:
   - ⚡ **2 minutes (Critical)** - Red countdown with urgent messaging
   - 🟠 **5 minutes (Urgent)** - Orange countdown with hurry-up messaging  
   - 🟡 **10 minutes (Warning)** - Amber countdown
   - 🟢 **20 minutes (On Track)** - Green countdown with positive messaging

3. The countdown timer will appear on the home screen
4. A notification will be shown with the countdown format
5. You can test different urgency levels without waiting

### What Gets Tested

- ✅ Visual countdown timer widget with color changes
- ✅ Circular progress indicator
- ✅ Pulsing animation for urgent times
- ✅ Notification with countdown format
- ✅ Dynamic urgency messages
- ✅ Journey start/stop functionality

## Removing the Test Button (For Production)

When ready to remove the test button, delete these sections from `lib/screens/home_screen.dart`:

### 1. Remove the test button from AppBar (around line 100):
```dart
// DELETE THIS BLOCK:
// Test button (remove in production)
IconButton(
  icon: const Icon(Icons.science, color: Colors.orange),
  tooltip: 'Test Countdown',
  onPressed: () {
    final appState = Provider.of<AppState>(context, listen: false);
    _showTestMenu(context, appState);
  },
),
```

### 2. Remove the test menu methods (around line 90):
```dart
// DELETE THESE METHODS:
void _showTestMenu(BuildContext context, AppState appState) { ... }
void _startTestCountdown(BuildContext context, AppState appState, int minutes) { ... }
```

### 3. Remove the _TestButton widget (at the end of the file):
```dart
// DELETE THIS CLASS:
class _TestButton extends StatelessWidget { ... }
```

### 4. Remove test deadline methods from `lib/providers/app_state.dart`:
```dart
// DELETE THESE:
DateTime? _testArrivalDeadline;
void setTestDeadline(DateTime deadline) { ... }
void clearTestDeadline() { ... }

// AND UPDATE arrivalDeadline getter to remove test deadline logic:
DateTime? get arrivalDeadline {
  if (_settings == null) return null;
  final now = DateTime.now();
  return DateTime(
    now.year,
    now.month,
    now.day,
    _settings!.arrivalDeadline.hour,
    _settings!.arrivalDeadline.minute,
  );
}
```

## Alternative: Keep Test Button in Debug Mode Only

You can also keep the button but only show it in debug mode:

```dart
import 'package:flutter/foundation.dart';

// In AppBar actions:
if (kDebugMode)
  IconButton(
    icon: const Icon(Icons.science, color: Colors.orange),
    tooltip: 'Test Countdown',
    onPressed: () {
      final appState = Provider.of<AppState>(context, listen: false);
      _showTestMenu(context, appState);
    },
  ),
```

This way it's automatically hidden in production builds but available during development.
