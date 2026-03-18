# Automatic Morning Activation & Voice/Notification Engine

*Part of the [Morning On Time PRD](MorningOnTime.md) — Sections 3 & 4 of Functional Requirements*

---

## Automatic Morning Activation

The app automatically schedules and fires alarms throughout the morning without requiring user interaction. All alarms use Android's native AlarmManager for reliable background execution and automatically reschedule for the next day.

---

## Voice & Notification Engine

The app schedules **5 different types of alarms** when settings are saved or updated.

The morning plan begins at wake-up time and finished at arrival time. The trip to school starts at leave time and finishes at arrival time.

See below the diffent types of alarms:

#### **4.1. Wake-Up Alarm (ID: 1)**

* **Trigger:** At the user's configured wake-up time
* **Voice Message (TTS):** Different messages are available
* **Notification:** Random message
* **Behavior:** 
  - Fires exactly at wake-up time using AlarmManager
  - The notification plays sounds/wake-up/morning-rooster.wav (even when app is closed)
  - TTS starts 5 seconds after notification sound playback begins
  - Plays TTS message automatically in background (even when app is closed)
  - There are different notification message (TTS) available:
    - "Today's mission is to arrive at school on time. Let's go!"
    - “Good morning, team! Today we’re heading to school right on time—let’s do it together!”
    - “Rise and shine! Our family mission today: calm, happy, and on time to school.”
    - “New day, new adventure! Let’s get ready and arrive at school right on time.”
    - “Good morning! Small steps, big win—let’s get out the door on time today.”
    - “Wake up, superheroes! Our mission is a smooth morning and an on-time arrival.”
    - “Good morning! Let’s start the day with smiles and make it to school right on time.”
    - “Team family, assemble! Today we move together and arrive at school on time.”
    - “Good morning! Let’s make today easy, fun, and right on schedule.”
    - “It’s a brand new day! Let’s help each other get ready and be on time.”
    - “Morning, everyone! Let’s win the day early by arriving at school on time.”
* **Reliability:** High (uses native Android AlarmManager, survives app closure and device restart)

#### **4.2. Checkpoint Alarms (IDs: 100-119)**

* **Trigger:** Every 5 minutes starting from wake-up time until the leave time
* **Voice Message (TTS):** Different messages are available
* **Notification:** Custom message with the minutes left to leave home
* **Behavior:**
  - The alarm is triggered 5 minutes after the wake up time
   - The notification plays randomly one of the audio files found at sounds/checkpoints/ (even when app is closed)
   - TTS starts 5 seconds after notification sound playback begins
  - It plays a TTS message that includes the minutes left to go, so the message is dynamic.
  - There are different types of notification message (TTS) depending on the time available. Choose one randomly from the right category based on minutes available.
    - if there is more than 75% of the time available from wake-up to leave time:
      - "Come on! We've a streak to beat, we're leaving in {minutes left to go} minutes."
      - "What, I won't be the first? Come on, we still have {minutes left to go} minutes to leave."
      - "Today is a fantastic day to be first. We still have {minutes left to go} minutes."
      - If there is a reward defined not achieved yet: "Come on, we have to leave in {minutes left to go} minutes if we want to win the {reward}"
    - else if there is more than 50% of the time available from wake-up to leave time:
      - "I've seen faster turtles. We have {minutes left to go} minutes left to leave."
      - "Do you expect to arrive on time? Hurry, we only have {minutes left to go} minutes left."
      - "Why are you moving so slowly? We need to leave in {minutes left to go} minutes."
      - If there is a reward defined not achieved yet: "We need to leave in {minutes left to go} minutes if we want {reward}"
    - else
      - "You look like sloths, run because you only have {minutes left to go} minutes left"
      - "I've never seen a family this slow. You have {minutes left to go} minutes left."
      - "Hurry up! We have {minutes left to go} minutes left to go"
      - "Are you deaf? We have to leave in {minutes left to go} minutes"
      - If there is a reward defined not achieved yet: "Do you still want the {reward}? If we don't leave the house in {minutes left to go} minutes, we won't get it.
  - It's triggered again every 5 minutes updating the TTS message with the minutes left to go.
  - The alarm doesn't trigger after 5 minutes before time to leave.
  - Each plays TTS message automatically in background. No need to open app.
* **Reliability:** High (uses AlarmManager for guaranteed delivery)

#### **4.3. Leave Home Soon Alarm (ID: 3)**

* **Trigger:** 5 minutes before leave home time
* **Voice Message (TTS):** "In five minutes we must leave home, hurry up!!"
* **Notification:** "🏃 Leave Home Soon!"
* **Behavior:**
  - The alarm is triggered 5 minutes before the time to leave
  - Creates sense of urgency as departure time approaches
   - The notification plays randomly one of the audio files found at sounds/leave-soon/ (even when app is closed)
   - TTS starts 5 seconds after notification sound playback begins
  - Plays TTS message automatically
* **Reliability:** High (AlarmManager-based)

#### **4.4. Leave Home Alarm (ID: 4)**

* **Trigger:** Exactly at leave home time
* **Voice Message (TTS):** "We leave home now or we'll be late."
* **Notification:** "🚪 Leave Home Now!"
* **Behavior:**
  - The alarm is triggered at time to leave
  - Final reminder to depart
   - The notification plays sounds/leave-now/war-horn.wav (even when app is closed)
   - TTS starts 5 seconds after notification sound playback begins
  - Plays TTS message automatically
  - A countdown timer begins from the leave home time to the arrival time so that the user can see how much time they have left
  - The coundown timer is shown in the home screen.
* **Reliability:** High (AlarmManager-based)

#### **4.5. Pre Arrival Check Alarms (IDs: 5, 7, 8)**

Three scheduled reminder alarms prompt the user to confirm arrival before the deadline. Their purpose is twofold:

1. **Urgency:** Alert the family that the countdown is finishing so they must hurry up.
2. **Prevent accidental failure:** If the family arrived on time but forgot to tap the confirmation button, the day would be recorded as a failure. Repeated reminders reduce the chance of this happening.

Each alarm fires at a fixed offset before the arrival deadline, plays a custom notification sound (no TTS), and includes an action button to confirm arrival directly from the notification.

##### **Alarm Schedule**

| Alarm | ID | Trigger | Notification Title | Notification Message |
|-------|----|---------|--------------------|----------------------|
| Pre Arrival Check 1 | 5 | 60 seconds before arrival deadline | "🎯 Have we arrived already?" | "Don't forget to confirm your arrival. 1 minute left!" |
| Pre Arrival Check 2 | 7 | 30 seconds before arrival deadline | "🎯 Have we arrived already?" | "Don't forget to confirm your arrival. 30 seconds left!" |
| Pre Arrival Check 3 | 8 | 10 seconds before arrival deadline | "⚠️ Last chance!" | "Confirm now or today will be marked as late. 10 seconds left!" |

##### **Action Buttons**

All three notifications include the same action button:
  - "✅ Yes, we have" — Marks the day as arrived on time

##### **Behavior**

* Each notification plays a **custom sound** that escalates in urgency:
  - **T-60s (ID 5):** Gentle reminder chime
  - **T-30s (ID 7):** More urgent alert tone
  - **T-10s (ID 8):** Critical/alarm tone
* **No TTS** — sound-only notifications to avoid overlapping voice messages near the deadline
* Notifications are delivered even when the app is in the background, closed, or the device is locked (AlarmManager-based)
* Tapping "✅ Yes, we have" on **any** of the three notifications:
  - Increments streak and marks day as achieved
  - Stops the countdown timer
  - Cancels any remaining Pre Arrival Check alarms that haven't fired yet
  - Cancels the Arrival Alarm (ID 6) since it's no longer needed
* If the user already confirmed arrival (e.g., via an earlier notification), subsequent Pre Arrival Check alarms are **silently skipped** (no notification shown)

##### **Cancellation Logic**

When the user confirms arrival from any source (notification action button or in-app button):
* All three Pre Arrival Check alarms (IDs 5, 7, 8) are cancelled for the current day
* The Arrival Alarm (ID 6) is cancelled for the current day
* No further notifications are shown for the current journey

* **Reliability:** High (AlarmManager-based, 3 independent alarms for redundancy)

#### **4.6. Arrival Alarm (ID: 6)**

* **Trigger:** At arrival deadline
* **Notification:** "⌛ Time is up!"
* **Message:** "Sorry, you did not make it today"
* **Behavior:**
   - Silent notification only (no custom sound and no TTS)
  - This notification is triggered if the user hasn't confirmed they arrived on time
  - It marks day as missed.
* **Reliability:** High (AlarmManager-based)

#### **Technical Implementation**

**Core Technology Stack:**
* All alarms use `android_alarm_manager_plus` for reliable background execution
* TTS uses `flutter_tts` plugin to speak messages automatically
* Alarms persist through app closure, phone restart, and Doze mode
* Each alarm callback runs in isolated background context
* Battery optimization set to "unrestricted" for consistent delivery

**7-Day Rolling Window Re-Scheduling Strategy:**

To ensure maximum reliability and eliminate single points of failure, the app maintains alarms for the next 7 days at all times:

* **Initial Setup:** When settings are saved, all alarms are scheduled for the next 7 days
* **Daily Extension:** When wake-up alarm fires each morning, it schedules alarms for day 8, maintaining the 7-day rolling window
* **Self-Healing:** When app launches, it verifies at least 2 days of alarms exist ahead; if not, reschedules the full 7-day window
* **Settings Changes:** When times are updated, all existing alarms are cancelled and the full 7-day window is rescheduled with new times

**Alarm ID Scheme:**

To support multiple days of alarms without conflicts, each alarm uses a unique ID based on day offset and alarm type:

```
Alarm ID = (day_offset × 1000) + alarm_type

Examples:
- Day 0, Wake-up (type 1):        0 × 1000 + 1   = 1
- Day 1, Wake-up (type 1):        1 × 1000 + 1   = 1001
- Day 2, Checkpoint #1 (type 100): 2 × 1000 + 100 = 2100
- Day 6, Arrival (type 6):        6 × 1000 + 6   = 6006
```

**Day-of-Week Scheduling Support:**

Alarms are only scheduled for days that match the user's active pattern:
* **Active Days:** User selects which days of the week alarms should fire (e.g., weekdays only)
* **Skip Dates:** User can disable alarms for specific dates (holidays, sick days)
* **Conditional Scheduling:** Each day in the 7-day window is checked against active pattern before scheduling

**Reliability Guarantees:**

* **7 consecutive wake-up failures** required to break the system
* **User opening app at any time** triggers self-healing and restores missing alarms
* **Maximum alarms:** 56 total (well within Android's 500+ alarm limit per app)
* **Transparent:** User can verify scheduled alarms in Android system settings
